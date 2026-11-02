-- id: 20261015-colonnes-hist-diag-synth-rss
-- system: cora
-- person_data: no-person-data
-- purpose: connaître les colonnes, leur type et leur taille dans TB_HIST_DIAG, TB_HIST_SYNTH_RSS, TB_SYNTH_RSS et TB_DIAG sur CWPROD, pour reconstituer l'état M8 (étape 1 du plan) : quelle colonne date un événement de TB_HIST_DIAG, ce que garde TB_HIST_SYNTH_RSS, le format de CODE_GHM
-- Oracle. Lit seulement le catalogue (ALL_TAB_COLUMNS, ALL_TABLES) : aucune donnée de table n'est lue.
SELECT '20261015-colonnes-hist-diag-synth-rss' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       c.OWNER,
       c.TABLE_NAME,
       c.COLUMN_ID,
       c.COLUMN_NAME,
       c.DATA_TYPE,
       c.DATA_LENGTH,
       t.NUM_ROWS AS LIGNES_STATS
FROM ALL_TAB_COLUMNS c
LEFT JOIN ALL_TABLES t ON t.OWNER = c.OWNER AND t.TABLE_NAME = c.TABLE_NAME
WHERE c.OWNER = 'CORA_REC'
  AND c.TABLE_NAME IN ('TB_HIST_DIAG', 'TB_HIST_SYNTH_RSS', 'TB_SYNTH_RSS', 'TB_DIAG')
ORDER BY c.TABLE_NAME, c.COLUMN_ID;
