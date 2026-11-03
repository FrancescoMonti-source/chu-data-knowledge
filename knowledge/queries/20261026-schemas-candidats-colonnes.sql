-- id: 20261026-schemas-candidats-colonnes
-- system: cora
-- person_data: no-person-data
-- purpose: lister les colonnes (nom, type, longueur) des tables et vues qui sont des candidats « structure de l'établissement », « ICR » ou « référentiel » dans tous les schémas visibles de CWPROD, pour choisir les tables à lire ensuite (étape 2 du plan, issue « schemas-cora »)
-- Oracle. Lit seulement le catalogue (ALL_TABLES, ALL_VIEWS, ALL_TAB_COLUMNS, ALL_COL_COMMENTS) : aucune donnée de table. Schémas non maintenus par Oracle.
-- THEME, trois règles sur le nom de l'objet ou de ses colonnes (insensible à la casse) :
--   STRUCTURE : nom évoquant STRUCT, POLE, SERVICE, DISCIPL, BATIMENT, ETAGE, FINESS, ETABLISSEMENT, SITE, UNITE, UF, UM, REGROUP, SECTEUR, ORGANI, HIERARCH, RATTACH ; ou, pour une table de moins de 200 000 lignes d'après les statistiques (ou sans statistiques), une colonne CODE_UNITE, CODE_UNITE_MED, ID_UNITE_MED, CODE_POLE, ID_POLE, CODE_SERVICE, ID_SERVICE, CODE_UF, CODE_UM ou CODE_FINESS.
--   ICR : nom évoquant ICR (entre soulignés ou en bord de nom), CCAM, COUT, ECHELLE, ENC, ATIH.
--   REFERENTIEL : nom commençant par TB_THES, PMSI_LIB, R_, REF_, LIB_, ou évoquant NOMENC, REFERENTIEL, TARIF, THESAURUS ; pour les tables de moins de 200 000 lignes seulement.
-- Un objet peut avoir plusieurs thèmes ; il sort alors une fois par thème. LIGNES_STATS : NUM_ROWS d'après les statistiques Oracle, vide pour une vue.
WITH objets AS (
  SELECT t.OWNER, t.TABLE_NAME AS OBJET, 'TABLE' AS TYPE_OBJET, t.NUM_ROWS AS LIGNES_STATS
  FROM ALL_TABLES t
  UNION ALL
  SELECT v.OWNER, v.VIEW_NAME, 'VIEW', NULL
  FROM ALL_VIEWS v
),
perimetre AS (
  SELECT o.OWNER, o.OBJET, o.TYPE_OBJET, o.LIGNES_STATS
  FROM objets o
  JOIN ALL_USERS u ON u.USERNAME = o.OWNER AND u.ORACLE_MAINTAINED = 'N'
),
colonnes_structure AS (
  SELECT DISTINCT c.OWNER, c.TABLE_NAME AS OBJET
  FROM ALL_TAB_COLUMNS c
  WHERE REGEXP_LIKE(c.COLUMN_NAME, '^(CODE_UNITE|CODE_UNITE_MED|ID_UNITE_MED|CODE_POLE|ID_POLE|CODE_SERVICE|ID_SERVICE|CODE_UF|CODE_UM|CODE_FINESS)$', 'i')
),
themes AS (
  SELECT p.OWNER, p.OBJET, p.TYPE_OBJET, p.LIGNES_STATS, 'STRUCTURE' AS THEME
  FROM perimetre p
  WHERE REGEXP_LIKE(p.OBJET, 'STRUCT|POLE|SERVICE|DISCIPL|BATIMENT|ETAGE|FINESS|ETABLISSEMENT|SITE|UNITE|(^|_)UF(_|$|S)|(^|_)UM(_|$|S)|REGROUP|SECTEUR|ORGANI|HIERARCH|RATTACH', 'i')
     OR (NVL(p.LIGNES_STATS, 0) < 200000
         AND EXISTS (SELECT 1 FROM colonnes_structure cs WHERE cs.OWNER = p.OWNER AND cs.OBJET = p.OBJET))
  UNION ALL
  SELECT p.OWNER, p.OBJET, p.TYPE_OBJET, p.LIGNES_STATS, 'ICR'
  FROM perimetre p
  WHERE REGEXP_LIKE(p.OBJET, '(^|_)ICR(_|$)|CCAM|COUT|ECHELLE|(^|_)ENC(_|$)|ATIH', 'i')
  UNION ALL
  SELECT p.OWNER, p.OBJET, p.TYPE_OBJET, p.LIGNES_STATS, 'REFERENTIEL'
  FROM perimetre p
  WHERE NVL(p.LIGNES_STATS, 0) < 200000
    AND REGEXP_LIKE(p.OBJET, '^(TB_THES|PMSI_LIB|R_|REF_|LIB_)|NOMENC|REFERENTIEL|TARIF|THESAURUS', 'i')
)
SELECT '20261026-schemas-candidats-colonnes' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       th.THEME, th.OWNER, th.OBJET, th.TYPE_OBJET, th.LIGNES_STATS,
       col.COLUMN_ID AS RANG, col.COLUMN_NAME AS COLONNE, col.DATA_TYPE AS TYPE_DONNEE, col.DATA_LENGTH AS LONGUEUR,
       SUBSTR(cc.COMMENTS, 1, 150) AS COMMENTAIRE
FROM themes th
JOIN ALL_TAB_COLUMNS col ON col.OWNER = th.OWNER AND col.TABLE_NAME = th.OBJET
LEFT JOIN ALL_COL_COMMENTS cc ON cc.OWNER = col.OWNER AND cc.TABLE_NAME = col.TABLE_NAME AND cc.COLUMN_NAME = col.COLUMN_NAME
ORDER BY th.THEME, th.OWNER, th.OBJET, col.COLUMN_ID;
