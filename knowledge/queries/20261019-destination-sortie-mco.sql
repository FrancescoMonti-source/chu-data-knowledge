-- id: 20261019-destination-sortie-mco
-- system: cora
-- person_data: masked
-- purpose: pour chaque année de sortie, la distribution de CODE_DESTINATION croisée avec MODE_SORTIE pour les séjours MCO (séjours reliés à un RSS) et pour les RSS, pour code-destination-2-est-smr (la destination '2' existe-t-elle, en quelle part, et avec quels modes de sortie ; le code '3' est-il bien rare) et pour la couverture de la destination renseignée (transfert-smr-interne-meme-jour)
-- Oracle 11g, schéma CORA_REC. Deux niveaux. SEJOUR : séjours de TB_SEJOUR sortis du 2018-01-01 à aujourd'hui, par année de DATE_SORTIE, hors préadmissions, ayant au moins un RSS par TB_SYNTH_RSS.ID_SEJOUR (le plus direct, voir joindre-rss-par-id-sejour). RSS : lignes de TB_SYNTH_RSS par année de DATE_FIN, même période. MODE_SORTIE et CODE_DESTINATION lus dans TB_SEJOUR ou dans TB_SYNTH_RSS selon le niveau ; vides en « (vide) ».
-- Colonnes : NIVEAU, ANNEE, MODE_SORTIE, CODE_DESTINATION, N, PCT_ANNEE (part dans le niveau et l'année, vide quand N est masqué).
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : dans chaque niveau, quand les cases masquées d'une année totalisent de 1 à 9, la plus grande case de l'année sort aussi en « masqué ». Aucune ligne de total.
WITH c AS (
  SELECT 'SEJOUR' AS NIVEAU, EXTRACT(YEAR FROM s.DATE_SORTIE) AS ANNEE,
         NVL(TRIM(s.MODE_SORTIE), '(vide)') AS MODE_SORTIE,
         NVL(TRIM(s.CODE_DESTINATION), '(vide)') AS CODE_DESTINATION,
         COUNT(*) AS N
  FROM CORA_REC.TB_SEJOUR s
  WHERE s.DATE_SORTIE >= DATE '2018-01-01' AND s.DATE_SORTIE < TRUNC(SYSDATE) + 1
    AND NVL(s.STATUT_PROG, '-') <> 'P'
    AND EXISTS (SELECT 1 FROM CORA_REC.TB_SYNTH_RSS r WHERE r.ID_SEJOUR = s.ID_SEJOUR)
  GROUP BY EXTRACT(YEAR FROM s.DATE_SORTIE), NVL(TRIM(s.MODE_SORTIE), '(vide)'), NVL(TRIM(s.CODE_DESTINATION), '(vide)')
  UNION ALL
  SELECT 'RSS', EXTRACT(YEAR FROM r.DATE_FIN),
         NVL(TRIM(TO_CHAR(r.MODE_SORTIE)), '(vide)'),
         NVL(TRIM(TO_CHAR(r.CODE_DESTINATION)), '(vide)'),
         COUNT(*)
  FROM CORA_REC.TB_SYNTH_RSS r
  WHERE r.DATE_FIN >= DATE '2018-01-01' AND r.DATE_FIN < TRUNC(SYSDATE) + 1
  GROUP BY EXTRACT(YEAR FROM r.DATE_FIN), NVL(TRIM(TO_CHAR(r.MODE_SORTIE)), '(vide)'), NVL(TRIM(TO_CHAR(r.CODE_DESTINATION)), '(vide)')
),
m AS (
  SELECT NIVEAU, ANNEE, MODE_SORTIE, CODE_DESTINATION, N,
         SUM(N) OVER (PARTITION BY NIVEAU, ANNEE) AS TOT,
         SUM(CASE WHEN N < 10 THEN N ELSE 0 END) OVER (PARTITION BY NIVEAU, ANNEE) AS CACHE,
         ROW_NUMBER() OVER (PARTITION BY NIVEAU, ANNEE ORDER BY N DESC, MODE_SORTIE, CODE_DESTINATION) AS RANG
  FROM c
)
SELECT '20261019-destination-sortie-mco' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       NIVEAU, ANNEE, MODE_SORTIE, CODE_DESTINATION,
       CASE WHEN N < 10 THEN '<10' WHEN CACHE BETWEEN 1 AND 9 AND RANG = 1 THEN 'masqué' ELSE TO_CHAR(N) END AS N,
       CASE WHEN N < 10 OR (CACHE BETWEEN 1 AND 9 AND RANG = 1) THEN NULL ELSE ROUND(100 * N / TOT, 2) END AS PCT_ANNEE
FROM m
ORDER BY NIVEAU, ANNEE, MODE_SORTIE, CODE_DESTINATION;
