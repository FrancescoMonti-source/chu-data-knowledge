-- id: 20261020-catalogue-ssr-htp
-- system: cora
-- person_data: no-person-data
-- purpose: lister dans le catalogue de CWPROD les tables SMR du RHS, des actes CSARR, des tarifs GMT et de la facturation, et les colonnes des six tables dont l'enquête se sert, pour savoir où CORA range le GME, le score et les montants d'un RHS en HTP (étape 2 du plan, issue 96)
-- Oracle. Lit seulement le catalogue (ALL_TABLES, ALL_VIEWS, ALL_TAB_COLUMNS, ALL_TAB_COMMENTS, ALL_COL_COMMENTS) : aucune donnée de table n'est lue. Schémas non maintenus par Oracle.
-- Deux niveaux : OBJET (tables et vues dont le nom évoque ces sujets, avec NUM_ROWS d'après les statistiques Oracle), COLONNE (colonnes de six tables, avec type et commentaire).
WITH objets AS (
  SELECT t.OWNER, t.TABLE_NAME AS OBJET, 'TABLE' AS TYPE_OBJET, t.NUM_ROWS AS LIGNES_STATS
  FROM ALL_TABLES t JOIN ALL_USERS u ON u.USERNAME = t.OWNER AND u.ORACLE_MAINTAINED = 'N'
  UNION ALL
  SELECT v.OWNER, v.VIEW_NAME, 'VIEW', NULL
  FROM ALL_VIEWS v JOIN ALL_USERS u ON u.USERNAME = v.OWNER AND u.ORACLE_MAINTAINED = 'N'
),
cibles AS (
  SELECT OWNER, OBJET, TYPE_OBJET, LIGNES_STATS FROM objets
  WHERE REGEXP_LIKE(OBJET, 'SSR|SMR|RHS|RHA|GME|GMT|CSARR|FACT', 'i')
),
colonnes_cibles AS (
  SELECT OWNER, OBJET, TYPE_OBJET FROM cibles
  WHERE OBJET IN ('TB_MVT_SSR_SEM', 'TB_ACTE_CSARR', 'CSARR_PONDERATION', 'PMSI_LIB_GMT_TARIF', 'TB_RSF_FACT_RHS', 'TB_RSF_FACT')
)
SELECT '20261020-catalogue-ssr-htp' AS query_id,
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
  JOIN colonnes_cibles c ON c.OWNER = col.OWNER AND c.OBJET = col.TABLE_NAME
  LEFT JOIN ALL_COL_COMMENTS cc ON cc.OWNER = col.OWNER AND cc.TABLE_NAME = col.TABLE_NAME AND cc.COLUMN_NAME = col.COLUMN_NAME
) r
ORDER BY r.OWNER, r.OBJET, CASE r.NIVEAU WHEN 'OBJET' THEN 1 ELSE 2 END, r.COLONNE;
