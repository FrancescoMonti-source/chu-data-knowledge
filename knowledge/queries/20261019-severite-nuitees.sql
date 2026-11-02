-- id: 20261019-severite-nuitees
-- system: cora
-- person_data: masked
-- purpose: croiser le niveau de sévérité (6e caractère de CODE_CMD || CODE_GHM, de 1 à 4) et la durée du RSS en classes 0, 1, 2, 3, 4, 5+ nuitées, pour tester seuil-duree-niveaux-severite (réfuté par un RSS de niveau 2 à moins de 3 nuitées, de niveau 3 à moins de 4, de niveau 4 à moins de 5, hors règles particulières ; sinon les seuils servent de borne). Deux mesures de la durée côte à côte : les nuitées des dates (DATE_FIN − DATE_DEBUT) et DUREE_SEJOUR, pour voir laquelle respecte les seuils.
-- Oracle 11g, schéma CORA_REC. RSS de TB_SYNTH_RSS dont DATE_FIN va du 2018-01-01 à aujourd'hui, toutes années réunies. GHM de type M ou C seulement (1er caractère de CODE_GHM), niveau 1 à 4 seulement, hors CMD 90 : les types J/T/E/Z et les niveaux A à D ne sont pas des niveaux ordinaux.
-- Colonnes : MESURE (NUITEES_DATES : TRUNC(DATE_FIN) − TRUNC(DATE_DEBUT) ; DUREE_SEJOUR), TYPE_GHM, NIVEAU, CLASSE ('(vide)', '<0', 0 à 4, '5+'), N (RSS), PCT_NIVEAU (part de la classe parmi les RSS du même type, niveau et mesure, vide quand N est masqué). Un effectif masqué dans une classe de seuil (par exemple niveau 2 en 0 ou 1 nuit) veut dire moins de 10 RSS : le seuil n'est alors pas réfuté au sens de la requête, à lire avec le claim.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : quand les cases masquées d'une mesure, d'un type et d'un niveau totalisent de 1 à 9, la plus grande case du groupe sort aussi en « masqué ». Aucune ligne de total.
WITH r AS (
  SELECT SUBSTR(TRIM(CODE_GHM), 1, 1) AS TYPE_GHM,
         SUBSTR(TRIM(CODE_CMD) || TRIM(CODE_GHM), 6, 1) AS NIVEAU,
         TRUNC(DATE_FIN) - TRUNC(DATE_DEBUT) AS NUITEES,
         DUREE_SEJOUR
  FROM CORA_REC.TB_SYNTH_RSS
  WHERE DATE_FIN >= DATE '2018-01-01' AND DATE_FIN < TRUNC(SYSDATE) + 1
    AND TRIM(CODE_CMD) <> '90'
    AND LENGTH(TRIM(CODE_CMD) || TRIM(CODE_GHM)) = 6
    AND SUBSTR(TRIM(CODE_GHM), 1, 1) IN ('M', 'C')
    AND SUBSTR(TRIM(CODE_CMD) || TRIM(CODE_GHM), 6, 1) IN ('1', '2', '3', '4')
),
c AS (
  SELECT 'NUITEES_DATES' AS MESURE, TYPE_GHM, NIVEAU,
         CASE WHEN NUITEES IS NULL THEN '(vide)' WHEN NUITEES < 0 THEN '<0'
              WHEN NUITEES >= 5 THEN '5+' ELSE TO_CHAR(NUITEES) END AS CLASSE
  FROM r
  UNION ALL
  SELECT 'DUREE_SEJOUR', TYPE_GHM, NIVEAU,
         CASE WHEN DUREE_SEJOUR IS NULL THEN '(vide)' WHEN DUREE_SEJOUR < 0 THEN '<0'
              WHEN DUREE_SEJOUR >= 5 THEN '5+' ELSE TO_CHAR(DUREE_SEJOUR) END
  FROM r
),
g AS (
  SELECT MESURE, TYPE_GHM, NIVEAU, CLASSE, COUNT(*) AS N
  FROM c
  GROUP BY MESURE, TYPE_GHM, NIVEAU, CLASSE
),
m AS (
  SELECT MESURE, TYPE_GHM, NIVEAU, CLASSE, N,
         SUM(N) OVER (PARTITION BY MESURE, TYPE_GHM, NIVEAU) AS TOT,
         SUM(CASE WHEN N < 10 THEN N ELSE 0 END) OVER (PARTITION BY MESURE, TYPE_GHM, NIVEAU) AS CACHE,
         ROW_NUMBER() OVER (PARTITION BY MESURE, TYPE_GHM, NIVEAU ORDER BY N DESC, CLASSE) AS RANG
  FROM g
)
SELECT '20261019-severite-nuitees' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       MESURE, TYPE_GHM, NIVEAU, CLASSE,
       CASE WHEN N < 10 THEN '<10' WHEN CACHE BETWEEN 1 AND 9 AND RANG = 1 THEN 'masqué' ELSE TO_CHAR(N) END AS N,
       CASE WHEN N < 10 OR (CACHE BETWEEN 1 AND 9 AND RANG = 1) THEN NULL ELSE ROUND(100 * N / TOT, 2) END AS PCT_NIVEAU
FROM m
ORDER BY MESURE, TYPE_GHM, NIVEAU, CLASSE;
