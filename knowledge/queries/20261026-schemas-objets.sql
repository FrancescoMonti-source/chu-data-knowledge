-- id: 20261026-schemas-objets
-- system: cora
-- person_data: no-person-data
-- purpose: lister toutes les tables, vues et synonymes que le compte voit dans CWPROD, avec volumétrie et commentaire, pour repérer à la lecture les tables de structure de l'établissement (UF, UM, services, pôles, historique de rattachement) et les référentiels (ICR notamment) (étape 1 du plan, issue « schemas-cora »)
-- Oracle. Lit seulement le catalogue (ALL_TABLES, ALL_VIEWS, ALL_SYNONYMS, ALL_TAB_COMMENTS) : aucune donnée de table. Schémas non maintenus par Oracle.
-- Une ligne par objet. LIGNES_STATS : NUM_ROWS d'après les statistiques Oracle (vide pour une vue ou une table sans statistiques). DERNIERE_STAT : date de ces statistiques. CIBLE : pour un synonyme, le schéma et l'objet visés. COMMENTAIRE : les 150 premiers caractères.
-- Le résultat est long (un schéma comme CORA_REC compte plus de 600 objets) : il est fait pour être filtré, pas lu en entier.
SELECT '20261026-schemas-objets' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       r.OWNER, r.OBJET, r.TYPE_OBJET, r.LIGNES_STATS, r.DERNIERE_STAT, r.CIBLE,
       SUBSTR(c.COMMENTS, 1, 150) AS COMMENTAIRE
FROM (
  SELECT t.OWNER, t.TABLE_NAME AS OBJET, 'TABLE' AS TYPE_OBJET, t.NUM_ROWS AS LIGNES_STATS,
         TO_CHAR(t.LAST_ANALYZED, 'YYYY-MM-DD') AS DERNIERE_STAT, CAST(NULL AS VARCHAR2(400)) AS CIBLE
  FROM ALL_TABLES t
  UNION ALL
  SELECT v.OWNER, v.VIEW_NAME, 'VIEW', NULL, NULL, NULL
  FROM ALL_VIEWS v
  UNION ALL
  SELECT s.OWNER, s.SYNONYM_NAME, 'SYNONYM', NULL, NULL, s.TABLE_OWNER || '.' || s.TABLE_NAME
  FROM ALL_SYNONYMS s
  WHERE s.OWNER <> 'PUBLIC'
) r
JOIN ALL_USERS u ON u.USERNAME = r.OWNER AND u.ORACLE_MAINTAINED = 'N'
LEFT JOIN ALL_TAB_COMMENTS c ON c.OWNER = r.OWNER AND c.TABLE_NAME = r.OBJET
ORDER BY r.OWNER, r.OBJET;
