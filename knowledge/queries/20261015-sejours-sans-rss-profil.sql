-- id: 20261015-sejours-sans-rss-profil
-- system: cora
-- person_data: masked
-- purpose: ce que sont les séjours clos sans RSS, comparés à ceux qui en ont un, par année de sortie depuis 2018 : durée, nombre de mouvements, champ de l'unité du dernier mouvement (MCO soumis au PMSI, psychiatrie, SMR, HAD, autre), TYPE_SEJOUR (#25, tests 1 à 6)
-- Oracle, schéma CORA_REC. Séjours sortis de 2018 à 2025, hors préadmissions. RSS : par TB_SYNTH_RSS.ID_SEJOUR (joindre-rss-par-id-sejour). Dernier mouvement : le plus tardif par DATE_DEBUT_MVT, HEURE_DEBUT_MVT, ID_MVT ; unité par son code (joindre-uf-par-code).
-- CHAMP : 'HAD' si le séjour a une ligne dans TB_MVT_HAD, sinon 'SMR' s'il en a une dans TB_MVT_SSR_SEM, sinon 'PSY' s'il en a une dans TB_MVT_PSY_SEQ ou si l'UF du dernier mouvement a TYPE_UNITE_PSY ; sinon 'MCO PMSI' si l'UF a GESTION_PMSI = 'O' ; sinon 'autre'.
-- Quatre vues, chacune par année et AVEC_RSS (O/N) : DUREE (0 jour, 1 jour, 2 à 7, 8 à 30, plus de 30, sortie − entrée en jours), NB_MVT (1, 2, 3 et plus), CHAMP, TYPE_SEJOUR. N : séjours.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : dans chaque vue, quand les cases masquées d'une année et d'une valeur de AVEC_RSS totalisent de 1 à 9, la plus grande case du groupe sort aussi en « masqué ». Aucune ligne de total.
WITH mv AS (
  SELECT ID_SEJOUR, COUNT(*) AS NB_MVT,
         MAX(TRIM(ID_UNITE_M)) KEEP (DENSE_RANK LAST ORDER BY DATE_DEBUT_MVT, HEURE_DEBUT_MVT, ID_MVT) AS UF
  FROM CORA_REC.TB_MVT GROUP BY ID_SEJOUR
),
uf AS (
  SELECT TRIM(CODE_UNITE) AS CODE, MAX(GESTION_PMSI) AS GESTION_PMSI, MAX(TRIM(TYPE_UNITE_PSY)) AS PSY
  FROM CORA_REC.TB_UNITE GROUP BY TRIM(CODE_UNITE)
),
rss AS (SELECT DISTINCT ID_SEJOUR FROM CORA_REC.TB_SYNTH_RSS WHERE ID_SEJOUR IS NOT NULL),
had AS (SELECT DISTINCT ID_SEJOUR FROM CORA_REC.TB_MVT_HAD),
smr AS (SELECT DISTINCT ID_SEJOUR FROM CORA_REC.TB_MVT_SSR_SEM),
psy AS (SELECT DISTINCT ID_SEJOUR FROM CORA_REC.TB_MVT_PSY_SEQ),
s AS (
  SELECT EXTRACT(YEAR FROM se.DATE_SORTIE) AS ANNEE,
         CASE WHEN rss.ID_SEJOUR IS NOT NULL THEN 'O' ELSE 'N' END AS AVEC_RSS,
         CASE WHEN TRUNC(se.DATE_SORTIE) - TRUNC(se.DATE_ENTREE) <= 0 THEN '1 0 jour'
              WHEN TRUNC(se.DATE_SORTIE) - TRUNC(se.DATE_ENTREE) = 1 THEN '2 1 jour'
              WHEN TRUNC(se.DATE_SORTIE) - TRUNC(se.DATE_ENTREE) <= 7 THEN '3 2 à 7 jours'
              WHEN TRUNC(se.DATE_SORTIE) - TRUNC(se.DATE_ENTREE) <= 30 THEN '4 8 à 30 jours'
              ELSE '5 plus de 30 jours' END AS DUREE,
         CASE WHEN mv.NB_MVT IS NULL THEN '0' WHEN mv.NB_MVT = 1 THEN '1' WHEN mv.NB_MVT = 2 THEN '2' ELSE '3 et plus' END AS NB_MVT,
         CASE WHEN had.ID_SEJOUR IS NOT NULL THEN 'HAD'
              WHEN smr.ID_SEJOUR IS NOT NULL THEN 'SMR'
              WHEN psy.ID_SEJOUR IS NOT NULL OR uf.PSY IS NOT NULL THEN 'PSY'
              WHEN uf.GESTION_PMSI = 'O' THEN 'MCO PMSI'
              ELSE 'autre' END AS CHAMP,
         NVL(TRIM(se.TYPE_SEJOUR), '(vide)') AS TYPE_SEJOUR
  FROM CORA_REC.TB_SEJOUR se
  LEFT JOIN mv ON mv.ID_SEJOUR = se.ID_SEJOUR
  LEFT JOIN uf ON uf.CODE = mv.UF
  LEFT JOIN rss ON rss.ID_SEJOUR = se.ID_SEJOUR
  LEFT JOIN had ON had.ID_SEJOUR = se.ID_SEJOUR
  LEFT JOIN smr ON smr.ID_SEJOUR = se.ID_SEJOUR
  LEFT JOIN psy ON psy.ID_SEJOUR = se.ID_SEJOUR
  WHERE se.DATE_SORTIE >= DATE '2018-01-01' AND se.DATE_SORTIE < DATE '2026-01-01'
    AND NVL(se.STATUT_PROG, '-') <> 'P'
),
c AS (
  SELECT 'DUREE' AS VUE, ANNEE, AVEC_RSS, DUREE AS VALEUR, COUNT(*) AS N FROM s GROUP BY ANNEE, AVEC_RSS, DUREE
  UNION ALL SELECT 'NB_MVT', ANNEE, AVEC_RSS, NB_MVT, COUNT(*) FROM s GROUP BY ANNEE, AVEC_RSS, NB_MVT
  UNION ALL SELECT 'CHAMP', ANNEE, AVEC_RSS, CHAMP, COUNT(*) FROM s GROUP BY ANNEE, AVEC_RSS, CHAMP
  UNION ALL SELECT 'TYPE_SEJOUR', ANNEE, AVEC_RSS, TYPE_SEJOUR, COUNT(*) FROM s GROUP BY ANNEE, AVEC_RSS, TYPE_SEJOUR
),
r AS (
  SELECT VUE, ANNEE, AVEC_RSS, VALEUR, N,
         SUM(CASE WHEN N < 10 THEN N ELSE 0 END) OVER (PARTITION BY VUE, ANNEE, AVEC_RSS) AS CACHE,
         ROW_NUMBER() OVER (PARTITION BY VUE, ANNEE, AVEC_RSS ORDER BY N DESC, VALEUR) AS RANG
  FROM c
)
SELECT '20261015-sejours-sans-rss-profil' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       VUE, ANNEE, AVEC_RSS, VALEUR,
       CASE WHEN N < 10 THEN '<10' WHEN CACHE BETWEEN 1 AND 9 AND RANG = 1 THEN 'masqué' ELSE TO_CHAR(N) END AS N
FROM r
ORDER BY VUE, ANNEE, AVEC_RSS, VALEUR;
