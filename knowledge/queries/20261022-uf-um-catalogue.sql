-- id: 20261022-uf-um-catalogue
-- system: cora
-- person_data: no-person-data
-- purpose: lister les colonnes (nom, type, longueur) de TB_UNITE_M_UNITE, TB_UNITE_MEDICALE, TB_UNITE_POLE_UM et les colonnes de TB_SYNTH_RUM qui parlent d'unité, pour fixer les colonnes des requêtes suivantes (le dictionnaire 2020 annonce ID_UF_ATTRIB dans TB_SYNTH_RUM, jamais observée) (étape 1 du plan)
-- Oracle, schéma CORA_REC. Lit seulement le catalogue (ALL_TAB_COLUMNS, ALL_TABLES) : aucune donnée de table. Les colonnes de TB_SYNTH_RUM listées sont celles dont le nom contient UF ou UNITE.
SELECT '20261022-uf-um-catalogue' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       c.TABLE_NAME, c.COLUMN_ID, c.COLUMN_NAME, c.DATA_TYPE, c.DATA_LENGTH, t.NUM_ROWS AS LIGNES_STATS
FROM ALL_TAB_COLUMNS c
JOIN ALL_TABLES t ON t.OWNER = c.OWNER AND t.TABLE_NAME = c.TABLE_NAME
WHERE c.OWNER = 'CORA_REC'
  AND (c.TABLE_NAME IN ('TB_UNITE_M_UNITE', 'TB_UNITE_MEDICALE', 'TB_UNITE_POLE_UM')
       OR (c.TABLE_NAME = 'TB_SYNTH_RUM' AND (c.COLUMN_NAME LIKE '%UF%' OR c.COLUMN_NAME LIKE '%UNITE%')))
ORDER BY c.TABLE_NAME, c.COLUMN_ID;
