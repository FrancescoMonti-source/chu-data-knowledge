-- id: 20261015-morts-foetales-codes
-- system: cora
-- person_data: masked
-- purpose: compter les patients qui portent un code CIM-10 de mort fœtale ou d'issue de grossesse avec enfant mort-né, et mesurer sur leur séjour ce dont le recensement a besoin : âge gestationnel, poids, mode d'entrée N, grossesse multiple, IMG (P96.4), doublons de séjours (étape 5 du plan, #42)
-- Oracle, schéma CORA_REC. Diagnostics de TB_DIAG rattachés à un mouvement (chemin-actes-diags-par-mouvement), datés par le début du mouvement (dater-diagnostic-par-mouvement), de 2018 à 2025 (periode-analyse-cora-2018).
-- Codes cherchés (CIM-10, points retirés, par préfixe) : P95 (mort fœtale de cause non précisée) ; P964 (interruption de la grossesse, fœtus et nouveau-né) ; Z371 (naissance unique, enfant mort-né) ; Z373, Z374, Z376, Z377 (naissances multiples avec au moins un mort-né), regroupés ; O364 (soins maternels pour mort intra-utérine). Libellés à vérifier dans la CIM-10 FR à usage PMSI (atih-cim-10-fr-pmsi-2026) ; leur usage dans le PMSI est à lire dans les textes du plan : ici, on mesure seulement ce que CORA contient.
-- Lignes : SIGNAL × PERIODE (2018-2021, 2022-2025). Unité : le patient (TB_SEJOUR.ID_PATIENT) qui porte le code ; un patient compte une fois par signal et par période. Un même patient peut compter sous plusieurs signaux.
-- Contexte pris sur le dernier séjour du patient qui porte le signal dans la période :
-- N_DP : le code est DP (TYPE_DIAG = 'P') ; N_SA_VIDE, N_SA_MOINS_22, N_SA_22_35, N_SA_36 : plus grande SEM_AMENORHEE des mouvements du séjour, vide ou 0, 1 à 21, 22 à 35, 36 et plus ;
-- N_POIDS : POIDS_RUM > 0 sur un mouvement du séjour ; N_MODE_N : un mouvement du séjour a MODE_ENTREE = 'N' ; N_SORTIE_9 : TB_SEJOUR.MODE_SORTIE = '9' ;
-- N_MULTIPLE : le séjour porte un code de grossesse multiple (P015, O30, Z372 à Z377) ; N_P964 : le séjour porte P964 ; N_RSS : le séjour a un RSS ; N_PLUSIEURS_SEJ : le patient porte le signal dans plus d'un séjour de la période.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N sort en « masqué » dès qu'un complément (N moins une autre colonne) est entre 1 et 9, ou dès qu'une des quatre classes d'âge gestationnel, qui font N à elles quatre, est entre 1 et 9. Aucune ligne de total.
WITH dx AS (
  SELECT d.ID_MVT, TRIM(d.TYPE_DIAG) AS TYPE_DIAG, REPLACE(TRIM(d.CODE_DIAG), '.', '') AS CODE
  FROM CORA_REC.TB_DIAG d
  WHERE REPLACE(TRIM(d.CODE_DIAG), '.', '') LIKE 'P95%'
     OR REPLACE(TRIM(d.CODE_DIAG), '.', '') LIKE 'P964%'
     OR REPLACE(TRIM(d.CODE_DIAG), '.', '') LIKE 'P015%'
     OR REPLACE(TRIM(d.CODE_DIAG), '.', '') LIKE 'Z37%'
     OR REPLACE(TRIM(d.CODE_DIAG), '.', '') LIKE 'O30%'
     OR REPLACE(TRIM(d.CODE_DIAG), '.', '') LIKE 'O364%'
),
dm AS (
  SELECT m.ID_SEJOUR, m.DATE_DEBUT_MVT, dx.TYPE_DIAG, dx.CODE,
         CASE WHEN dx.CODE LIKE 'P95%' THEN 'P95'
              WHEN dx.CODE LIKE 'P964%' THEN 'P964'
              WHEN dx.CODE LIKE 'Z371%' THEN 'Z371'
              WHEN dx.CODE LIKE 'Z373%' OR dx.CODE LIKE 'Z374%' OR dx.CODE LIKE 'Z376%' OR dx.CODE LIKE 'Z377%' THEN 'Z373-Z377'
              WHEN dx.CODE LIKE 'O364%' THEN 'O364'
         END AS SIGNAL
  FROM dx
  JOIN CORA_REC.TB_MVT m ON m.ID_MVT = dx.ID_MVT
),
sj AS (
  SELECT dm.ID_SEJOUR,
         MAX(CASE WHEN dm.CODE LIKE 'P015%' OR dm.CODE LIKE 'O30%' OR dm.CODE LIKE 'Z372%' OR dm.CODE LIKE 'Z373%'
                    OR dm.CODE LIKE 'Z374%' OR dm.CODE LIKE 'Z375%' OR dm.CODE LIKE 'Z376%' OR dm.CODE LIKE 'Z377%' THEN 1 ELSE 0 END) AS MULTIPLE,
         MAX(CASE WHEN dm.CODE LIKE 'P964%' THEN 1 ELSE 0 END) AS P964
  FROM dm
  GROUP BY dm.ID_SEJOUR
),
mv AS (
  SELECT ID_SEJOUR,
         MAX(SEM_AMENORHEE) AS SA_MAX,
         MAX(CASE WHEN POIDS_RUM > 0 THEN 1 ELSE 0 END) AS POIDS,
         MAX(CASE WHEN TRIM(MODE_ENTREE) = 'N' THEN 1 ELSE 0 END) AS MODE_N
  FROM CORA_REC.TB_MVT
  WHERE ID_SEJOUR IN (SELECT ID_SEJOUR FROM dm)
  GROUP BY ID_SEJOUR
),
rss AS (
  SELECT DISTINCT ID_SEJOUR FROM CORA_REC.TB_SYNTH_RSS
),
ps AS (
  SELECT s.ID_PATIENT, dm.SIGNAL, s.ID_SEJOUR,
         CASE WHEN dm.DATE_DEBUT_MVT < DATE '2022-01-01' THEN '2018-2021' ELSE '2022-2025' END AS PERIODE,
         MAX(s.DATE_ENTREE) AS DATE_ENTREE,
         MAX(CASE WHEN dm.TYPE_DIAG = 'P' THEN 1 ELSE 0 END) AS DP
  FROM dm
  JOIN CORA_REC.TB_SEJOUR s ON s.ID_SEJOUR = dm.ID_SEJOUR
  WHERE dm.SIGNAL IS NOT NULL
    AND dm.DATE_DEBUT_MVT >= DATE '2018-01-01'
    AND dm.DATE_DEBUT_MVT < DATE '2026-01-01'
  GROUP BY s.ID_PATIENT, dm.SIGNAL, s.ID_SEJOUR,
           CASE WHEN dm.DATE_DEBUT_MVT < DATE '2022-01-01' THEN '2018-2021' ELSE '2022-2025' END
),
pp AS (
  SELECT ps.ID_PATIENT, ps.SIGNAL, ps.PERIODE,
         COUNT(*) AS NB_SEJ,
         MAX(ps.ID_SEJOUR) KEEP (DENSE_RANK LAST ORDER BY ps.DATE_ENTREE, ps.ID_SEJOUR) AS ID_SEJOUR,
         MAX(ps.DP) KEEP (DENSE_RANK LAST ORDER BY ps.DATE_ENTREE, ps.ID_SEJOUR) AS DP
  FROM ps
  GROUP BY ps.ID_PATIENT, ps.SIGNAL, ps.PERIODE
),
t AS (
  SELECT pp.SIGNAL, pp.PERIODE,
         COUNT(*) AS N,
         SUM(pp.DP) AS C1,
         SUM(CASE WHEN NVL(mv.SA_MAX, 0) <= 0 THEN 1 ELSE 0 END) AS C2,
         SUM(CASE WHEN mv.SA_MAX BETWEEN 1 AND 21 THEN 1 ELSE 0 END) AS C3,
         SUM(CASE WHEN mv.SA_MAX BETWEEN 22 AND 35 THEN 1 ELSE 0 END) AS C4,
         SUM(CASE WHEN mv.SA_MAX >= 36 THEN 1 ELSE 0 END) AS C5,
         SUM(NVL(mv.POIDS, 0)) AS C6,
         SUM(NVL(mv.MODE_N, 0)) AS C7,
         SUM(CASE WHEN TRIM(s.MODE_SORTIE) = '9' THEN 1 ELSE 0 END) AS C8,
         SUM(NVL(sj.MULTIPLE, 0)) AS C9,
         SUM(NVL(sj.P964, 0)) AS C10,
         SUM(CASE WHEN rss.ID_SEJOUR IS NOT NULL THEN 1 ELSE 0 END) AS C11,
         SUM(CASE WHEN pp.NB_SEJ > 1 THEN 1 ELSE 0 END) AS C12
  FROM pp
  JOIN CORA_REC.TB_SEJOUR s ON s.ID_SEJOUR = pp.ID_SEJOUR
  LEFT JOIN mv ON mv.ID_SEJOUR = pp.ID_SEJOUR
  LEFT JOIN sj ON sj.ID_SEJOUR = pp.ID_SEJOUR
  LEFT JOIN rss ON rss.ID_SEJOUR = pp.ID_SEJOUR
  GROUP BY pp.SIGNAL, pp.PERIODE
)
SELECT '20261015-morts-foetales-codes' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       SIGNAL, PERIODE,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C1 BETWEEN 1 AND 9 OR N - C2 BETWEEN 1 AND 9 OR N - C3 BETWEEN 1 AND 9 OR N - C4 BETWEEN 1 AND 9
              OR N - C5 BETWEEN 1 AND 9 OR N - C6 BETWEEN 1 AND 9 OR N - C7 BETWEEN 1 AND 9 OR N - C8 BETWEEN 1 AND 9
              OR N - C9 BETWEEN 1 AND 9 OR N - C10 BETWEEN 1 AND 9 OR N - C11 BETWEEN 1 AND 9 OR N - C12 BETWEEN 1 AND 9
              OR C2 BETWEEN 1 AND 9 OR C3 BETWEEN 1 AND 9 OR C4 BETWEEN 1 AND 9 OR C5 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N,
       CASE WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_DP,
       CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_SA_VIDE,
       CASE WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_SA_MOINS_22,
       CASE WHEN C4 < 10 THEN '<10' ELSE TO_CHAR(C4) END AS N_SA_22_35,
       CASE WHEN C5 < 10 THEN '<10' ELSE TO_CHAR(C5) END AS N_SA_36,
       CASE WHEN C6 < 10 THEN '<10' ELSE TO_CHAR(C6) END AS N_POIDS,
       CASE WHEN C7 < 10 THEN '<10' ELSE TO_CHAR(C7) END AS N_MODE_N,
       CASE WHEN C8 < 10 THEN '<10' ELSE TO_CHAR(C8) END AS N_SORTIE_9,
       CASE WHEN C9 < 10 THEN '<10' ELSE TO_CHAR(C9) END AS N_MULTIPLE,
       CASE WHEN C10 < 10 THEN '<10' ELSE TO_CHAR(C10) END AS N_P964,
       CASE WHEN C11 < 10 THEN '<10' ELSE TO_CHAR(C11) END AS N_RSS,
       CASE WHEN C12 < 10 THEN '<10' ELSE TO_CHAR(C12) END AS N_PLUSIEURS_SEJ
FROM t
ORDER BY SIGNAL, PERIODE;
