-- id: 20261103-colonnes-exclusions-specialites
-- system: cora
-- person_data: no-person-data
-- purpose: lister les colonnes des tables d'exclusion de CMA et de CIM_HIERARCHIE (pour écrire plus tard une requête dessus) et des tables dont le nom évoque une spécialité (pour savoir si CORA porte une spécialité au niveau de l'UF ou du service) (issue « schemas-cora »)
-- Oracle. Lit seulement le catalogue (ALL_TAB_COLUMNS, ALL_COL_COMMENTS) : aucune donnée de table. Tables nommées une par une.
-- Si une table est absente du résultat, elle n'est pas visible pour le compte.
SELECT '20261103-colonnes-exclusions-specialites' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       c.OWNER, c.TABLE_NAME AS OBJET, c.COLUMN_ID AS RANG, c.COLUMN_NAME AS COLONNE,
       c.DATA_TYPE AS TYPE_DONNEE, c.DATA_LENGTH AS LONGUEUR, SUBSTR(cc.COMMENTS, 1, 150) AS COMMENTAIRE
FROM ALL_TAB_COLUMNS c
LEFT JOIN ALL_COL_COMMENTS cc ON cc.OWNER = c.OWNER AND cc.TABLE_NAME = c.TABLE_NAME AND cc.COLUMN_NAME = c.COLUMN_NAME
WHERE (c.OWNER = 'CORA_CCAM' AND c.TABLE_NAME IN ('CIM_DP_EXCLU', 'CIM_LISTE_DIAG_EXCLU', 'CIM_LISTE_EXCLU_CAV', 'FG_DP_EXCLUANT',
                                                  'CIM_HIERARCHIE', 'CCAM_CODE_SPE', 'CCAM_SPE_CCAM'))
   OR (c.OWNER = 'CORA_REC' AND c.TABLE_NAME IN ('TB_SPECIALITE', 'TB_THESAURUS_SPECIALITE', 'TB_THES_TYPE_ACTIVITE'))
   OR (c.OWNER = 'CORA_UTIL' AND c.TABLE_NAME = 'TB_SPECIALITE_MED')
ORDER BY c.OWNER, c.TABLE_NAME, c.COLUMN_ID;
