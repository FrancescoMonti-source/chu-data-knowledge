-- id: 20261019-ccam-nv-doublons
-- system: cora
-- person_data: masked
-- purpose: mesurer combien de codes de CORA_REC.V_CCAM_NV portent plusieurs lignes (toutes lignes, puis lignes TYPE = 'A') et de combien une jointure directe de TB_ACTE.CODE_ACTE sur V_CCAM_NV.CODE augmente le nombre d'actes, par année de DATE_ACTE, pour trancher ccam-nv-plusieurs-lignes-par-code (réfuté si CODE est unique pour TYPE = 'A' et si la jointure directe ne change aucun effectif ; confirmé sinon, et l'ampleur dit s'il faut réduire à un libellé par code)
-- Oracle, schéma CORA_REC. CONDITIONNELLE : les colonnes CODE et TYPE de V_CCAM_NV viennent du dictionnaire CCAM_NV 2020 ; à vérifier avec 20261019-catalogue-objets-g3 (niveau COLONNE de V_CCAM_NV). Actes datés du 2018-01-01 à aujourd'hui. Clé de jointure : TRIM(CODE_ACTE) = TRIM(CODE).
-- Niveau VUE (référentiel, une ligne) : N_LIGNES, N_CODES (distincts), N_CODES_PLUSIEURS (codes à plus d'une ligne), N_CODES_A (codes ayant au moins une ligne TYPE = 'A'), N_CODES_A_PLUSIEURS (codes à plus d'une ligne TYPE = 'A'), MAX_LIGNES_PAR_CODE (maximum, toutes lignes), MAX_LIGNES_A_PAR_CODE.
-- Niveau ACTES (une ligne par année) : N_ACTES ; N_ACTES_CODE_DANS_VUE (code présent dans la vue) ; N_ACTES_CODE_PLUSIEURS (code à plus d'une ligne) ; N_LIGNES_EN_TROP (lignes que la jointure directe ajoute : par acte, nombre de lignes de la vue moins 1) ; N_LIGNES_EN_TROP_A (idem en ne gardant que TYPE = 'A' côté vue).
-- Masquage : chaque effectif < 10 sort en <10 (niveau ACTES). Suppression secondaire (règle 4) : N_ACTES sort en « masqué » dès que N_ACTES moins N_ACTES_CODE_DANS_VUE vaut de 1 à 9, et N_ACTES_CODE_DANS_VUE de même avec N_ACTES_CODE_PLUSIEURS. Le niveau VUE ne compte que des codes d'un référentiel, pas des personnes. Aucune ligne de total.
WITH m AS (
  SELECT TRIM(CODE) AS CODE,
         COUNT(*) AS M_TOUS,
         SUM(CASE WHEN TRIM(TYPE) = 'A' THEN 1 ELSE 0 END) AS M_A
  FROM CORA_REC.V_CCAM_NV
  GROUP BY TRIM(CODE)
),
vue AS (
  SELECT COUNT(*) AS N_CODES,
         SUM(M_TOUS) AS N_LIGNES,
         SUM(CASE WHEN M_TOUS > 1 THEN 1 ELSE 0 END) AS N_PLUSIEURS,
         SUM(CASE WHEN M_A >= 1 THEN 1 ELSE 0 END) AS N_CODES_A,
         SUM(CASE WHEN M_A > 1 THEN 1 ELSE 0 END) AS N_A_PLUSIEURS,
         MAX(M_TOUS) AS MAX_TOUS,
         MAX(M_A) AS MAX_A
  FROM m
),
ac AS (
  SELECT EXTRACT(YEAR FROM DATE_ACTE) AS ANNEE, TRIM(CODE_ACTE) AS CODE, COUNT(*) AS N
  FROM CORA_REC.TB_ACTE
  WHERE DATE_ACTE >= DATE '2018-01-01' AND DATE_ACTE < TRUNC(SYSDATE) + 1
  GROUP BY EXTRACT(YEAR FROM DATE_ACTE), TRIM(CODE_ACTE)
),
an AS (
  SELECT ac.ANNEE,
         SUM(ac.N) AS N_ACTES,
         SUM(CASE WHEN m.CODE IS NOT NULL THEN ac.N ELSE 0 END) AS C1,
         SUM(CASE WHEN m.M_TOUS > 1 THEN ac.N ELSE 0 END) AS C2,
         SUM(CASE WHEN m.M_TOUS > 1 THEN ac.N * (m.M_TOUS - 1) ELSE 0 END) AS C3,
         SUM(CASE WHEN m.M_A > 1 THEN ac.N * (m.M_A - 1) ELSE 0 END) AS C4
  FROM ac
  LEFT JOIN m ON m.CODE = ac.CODE
  GROUP BY ac.ANNEE
)
SELECT '20261019-ccam-nv-doublons' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       'VUE' AS NIVEAU, CAST(NULL AS NUMBER) AS ANNEE,
       TO_CHAR(N_LIGNES) AS N_LIGNES, TO_CHAR(N_CODES) AS N_CODES,
       TO_CHAR(N_PLUSIEURS) AS N_CODES_PLUSIEURS, TO_CHAR(N_CODES_A) AS N_CODES_A,
       TO_CHAR(N_A_PLUSIEURS) AS N_CODES_A_PLUSIEURS,
       TO_CHAR(MAX_TOUS) AS MAX_LIGNES_PAR_CODE, TO_CHAR(MAX_A) AS MAX_LIGNES_A_PAR_CODE,
       CAST(NULL AS VARCHAR2(20)) AS N_ACTES, CAST(NULL AS VARCHAR2(20)) AS N_ACTES_CODE_DANS_VUE,
       CAST(NULL AS VARCHAR2(20)) AS N_ACTES_CODE_PLUSIEURS, CAST(NULL AS VARCHAR2(20)) AS N_LIGNES_EN_TROP,
       CAST(NULL AS VARCHAR2(20)) AS N_LIGNES_EN_TROP_A
FROM vue
UNION ALL
SELECT '20261019-ccam-nv-doublons', SYS_CONTEXT('USERENV', 'DB_NAME'), TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI'),
       'ACTES', ANNEE,
       NULL, NULL, NULL, NULL, NULL, NULL, NULL,
       CASE WHEN N_ACTES < 10 THEN '<10'
            WHEN N_ACTES - C1 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(N_ACTES) END,
       CASE WHEN C1 < 10 THEN '<10'
            WHEN C1 - C2 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(C1) END,
       CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END,
       CASE WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END,
       CASE WHEN C4 < 10 THEN '<10' ELSE TO_CHAR(C4) END
FROM an
ORDER BY 4, 5;
