-- id: 20261020-montant-total-composantes
-- system: cora
-- person_data: masked
-- purpose: par année de fin de RSS (DATE_FIN), décomposer l'écart de 14 à 17 % entre TB_SYNTH_RSS.MNT_TOTAL et MONTANT_GHS (rapport lu dans 20261019-montant-ghs-rss, claim montant-ghs-rss) : sommes en euros de MNT_TOTAL, de MONTANT_GHS, des suppléments journaliers et forfaits, du montant de dépassement de borne haute, puis le résidu inexpliqué en % de MNT_TOTAL. Si le résidu est proche de 0 : MNT_TOTAL = GHS + suppléments (+ dépassement) et le claim peut le dire ; s'il reste de plusieurs points : une composante manque (borne basse, minoration, colonne non listée) et le claim ne doit pas affirmer cette décomposition
-- Oracle 11g, schéma CORA_REC. RSS groupés (CODE_GHM renseigné, CODE_CMD <> '90') dont DATE_FIN va du 2022-01-01 au 2025-12-31 (années complètes). Une ligne par année de DATE_FIN, un seul niveau. Sommes en euros arrondis à l'unité, calculées sur tous les RSS groupés de l'année (NVL(col, 0) autour de chaque colonne) ; jamais de montant par RSS.
-- Suppléments retenus (somme dans EUR_SUPPLEMENTS) : MONTANT_REA (réanimation) ; MNT_JOUR_NEO1, MNT_JOUR_NEO2, MNT_JOUR_NEO3 (néonatologie) ; MNT_JOUR_SOINS_INT (soins intensifs) ; MNT_JOUR_SURV_CONT (surveillance continue) ; MNT_JOUR_SOINS_PALL (soins palliatifs) ; MNT_JOUR_SOINS_INT_REA (soins intensifs issus de réanimation) ; MNT_SRA ; MNT_REP (forfait réa pédiatrique) ; MNT_CAISSON_HB (caisson hyperbare) ; MNT_APHERESE ; MNT_RDTH ; MNT_RDTH_PED ; MNT_ANTEPARTUM ; MNT_SDC (défibrillateur) ; MNT_SUP_CARTCELL ; MNT_JOUR_USIP ; MNT_SUP_INNOV_I04, I11, I12, I14, I19. Toutes existent dans TB_SYNTH_RSS (catalogue 20261015-colonnes-hist-diag-synth-rss-resultat). Dictionnaire : MNT_TOTAL = prix du GHS + borne haute - borne basse + suppléments (hors DIP et PO).
-- Écart de bornes : le dictionnaire ne donne aucun montant d'EXB ni de borne basse (NB_JOUR_EXB et BORNE_BASSE sont un nombre de jours et un indicateur) ; seul MONTANT_DEP (dépassement de borne haute, EXH) est un montant : colonne EUR_DEPASSEMENT_BH, hors EUR_SUPPLEMENTS. RESIDU_EUR = MNT_TOTAL - MONTANT_GHS - suppléments (comme demandé, dépassement inclus dans le résidu) ; RESIDU_APRES_DEP_EUR = ce résidu moins MONTANT_DEP (ce qui reste, dont l'EXB négatif, non mesurable ici). RAPPORT_RESIDU_PCT et RAPPORT_RESIDU_APRES_DEP_PCT = résidu / MNT_TOTAL en %.
-- Colonnes écartées : MNT_DIP et MNT_PRELEV_ORGANE (le dictionnaire les dit hors MNT_TOTAL ; MNT_PRELEV_ORGANE ne stocke que le type 1, 2 ou 3, pas un montant) ; MNT_TOTAL_SUPPLEMENT (total des suppléments : double compte ; sortie seule comme contrôle EUR_TOTAL_SUPPLEMENT_DICO) ; MNT_TMJ, MNT_TMH, MNT_TMJ_GHS, MNT_PRORATA_STRA_ETAB (tarifs moyens calculés, pas des composantes) ; MONTANT_COEF (coefficient de survalorisation, déjà dans MONTANT_GHS) ; MONTANT_REDU, MT_24Z05Z, MT_24Z06Z, MT_24Z07Z, MT_DIALYSE (sens non documenté ou sous-ensemble de MONTANT_GHS). MONTANT_URG (passage aux urgences) et MNT_MINORE_MON (minoration molécule onéreuse) sont sortis à part pour lecture, sans entrer dans le résidu.
-- Masquage : N_RSS < 10 sort en <10 et toutes les sommes de la ligne sont vides ; sinon les sommes sont des agrégats d'au moins 10 RSS. Suppression secondaire (règle 4) : aucun effectif complémentaire n'est publié, donc rien à masquer en plus ; aucune ligne de total entre années.
WITH r AS (
  SELECT EXTRACT(YEAR FROM s.DATE_FIN) AS ANNEE,
         NVL(s.MNT_TOTAL, 0) AS TOT,
         NVL(s.MONTANT_GHS, 0) AS GHS,
         NVL(s.MONTANT_DEP, 0) AS DEP,
         NVL(s.MONTANT_URG, 0) AS URG,
         NVL(s.MNT_MINORE_MON, 0) AS MINORE,
         NVL(s.MNT_TOTAL_SUPPLEMENT, 0) AS TOT_SUP_DICO,
         NVL(s.MONTANT_REA, 0) + NVL(s.MNT_JOUR_NEO1, 0) + NVL(s.MNT_JOUR_NEO2, 0) + NVL(s.MNT_JOUR_NEO3, 0)
           + NVL(s.MNT_JOUR_SOINS_INT, 0) + NVL(s.MNT_JOUR_SURV_CONT, 0) + NVL(s.MNT_JOUR_SOINS_PALL, 0)
           + NVL(s.MNT_JOUR_SOINS_INT_REA, 0) + NVL(s.MNT_SRA, 0) + NVL(s.MNT_REP, 0) + NVL(s.MNT_CAISSON_HB, 0)
           + NVL(s.MNT_APHERESE, 0) + NVL(s.MNT_RDTH, 0) + NVL(s.MNT_RDTH_PED, 0) + NVL(s.MNT_ANTEPARTUM, 0)
           + NVL(s.MNT_SDC, 0) + NVL(s.MNT_SUP_CARTCELL, 0) + NVL(s.MNT_JOUR_USIP, 0)
           + NVL(s.MNT_SUP_INNOV_I04, 0) + NVL(s.MNT_SUP_INNOV_I11, 0) + NVL(s.MNT_SUP_INNOV_I12, 0)
           + NVL(s.MNT_SUP_INNOV_I14, 0) + NVL(s.MNT_SUP_INNOV_I19, 0) AS SUPP
  FROM CORA_REC.TB_SYNTH_RSS s
  WHERE s.DATE_FIN >= DATE '2022-01-01' AND s.DATE_FIN < DATE '2026-01-01'
    AND TRIM(s.CODE_GHM) IS NOT NULL AND TRIM(s.CODE_CMD) <> '90'
),
a AS (
  SELECT ANNEE,
         COUNT(*) AS N,
         SUM(TOT) AS S_TOT,
         SUM(GHS) AS S_GHS,
         SUM(SUPP) AS S_SUPP,
         SUM(DEP) AS S_DEP,
         SUM(URG) AS S_URG,
         SUM(MINORE) AS S_MINORE,
         SUM(TOT_SUP_DICO) AS S_TSD
  FROM r
  GROUP BY ANNEE
)
SELECT '20261020-montant-total-composantes' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       TO_CHAR(ANNEE) AS ANNEE_FIN,
       CASE WHEN N < 10 THEN '<10' ELSE TO_CHAR(N) END AS N_RSS,
       CASE WHEN N < 10 THEN NULL ELSE ROUND(S_TOT) END AS EUR_MNT_TOTAL,
       CASE WHEN N < 10 THEN NULL ELSE ROUND(S_GHS) END AS EUR_MONTANT_GHS,
       CASE WHEN N < 10 THEN NULL ELSE ROUND(S_SUPP) END AS EUR_SUPPLEMENTS,
       CASE WHEN N < 10 THEN NULL ELSE ROUND(S_DEP) END AS EUR_DEPASSEMENT_BH,
       CASE WHEN N < 10 THEN NULL ELSE ROUND(S_TOT - S_GHS - S_SUPP) END AS RESIDU_EUR,
       CASE WHEN N >= 10 AND S_TOT <> 0
            THEN TO_CHAR(ROUND(100 * (S_TOT - S_GHS - S_SUPP) / S_TOT, 2), 'FM990.00', 'NLS_NUMERIC_CHARACTERS=''. ''') END AS RAPPORT_RESIDU_PCT,
       CASE WHEN N < 10 THEN NULL ELSE ROUND(S_TOT - S_GHS - S_SUPP - S_DEP) END AS RESIDU_APRES_DEP_EUR,
       CASE WHEN N >= 10 AND S_TOT <> 0
            THEN TO_CHAR(ROUND(100 * (S_TOT - S_GHS - S_SUPP - S_DEP) / S_TOT, 2), 'FM990.00', 'NLS_NUMERIC_CHARACTERS=''. ''') END AS RAPPORT_RESIDU_APRES_DEP_PCT,
       CASE WHEN N < 10 THEN NULL ELSE ROUND(S_URG) END AS EUR_URGENCE_A_PART,
       CASE WHEN N < 10 THEN NULL ELSE ROUND(S_MINORE) END AS EUR_MINORATION_MON_A_PART,
       CASE WHEN N < 10 THEN NULL ELSE ROUND(S_TSD) END AS EUR_TOTAL_SUPPLEMENT_DICO
FROM a
ORDER BY ANNEE;
