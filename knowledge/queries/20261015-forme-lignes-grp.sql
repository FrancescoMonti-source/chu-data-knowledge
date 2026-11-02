-- id: 20261015-forme-lignes-grp
-- system: cora
-- person_data: masked
-- purpose: pour les RSS MCO finis de janvier à août 2026, vérifier que TB_SYNTH_RSS.LIGNES_GRP suit la mise en page du fichier groupé (feuille « RSS groupé format 123 », atih-formats-mco-2026) : versions lues aux positions fixes, CMD, GHM et n° de RSS aux mêmes positions que le fichier, longueur de ligne, une ligne par RUM (étape 2 du plan)
-- Oracle, schéma CORA_REC. Aucun contenu de LIGNES_GRP ne sort : seulement des codes de version fixes et des comptages. Les RSS sans LIGNES_GRP sont écartés.
-- Positions (feuille) : version de classification 1-2, CMD 3-4, GHM 5-8, version du format du RSS 10-12, version du format du RUM 25-27, n° de RSS 28-47, nDA 134-135, nDAD 136-137, nZA 138-140.
-- On lit la 1re ligne de LIGNES_GRP (jusqu'au premier saut de ligne). Longueur attendue : formule de la feuille, 192 + 8 nDA + 8 nDAD + 29 nZA ; ou somme des tailles des champs, 205 + 8 nDA + 8 nDAD + 32 nZA.
-- N_RSS_LONGUEUR_FORMULE, N_RSS_LONGUEUR_SOMME_TAILLES, N_RSS_LONGUEUR_AUTRE : la 1re ligne a l'une ou l'autre longueur, ou aucune (nDA, nDAD ou nZA illisibles compris).
-- N_RSS_CMD_DIFFERENTE, N_RSS_GHM_DIFFERENT, N_RSS_NO_RSS_DIFFERENT : la valeur aux positions du fichier diffère de CODE_CMD, CODE_GHM ou NO_RSS.
-- N_RSS_NB_LIGNES_DIFFERENT_NB_RUM : le nombre de lignes de LIGNES_GRP diffère de NB_RUM.
-- Règle 4 : pas de colonne total ni de ligne total ; les trois colonnes de longueur partagent les RSS de la ligne sans total affiché.
WITH r AS (
  SELECT s.CODE_CMD, s.CODE_GHM, s.NO_RSS, s.NB_RUM,
         DBMS_LOB.SUBSTR(s.LIGNES_GRP, 4000, 1) AS DEBUT,
         REGEXP_COUNT(RTRIM(s.LIGNES_GRP, CHR(13) || CHR(10)), CHR(10)) + 1 AS NB_LIGNES
  FROM CORA_REC.TB_SYNTH_RSS s
  WHERE s.DATE_FIN >= DATE '2026-01-01'
    AND s.DATE_FIN <  DATE '2026-09-01'
    AND s.LIGNES_GRP IS NOT NULL
    AND DBMS_LOB.GETLENGTH(s.LIGNES_GRP) > 0
),
l AS (
  SELECT r.CODE_CMD, r.CODE_GHM, r.NO_RSS, r.NB_RUM, r.NB_LIGNES,
         RTRIM(CASE WHEN INSTR(DEBUT, CHR(10)) > 0 THEN SUBSTR(DEBUT, 1, INSTR(DEBUT, CHR(10)) - 1) ELSE DEBUT END, CHR(13)) AS L1
  FROM r
),
f AS (
  SELECT l.CODE_CMD, l.CODE_GHM, l.NO_RSS, l.NB_RUM, l.NB_LIGNES, l.L1,
         LENGTH(L1) AS LONG1,
         CASE WHEN REGEXP_LIKE(SUBSTR(L1, 134, 7), '^[0-9]{7}$')
              THEN TO_NUMBER(SUBSTR(L1, 134, 2)) * 8 + TO_NUMBER(SUBSTR(L1, 136, 2)) * 8 END AS PART_DIAG,
         CASE WHEN REGEXP_LIKE(SUBSTR(L1, 134, 7), '^[0-9]{7}$')
              THEN TO_NUMBER(SUBSTR(L1, 138, 3)) END AS NZA
  FROM l
),
agg AS (
  SELECT SUBSTR(L1, 1, 2) AS VERSION_CLASSIF,
         SUBSTR(L1, 10, 3) AS FORMAT_RSS,
         SUBSTR(L1, 25, 3) AS FORMAT_RUM,
         SUM(CASE WHEN LONG1 = 192 + PART_DIAG + 29 * NZA THEN 1 ELSE 0 END) AS NB_FORMULE,
         SUM(CASE WHEN LONG1 = 205 + PART_DIAG + 32 * NZA THEN 1 ELSE 0 END) AS NB_SOMME,
         SUM(CASE WHEN PART_DIAG IS NULL
                    OR (LONG1 <> 192 + PART_DIAG + 29 * NZA AND LONG1 <> 205 + PART_DIAG + 32 * NZA) THEN 1 ELSE 0 END) AS NB_AUTRE,
         SUM(CASE WHEN SUBSTR(L1, 3, 2) = TRIM(CODE_CMD) THEN 0 ELSE 1 END) AS NB_CMD_DIFF,
         SUM(CASE WHEN SUBSTR(L1, 5, 4) = TRIM(CODE_GHM) THEN 0 ELSE 1 END) AS NB_GHM_DIFF,
         SUM(CASE WHEN TRIM(SUBSTR(L1, 28, 20)) = TRIM(NO_RSS) THEN 0 ELSE 1 END) AS NB_NO_RSS_DIFF,
         SUM(CASE WHEN NB_LIGNES = NB_RUM THEN 0 ELSE 1 END) AS NB_LIGNES_DIFF
  FROM f
  GROUP BY SUBSTR(L1, 1, 2), SUBSTR(L1, 10, 3), SUBSTR(L1, 25, 3)
)
SELECT '20261015-forme-lignes-grp' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       CASE WHEN REGEXP_LIKE(VERSION_CLASSIF, '^[0-9]{2}$') THEN VERSION_CLASSIF ELSE 'autre' END AS VERSION_CLASSIF,
       CASE WHEN REGEXP_LIKE(FORMAT_RSS, '^[0-9]{3}$') THEN FORMAT_RSS ELSE 'autre' END AS FORMAT_RSS,
       CASE WHEN REGEXP_LIKE(FORMAT_RUM, '^[0-9]{3}$') THEN FORMAT_RUM ELSE 'autre' END AS FORMAT_RUM,
       CASE WHEN NB_FORMULE < 10 THEN '<10' ELSE TO_CHAR(NB_FORMULE) END AS N_RSS_LONGUEUR_FORMULE,
       CASE WHEN NB_SOMME < 10 THEN '<10' ELSE TO_CHAR(NB_SOMME) END AS N_RSS_LONGUEUR_SOMME_TAILLES,
       CASE WHEN NB_AUTRE < 10 THEN '<10' ELSE TO_CHAR(NB_AUTRE) END AS N_RSS_LONGUEUR_AUTRE,
       CASE WHEN NB_CMD_DIFF < 10 THEN '<10' ELSE TO_CHAR(NB_CMD_DIFF) END AS N_RSS_CMD_DIFFERENTE,
       CASE WHEN NB_GHM_DIFF < 10 THEN '<10' ELSE TO_CHAR(NB_GHM_DIFF) END AS N_RSS_GHM_DIFFERENT,
       CASE WHEN NB_NO_RSS_DIFF < 10 THEN '<10' ELSE TO_CHAR(NB_NO_RSS_DIFF) END AS N_RSS_NO_RSS_DIFFERENT,
       CASE WHEN NB_LIGNES_DIFF < 10 THEN '<10' ELSE TO_CHAR(NB_LIGNES_DIFF) END AS N_RSS_NB_LIGNES_DIFFERENT_NB_RUM
FROM agg
ORDER BY 4, 5, 6;
