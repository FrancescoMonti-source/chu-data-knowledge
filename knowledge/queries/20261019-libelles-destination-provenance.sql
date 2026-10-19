-- id: 20261019-libelles-destination-provenance
-- system: cora
-- person_data: no-person-data
-- purpose: lire les libellés et les codes PMSI des modes et des codes de destination ou de provenance (TB_MODE_ES_ADMIN avec CODE_DEST_PROV, et TB_MODE_ES), pour établir code-destination-2-est-smr (claim documentaire : 2 = SSR/SMR et 3 = soins de longue durée ; la nomenclature lue dans CORA confirme ou corrige ces correspondances, et dit si MODE_SORTIE 6 = mutation, 7 = transfert)
-- Oracle 11g, schéma CORA_REC. Référentiels de codes : aucune donnée de personne, aucun effectif. Une ligne par code. TB_MODE_ES_ADMIN : CODE_ES_ADMIN, LIBELLE, TYPE_ES (E ou S), CODE_PMSI (mode), CODE_DEST_PROV (destination ou provenance). TB_MODE_ES : CODE_INTERNE, LIBELLE_INTERNE, ENTREE_SORTIE, CODE_OFFICIEL (mode PMSI), PROVENANCE_DESTINATION.
-- Colonnes de sortie : SOURCE, CODE_INTERNE, LIBELLE, TYPE_ES, MODE_PMSI, CODE_DEST_PROV.
SELECT '20261019-libelles-destination-provenance' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       'TB_MODE_ES_ADMIN' AS SOURCE,
       TRIM(TO_CHAR(CODE_ES_ADMIN)) AS CODE_INTERNE,
       TRIM(LIBELLE) AS LIBELLE,
       TRIM(TYPE_ES) AS TYPE_ES,
       TRIM(CODE_PMSI) AS MODE_PMSI,
       TRIM(CODE_DEST_PROV) AS CODE_DEST_PROV
FROM CORA_REC.TB_MODE_ES_ADMIN
UNION ALL
SELECT '20261019-libelles-destination-provenance',
       SYS_CONTEXT('USERENV', 'DB_NAME'),
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI'),
       'TB_MODE_ES',
       TRIM(TO_CHAR(CODE_INTERNE)),
       TRIM(LIBELLE_INTERNE),
       TRIM(ENTREE_SORTIE),
       TRIM(CODE_OFFICIEL),
       TRIM(PROVENANCE_DESTINATION)
FROM CORA_REC.TB_MODE_ES
ORDER BY 4, 7, 9, 5;
