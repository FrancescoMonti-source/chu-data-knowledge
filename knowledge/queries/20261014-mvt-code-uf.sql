-- id: 20261014-mvt-code-uf
-- system: cora
-- person_data: masked
-- purpose: savoir à quoi se joint TB_MVT.ID_UNITE_M, qui ne correspond ni à TB_UNITE.ID_UNITE ni à TB_UNITE_MEDICALE.ID_UNITE_MED (20261014-unicite-code-uf-resultat) : au code d'UF (TB_UNITE.CODE_UNITE) ou au code d'UM (TB_UNITE_MEDICALE.CODE_UNITE_MED) (étape 14 du plan, #24)
-- Oracle, schéma CORA_REC. Mouvements commencés de 2018 à 2025, par année de début.
-- MODALITE : TRIM(ID_UNITE_M) égal à un TRIM(CODE_UNITE), à un TRIM(CODE_UNITE_MED), aux deux, à aucun, ou ID_UNITE_M vide. LONGUEUR : la longueur de TRIM(ID_UNITE_M), jamais sa valeur.
-- Masquage : chaque effectif < 10 sort en <10. Aucune ligne de total : rien ne permet de recalculer une case masquée.
WITH uf AS (
  SELECT DISTINCT TRIM(CODE_UNITE) AS CODE FROM CORA_REC.TB_UNITE
),
um AS (
  SELECT DISTINCT TRIM(CODE_UNITE_MED) AS CODE FROM CORA_REC.TB_UNITE_MEDICALE
),
m AS (
  SELECT EXTRACT(YEAR FROM t.DATE_DEBUT_MVT) AS ANNEE,
         CASE WHEN TRIM(t.ID_UNITE_M) IS NULL THEN 'vide'
              WHEN uf.CODE IS NOT NULL AND um.CODE IS NOT NULL THEN 'code UF et code UM'
              WHEN uf.CODE IS NOT NULL THEN 'code UF seulement'
              WHEN um.CODE IS NOT NULL THEN 'code UM seulement'
              ELSE 'aucun' END AS MODALITE,
         LENGTH(TRIM(t.ID_UNITE_M)) AS LONGUEUR
  FROM CORA_REC.TB_MVT t
  LEFT JOIN uf ON uf.CODE = TRIM(t.ID_UNITE_M)
  LEFT JOIN um ON um.CODE = TRIM(t.ID_UNITE_M)
  WHERE t.DATE_DEBUT_MVT >= DATE '2018-01-01'
    AND t.DATE_DEBUT_MVT < DATE '2026-01-01'
)
SELECT '20261014-mvt-code-uf' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE, MODALITE, LONGUEUR,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE TO_CHAR(COUNT(*)) END AS N_MVT
FROM m
GROUP BY ANNEE, MODALITE, LONGUEUR
ORDER BY ANNEE, MODALITE, LONGUEUR;
