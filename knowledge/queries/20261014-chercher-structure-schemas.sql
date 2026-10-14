-- id: 20261014-chercher-structure-schemas
-- system: cora
-- person_data: no-person-data
-- purpose: chercher, dans tous les schémas que le compte voit sur CWPROD, les tables et colonnes de la structure de l'établissement exportée par Cora Admin Recueil (pôle, service, type d'activité CODE_TA, discipline CODE_DE, bâtiment, étage, type de prise en charge) (étape 13 du plan, #24)
-- Oracle. Lit seulement le catalogue (ALL_USERS, ALL_TABLES, ALL_VIEWS, ALL_TAB_COLUMNS, ALL_TAB_COMMENTS) : aucune donnée de table n'est lue.
-- Trois niveaux : SCHEMA (chaque schéma visible et son nombre de tables et de vues), OBJET (tables et vues dont le nom évoque la structure), COLONNE (colonnes dont le nom évoque l'export de Cora Admin Recueil).
-- LIGNES_STATS : nombre de lignes d'après les statistiques Oracle (ALL_TABLES.NUM_ROWS), pour repérer les référentiels ; vide pour une vue.
WITH perimetre AS (
  SELECT USERNAME AS OWNER
  FROM ALL_USERS
  WHERE ORACLE_MAINTAINED = 'N'
),
objets AS (
  SELECT t.OWNER, t.TABLE_NAME AS OBJET, 'TABLE' AS TYPE_OBJET, t.NUM_ROWS AS LIGNES_STATS
  FROM ALL_TABLES t
  WHERE t.OWNER IN (SELECT OWNER FROM perimetre)
  UNION ALL
  SELECT v.OWNER, v.VIEW_NAME, 'VIEW', NULL
  FROM ALL_VIEWS v
  WHERE v.OWNER IN (SELECT OWNER FROM perimetre)
)
SELECT '20261014-chercher-structure-schemas' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       r.NIVEAU, r.OWNER, r.OBJET, r.TYPE_OBJET, r.COLONNE, r.TYPE_DONNEE, r.LIGNES_STATS, r.COMMENTAIRE
FROM (
  SELECT 'SCHEMA' AS NIVEAU, o.OWNER, NULL AS OBJET, NULL AS TYPE_OBJET, NULL AS COLONNE, NULL AS TYPE_DONNEE,
         COUNT(*) AS LIGNES_STATS, NULL AS COMMENTAIRE
  FROM objets o
  GROUP BY o.OWNER
  UNION ALL
  SELECT 'OBJET', o.OWNER, o.OBJET, o.TYPE_OBJET, NULL, NULL, o.LIGNES_STATS, SUBSTR(c.COMMENTS, 1, 200)
  FROM objets o
  LEFT JOIN ALL_TAB_COMMENTS c ON c.OWNER = o.OWNER AND c.TABLE_NAME = o.OBJET
  WHERE REGEXP_LIKE(o.OBJET, 'STRUCT|POLE|SERVICE|DISCIPL|ACTIVIT|BATIMENT|ETAGE|FICUM|SAE|(^|_)UF(_|$|S)|(^|_)UM(_|$|S)', 'i')
  UNION ALL
  SELECT 'COLONNE', col.OWNER, col.TABLE_NAME, o.TYPE_OBJET, col.COLUMN_NAME, col.DATA_TYPE, o.LIGNES_STATS, NULL
  FROM ALL_TAB_COLUMNS col
  JOIN objets o ON o.OWNER = col.OWNER AND o.OBJET = col.TABLE_NAME
  WHERE REGEXP_LIKE(col.COLUMN_NAME, '(^|_)CODE_TA$|(^|_)CODE_DE$|^TA$|^DE$|DISCIPL|TYPE_ACTIV|SERVICE|CODE_POLE|LETTRE_BUD|BATIMENT|ETAGE|PRISE_EN_CHARGE|TYPE_PEC|TRES_LONG|LIB.*COURT|DATE_FIN_UF|RESP_UF', 'i')
) r
ORDER BY CASE r.NIVEAU WHEN 'SCHEMA' THEN 1 WHEN 'OBJET' THEN 2 ELSE 3 END, r.OWNER, r.OBJET, r.COLONNE;
