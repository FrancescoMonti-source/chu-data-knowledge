-- id: 20261023-ccam-endarteriectomie-carotide
-- system: cora
-- person_data: masked
-- purpose: vérifier les libellés des trois actes d'endartériectomie carotidienne retenus (EBFA003, EBFA009, EBFA010) et repérer d'autres codes de la vue dont le libellé parle d'endartériectomie carotidienne, avec le nombre d'actes de chacun par année depuis 2022 (étape 1 du plan ; étape 5 ensuite)
-- Oracle, schéma CORA_REC. V_CCAM_NV filtrée sur TYPE = 'A', une ligne par code (ccam-nv-une-ligne-par-code) ; colonnes CODE, TYPE, LIBELLE_LONG lues dans 20261019-catalogue-objets-g3. Actes de TB_ACTE datés (DATE_ACTE) du 2022-01-01 à aujourd'hui, joints par TRIM(CODE_ACTE) = TRIM(CODE).
-- Codes retenus : les trois codes, plus tout code dont le libellé long contient ENDART (ou THROMBOENDART) et CAROTI, sans tenir compte de la casse. RETENU : 'oui' pour les trois codes, 'non' pour les autres. Une ligne par code et par année (ANNEE vide quand le code n'a aucun acte depuis 2022). N_ACTES : actes ; N_SEJ : séjours distincts.
-- Masquage : chaque effectif < 10 sort en <10. Aucune ligne de total.
WITH codes AS (
  SELECT TRIM(v.CODE) AS CODE, v.LIBELLE_LONG,
         CASE WHEN TRIM(v.CODE) IN ('EBFA003', 'EBFA009', 'EBFA010') THEN 'oui' ELSE 'non' END AS RETENU
  FROM CORA_REC.V_CCAM_NV v
  WHERE v.TYPE = 'A'
    AND (TRIM(v.CODE) IN ('EBFA003', 'EBFA009', 'EBFA010')
         OR (UPPER(v.LIBELLE_LONG) LIKE '%ENDART%' AND UPPER(v.LIBELLE_LONG) LIKE '%CAROTI%'))
),
act AS (
  SELECT TRIM(a.CODE_ACTE) AS CODE, EXTRACT(YEAR FROM a.DATE_ACTE) AS ANNEE,
         COUNT(*) AS N_ACTES, COUNT(DISTINCT a.ID_SEJOUR) AS N_SEJ
  FROM CORA_REC.TB_ACTE a
  WHERE a.DATE_ACTE >= DATE '2022-01-01' AND a.DATE_ACTE < TRUNC(SYSDATE) + 1
    AND TRIM(a.CODE_ACTE) IN (SELECT CODE FROM codes)
  GROUP BY TRIM(a.CODE_ACTE), EXTRACT(YEAR FROM a.DATE_ACTE)
)
SELECT '20261023-ccam-endarteriectomie-carotide' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       c.CODE, c.RETENU, c.LIBELLE_LONG, act.ANNEE,
       CASE WHEN act.N_ACTES < 10 THEN '<10' ELSE TO_CHAR(act.N_ACTES) END AS N_ACTES,
       CASE WHEN act.N_SEJ < 10 THEN '<10' ELSE TO_CHAR(act.N_SEJ) END AS N_SEJ
FROM codes c
LEFT JOIN act ON act.CODE = c.CODE
ORDER BY c.RETENU DESC, c.CODE, act.ANNEE;
