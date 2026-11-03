-- id: 20261103-icr-cle-liberale
-- system: cora
-- person_data: no-person-data
-- purpose: comprendre pourquoi PMSI_CCAM_ICR a deux lignes par combinaison CODE, EXTENSION_ATIH, PHASE, ACTIVITE (14 900 clés pour 29 800 lignes, 20261103-icr-lecture-resultat) : ACTIVITE_LIBERALE fait-elle la différence, et l'ICR change-t-il entre les deux lignes ? (issue « schemas-cora », suite du claim icr-table-cora-ccam)
-- Oracle. Table de référentiel (codes d'actes et leur ICR), aucune donnée de personne ; aucune ligne n'est affichée, seulement des comptages et des valeurs de ACTIVITE_LIBERALE (un indicateur d'un caractère).
-- Deux sections : PAR_ACTIVITE_LIBERALE (une ligne par valeur de ACTIVITE_LIBERALE) et CLES_PAR_NOMBRE_DE_LIGNES (combien de clés ont 1, 2, 3 lignes ou plus, et pour combien d'entre elles l'ICR diffère entre les lignes).
WITH cles AS (
  SELECT CODE, EXTENSION_ATIH, PHASE, ACTIVITE,
         COUNT(*) AS NB_LIGNES,
         COUNT(DISTINCT ICR) AS NB_ICR,
         COUNT(DISTINCT ACTIVITE_LIBERALE) AS NB_LIBERALE
  FROM CORA_REC.PMSI_CCAM_ICR
  GROUP BY CODE, EXTENSION_ATIH, PHASE, ACTIVITE
)
SELECT '20261103-icr-cle-liberale' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       r.SECTION, r.VALEUR, r.N_LIGNES, r.N_CLES, r.N_CLES_ICR_DIFFERENT
FROM (
  SELECT 'PAR_ACTIVITE_LIBERALE' AS SECTION, NVL(TO_CHAR(ACTIVITE_LIBERALE), '(vide)') AS VALEUR,
         COUNT(*) AS N_LIGNES,
         COUNT(DISTINCT CODE || '|' || EXTENSION_ATIH || '|' || PHASE || '|' || ACTIVITE) AS N_CLES,
         CAST(NULL AS NUMBER) AS N_CLES_ICR_DIFFERENT
  FROM CORA_REC.PMSI_CCAM_ICR
  GROUP BY NVL(TO_CHAR(ACTIVITE_LIBERALE), '(vide)')
  UNION ALL
  SELECT 'CLES_PAR_NOMBRE_DE_LIGNES', TO_CHAR(LEAST(NB_LIGNES, 3)) || CASE WHEN NB_LIGNES >= 3 THEN '+' ELSE '' END,
         SUM(NB_LIGNES), COUNT(*), SUM(CASE WHEN NB_ICR > 1 THEN 1 ELSE 0 END)
  FROM cles
  GROUP BY LEAST(NB_LIGNES, 3), CASE WHEN NB_LIGNES >= 3 THEN '+' ELSE '' END
) r
ORDER BY r.SECTION, r.VALEUR;
