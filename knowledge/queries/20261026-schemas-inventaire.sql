-- id: 20261026-schemas-inventaire
-- system: cora
-- person_data: no-person-data
-- purpose: lister les schémas de CWPROD que le compte voit depuis l'ajout de tous les schémas CORA, avec leur nombre de tables et de vues et leur volumétrie, pour savoir où chercher la structure de l'établissement et les référentiels (étape 1 du plan, issue « schemas-cora »)
-- Oracle. Lit seulement le catalogue (ALL_USERS, ALL_TABLES, ALL_VIEWS) : aucune donnée de table. Schémas non maintenus par Oracle. Un schéma sans aucun objet visible apparaît avec des zéros : il existe, mais le compte n'a aucun droit dessus.
-- LIGNES_STATS_TOTAL : somme des NUM_ROWS d'après les statistiques Oracle, qui peuvent être anciennes ou absentes (NB_TABLES_SANS_STATS) ; un ordre de grandeur, pas un effectif.
WITH objets AS (
  SELECT t.OWNER, 'TABLE' AS TYPE_OBJET, t.NUM_ROWS, t.LAST_ANALYZED
  FROM ALL_TABLES t
  UNION ALL
  SELECT v.OWNER, 'VIEW', NULL, NULL
  FROM ALL_VIEWS v
)
SELECT '20261026-schemas-inventaire' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       u.USERNAME AS OWNER,
       TO_CHAR(u.CREATED, 'YYYY-MM-DD') AS CREE_LE,
       NVL(SUM(CASE WHEN o.TYPE_OBJET = 'TABLE' THEN 1 ELSE 0 END), 0) AS NB_TABLES,
       NVL(SUM(CASE WHEN o.TYPE_OBJET = 'VIEW' THEN 1 ELSE 0 END), 0) AS NB_VUES,
       NVL(SUM(CASE WHEN o.TYPE_OBJET = 'TABLE' AND o.NUM_ROWS IS NULL THEN 1 ELSE 0 END), 0) AS NB_TABLES_SANS_STATS,
       NVL(SUM(CASE WHEN o.TYPE_OBJET = 'TABLE' AND o.NUM_ROWS = 0 THEN 1 ELSE 0 END), 0) AS NB_TABLES_VIDES,
       SUM(o.NUM_ROWS) AS LIGNES_STATS_TOTAL,
       TO_CHAR(MAX(o.LAST_ANALYZED), 'YYYY-MM-DD') AS DERNIERE_STAT
FROM ALL_USERS u
LEFT JOIN objets o ON o.OWNER = u.USERNAME
WHERE u.ORACLE_MAINTAINED = 'N'
GROUP BY u.USERNAME, u.CREATED
ORDER BY u.USERNAME;
