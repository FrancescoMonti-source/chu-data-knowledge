-- id: 20261019-libelles-destination-provenance-2
-- system: cora
-- person_data: no-person-data
-- purpose: établir pourquoi 20261019-libelles-destination-provenance a rendu 0 ligne sans erreur, pour code-destination-2-est-smr : les deux tables TB_MODE_ES_ADMIN et TB_MODE_ES existent et se lisent (sinon ORA-00942 ou ORA-00904) mais sont vides dans CORA_REC, ou ne sont qu'une vue ou un synonyme qui ne rend rien ; si elles portent des lignes ici, le niveau CODES liste les libellés ; si elles sont vides, les libellés ne se lisent pas dans CORA et les codes de destination se lisent par les valeurs distinctes de TB_SEJOUR.CODE_DESTINATION et MODE_SORTIE par année, déjà dans 20261019-destination-sortie-mco (la nomenclature PMSI reste alors documentaire : 2 = soins de suite et de réadaptation, 3 = soins de longue durée, 6 = mutation et 7 = transfert pour MODE_SORTIE)
-- Cause constatée de la première version : sa requête n'avait aucun filtre (WHERE), ses colonnes sont celles du dictionnaire 2020 (TB_MODE_ES_ADMIN : CODE_ES_ADMIN, LIBELLE, TYPE_ES, CODE_PMSI, CODE_DEST_PROV ; TB_MODE_ES : CODE_INTERNE, LIBELLE_INTERNE, CODE_OFFICIEL, ENTREE_SORTIE, PROVENANCE_DESTINATION) et le catalogue 20261019-catalogue-objets-g3 ne cherchait pas ces noms ; zéro ligne sans erreur ne s'explique donc que par des tables vides (ou une vue filtrée) ; cette version le vérifie.
-- Oracle 11g, schéma CORA_REC. Référentiels de codes : aucune donnée de personne, comptages de lignes de référentiel sans masquage. Les colonnes de comptage ne s'appellent pas N_… ni NB_….
-- Niveau OBJET : propriétaire, type et état des objets nommés TB_MODE_ES ou TB_MODE_ES_ADMIN visibles du compte (ALL_OBJECTS). Niveau STATS : LIGNES = NUM_ROWS des statistiques Oracle (ALL_TABLES, peut être vide ou périmé). Niveau LIGNES : LIGNES = comptage exact de chaque table dans CORA_REC. Niveau CODES : une ligne par code (SOURCE, CODE_INTERNE, LIBELLE, TYPE_ES, MODE_PMSI, CODE_DEST_PROV), comme dans la première version ; aucune ligne si les tables sont vides.
SELECT '20261019-libelles-destination-provenance-2' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       r.NIVEAU, r.SOURCE, r.OWNER, r.TYPE_OBJET, r.ETAT, r.LIGNES,
       r.CODE_INTERNE, r.LIBELLE, r.TYPE_ES, r.MODE_PMSI, r.CODE_DEST_PROV
FROM (
  SELECT 'OBJET' AS NIVEAU, o.OBJECT_NAME AS SOURCE, o.OWNER AS OWNER, o.OBJECT_TYPE AS TYPE_OBJET, o.STATUS AS ETAT,
         CAST(NULL AS VARCHAR2(20)) AS LIGNES, CAST(NULL AS VARCHAR2(10)) AS CODE_INTERNE,
         CAST(NULL AS VARCHAR2(100)) AS LIBELLE, CAST(NULL AS VARCHAR2(10)) AS TYPE_ES,
         CAST(NULL AS VARCHAR2(10)) AS MODE_PMSI, CAST(NULL AS VARCHAR2(10)) AS CODE_DEST_PROV
  FROM ALL_OBJECTS o
  WHERE UPPER(o.OBJECT_NAME) IN ('TB_MODE_ES', 'TB_MODE_ES_ADMIN')
    AND o.OBJECT_TYPE IN ('TABLE', 'VIEW', 'SYNONYM', 'MATERIALIZED VIEW')
  UNION ALL
  SELECT 'STATS', t.TABLE_NAME, t.OWNER, 'TABLE', NULL, TO_CHAR(t.NUM_ROWS), NULL, NULL, NULL, NULL, NULL
  FROM ALL_TABLES t
  WHERE UPPER(t.TABLE_NAME) IN ('TB_MODE_ES', 'TB_MODE_ES_ADMIN')
  UNION ALL
  SELECT 'LIGNES', 'TB_MODE_ES_ADMIN', 'CORA_REC', NULL, NULL, TO_CHAR(COUNT(*)), NULL, NULL, NULL, NULL, NULL
  FROM CORA_REC.TB_MODE_ES_ADMIN
  UNION ALL
  SELECT 'LIGNES', 'TB_MODE_ES', 'CORA_REC', NULL, NULL, TO_CHAR(COUNT(*)), NULL, NULL, NULL, NULL, NULL
  FROM CORA_REC.TB_MODE_ES
  UNION ALL
  SELECT 'CODES', 'TB_MODE_ES_ADMIN', NULL, NULL, NULL, NULL,
         TRIM(TO_CHAR(CODE_ES_ADMIN)), TRIM(LIBELLE), TRIM(TYPE_ES), TRIM(CODE_PMSI), TRIM(CODE_DEST_PROV)
  FROM CORA_REC.TB_MODE_ES_ADMIN
  UNION ALL
  SELECT 'CODES', 'TB_MODE_ES', NULL, NULL, NULL, NULL,
         TRIM(TO_CHAR(CODE_INTERNE)), TRIM(LIBELLE_INTERNE), TRIM(ENTREE_SORTIE), TRIM(CODE_OFFICIEL), TRIM(PROVENANCE_DESTINATION)
  FROM CORA_REC.TB_MODE_ES
) r
ORDER BY 4, 5, 6, 10, 12;
