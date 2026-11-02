-- id: 20261019-icr-lisible
-- system: cora
-- person_data: no-person-data
-- purpose: tester par une lecture directe si CORA_REC.PMSI_CCAM_ICR est lisible et remplie, pour icr-version-unique-couverture (le claim est réfuté si la table est lisible ; sinon ORA-00942 est la preuve) ; à lancer seulement si 20261019-catalogue-objets-g3 montre la table, ou pour confirmer son absence
-- Oracle, schéma CORA_REC. Table de référentiel, aucune donnée de personne. CONDITIONNELLE : le nom PMSI_CCAM_ICR vient du claim icr-version-unique-couverture ; si le catalogue montre une autre table ICR, la personne remplace seulement ce nom et le dit. Une erreur ORA-00942 (table ou vue inexistante) est le résultat attendu si le claim tient : la reporter telle quelle.
-- Un seul comptage, sans colonne de la table : le nombre de lignes. Le référentiel n'a pas d'effectif de personnes, le seuil de 10 est appliqué par prudence (< 10 sort en <10).
SELECT '20261019-icr-lisible' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       'PMSI_CCAM_ICR' AS TABLE_LUE,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE TO_CHAR(COUNT(*)) END AS N_LIGNES
FROM CORA_REC.PMSI_CCAM_ICR;
