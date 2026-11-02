-- id: 20261019-ccam-nv-actes
-- system: cora
-- person_data: masked
-- purpose: mesurer, par année de DATE_ACTE, de combien une jointure directe de TB_ACTE.CODE_ACTE sur V_CCAM_NV.CODE augmente le nombre d'actes (toutes lignes de la vue, puis lignes TYPE = 'A'), pour trancher ccam-nv-plusieurs-lignes-par-code côté actes (réfuté si la jointure directe ne change aucun effectif ; confirmé sinon, et l'ampleur dit s'il faut réduire la vue à une ligne par code avant de joindre) ; seconde des deux requêtes qui remplacent 20261019-ccam-nv-doublons (la mesure du référentiel seul est dans 20261019-ccam-nv-vue)
-- Oracle 11g, schéma CORA_REC. Colonnes CODE et TYPE de V_CCAM_NV vérifiées par 20261019-catalogue-objets-g3. Actes datés du 2018-01-01 à aujourd'hui, comptés par année de DATE_ACTE. Clé de jointure : TRIM(CODE_ACTE) = TRIM(CODE), après regroupement des actes par code et des lignes de la vue par code.
-- Colonnes : N_ACTES ; N_ACTES_CODE_DANS_VUE (code présent dans la vue) ; N_ACTES_CODE_PLUSIEURS (code à plus d'une ligne dans la vue) ; N_LIGNES_EN_TROP (lignes que la jointure directe ajoute : par acte, nombre de lignes de la vue moins 1) ; N_LIGNES_EN_TROP_A (idem en ne gardant que TYPE = 'A' côté vue).
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N_ACTES sort en « masqué » dès que N_ACTES moins N_ACTES_CODE_DANS_VUE vaut de 1 à 9, et N_ACTES_CODE_DANS_VUE de même avec N_ACTES_CODE_PLUSIEURS. Aucune ligne de total.
WITH m AS (
  SELECT TRIM(v.CODE) AS CODE,
         COUNT(*) AS M_TOUS,
         SUM(CASE WHEN TRIM(v.TYPE) = 'A' THEN 1 ELSE 0 END) AS M_A
  FROM CORA_REC.V_CCAM_NV v
  GROUP BY TRIM(v.CODE)
),
ac AS (
  SELECT EXTRACT(YEAR FROM x.DATE_ACTE) AS ANNEE, TRIM(x.CODE_ACTE) AS CODE, COUNT(*) AS N
  FROM CORA_REC.TB_ACTE x
  WHERE x.DATE_ACTE >= DATE '2018-01-01' AND x.DATE_ACTE < TRUNC(SYSDATE) + 1
  GROUP BY EXTRACT(YEAR FROM x.DATE_ACTE), TRIM(x.CODE_ACTE)
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
SELECT '20261019-ccam-nv-actes' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE,
       CASE WHEN N_ACTES < 10 THEN '<10'
            WHEN N_ACTES - C1 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(N_ACTES) END AS N_ACTES,
       CASE WHEN C1 < 10 THEN '<10'
            WHEN C1 - C2 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(C1) END AS N_ACTES_CODE_DANS_VUE,
       CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_ACTES_CODE_PLUSIEURS,
       CASE WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_LIGNES_EN_TROP,
       CASE WHEN C4 < 10 THEN '<10' ELSE TO_CHAR(C4) END AS N_LIGNES_EN_TROP_A
FROM an
ORDER BY ANNEE;
