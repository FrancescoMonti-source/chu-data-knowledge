-- id: 20261023-usip-catalogue
-- system: cora
-- person_data: no-person-data
-- purpose: lire dans le catalogue les colonnes dont les requêtes de l'enquête usip-parcours auront besoin et qu'aucun claim ne donne : drapeaux et autorisation de TB_UNITE, colonnes d'unité, de dates et de durée de TB_SYNTH_RUM, colonnes de durée, de montant et de suppléments (réanimation, soins intensifs, surveillance continue) de TB_SYNTH_RSS, heures d'entrée et de sortie de TB_SEJOUR, colonnes de TB_MVT_RUM et de TB_UNITE_M_UNITE (étape 1 du plan)
-- Oracle, schéma CORA_REC. Lit seulement ALL_TAB_COLUMNS : aucune donnée de table.
-- Une ligne par colonne retenue : TABLE_NAME, COLUMN_ID, COLUMN_NAME, DATA_TYPE, DATA_LENGTH.
SELECT '20261023-usip-catalogue' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       c.TABLE_NAME, c.COLUMN_ID, c.COLUMN_NAME, c.DATA_TYPE, c.DATA_LENGTH
FROM ALL_TAB_COLUMNS c
WHERE c.OWNER = 'CORA_REC'
  AND (
       (c.TABLE_NAME = 'TB_UNITE'
        AND REGEXP_LIKE(c.COLUMN_NAME, 'AUTORIS|REA|TYPE_UNITE|ACTIF|UF|UM|LIBELLE|CODE_UNITE|^ID_UNITE$'))
    OR (c.TABLE_NAME = 'TB_SYNTH_RUM'
        AND REGEXP_LIKE(c.COLUMN_NAME, 'UNITE|UF|^DATE_|^HEURE_|DUREE|^ID_RSS$|^ID_RUM$|^ID_SEJOUR$|IGS|SOINS_INT|SURV|REA'))
    OR (c.TABLE_NAME = 'TB_SYNTH_RSS'
        AND REGEXP_LIKE(c.COLUMN_NAME, '^DATE_|^HEURE_|DUREE|MONTANT|^MNT_|SOINS_INT|SURV|REA|SUPPL|^MODE_|^CODE_|VERSION|^ID_RSS$|^ID_SEJOUR$|^NO_RSS$|SEXE|AGE'))
    OR (c.TABLE_NAME = 'TB_SEJOUR'
        AND REGEXP_LIKE(c.COLUMN_NAME, '^HEURE_|^DATE_ENTREE$|^DATE_SORTIE$|^MODE_|^CODE_PROVENANCE$|^CODE_DESTINATION$'))
    OR c.TABLE_NAME IN ('TB_MVT_RUM', 'TB_UNITE_M_UNITE', 'TB_UNITE_MEDICALE')
  )
ORDER BY c.TABLE_NAME, c.COLUMN_ID;
