-- id: 20261019-catalogue-types-colonnes-g3
-- system: cora
-- person_data: no-person-data
-- purpose: lire dans le catalogue les types des colonnes DATE_* et HEURE_* de TB_SEJOUR, TB_MVT et TB_ACTE (claim date-et-heure-dans-deux-colonnes), les colonnes CHAR de longueur fixe de CORA_REC qui portent un code (codes-char-completes-de-blancs : CODE_ACTE, CODE_DIAG, NO_SEJOUR, UF, unités) et les types de NO_SEJOUR_MAITRE et NO_SEJOUR_LIE de TB_SEJOUR_LIE, ainsi que la présence des colonnes de drapeaux étudiées (drapeaux-cora-valeurs-propres) ; fixe les noms de colonnes des requêtes de mesure du même lot
-- Oracle, schéma CORA_REC. Lit seulement ALL_TAB_COLUMNS : aucune donnée de table.
-- Niveaux : DATE_HEURE (colonnes de type DATE ou TIMESTAMP, ou de nom DATE_* / HEURE_*, des trois tables), CHAR_CODE (colonnes CHAR de CORA_REC dont le nom évoque un code, une unité, un séjour ou une UF), SEJOUR_LIE (colonnes NO_SEJOUR_* de TB_SEJOUR_LIE), DRAPEAU (colonnes de drapeaux de TB_UNITE, TB_SITE, TB_DET_ACTE, TB_MVT, TB_SYNTH_RUM), RESUME_CHAR (une ligne : nombre de colonnes CHAR et de tables concernées dans CORA_REC).
-- ALL_TAB_COLUMNS mêle tables et vues : le type d'objet n'est pas distingué ici.
SELECT '20261019-catalogue-types-colonnes-g3' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       r.NIVEAU, r.TABLE_NAME, r.COLUMN_NAME, r.DATA_TYPE, r.DATA_LENGTH, r.NB_COLONNES, r.NB_TABLES
FROM (
  SELECT 'DATE_HEURE' AS NIVEAU, c.TABLE_NAME, c.COLUMN_NAME, c.DATA_TYPE, c.DATA_LENGTH,
         CAST(NULL AS NUMBER) AS NB_COLONNES, CAST(NULL AS NUMBER) AS NB_TABLES
  FROM ALL_TAB_COLUMNS c
  WHERE c.OWNER = 'CORA_REC'
    AND c.TABLE_NAME IN ('TB_SEJOUR', 'TB_MVT', 'TB_ACTE')
    AND (c.DATA_TYPE = 'DATE' OR c.DATA_TYPE LIKE 'TIMESTAMP%' OR REGEXP_LIKE(c.COLUMN_NAME, '^(DATE|HEURE)_'))
  UNION ALL
  SELECT 'CHAR_CODE', c.TABLE_NAME, c.COLUMN_NAME, c.DATA_TYPE, c.DATA_LENGTH, NULL, NULL
  FROM ALL_TAB_COLUMNS c
  WHERE c.OWNER = 'CORA_REC' AND c.DATA_TYPE = 'CHAR'
    AND REGEXP_LIKE(c.COLUMN_NAME, 'CODE_ACTE|CODE_DIAG|NO_SEJOUR|(^|_)UF(_|$)|UNITE|CODE_GHM|CODE_GHS|CODE_CMD|^DP$|^DR$')
  UNION ALL
  SELECT 'SEJOUR_LIE', c.TABLE_NAME, c.COLUMN_NAME, c.DATA_TYPE, c.DATA_LENGTH, NULL, NULL
  FROM ALL_TAB_COLUMNS c
  WHERE c.OWNER = 'CORA_REC' AND c.TABLE_NAME = 'TB_SEJOUR_LIE' AND c.COLUMN_NAME LIKE 'NO_SEJOUR%'
  UNION ALL
  SELECT 'DRAPEAU', c.TABLE_NAME, c.COLUMN_NAME, c.DATA_TYPE, c.DATA_LENGTH, NULL, NULL
  FROM ALL_TAB_COLUMNS c
  WHERE c.OWNER = 'CORA_REC'
    AND ((c.TABLE_NAME = 'TB_UNITE' AND c.COLUMN_NAME IN ('URGENCE', 'EXTERNE', 'HJ', 'GESTION_PMSI', 'REA', 'UHCD', 'AMBULATOIRE', 'EXT_MED_TECH', 'ACTIF', 'UF', 'UM', 'SEANCE'))
      OR (c.TABLE_NAME = 'TB_SITE' AND c.COLUMN_NAME IN ('BLOC', 'ACTIF', 'LIEU_REAL_ACTE'))
      OR (c.TABLE_NAME = 'TB_DET_ACTE' AND c.COLUMN_NAME IN ('FACTURABLE', 'ACTE_GRATUIT', 'POUR_MEMOIRE', 'ETAT', 'ID_ACTIVITE'))
      OR (c.TABLE_NAME = 'TB_MVT' AND c.COLUMN_NAME IN ('FLAG_MVT_SITE', 'BLOCAGE_RSS'))
      OR (c.TABLE_NAME = 'TB_SYNTH_RUM' AND c.COLUMN_NAME = 'DP_MVT_RETENU'))
  UNION ALL
  SELECT 'RESUME_CHAR', NULL, NULL, 'CHAR', NULL, COUNT(*), COUNT(DISTINCT c.TABLE_NAME)
  FROM ALL_TAB_COLUMNS c
  WHERE c.OWNER = 'CORA_REC' AND c.DATA_TYPE = 'CHAR'
) r
ORDER BY CASE r.NIVEAU WHEN 'DATE_HEURE' THEN 1 WHEN 'CHAR_CODE' THEN 2 WHEN 'SEJOUR_LIE' THEN 3 WHEN 'DRAPEAU' THEN 4 ELSE 5 END,
         r.TABLE_NAME, r.COLUMN_NAME;
