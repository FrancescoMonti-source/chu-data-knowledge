-- id: 20261015-naissances-remplissage
-- system: cora
-- person_data: masked
-- purpose: pour les séjours de naissance, mesurer si CORA garde ce qu'il faut pour le recensement des décès périnatals : mode d'entrée N, âge gestationnel, poids, rang de naissance, lien vers la mère (IPP de la mère, séjour de la mère) ; le lien est-il retrouvé dans CORA ? (étape 3 du plan, #42)
-- Oracle, schéma CORA_REC. Séjours entrés de 2018 à 2025 (periode-analyse-cora-2018), par année d'entrée.
-- Séjour de naissance, deux signaux, l'un ou l'autre : la date de naissance du patient (TB_PATIENT.DATE_NAIS) est le jour d'entrée du séjour ; ou un mouvement du séjour a MODE_ENTREE = 'N' (« né dans l'établissement », dictionnaire, TB_MVT).
-- N : séjours ; N_DATE_NAIS_ENTREE, N_MODE_N : chacun des deux signaux ;
-- N_SA : SEM_AMENORHEE > 0 sur un mouvement du séjour ; N_SA_36 : la plus grande valeur est >= 36 ; N_POIDS_RUM : POIDS_RUM > 0 sur un mouvement ; N_POIDS_NAIS : TB_PATIENT.POID_NAISSANCE > 0 ; N_RANG : RANG_NAISSANCE renseigné ;
-- N_IPP_MERE : TB_PATIENT.IPP_MERE renseigné ; N_IPP_MERE_TROUVE : cet IPP est l'IPP_PATIENT d'un patient de CORA ;
-- N_SEJ_MERE : TB_SEJOUR.NO_SEJOUR_DOSSIER_MERE renseigné ; N_SEJ_MERE_TROUVE : ce numéro est le NO_SEJOUR d'un séjour de CORA ;
-- N_RSS : le séjour a un RSS (TB_SYNTH_RSS.ID_SEJOUR, joindre-rss-par-id-sejour) ; N_DECES : TB_SEJOUR.MODE_SORTIE = '9' (mode-sortie-du-sejour).
-- Les dates de naissance ne servent qu'au calcul : la requête ne sort que des effectifs par année.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N sort en « masqué » dès qu'un complément (N moins une autre colonne) est entre 1 et 9 ; une colonne contenue dans une autre (N_SA_36 dans N_SA, N_IPP_MERE_TROUVE dans N_IPP_MERE, N_SEJ_MERE_TROUVE dans N_SEJ_MERE) sort en « masqué » si la différence est entre 1 et 9. Aucune ligne de total.
WITH mv AS (
  SELECT ID_SEJOUR,
         MAX(CASE WHEN TRIM(MODE_ENTREE) = 'N' THEN 1 ELSE 0 END) AS MODE_N,
         MAX(SEM_AMENORHEE) AS SA_MAX,
         MAX(CASE WHEN POIDS_RUM > 0 THEN 1 ELSE 0 END) AS POIDS_RUM
  FROM CORA_REC.TB_MVT
  GROUP BY ID_SEJOUR
),
ipp AS (
  SELECT DISTINCT TRIM(IPP_PATIENT) AS IPP FROM CORA_REC.TB_PATIENT
),
sejn AS (
  SELECT DISTINCT TRIM(NO_SEJOUR) AS NO_SEJ FROM CORA_REC.TB_SEJOUR
),
rss AS (
  SELECT DISTINCT ID_SEJOUR FROM CORA_REC.TB_SYNTH_RSS
),
ne0 AS (
  SELECT s.ID_SEJOUR,
         EXTRACT(YEAR FROM s.DATE_ENTREE) AS ANNEE,
         CASE WHEN TRUNC(p.DATE_NAIS) = TRUNC(s.DATE_ENTREE) THEN 1 ELSE 0 END AS NAIS_ENTREE,
         NVL(mv.MODE_N, 0) AS MODE_N,
         mv.SA_MAX,
         NVL(mv.POIDS_RUM, 0) AS POIDS_RUM,
         CASE WHEN p.POID_NAISSANCE > 0 THEN 1 ELSE 0 END AS POIDS_NAIS,
         CASE WHEN TRIM(p.RANG_NAISSANCE) IS NOT NULL THEN 1 ELSE 0 END AS RANG,
         TRIM(p.IPP_MERE) AS IPP_MERE,
         TRIM(s.NO_SEJOUR_DOSSIER_MERE) AS SEJ_MERE,
         CASE WHEN TRIM(s.MODE_SORTIE) = '9' THEN 1 ELSE 0 END AS DECES
  FROM CORA_REC.TB_SEJOUR s
  JOIN CORA_REC.TB_PATIENT p ON p.ID_PATIENT = s.ID_PATIENT
  LEFT JOIN mv ON mv.ID_SEJOUR = s.ID_SEJOUR
  WHERE s.DATE_ENTREE >= DATE '2018-01-01'
    AND s.DATE_ENTREE < DATE '2026-01-01'
    AND (TRUNC(p.DATE_NAIS) = TRUNC(s.DATE_ENTREE) OR mv.MODE_N = 1)
),
ne AS (
  SELECT ne0.ANNEE, ne0.NAIS_ENTREE, ne0.MODE_N, ne0.SA_MAX, ne0.POIDS_RUM, ne0.POIDS_NAIS, ne0.RANG, ne0.DECES,
         CASE WHEN ne0.IPP_MERE IS NOT NULL THEN 1 ELSE 0 END AS IPP_MERE,
         CASE WHEN ipp.IPP IS NOT NULL THEN 1 ELSE 0 END AS IPP_MERE_TROUVE,
         CASE WHEN ne0.SEJ_MERE IS NOT NULL THEN 1 ELSE 0 END AS SEJ_MERE,
         CASE WHEN sejn.NO_SEJ IS NOT NULL THEN 1 ELSE 0 END AS SEJ_MERE_TROUVE,
         CASE WHEN rss.ID_SEJOUR IS NOT NULL THEN 1 ELSE 0 END AS RSS
  FROM ne0
  LEFT JOIN ipp ON ipp.IPP = ne0.IPP_MERE
  LEFT JOIN sejn ON sejn.NO_SEJ = ne0.SEJ_MERE
  LEFT JOIN rss ON rss.ID_SEJOUR = ne0.ID_SEJOUR
),
t AS (
  SELECT ne.ANNEE,
         COUNT(*) AS N,
         SUM(ne.NAIS_ENTREE) AS C1,
         SUM(ne.MODE_N) AS C2,
         SUM(CASE WHEN ne.SA_MAX > 0 THEN 1 ELSE 0 END) AS C3,
         SUM(CASE WHEN ne.SA_MAX >= 36 THEN 1 ELSE 0 END) AS C4,
         SUM(ne.POIDS_RUM) AS C5,
         SUM(ne.POIDS_NAIS) AS C6,
         SUM(ne.RANG) AS C7,
         SUM(ne.IPP_MERE) AS C8,
         SUM(ne.IPP_MERE_TROUVE) AS C9,
         SUM(ne.SEJ_MERE) AS C10,
         SUM(ne.SEJ_MERE_TROUVE) AS C11,
         SUM(ne.RSS) AS C12,
         SUM(ne.DECES) AS C13
  FROM ne
  GROUP BY ne.ANNEE
)
SELECT '20261015-naissances-remplissage' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C1 BETWEEN 1 AND 9 OR N - C2 BETWEEN 1 AND 9 OR N - C3 BETWEEN 1 AND 9 OR N - C4 BETWEEN 1 AND 9
              OR N - C5 BETWEEN 1 AND 9 OR N - C6 BETWEEN 1 AND 9 OR N - C7 BETWEEN 1 AND 9 OR N - C8 BETWEEN 1 AND 9
              OR N - C9 BETWEEN 1 AND 9 OR N - C10 BETWEEN 1 AND 9 OR N - C11 BETWEEN 1 AND 9 OR N - C12 BETWEEN 1 AND 9
              OR N - C13 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N,
       CASE WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_DATE_NAIS_ENTREE,
       CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_MODE_N,
       CASE WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_SA,
       CASE WHEN C4 < 10 THEN '<10' WHEN C3 - C4 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(C4) END AS N_SA_36,
       CASE WHEN C5 < 10 THEN '<10' ELSE TO_CHAR(C5) END AS N_POIDS_RUM,
       CASE WHEN C6 < 10 THEN '<10' ELSE TO_CHAR(C6) END AS N_POIDS_NAIS,
       CASE WHEN C7 < 10 THEN '<10' ELSE TO_CHAR(C7) END AS N_RANG,
       CASE WHEN C8 < 10 THEN '<10' ELSE TO_CHAR(C8) END AS N_IPP_MERE,
       CASE WHEN C9 < 10 THEN '<10' WHEN C8 - C9 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(C9) END AS N_IPP_MERE_TROUVE,
       CASE WHEN C10 < 10 THEN '<10' ELSE TO_CHAR(C10) END AS N_SEJ_MERE,
       CASE WHEN C11 < 10 THEN '<10' WHEN C10 - C11 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(C11) END AS N_SEJ_MERE_TROUVE,
       CASE WHEN C12 < 10 THEN '<10' ELSE TO_CHAR(C12) END AS N_RSS,
       CASE WHEN C13 < 10 THEN '<10' ELSE TO_CHAR(C13) END AS N_DECES
FROM t
ORDER BY ANNEE;
