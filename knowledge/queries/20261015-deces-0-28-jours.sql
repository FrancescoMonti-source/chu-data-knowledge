-- id: 20261015-deces-0-28-jours
-- system: cora
-- person_data: masked
-- purpose: compter les enfants nés vivants décédés de J0 à J28 que CORA laisse voir, et mesurer pour eux ce dont le recensement a besoin : jour du décès, séjour de naissance ou réhospitalisation, entrée par transfert, âge gestationnel, date de décès du patient, lien vers la mère, P95 codé (mort-né ?) (étape 4 du plan, #42)
-- Oracle, schéma CORA_REC. Séjours sortis de 2018 à 2025 (periode-analyse-cora-2018) avec TB_SEJOUR.MODE_SORTIE = '9' (mode-sortie-du-sejour).
-- Âge au décès en jours : TRUNC(DATE_SORTIE) - TRUNC(DATE_NAIS), de 0 à 28 ; J0 est le jour de naissance. J28 est hors du recensement : il est compté à part pour voir la borne.
-- Unité : l'enfant (ID_PATIENT du séjour). S'il a plusieurs séjours avec un décès, on garde le dernier sorti.
-- Lignes : PERIODE (2018-2021, 2022-2025) × CLASSE (J0, J1-J6, J7-J27, J28). Plus une ligne par période, CLASSE « sans sortie 9 » : enfants dont TB_PATIENT.DATE_DECES tombe de J0 à J28, en 2018-2025, sans aucun séjour avec MODE_SORTIE = '9'.
-- N : enfants ; N_PLUSIEURS_DECES : plus d'un séjour avec MODE_SORTIE = '9' ; N_SEJ_NAISSANCE : le séjour du décès commence le jour de la naissance ;
-- N_ENTREE_7 : TB_SEJOUR.MODE_ENTREE = '7' (transfert) ; N_MODE_N : un mouvement du séjour a MODE_ENTREE = 'N' ;
-- N_SA_36 : la plus grande SEM_AMENORHEE des mouvements de l'enfant est >= 36 ; N_SA_VIDE : aucune SEM_AMENORHEE > 0 ;
-- N_DATE_DECES : TB_PATIENT.DATE_DECES renseignée ; N_DECES_EGAL_SORTIE : même jour que la sortie ; N_LIEN_MERE : IPP_MERE ou NO_SEJOUR_DOSSIER_MERE renseigné ;
-- N_RSS : le séjour a un RSS (joindre-rss-par-id-sejour) ; N_P95 : un diagnostic P95 sur un mouvement de l'enfant (chemin-actes-diags-par-mouvement).
-- Pour la ligne « sans sortie 9 », N_SEJ_NAISSANCE dit si l'enfant a un séjour qui commence le jour de sa naissance ; N_PLUSIEURS_DECES, N_ENTREE_7, N_MODE_N, N_DECES_EGAL_SORTIE, N_RSS sont vides.
-- Les dates ne servent qu'au calcul : la requête ne sort que des effectifs.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N sort en « masqué » dès qu'un complément (N moins une autre colonne, ou N moins N_SA_36 et N_SA_VIDE) est entre 1 et 9 ; N_DECES_EGAL_SORTIE sort en « masqué » si N_DATE_DECES moins lui est entre 1 et 9. Aucune ligne de total.
WITH mv AS (
  SELECT ID_SEJOUR,
         MAX(CASE WHEN TRIM(MODE_ENTREE) = 'N' THEN 1 ELSE 0 END) AS MODE_N
  FROM CORA_REC.TB_MVT
  GROUP BY ID_SEJOUR
),
sa AS (
  SELECT s.ID_PATIENT, MAX(m.SEM_AMENORHEE) AS SA_MAX
  FROM CORA_REC.TB_MVT m
  JOIN CORA_REC.TB_SEJOUR s ON s.ID_SEJOUR = m.ID_SEJOUR
  GROUP BY s.ID_PATIENT
),
p95 AS (
  SELECT DISTINCT s.ID_PATIENT
  FROM CORA_REC.TB_DIAG d
  JOIN CORA_REC.TB_MVT m ON m.ID_MVT = d.ID_MVT
  JOIN CORA_REC.TB_SEJOUR s ON s.ID_SEJOUR = m.ID_SEJOUR
  WHERE REPLACE(TRIM(d.CODE_DIAG), '.', '') LIKE 'P95%'
),
rss AS (
  SELECT DISTINCT ID_SEJOUR FROM CORA_REC.TB_SYNTH_RSS
),
nais AS (
  SELECT DISTINCT s.ID_PATIENT
  FROM CORA_REC.TB_SEJOUR s
  JOIN CORA_REC.TB_PATIENT p ON p.ID_PATIENT = s.ID_PATIENT
  WHERE TRUNC(s.DATE_ENTREE) = TRUNC(p.DATE_NAIS)
),
dc0 AS (
  SELECT s.ID_PATIENT, s.ID_SEJOUR, s.DATE_SORTIE,
         TRUNC(s.DATE_SORTIE) - TRUNC(p.DATE_NAIS) AS AGE_J,
         CASE WHEN TRUNC(s.DATE_ENTREE) = TRUNC(p.DATE_NAIS) THEN 1 ELSE 0 END AS SEJ_NAISSANCE,
         CASE WHEN TRIM(s.MODE_ENTREE) = '7' THEN 1 ELSE 0 END AS ENTREE_7,
         NVL(mv.MODE_N, 0) AS MODE_N,
         CASE WHEN p.DATE_DECES IS NOT NULL THEN 1 ELSE 0 END AS DATE_DECES,
         CASE WHEN TRUNC(p.DATE_DECES) = TRUNC(s.DATE_SORTIE) THEN 1 ELSE 0 END AS DECES_EGAL,
         CASE WHEN TRIM(p.IPP_MERE) IS NOT NULL OR TRIM(s.NO_SEJOUR_DOSSIER_MERE) IS NOT NULL THEN 1 ELSE 0 END AS LIEN_MERE,
         CASE WHEN rss.ID_SEJOUR IS NOT NULL THEN 1 ELSE 0 END AS RSS
  FROM CORA_REC.TB_SEJOUR s
  JOIN CORA_REC.TB_PATIENT p ON p.ID_PATIENT = s.ID_PATIENT
  LEFT JOIN mv ON mv.ID_SEJOUR = s.ID_SEJOUR
  LEFT JOIN rss ON rss.ID_SEJOUR = s.ID_SEJOUR
  WHERE TRIM(s.MODE_SORTIE) = '9'
    AND s.DATE_SORTIE >= DATE '2018-01-01'
    AND s.DATE_SORTIE < DATE '2026-01-01'
    AND TRUNC(s.DATE_SORTIE) - TRUNC(p.DATE_NAIS) BETWEEN 0 AND 28
),
dc AS (
  SELECT ID_PATIENT,
         COUNT(*) AS NB_SEJ,
         MAX(DATE_SORTIE) AS DATE_SORTIE,
         MAX(AGE_J) KEEP (DENSE_RANK LAST ORDER BY DATE_SORTIE, ID_SEJOUR) AS AGE_J,
         MAX(SEJ_NAISSANCE) KEEP (DENSE_RANK LAST ORDER BY DATE_SORTIE, ID_SEJOUR) AS SEJ_NAISSANCE,
         MAX(ENTREE_7) KEEP (DENSE_RANK LAST ORDER BY DATE_SORTIE, ID_SEJOUR) AS ENTREE_7,
         MAX(MODE_N) KEEP (DENSE_RANK LAST ORDER BY DATE_SORTIE, ID_SEJOUR) AS MODE_N,
         MAX(DATE_DECES) AS DATE_DECES,
         MAX(DECES_EGAL) KEEP (DENSE_RANK LAST ORDER BY DATE_SORTIE, ID_SEJOUR) AS DECES_EGAL,
         MAX(LIEN_MERE) AS LIEN_MERE,
         MAX(RSS) KEEP (DENSE_RANK LAST ORDER BY DATE_SORTIE, ID_SEJOUR) AS RSS
  FROM dc0
  GROUP BY ID_PATIENT
),
sans9 AS (
  SELECT p.ID_PATIENT,
         CASE WHEN p.DATE_DECES < DATE '2022-01-01' THEN '2018-2021' ELSE '2022-2025' END AS PERIODE,
         CASE WHEN nais.ID_PATIENT IS NOT NULL THEN 1 ELSE 0 END AS SEJ_NAISSANCE,
         CASE WHEN TRIM(p.IPP_MERE) IS NOT NULL THEN 1 ELSE 0 END AS LIEN_MERE
  FROM CORA_REC.TB_PATIENT p
  LEFT JOIN nais ON nais.ID_PATIENT = p.ID_PATIENT
  WHERE p.DATE_DECES >= DATE '2018-01-01'
    AND p.DATE_DECES < DATE '2026-01-01'
    AND TRUNC(p.DATE_DECES) - TRUNC(p.DATE_NAIS) BETWEEN 0 AND 28
    AND NOT EXISTS (SELECT 1 FROM CORA_REC.TB_SEJOUR s
                    WHERE s.ID_PATIENT = p.ID_PATIENT AND TRIM(s.MODE_SORTIE) = '9')
),
t AS (
  SELECT CASE WHEN dc.DATE_SORTIE < DATE '2022-01-01' THEN '2018-2021' ELSE '2022-2025' END AS PERIODE,
         CASE WHEN dc.AGE_J = 0 THEN 'J0'
              WHEN dc.AGE_J <= 6 THEN 'J1-J6'
              WHEN dc.AGE_J <= 27 THEN 'J7-J27'
              ELSE 'J28' END AS CLASSE,
         COUNT(*) AS N,
         SUM(CASE WHEN dc.NB_SEJ > 1 THEN 1 ELSE 0 END) AS C1,
         SUM(dc.SEJ_NAISSANCE) AS C2,
         SUM(dc.ENTREE_7) AS C3,
         SUM(dc.MODE_N) AS C4,
         SUM(CASE WHEN sa.SA_MAX >= 36 THEN 1 ELSE 0 END) AS C5,
         SUM(CASE WHEN NVL(sa.SA_MAX, 0) <= 0 THEN 1 ELSE 0 END) AS C6,
         SUM(dc.DATE_DECES) AS C7,
         SUM(dc.DECES_EGAL) AS C8,
         SUM(dc.LIEN_MERE) AS C9,
         SUM(dc.RSS) AS C10,
         SUM(CASE WHEN p95.ID_PATIENT IS NOT NULL THEN 1 ELSE 0 END) AS C11
  FROM dc
  LEFT JOIN sa ON sa.ID_PATIENT = dc.ID_PATIENT
  LEFT JOIN p95 ON p95.ID_PATIENT = dc.ID_PATIENT
  GROUP BY CASE WHEN dc.DATE_SORTIE < DATE '2022-01-01' THEN '2018-2021' ELSE '2022-2025' END,
           CASE WHEN dc.AGE_J = 0 THEN 'J0'
                WHEN dc.AGE_J <= 6 THEN 'J1-J6'
                WHEN dc.AGE_J <= 27 THEN 'J7-J27'
                ELSE 'J28' END
  UNION ALL
  SELECT x.PERIODE, 'sans sortie 9',
         COUNT(*),
         NULL,
         SUM(x.SEJ_NAISSANCE),
         NULL,
         NULL,
         SUM(CASE WHEN sa.SA_MAX >= 36 THEN 1 ELSE 0 END),
         SUM(CASE WHEN NVL(sa.SA_MAX, 0) <= 0 THEN 1 ELSE 0 END),
         COUNT(*),
         NULL,
         SUM(x.LIEN_MERE),
         NULL,
         SUM(CASE WHEN p95.ID_PATIENT IS NOT NULL THEN 1 ELSE 0 END)
  FROM sans9 x
  LEFT JOIN sa ON sa.ID_PATIENT = x.ID_PATIENT
  LEFT JOIN p95 ON p95.ID_PATIENT = x.ID_PATIENT
  GROUP BY x.PERIODE
)
SELECT '20261015-deces-0-28-jours' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       PERIODE, CLASSE,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C1 BETWEEN 1 AND 9 OR N - C2 BETWEEN 1 AND 9 OR N - C3 BETWEEN 1 AND 9 OR N - C4 BETWEEN 1 AND 9
              OR N - C5 BETWEEN 1 AND 9 OR N - C6 BETWEEN 1 AND 9 OR N - C7 BETWEEN 1 AND 9 OR N - C8 BETWEEN 1 AND 9
              OR N - C9 BETWEEN 1 AND 9 OR N - C10 BETWEEN 1 AND 9 OR N - C11 BETWEEN 1 AND 9
              OR N - C5 - C6 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N,
       CASE WHEN C1 IS NULL THEN NULL WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_PLUSIEURS_DECES,
       CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_SEJ_NAISSANCE,
       CASE WHEN C3 IS NULL THEN NULL WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_ENTREE_7,
       CASE WHEN C4 IS NULL THEN NULL WHEN C4 < 10 THEN '<10' ELSE TO_CHAR(C4) END AS N_MODE_N,
       CASE WHEN C5 < 10 THEN '<10' ELSE TO_CHAR(C5) END AS N_SA_36,
       CASE WHEN C6 < 10 THEN '<10' ELSE TO_CHAR(C6) END AS N_SA_VIDE,
       CASE WHEN C7 < 10 THEN '<10' ELSE TO_CHAR(C7) END AS N_DATE_DECES,
       CASE WHEN C8 IS NULL THEN NULL WHEN C8 < 10 THEN '<10' WHEN C7 - C8 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(C8) END AS N_DECES_EGAL_SORTIE,
       CASE WHEN C9 < 10 THEN '<10' ELSE TO_CHAR(C9) END AS N_LIEN_MERE,
       CASE WHEN C10 IS NULL THEN NULL WHEN C10 < 10 THEN '<10' ELSE TO_CHAR(C10) END AS N_RSS,
       CASE WHEN C11 < 10 THEN '<10' ELSE TO_CHAR(C11) END AS N_P95
FROM t
ORDER BY PERIODE, CLASSE;
