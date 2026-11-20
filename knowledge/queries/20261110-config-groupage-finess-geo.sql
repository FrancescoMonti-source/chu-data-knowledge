-- id: 20261110-config-groupage-finess-geo
-- system: cora
-- person_data: no-person-data
-- purpose: étape 6 du plan (#133, enquête ghs-par-sejour), suite de la relecture de la PR #134 : environ 200 RSS par an restent sur deux entités géographiques ; lire les paramètres de CORA qui activent le groupage par FINESS géographique (un RSS par site), d'après le dictionnaire (20261110-dictionnaire-groupage-finess-geo), pour savoir depuis quand et avec quelle exclusion CORA découpe les séjours par site
-- Oracle, schéma CORA_REC. TB_CONFIG_LISTE, une ligne par paramètre et par EJ : GRP_FINESS_GEOD (date d'activation), GRP_FINESS_GEOE (exclusion des RSS générés avant cette date, O/N). Paramètres de l'établissement, pas des personnes.
SELECT '20261110-config-groupage-finess-geo' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       TRIM(c.CODE_CONFIG) AS CODE_CONFIG,
       TRIM(c.TYPE_CONFIG) AS TYPE_CONFIG,
       TRIM(c.VAL_CONFIG) AS VAL_CONFIG,
       TO_CHAR(c.DATE_MODIF, 'YYYY-MM-DD HH24:MI') AS DATE_MODIF,
       c.ID_EJ
FROM CORA_REC.TB_CONFIG_LISTE c
WHERE TRIM(c.CODE_CONFIG) IN ('GRP_FINESS_GEOD', 'GRP_FINESS_GEOE')
ORDER BY CODE_CONFIG, c.ID_EJ;
