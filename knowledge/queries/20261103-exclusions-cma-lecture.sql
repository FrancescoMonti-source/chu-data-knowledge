-- id: 20261103-exclusions-cma-lecture
-- system: cora
-- person_data: no-person-data
-- purpose: lire par les synonymes de CORA_REC le nombre de lignes des listes d'exclusion de CMA et de CIM_HIERARCHIE, que le catalogue montre dans CORA_CCAM : se lisent-elles, et sont-elles remplies (issue « schemas-cora », suite du claim referentiels-pmsi-dans-cora)
-- Oracle. Tables de référentiel (codes CIM-10), aucune donnée de personne. Une erreur ORA-00942 (table ou vue inexistante) veut dire que le droit de lecture manque pour l'une des cinq tables : la reporter telle quelle ; l'exécutant relance alors la requête en retirant la table fautive, et le dit.
-- Seulement un comptage par table ; aucune ligne n'est affichée.
SELECT '20261103-exclusions-cma-lecture' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       r.TABLE_LUE, r.N_LIGNES
FROM (
  SELECT 'CIM_DP_EXCLU' AS TABLE_LUE, COUNT(*) AS N_LIGNES FROM CORA_REC.CIM_DP_EXCLU
  UNION ALL
  SELECT 'CIM_LISTE_DIAG_EXCLU', COUNT(*) FROM CORA_REC.CIM_LISTE_DIAG_EXCLU
  UNION ALL
  SELECT 'CIM_LISTE_EXCLU_CAV', COUNT(*) FROM CORA_REC.CIM_LISTE_EXCLU_CAV
  UNION ALL
  SELECT 'FG_DP_EXCLUANT', COUNT(*) FROM CORA_REC.FG_DP_EXCLUANT
  UNION ALL
  SELECT 'CIM_HIERARCHIE', COUNT(*) FROM CORA_REC.CIM_HIERARCHIE
) r
ORDER BY r.TABLE_LUE;
