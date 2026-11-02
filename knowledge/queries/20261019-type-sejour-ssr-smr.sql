-- id: 20261019-type-sejour-ssr-smr
-- system: cora
-- person_data: masked
-- purpose: pour chaque année d'entrée, les valeurs de TB_SEJOUR.TYPE_SEJOUR et, pour les séjours 'SSR' ou 'SMR', les unités d'entrée et leur CODE_AUTORISATION_SSR (TB_UNITE), pour tester type-sejour-smr-et-ssr (réfuté si une seule des deux valeurs sert pour tous les séjours SMR de chaque année 2018-2026, l'autre étant absente ou sous 0,5 %) et pour savoir si CODE_AUTORISATION_SSR repère les unités de SMR comme TYPE_SEJOUR (alors le filtre sur l'unité peut contrôler le filtre sur le type)
-- Oracle 11g, schéma CORA_REC. Séjours entrés du 2018-01-01 à aujourd'hui, par année de DATE_ENTREE, hors préadmissions (STATUT_PROG = 'P'). UF d'entrée : TB_SEJOUR.UF_ENTREE rapprochée de TB_UNITE.CODE_UNITE (une ligne par code, MAX de CODE_AUTORISATION_SSR).
-- Deux niveaux. TYPE : tous les séjours, VALEUR_1 = TYPE_SEJOUR, VALEUR_2 = autorisation de l'UF d'entrée (« renseignée » ou « vide »). UNITES : séjours de TYPE_SEJOUR 'SSR' ou 'SMR', VALEUR_1 = TYPE_SEJOUR, VALEUR_2 = valeur de CODE_AUTORISATION_SSR de l'UF d'entrée ('(vide)' si absente). N : séjours. UF_DISTINCTES : nombre d'UF d'entrée différentes (des unités, pas des personnes ; vide au niveau TYPE).
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : dans chaque niveau, quand les cases masquées d'une année totalisent de 1 à 9, la plus grande case de l'année sort aussi en « masqué ». Aucune ligne de total.
WITH u AS (
  SELECT TRIM(CODE_UNITE) AS UF, MAX(TRIM(CODE_AUTORISATION_SSR)) AS AUT
  FROM CORA_REC.TB_UNITE
  GROUP BY TRIM(CODE_UNITE)
),
s AS (
  SELECT EXTRACT(YEAR FROM se.DATE_ENTREE) AS ANNEE,
         NVL(TRIM(se.TYPE_SEJOUR), '(vide)') AS TYPE_SEJOUR,
         TRIM(se.UF_ENTREE) AS UF,
         u.AUT
  FROM CORA_REC.TB_SEJOUR se
  LEFT JOIN u ON u.UF = TRIM(se.UF_ENTREE)
  WHERE se.DATE_ENTREE >= DATE '2018-01-01' AND se.DATE_ENTREE < TRUNC(SYSDATE) + 1
    AND NVL(se.STATUT_PROG, '-') <> 'P'
),
c AS (
  SELECT 'TYPE' AS NIVEAU, ANNEE, TYPE_SEJOUR AS VALEUR_1,
         CASE WHEN AUT IS NULL THEN 'vide' ELSE 'renseignée' END AS VALEUR_2,
         COUNT(*) AS N, TO_NUMBER(NULL) AS UFD
  FROM s
  GROUP BY ANNEE, TYPE_SEJOUR, CASE WHEN AUT IS NULL THEN 'vide' ELSE 'renseignée' END
  UNION ALL
  SELECT 'UNITES', ANNEE, TYPE_SEJOUR, NVL(AUT, '(vide)'), COUNT(*), COUNT(DISTINCT UF)
  FROM s
  WHERE TYPE_SEJOUR IN ('SSR', 'SMR')
  GROUP BY ANNEE, TYPE_SEJOUR, NVL(AUT, '(vide)')
),
m AS (
  SELECT NIVEAU, ANNEE, VALEUR_1, VALEUR_2, N, UFD,
         SUM(CASE WHEN N < 10 THEN N ELSE 0 END) OVER (PARTITION BY NIVEAU, ANNEE) AS CACHE,
         ROW_NUMBER() OVER (PARTITION BY NIVEAU, ANNEE ORDER BY N DESC, VALEUR_1, VALEUR_2) AS RANG
  FROM c
)
SELECT '20261019-type-sejour-ssr-smr' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       NIVEAU, ANNEE, VALEUR_1, VALEUR_2,
       CASE WHEN N < 10 THEN '<10' WHEN CACHE BETWEEN 1 AND 9 AND RANG = 1 THEN 'masqué' ELSE TO_CHAR(N) END AS N,
       UFD AS UF_DISTINCTES
FROM m
ORDER BY NIVEAU, ANNEE, VALEUR_1, VALEUR_2;
