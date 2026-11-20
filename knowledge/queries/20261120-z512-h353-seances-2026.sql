-- id: 20261120-z512-h353-seances-2026
-- system: cora
-- person_data: masked
-- purpose: compter les RSS à DP Z51.2 finis de janvier à septembre 2026, par UF, GHM, GHS, place de H35.3 (DR, DAS) et mois, avec leurs séances, leurs jours d'injection intravitréenne (BGLB001) et d'OCT (BZQK001) et leur MONTANT_GHS, pour chiffrer ce qu'ils deviendraient recodés en DP H35.3 + BGLB001 + BZQK001 (étape 2 du plan)
-- Oracle, schéma CORA_REC. RSS de TB_SYNTH_RSS dont DATE_FIN va du 2026-01-01 au 2026-09-30, DP_RETENU LIKE 'Z512%' (code-cim10-sans-point, règle 7 de method/queries.md).
-- Place de H35.3 : DR si DR_RETENU LIKE 'H353%' ; DAS si un diagnostic TB_DIAG de TYPE_DIAG = 'S' et de code LIKE 'H353%' est sur un mouvement du séjour du RSS (chemin-actes-diags-par-mouvement), à n'importe quelle date du séjour.
-- UF : UF d'hébergement des RUM du RSS (uf-du-rum-hebergement) ; « plusieurs » si les RUM ont des UF différentes. Les RSS sans H35.3 sont regroupés en « 5170 » ou « autres UF », pour le contexte.
-- Jours d'acte : couples (séjour, DATE_ACTE) distincts d'un acte CODE_ACTE LIKE 'BGLB001%' (ou 'BZQK001%') sur un mouvement du séjour, daté entre DATE_DEBUT et DATE_FIN du RSS (bornes tronquées au jour).
-- N_PATIENTS : patients distincts ; N_RSS : RSS ; NB_SEANCES : somme de NB_SEANCES (vide compté 0) ; N_JOURS_IVT, N_JOURS_OCT, N_JOURS_IVT_ET_OCT : jours d'acte ; MONTANT_GHS_EUR : somme de MONTANT_GHS arrondie à l'euro (montant-ghs-rss).
-- Masquage : si N_PATIENTS < 10, toute la ligne sort en <10. Dans une ligne visible, un effectif dont l'écart à un autre effectif de la ligne vaut de 1 à 9 sort en « masqué », et un effectif de 1 à 9 sort en <10. Aucune ligne de total : les lignes sont disjointes et aucun autre résultat ne donne de total.
WITH das AS (
  SELECT DISTINCT m.ID_SEJOUR
  FROM CORA_REC.TB_DIAG d
  JOIN CORA_REC.TB_MVT m ON m.ID_MVT = d.ID_MVT
  WHERE d.TYPE_DIAG = 'S' AND d.CODE_DIAG LIKE 'H353%'
),
x AS (
  SELECT r.ID_RSS, r.ID_SEJOUR, s.ID_PATIENT,
         TRUNC(r.DATE_DEBUT) AS D1, TRUNC(r.DATE_FIN) AS D2,
         TO_CHAR(r.DATE_FIN, 'YYYY-MM') AS MOIS,
         TRIM(r.CODE_CMD) || TRIM(r.CODE_GHM) AS GHM,
         NVL(TRIM(r.CODE_GHS), '(vide)') AS GHS,
         NVL(r.NB_SEANCES, 0) AS SEANCES,
         NVL(r.MONTANT_GHS, 0) AS MONTANT,
         CASE WHEN r.DR_RETENU LIKE 'H353%' AND das.ID_SEJOUR IS NOT NULL THEN '3 DR et DAS'
              WHEN r.DR_RETENU LIKE 'H353%' THEN '1 DR'
              WHEN das.ID_SEJOUR IS NOT NULL THEN '2 DAS'
              ELSE '4 sans H353' END AS H353
  FROM CORA_REC.TB_SYNTH_RSS r
  LEFT JOIN CORA_REC.TB_SEJOUR s ON s.ID_SEJOUR = r.ID_SEJOUR
  LEFT JOIN das ON das.ID_SEJOUR = r.ID_SEJOUR
  WHERE r.DATE_FIN >= DATE '2026-01-01' AND r.DATE_FIN < DATE '2026-10-01'
    AND r.DP_RETENU LIKE 'Z512%'
),
uf AS (
  SELECT ru.ID_RSS,
         CASE WHEN MIN(TRIM(u.CODE_UNITE)) = MAX(TRIM(u.CODE_UNITE)) THEN MIN(TRIM(u.CODE_UNITE))
              ELSE 'plusieurs' END AS UF
  FROM CORA_REC.TB_SYNTH_RUM ru
  JOIN CORA_REC.TB_UNITE u ON u.ID_UNITE = ru.ID_UNITE_HEBERG
  WHERE ru.ID_RSS IN (SELECT ID_RSS FROM x)
  GROUP BY ru.ID_RSS
),
actes AS (
  SELECT x.ID_RSS, TRUNC(a.DATE_ACTE) AS JOUR,
         MAX(CASE WHEN a.CODE_ACTE LIKE 'BGLB001%' THEN 1 ELSE 0 END) AS IVT,
         MAX(CASE WHEN a.CODE_ACTE LIKE 'BZQK001%' THEN 1 ELSE 0 END) AS OCT
  FROM x
  JOIN CORA_REC.TB_MVT m ON m.ID_SEJOUR = x.ID_SEJOUR
  JOIN CORA_REC.TB_ACTE a ON a.ID_MVT = m.ID_MVT
  WHERE (a.CODE_ACTE LIKE 'BGLB001%' OR a.CODE_ACTE LIKE 'BZQK001%')
    AND TRUNC(a.DATE_ACTE) BETWEEN x.D1 AND x.D2
  GROUP BY x.ID_RSS, TRUNC(a.DATE_ACTE)
),
j AS (
  SELECT ID_RSS, SUM(IVT) AS J_IVT, SUM(OCT) AS J_OCT, SUM(IVT * OCT) AS J_IO
  FROM actes
  GROUP BY ID_RSS
),
r AS (
  SELECT x.MOIS, x.GHM, x.GHS, x.H353, x.ID_PATIENT, x.SEANCES, x.MONTANT,
         CASE WHEN x.H353 <> '4 sans H353' THEN NVL(uf.UF, '(sans RUM)')
              WHEN uf.UF = '5170' THEN '5170'
              ELSE 'autres UF' END AS UF,
         NVL(j.J_IVT, 0) AS J_IVT, NVL(j.J_OCT, 0) AS J_OCT, NVL(j.J_IO, 0) AS J_IO
  FROM x
  LEFT JOIN uf ON uf.ID_RSS = x.ID_RSS
  LEFT JOIN j ON j.ID_RSS = x.ID_RSS
),
t AS (
  SELECT UF, H353, GHM, GHS, MOIS,
         COUNT(DISTINCT ID_PATIENT) AS P, COUNT(*) AS R, SUM(SEANCES) AS S,
         SUM(J_IVT) AS JI, SUM(J_OCT) AS JO, SUM(J_IO) AS JIO,
         ROUND(SUM(MONTANT)) AS M
  FROM r
  GROUP BY UF, H353, GHM, GHS, MOIS
)
SELECT '20261120-z512-h353-seances-2026' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       UF, H353, GHM, GHS, MOIS,
       CASE WHEN P < 10 THEN '<10' ELSE TO_CHAR(P) END AS N_PATIENTS,
       CASE WHEN P < 10 THEN '<10'
            WHEN R - P BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(R) END AS N_RSS,
       CASE WHEN P < 10 THEN '<10'
            WHEN S BETWEEN 1 AND 9 THEN '<10'
            WHEN ABS(S - R) BETWEEN 1 AND 9 OR ABS(S - P) BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(S) END AS NB_SEANCES,
       CASE WHEN P < 10 THEN '<10'
            WHEN JI BETWEEN 1 AND 9 THEN '<10'
            WHEN ABS(JI - S) BETWEEN 1 AND 9 OR ABS(JI - R) BETWEEN 1 AND 9 OR ABS(JI - P) BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(JI) END AS N_JOURS_IVT,
       CASE WHEN P < 10 THEN '<10'
            WHEN JO BETWEEN 1 AND 9 THEN '<10'
            WHEN ABS(JO - JI) BETWEEN 1 AND 9 OR ABS(JO - S) BETWEEN 1 AND 9 OR ABS(JO - R) BETWEEN 1 AND 9 OR ABS(JO - P) BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(JO) END AS N_JOURS_OCT,
       CASE WHEN P < 10 THEN '<10'
            WHEN JIO BETWEEN 1 AND 9 THEN '<10'
            WHEN ABS(JIO - JI) BETWEEN 1 AND 9 OR ABS(JIO - JO) BETWEEN 1 AND 9 OR ABS(JIO - S) BETWEEN 1 AND 9 OR ABS(JIO - R) BETWEEN 1 AND 9 OR ABS(JIO - P) BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(JIO) END AS N_JOURS_IVT_ET_OCT,
       CASE WHEN P < 10 THEN '<10' ELSE TO_CHAR(M) END AS MONTANT_GHS_EUR
FROM t
ORDER BY UF, H353, GHM, GHS, MOIS;
