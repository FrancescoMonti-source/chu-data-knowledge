-- id: 20261015-applications-libelles
-- system: cora
-- person_data: no-person-data
-- purpose: lire le référentiel TB_INT_APPLICATION (17 lignes), seule table candidate pour nommer les applications émettrices des actes, diagnostics et interventions (ID_APPLICATION_TRANSFERT 7, 10, 16, 17, 0, −3010), TB_APPLICATION_TRANSFERT étant vide (20261015-catalogue-referentiels-resultat) (kb : backlog application-codes, #24)
-- Oracle, schéma CORA_REC. Référentiel d'applications : aucune donnée de personne.
SELECT '20261015-applications-libelles' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ID, TRIM(LIBELLE) AS LIBELLE, TRIM(LIBELLE_AFFICHAGE) AS LIBELLE_AFFICHAGE,
       TYPE_APPLICATION, TRIM(TYPE_ROLE) AS TYPE_ROLE, TRIM(TYPE_TRANSFERT) AS TYPE_TRANSFERT,
       TO_CHAR(DATE_CREAT, 'YYYY-MM') AS MOIS_CREATION
FROM CORA_REC.TB_INT_APPLICATION
ORDER BY ID;
