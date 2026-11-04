-- id: 20261104-snds-objets-visibles
-- system: snds
-- person_data: no-person-data
-- purpose: vérifier que ROracle se connecte au portail (IPIAMPR2.WORLD) et lister les tables, vues et synonymes que le profil 108 voit, pour les comparer au schéma du HDH (étapes 2 et 3 du plan, #127)
-- Oracle. Lit seulement le catalogue (ALL_TABLES, ALL_VIEWS, ALL_SYNONYMS, ALL_USERS) : aucune donnée de table. Schémas non maintenus par Oracle.
-- Exécutée depuis R par executer_requete_cdk() de DIM-code (src/snds_r/requete_cdk.R), qui ouvre la connexion ROracle et sort le résultat par sortir().
-- TYPE_OBJET : TABLE, VIEW ou SYNONYM. CIBLE : pour un synonyme, l'objet qu'il désigne (propriétaire.nom) ; vide sinon.
SELECT '20261104-snds-objets-visibles' AS QUERY_ID,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS DATABASE_NAME,
       TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI') AS RUN_AT,
       o.OWNER, o.TYPE_OBJET, o.OBJET, o.CIBLE
FROM (
  SELECT t.OWNER, 'TABLE' AS TYPE_OBJET, t.TABLE_NAME AS OBJET, CAST(NULL AS VARCHAR2(261)) AS CIBLE
  FROM ALL_TABLES t
  UNION ALL
  SELECT v.OWNER, 'VIEW', v.VIEW_NAME, NULL
  FROM ALL_VIEWS v
  UNION ALL
  SELECT s.OWNER, 'SYNONYM', s.SYNONYM_NAME, s.TABLE_OWNER || '.' || s.TABLE_NAME
  FROM ALL_SYNONYMS s
  JOIN ALL_USERS ut ON ut.USERNAME = s.TABLE_OWNER AND ut.ORACLE_MAINTAINED = 'N'
) o
WHERE o.OWNER = 'PUBLIC'
   OR o.OWNER IN (SELECT u.USERNAME FROM ALL_USERS u WHERE u.ORACLE_MAINTAINED = 'N')
ORDER BY o.OWNER, o.TYPE_OBJET, o.OBJET;
