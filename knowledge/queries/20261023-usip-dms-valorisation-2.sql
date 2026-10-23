-- id: 20261023-usip-dms-valorisation-2
-- system: cora
-- person_data: masked
-- purpose: mesurer, par période et selon le passage en soins intensifs post-opératoires, la durée et la valorisation de trois populations de RSS : ceux qui passent par l'USIP (UM 6281) ou par l'UF 6284 qui la précédait (étape 4 du plan), les endartériectomies carotidiennes (étape 5) et la chirurgie digestive (étape 6)
-- Version allégée de 20261023-usip-dms-valorisation, trop lente : les RSS candidats sont d'abord pris par les RUM des douze UM et par les actes des neuf codes (petits ensembles, matérialisés), puis seulement ces RSS sont lus dans TB_SYNTH_RSS, TB_SYNTH_RUM et TB_SEJOUR. Mêmes définitions et même sortie.
-- Oracle, schéma CORA_REC. Unité : le RSS (TB_SYNTH_RSS) d'hospitalisation complète (au moins une nuit), groupé (CODE_GHM renseigné, CMD ni 90 ni 28) (type-prise-en-charge-mco). PERIODE d'après DATE_FIN du RSS, d'octobre à août : 2022-10 à 2023-08, 2023-10 à 2024-08, 2024-10 à 2025-08, 2025-10 à 2026-08 ; les mois de septembre sont écartés (choix de l'enquête usip-parcours).
-- POPULATION (un RSS peut être dans plusieurs) : USI = un RUM dans l'UM 6281 ou 6284 ; CAROTIDE = un acte EBFA002, EBFA003, EBFA006, EBFA008, EBFA009, EBFA010, EBFA012, EBFA015 ou EBFA016 du séjour du RSS (TB_ACTE.ID_SEJOUR), daté entre le début et la fin du RSS ; CHIR_DIG = un RUM dans l'UM 6310, 6311, 6320, 6330 ou 6340 (UM CGCD) et un GHM de type C. PASSAGE, dans cet ordre : '6281 USIP', '6284 SI', 'réa chir' (un RUM dans l'UM 6282, 6283, 6285, 6288 ou 6289), 'aucun'. UM par TB_SYNTH_RUM.ID_UNITE_MEDICALE → TB_UNITE_MEDICALE.CODE_UNITE_MED (20261023-usip-uf-structure).
-- Durées : NUITEES = TRUNC(DATE_FIN) − TRUNC(DATE_DEBUT) du RSS ; JOURNEES = NUITEES + 1 (duree-sejour-journees-ou-nuitees). HEURES = HEURE_SORTIE − HEURE_ENTREE du séjour (date-et-heure-dans-deux-colonnes), seulement quand le RSS couvre tout le séjour (mêmes jours d'entrée et de sortie) et que la sortie n'est pas à minuit pile ; N_HEURES_EXCLUS : RSS sans durée en heures (sortie à minuit, séjour à plusieurs RSS, heure absente).
-- Valorisation (montant-ghs-rss) : MONTANT_GHS_MOY sur les RSS hors GHS 9999 ; PRIX_2026_MOY : tarif de base du GHM (PRIX de PMSI_LIB_GHS_TARIF, GHS = CODE_CMD || CODE_GHM, ligne valide au 2026-06-30, plus petit PRIX si le GHM a plusieurs GHS) pour comparer à tarif constant (tarif-ghs-jointure-couverture), sur les RSS qui le trouvent ; N_SANS_PRIX_2026 : RSS dont le GHM n'a pas de ligne valide à cette date. Moyennes par RSS de MNT_TOTAL_SUPPLEMENT, MNT_JOUR_USIP, MNT_JOUR_SOINS_INT, MNT_JOUR_SURV_CONT et MONTANT_REA (vide compté 0), et des jours NB_JOUR_SOINS_INT et NB_JOUR_SURV_CONT. N_DECES : MODE_SORTIE 9.
-- Masquage : chaque effectif < 10 sort en <10 ; moyennes et médianes vides quand N_RSS < 10. Suppression secondaire (règle 4) : N_RSS sort en « masqué » quand N_RSS moins N_GHS_9999, N_SANS_PRIX_2026 ou N_HEURES_EXCLUS vaut de 1 à 9. Aucune ligne de total.
WITH um_u AS (
  SELECT /*+ MATERIALIZE */ ID_UNITE_MED, TRIM(CODE_UNITE_MED) AS CODE_UM
  FROM CORA_REC.TB_UNITE_MEDICALE
  WHERE TRIM(CODE_UNITE_MED) IN ('6281', '6284', '6282', '6283', '6285', '6288', '6289', '6310', '6311', '6320', '6330', '6340')
),
fl AS (
  SELECT /*+ MATERIALIZE */ ru.ID_RSS,
         MAX(CASE WHEN u.CODE_UM = '6281' THEN 1 ELSE 0 END) AS A_6281,
         MAX(CASE WHEN u.CODE_UM = '6284' THEN 1 ELSE 0 END) AS A_6284,
         MAX(CASE WHEN u.CODE_UM IN ('6282', '6283', '6285', '6288', '6289') THEN 1 ELSE 0 END) AS A_REA,
         MAX(CASE WHEN u.CODE_UM IN ('6310', '6311', '6320', '6330', '6340') THEN 1 ELSE 0 END) AS A_DIG
  FROM CORA_REC.TB_SYNTH_RUM ru
  JOIN um_u u ON u.ID_UNITE_MED = ru.ID_UNITE_MEDICALE
  WHERE ru.DATE_FIN_RUM >= DATE '2022-06-01' AND ru.DATE_FIN_RUM < DATE '2026-09-01'
  GROUP BY ru.ID_RSS
),
act AS (
  SELECT /*+ MATERIALIZE */ DISTINCT a.ID_SEJOUR, TRUNC(a.DATE_ACTE) AS JOUR
  FROM CORA_REC.TB_ACTE a
  WHERE a.DATE_ACTE >= DATE '2022-06-01' AND a.DATE_ACTE < DATE '2026-09-01'
    AND TRIM(a.CODE_ACTE) IN ('EBFA002', 'EBFA003', 'EBFA006', 'EBFA008', 'EBFA009',
                              'EBFA010', 'EBFA012', 'EBFA015', 'EBFA016')
),
cand AS (
  SELECT /*+ MATERIALIZE */ ID_RSS FROM fl
  UNION
  SELECT r2.ID_RSS FROM CORA_REC.TB_SYNTH_RSS r2 JOIN (SELECT DISTINCT ID_SEJOUR FROM act) x ON x.ID_SEJOUR = r2.ID_SEJOUR
),
rss AS (
  SELECT /*+ MATERIALIZE */ r.ID_RSS, r.ID_SEJOUR, r.DATE_DEBUT, r.DATE_FIN,
         TRIM(r.CODE_CMD) || TRIM(r.CODE_GHM) AS GHM6,
         SUBSTR(TRIM(r.CODE_GHM), 1, 1) AS TYPE_GHM,
         TRIM(r.CODE_GHS) AS GHS, r.MONTANT_GHS, TRIM(r.MODE_SORTIE) AS MS,
         NVL(r.MNT_TOTAL_SUPPLEMENT, 0) AS SUPPL, NVL(r.MNT_JOUR_USIP, 0) AS USIP,
         NVL(r.MNT_JOUR_SOINS_INT, 0) AS SI, NVL(r.MNT_JOUR_SURV_CONT, 0) AS SC,
         NVL(r.MONTANT_REA, 0) AS REA,
         NVL(r.NB_JOUR_SOINS_INT, 0) AS J_SI, NVL(r.NB_JOUR_SURV_CONT, 0) AS J_SC,
         TRUNC(r.DATE_FIN) - TRUNC(r.DATE_DEBUT) AS NUITEES,
         CASE WHEN r.DATE_FIN >= DATE '2022-10-01' AND r.DATE_FIN < DATE '2023-09-01' THEN '2022-10 à 2023-08'
              WHEN r.DATE_FIN >= DATE '2023-10-01' AND r.DATE_FIN < DATE '2024-09-01' THEN '2023-10 à 2024-08'
              WHEN r.DATE_FIN >= DATE '2024-10-01' AND r.DATE_FIN < DATE '2025-09-01' THEN '2024-10 à 2025-08'
              WHEN r.DATE_FIN >= DATE '2025-10-01' AND r.DATE_FIN < DATE '2026-09-01' THEN '2025-10 à 2026-08'
         END AS PERIODE,
         CASE WHEN EXISTS (SELECT 1 FROM act WHERE act.ID_SEJOUR = r.ID_SEJOUR
                           AND act.JOUR BETWEEN TRUNC(r.DATE_DEBUT) AND TRUNC(r.DATE_FIN)) THEN 1 ELSE 0 END AS EST_CAR
  FROM CORA_REC.TB_SYNTH_RSS r
  JOIN cand ON cand.ID_RSS = r.ID_RSS
  WHERE r.DATE_FIN >= DATE '2022-10-01' AND r.DATE_FIN < DATE '2026-09-01'
    AND EXTRACT(MONTH FROM r.DATE_FIN) <> 9
    AND TRIM(r.CODE_GHM) IS NOT NULL AND TRIM(r.CODE_CMD) NOT IN ('90', '28')
    AND TRUNC(r.DATE_FIN) - TRUNC(r.DATE_DEBUT) >= 1
),
tarif AS (
  SELECT /*+ MATERIALIZE */ TRIM(t.GHS) AS GHM6, MIN(t.PRIX) AS PRIX
  FROM CORA_REC.PMSI_LIB_GHS_TARIF t
  WHERE t.DATE_DEBUT <= DATE '2026-06-30' AND (t.DATE_FIN IS NULL OR t.DATE_FIN > DATE '2026-06-30')
  GROUP BY TRIM(t.GHS)
),
b AS (
  SELECT rss.PERIODE, rss.GHS, rss.MONTANT_GHS, rss.MS, rss.NUITEES,
         rss.SUPPL, rss.USIP, rss.SI, rss.SC, rss.REA, rss.J_SI, rss.J_SC,
         CASE WHEN fl.A_6281 = 1 THEN '6281 USIP' WHEN fl.A_6284 = 1 THEN '6284 SI'
              WHEN fl.A_REA = 1 THEN 'réa chir' ELSE 'aucun' END AS PASSAGE,
         NVL(fl.A_6281, 0) + NVL(fl.A_6284, 0) AS EST_USI,
         CASE WHEN fl.A_DIG = 1 AND rss.TYPE_GHM = 'C' THEN 1 ELSE 0 END AS EST_DIG,
         rss.EST_CAR,
         tarif.PRIX AS PRIX_2026,
         CASE WHEN TRUNC(s.DATE_ENTREE) = TRUNC(rss.DATE_DEBUT) AND TRUNC(s.DATE_SORTIE) = TRUNC(rss.DATE_FIN)
                   AND s.HEURE_SORTIE IS NOT NULL AND s.HEURE_ENTREE IS NOT NULL
                   AND s.HEURE_SORTIE <> TRUNC(s.HEURE_SORTIE)
              THEN (s.HEURE_SORTIE - s.HEURE_ENTREE) * 24 END AS HEURES
  FROM rss
  LEFT JOIN fl ON fl.ID_RSS = rss.ID_RSS
  LEFT JOIN tarif ON tarif.GHM6 = rss.GHM6
  LEFT JOIN CORA_REC.TB_SEJOUR s ON s.ID_SEJOUR = rss.ID_SEJOUR
  WHERE fl.A_6281 = 1 OR fl.A_6284 = 1 OR (fl.A_DIG = 1 AND rss.TYPE_GHM = 'C') OR rss.EST_CAR = 1
),
l AS (
  SELECT 'USI' AS POPULATION, PERIODE, PASSAGE, GHS, MONTANT_GHS, MS, NUITEES, SUPPL, USIP, SI, SC, REA, J_SI, J_SC, PRIX_2026, HEURES FROM b WHERE EST_USI > 0
  UNION ALL
  SELECT 'CAROTIDE', PERIODE, PASSAGE, GHS, MONTANT_GHS, MS, NUITEES, SUPPL, USIP, SI, SC, REA, J_SI, J_SC, PRIX_2026, HEURES FROM b WHERE EST_CAR = 1
  UNION ALL
  SELECT 'CHIR_DIG', PERIODE, PASSAGE, GHS, MONTANT_GHS, MS, NUITEES, SUPPL, USIP, SI, SC, REA, J_SI, J_SC, PRIX_2026, HEURES FROM b WHERE EST_DIG = 1
),
a AS (
  SELECT POPULATION, PERIODE, PASSAGE,
         COUNT(*) AS N,
         SUM(CASE WHEN GHS = '9999' THEN 1 ELSE 0 END) AS N9,
         SUM(CASE WHEN PRIX_2026 IS NULL THEN 1 ELSE 0 END) AS NP,
         SUM(CASE WHEN HEURES IS NULL THEN 1 ELSE 0 END) AS NH,
         SUM(CASE WHEN MS = '9' THEN 1 ELSE 0 END) AS ND,
         AVG(NUITEES) AS NUIT_MOY, MEDIAN(NUITEES) AS NUIT_MED,
         AVG(HEURES) AS H_MOY, MEDIAN(HEURES) AS H_MED, COUNT(HEURES) AS NHV,
         AVG(CASE WHEN GHS <> '9999' THEN MONTANT_GHS END) AS GHS_MOY,
         AVG(PRIX_2026) AS PRIX_MOY,
         AVG(SUPPL) AS SUPPL_MOY, AVG(USIP) AS USIP_MOY, AVG(SI) AS SI_MOY, AVG(SC) AS SC_MOY, AVG(REA) AS REA_MOY,
         AVG(J_SI) AS J_SI_MOY, AVG(J_SC) AS J_SC_MOY
  FROM l
  GROUP BY POPULATION, PERIODE, PASSAGE
)
SELECT '20261023-usip-dms-valorisation-2' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       POPULATION, PASSAGE, PERIODE,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - N9 BETWEEN 1 AND 9 OR N - NP BETWEEN 1 AND 9 OR N - NH BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N_RSS,
       CASE WHEN N9 BETWEEN 1 AND 9 THEN '<10' ELSE TO_CHAR(N9) END AS N_GHS_9999,
       CASE WHEN NP BETWEEN 1 AND 9 THEN '<10' ELSE TO_CHAR(NP) END AS N_SANS_PRIX_2026,
       CASE WHEN NH BETWEEN 1 AND 9 THEN '<10' ELSE TO_CHAR(NH) END AS N_HEURES_EXCLUS,
       CASE WHEN ND BETWEEN 1 AND 9 THEN '<10' ELSE TO_CHAR(ND) END AS N_DECES,
       CASE WHEN N >= 10 THEN ROUND(NUIT_MOY, 2) END AS NUITEES_MOY,
       CASE WHEN N >= 10 THEN ROUND(NUIT_MOY + 1, 2) END AS JOURNEES_MOY,
       CASE WHEN N >= 10 THEN NUIT_MED END AS NUITEES_MED,
       CASE WHEN NHV >= 10 THEN ROUND(H_MOY, 1) END AS HEURES_MOY,
       CASE WHEN NHV >= 10 THEN ROUND(H_MED, 1) END AS HEURES_MED,
       CASE WHEN N - N9 >= 10 THEN ROUND(GHS_MOY) END AS MONTANT_GHS_MOY,
       CASE WHEN N - NP >= 10 THEN ROUND(PRIX_MOY) END AS PRIX_2026_MOY,
       CASE WHEN N >= 10 THEN ROUND(SUPPL_MOY) END AS SUPPLEMENTS_MOY,
       CASE WHEN N >= 10 THEN ROUND(USIP_MOY) END AS MNT_USIP_MOY,
       CASE WHEN N >= 10 THEN ROUND(SI_MOY) END AS MNT_SI_MOY,
       CASE WHEN N >= 10 THEN ROUND(SC_MOY) END AS MNT_SC_MOY,
       CASE WHEN N >= 10 THEN ROUND(REA_MOY) END AS MNT_REA_MOY,
       CASE WHEN N >= 10 THEN ROUND(J_SI_MOY, 2) END AS JOURS_SI_MOY,
       CASE WHEN N >= 10 THEN ROUND(J_SC_MOY, 2) END AS JOURS_SC_MOY
FROM a
ORDER BY POPULATION, PASSAGE, PERIODE;
