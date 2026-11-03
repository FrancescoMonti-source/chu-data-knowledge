-- id: 20261103-icr-lecture
-- system: cora
-- person_data: no-person-data
-- purpose: lire PMSI_CCAM_ICR par le synonyme de CORA_REC, que le catalogue montre dans CORA_CCAM : la table se lit-elle, combien de lignes, ICR renseigné, quelle est la clé (issue « schemas-cora », suite du claim icr-table-cora-ccam)
-- Oracle. Table de référentiel (codes d'actes et leur ICR), aucune donnée de personne. Une erreur ORA-00942 (table ou vue inexistante) veut dire que le droit de lecture manque : la reporter telle quelle, c'est le résultat.
-- Aucune ligne de la table n'est affichée : seulement des comptages et le minimum et le maximum de l'ICR. N_CLES_DISTINCTES compte les combinaisons CODE, EXTENSION_ATIH, PHASE, ACTIVITE ; si N_CLES_DISTINCTES < N_LIGNES, la clé n'est pas ces quatre colonnes.
SELECT '20261103-icr-lecture' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       'PMSI_CCAM_ICR' AS TABLE_LUE,
       COUNT(*) AS N_LIGNES,
       COUNT(ICR) AS N_ICR_RENSEIGNES,
       COUNT(DISTINCT CODE) AS N_CODES_DISTINCTS,
       COUNT(DISTINCT CODE || '|' || EXTENSION_ATIH || '|' || PHASE || '|' || ACTIVITE) AS N_CLES_DISTINCTES,
       COUNT(DISTINCT ICR) AS N_VALEURS_ICR_DISTINCTES,
       MIN(ICR) AS ICR_MIN,
       MAX(ICR) AS ICR_MAX
FROM CORA_REC.PMSI_CCAM_ICR;
