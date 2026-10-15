-- id: 20261015-catalogue-referentiels
-- system: cora
-- person_data: no-person-data
-- purpose: chercher dans le catalogue de CWPROD les tables et les colonnes des applications émettrices (codes 7, 10, 16, −3010), des listes d'exclusion de CMA, des niveaux de sévérité et des tarifs GHS, pour savoir où CORA les range (kb : backlog application-codes, cma-exclusion-lists, severity-duration-age-rules, tariff-reference-date, definition.ghm-to-ghs-table)
-- Oracle. Lit seulement le catalogue (ALL_TABLES, ALL_VIEWS, ALL_TAB_COLUMNS, ALL_TAB_COMMENTS) : aucune donnée de table n'est lue. Schémas non maintenus par Oracle.
-- Deux niveaux : OBJET (tables et vues dont le nom évoque ces sujets, avec NUM_ROWS d'après les statistiques Oracle), COLONNE (colonnes de ces objets, avec type et commentaire).
WITH objets AS (
  SELECT t.OWNER, t.TABLE_NAME AS OBJET, 'TABLE' AS TYPE_OBJET, t.NUM_ROWS AS LIGNES_STATS
  FROM ALL_TABLES t JOIN ALL_USERS u ON u.USERNAME = t.OWNER AND u.ORACLE_MAINTAINED = 'N'
  UNION ALL
  SELECT v.OWNER, v.VIEW_NAME, 'VIEW', NULL
  FROM ALL_VIEWS v JOIN ALL_USERS u ON u.USERNAME = v.OWNER AND u.ORACLE_MAINTAINED = 'N'
),
cibles AS (
  SELECT OWNER, OBJET, TYPE_OBJET, LIGNES_STATS FROM objets
  WHERE REGEXP_LIKE(OBJET, 'APPLI|TRANSFERT|CMA|EXCLU|SEVER|NIVEAU|GHS|TARIF|GHM|RACINE|ANNEXE', 'i')
)
SELECT '20261015-catalogue-referentiels' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       r.NIVEAU, r.OWNER, r.OBJET, r.TYPE_OBJET, r.COLONNE, r.TYPE_DONNEE, r.LIGNES_STATS, r.COMMENTAIRE
FROM (
  SELECT 'OBJET' AS NIVEAU, c.OWNER, c.OBJET, c.TYPE_OBJET, NULL AS COLONNE, NULL AS TYPE_DONNEE,
         c.LIGNES_STATS, SUBSTR(tc.COMMENTS, 1, 200) AS COMMENTAIRE
  FROM cibles c
  LEFT JOIN ALL_TAB_COMMENTS tc ON tc.OWNER = c.OWNER AND tc.TABLE_NAME = c.OBJET
  UNION ALL
  SELECT 'COLONNE', col.OWNER, col.TABLE_NAME, c.TYPE_OBJET, col.COLUMN_NAME, col.DATA_TYPE, NULL,
         SUBSTR(cc.COMMENTS, 1, 200)
  FROM ALL_TAB_COLUMNS col
  JOIN cibles c ON c.OWNER = col.OWNER AND c.OBJET = col.TABLE_NAME
  LEFT JOIN ALL_COL_COMMENTS cc ON cc.OWNER = col.OWNER AND cc.TABLE_NAME = col.TABLE_NAME AND cc.COLUMN_NAME = col.COLUMN_NAME
) r
ORDER BY r.OWNER, r.OBJET, CASE r.NIVEAU WHEN 'OBJET' THEN 1 ELSE 2 END, r.COLONNE;
