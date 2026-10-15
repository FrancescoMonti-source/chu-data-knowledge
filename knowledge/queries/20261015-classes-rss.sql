-- id: 20261015-classes-rss
-- system: cora
-- person_data: masked
-- purpose: répartir les RSS selon la classe de type-prise-en-charge-mco (séance CMD 28, 0 nuit, au moins une nuit, durée vide), le TYPE_PEC du RSS, la lettre de type du GHM (C, K, M, Z) et son dernier caractère (niveau 1 à 4, J ambulatoire, T très courte durée…), pour savoir si TYPE_PEC ou le GHM séparent l'hôpital de jour de médecine de la chirurgie ambulatoire, et pour poser les questions des séjours ambulatoires et d'hospitalisation (kb : backlog ambulatory-stay-definition, inpatient-stay-definition)
-- Oracle, schéma CORA_REC. RSS de TB_SYNTH_RSS finis de 2018 à 2025, par année de DATE_FIN. CODE_GHM sur 4 caractères sans la CMD (ghm-code-without-cmd dans la kb) : lettre de type = 1er caractère, niveau = dernier caractère.
-- Deux niveaux : TYPE_PEC (année, classe, TYPE_PEC) et GHM (année, classe, lettre, niveau). N : RSS.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : dans chaque niveau, quand les cases masquées d'une année et d'une classe totalisent de 1 à 9, la plus grande case du groupe sort aussi en « masqué ». Aucune ligne de total.
WITH r AS (
  SELECT EXTRACT(YEAR FROM DATE_FIN) AS ANNEE,
         CASE WHEN TRIM(CODE_CMD) = '28' THEN '1 séance (CMD 28)'
              WHEN DUREE_SEJOUR IS NULL THEN '4 durée vide'
              WHEN DUREE_SEJOUR = 0 THEN '2 0 nuit'
              ELSE '3 au moins une nuit' END AS CLASSE,
         NVL(TRIM(TO_CHAR(TYPE_PEC)), '(vide)') AS TYPE_PEC,
         NVL(SUBSTR(TRIM(CODE_GHM), 1, 1), '(vide)') AS LETTRE,
         NVL(SUBSTR(TRIM(CODE_GHM), -1, 1), '(vide)') AS NIVEAU
  FROM CORA_REC.TB_SYNTH_RSS
  WHERE DATE_FIN >= DATE '2018-01-01' AND DATE_FIN < DATE '2026-01-01'
),
c AS (
  SELECT 'TYPE_PEC' AS VUE, ANNEE, CLASSE, TYPE_PEC AS VALEUR_1, NULL AS VALEUR_2, COUNT(*) AS N
  FROM r GROUP BY ANNEE, CLASSE, TYPE_PEC
  UNION ALL
  SELECT 'GHM', ANNEE, CLASSE, LETTRE, NIVEAU, COUNT(*)
  FROM r GROUP BY ANNEE, CLASSE, LETTRE, NIVEAU
),
m AS (
  SELECT VUE, ANNEE, CLASSE, VALEUR_1, VALEUR_2, N,
         SUM(CASE WHEN N < 10 THEN N ELSE 0 END) OVER (PARTITION BY VUE, ANNEE, CLASSE) AS CACHE,
         ROW_NUMBER() OVER (PARTITION BY VUE, ANNEE, CLASSE ORDER BY N DESC, VALEUR_1, VALEUR_2) AS RANG
  FROM c
)
SELECT '20261015-classes-rss' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       VUE, ANNEE, CLASSE, VALEUR_1, VALEUR_2,
       CASE WHEN N < 10 THEN '<10' WHEN CACHE BETWEEN 1 AND 9 AND RANG = 1 THEN 'masqué' ELSE TO_CHAR(N) END AS N
FROM m
ORDER BY VUE, ANNEE, CLASSE, VALEUR_1, VALEUR_2;
