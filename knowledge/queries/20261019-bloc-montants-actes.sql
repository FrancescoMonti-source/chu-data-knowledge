-- id: 20261019-bloc-montants-actes
-- system: cora
-- person_data: masked
-- purpose: pour les actes chirurgicaux de bloc (TB_DET_ACTE, activité 1), par année de DATE_ACTE depuis 2022, mesurer : (1) la part des actes FACTURABLE = 'N' qui portent un MNT_TOTAL positif, et le MNT_TOTAL moyen des actes non facturables, gratuits (ACTE_GRATUIT = 'O') et pour mémoire (POUR_MEMOIRE = 'O') ; (2) l'écart entre MNT_TOTAL et la somme MNT_ACTIVITE + MNT_MODIFICATEUR + MNT_DEPASS, les sommes de chaque montant et la part d'actes à MNT_DEPASS positif. Tranche acte-non-facturable-montant-non-nul (réfuté si plus de 20 % des actes FACTURABLE = 'N' ont MNT_TOTAL nul ou vide) et montant-acte-tarif-modificateurs (réfuté si MNT_DEPASS > 0 pour plus de 1 % des actes ; la moyenne de |MNT_ACTIVITE − tarif| ne se mesure pas ici : elle demande le tarif CCAM, hors CORA)
-- Oracle, schéma CORA_REC. Actes de bloc selon reperer-actes-de-bloc : TB_ACTE.ID_SITE relié à TB_SITE avec BLOC = 'O', hors site de code 2620 (salle de naissance), actes datés du 2022-01-01 à aujourd'hui. Les trois UF rangées dans le bloc par Pierre (5508, 6510, 6196) ne sont pas incluses : elles demanderaient la jointure à TB_MVT, et le claim 11.1 parle des actes de site de bloc. Activité 1 : TB_DET_ACTE.ID_ACTIVITE = 1 ; une ligne de TB_DET_ACTE est une activité d'acte, la population est donc des activités d'actes. FACTURABLE, ACTE_GRATUIT, POUR_MEMOIRE comparés après TRIM ; valeurs lues avec 20261019-drapeaux-activite. Noms de colonnes d'après TB_DET_ACTE.txt.
-- N : activités d'actes ; N_NON_FACTURABLE : FACTURABLE = 'N' ; N_NF_MNT_POSITIF : parmi eux MNT_TOTAL > 0 ; N_NF_MNT_NUL_OU_VIDE : MNT_TOTAL nul ou vide ; PCT_NF_MNT_POSITIF ; MOY_MNT_TOTAL_NF, MOY_MNT_TOTAL_GRATUIT, MOY_MNT_TOTAL_POUR_MEMOIRE : moyenne des MNT_TOTAL renseignés (en euros) ; N_GRATUIT, N_POUR_MEMOIRE ; N_MNT_TOTAL_VIDE ; N_DEPASS_POSITIF : MNT_DEPASS > 0 ; PCT_DEPASS_POSITIF ; SOMME_MNT_TOTAL, SOMME_MNT_ACTIVITE, SOMME_MNT_MODIFICATEUR, SOMME_MNT_DEPASS : sommes (euros) ; MOY_ECART_TOTAL_MOINS_SOMME : moyenne par activité de MNT_TOTAL − (MNT_ACTIVITE + MNT_MODIFICATEUR + MNT_DEPASS), vides comptés 0, sur les lignes à MNT_TOTAL renseigné ; RAPPORT_TOTAL_SUR_ACTIVITE = SOMME_MNT_TOTAL / SOMME_MNT_ACTIVITE.
-- Masquage : tout effectif < 10 sort en <10 ; une moyenne ou une somme sort en <10 quand le nombre de lignes qui la porte est < 10 ; les pourcentages et le rapport ne sortent que si numérateur et dénominateur sont visibles. Suppression secondaire (règle 4) : N sort en « masqué » dès que N moins N_NON_FACTURABLE, ou N moins N_DEPASS_POSITIF, vaut de 1 à 9 ; N_NON_FACTURABLE de même quand N_NF_MNT_POSITIF ou N_NF_MNT_NUL_OU_VIDE vaut de 1 à 9. Aucune ligne de total.
WITH b AS (
  SELECT a.ID_ACTE, EXTRACT(YEAR FROM a.DATE_ACTE) AS ANNEE
  FROM CORA_REC.TB_ACTE a
  JOIN CORA_REC.TB_SITE si ON si.ID_SITE = a.ID_SITE
  WHERE a.DATE_ACTE >= DATE '2022-01-01' AND a.DATE_ACTE < TRUNC(SYSDATE) + 1
    AND si.BLOC = 'O' AND TRIM(si.CODE_SITE) <> '2620'
),
g AS (
  SELECT b.ANNEE,
         COUNT(*) AS N,
         SUM(CASE WHEN TRIM(d.FACTURABLE) = 'N' THEN 1 ELSE 0 END) AS C1,
         SUM(CASE WHEN TRIM(d.FACTURABLE) = 'N' AND d.MNT_TOTAL > 0 THEN 1 ELSE 0 END) AS C2,
         SUM(CASE WHEN TRIM(d.FACTURABLE) = 'N' AND NVL(d.MNT_TOTAL, 0) <= 0 THEN 1 ELSE 0 END) AS C3,
         SUM(CASE WHEN TRIM(d.ACTE_GRATUIT) = 'O' THEN 1 ELSE 0 END) AS C4,
         SUM(CASE WHEN TRIM(d.POUR_MEMOIRE) = 'O' THEN 1 ELSE 0 END) AS C5,
         SUM(CASE WHEN d.MNT_DEPASS > 0 THEN 1 ELSE 0 END) AS C6,
         SUM(CASE WHEN d.MNT_TOTAL IS NULL THEN 1 ELSE 0 END) AS C7,
         COUNT(CASE WHEN TRIM(d.FACTURABLE) = 'N' THEN d.MNT_TOTAL END) AS K1,
         COUNT(CASE WHEN TRIM(d.ACTE_GRATUIT) = 'O' THEN d.MNT_TOTAL END) AS K4,
         COUNT(CASE WHEN TRIM(d.POUR_MEMOIRE) = 'O' THEN d.MNT_TOTAL END) AS K5,
         AVG(CASE WHEN TRIM(d.FACTURABLE) = 'N' THEN d.MNT_TOTAL END) AS A1,
         AVG(CASE WHEN TRIM(d.ACTE_GRATUIT) = 'O' THEN d.MNT_TOTAL END) AS A4,
         AVG(CASE WHEN TRIM(d.POUR_MEMOIRE) = 'O' THEN d.MNT_TOTAL END) AS A5,
         SUM(d.MNT_TOTAL) AS S_TOT,
         SUM(d.MNT_ACTIVITE) AS S_ACT,
         SUM(d.MNT_MODIFICATEUR) AS S_MOD,
         SUM(d.MNT_DEPASS) AS S_DEP,
         AVG(CASE WHEN d.MNT_TOTAL IS NOT NULL
                  THEN d.MNT_TOTAL - (NVL(d.MNT_ACTIVITE, 0) + NVL(d.MNT_MODIFICATEUR, 0) + NVL(d.MNT_DEPASS, 0)) END) AS A_ECART
  FROM b
  JOIN CORA_REC.TB_DET_ACTE d ON d.ID_ACTE = b.ID_ACTE
  WHERE d.ID_ACTIVITE = 1
  GROUP BY b.ANNEE
)
SELECT '20261019-bloc-montants-actes' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C1 BETWEEN 1 AND 9 OR N - C6 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(N) END AS N,
       CASE WHEN C1 < 10 THEN '<10'
            WHEN C2 BETWEEN 1 AND 9 OR C3 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(C1) END AS N_NON_FACTURABLE,
       CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_NF_MNT_POSITIF,
       CASE WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_NF_MNT_NUL_OU_VIDE,
       CASE WHEN C1 >= 10 AND C2 >= 10 AND C2 <> 0 AND C3 NOT BETWEEN 1 AND 9
            THEN TO_CHAR(ROUND(100 * C2 / C1, 2), 'FM990.00', 'NLS_NUMERIC_CHARACTERS=''. ''') END AS PCT_NF_MNT_POSITIF,
       CASE WHEN K1 < 10 THEN '<10' ELSE TO_CHAR(ROUND(A1, 2), 'FM99999990.00', 'NLS_NUMERIC_CHARACTERS=''. ''') END AS MOY_MNT_TOTAL_NF,
       CASE WHEN C4 < 10 THEN '<10' ELSE TO_CHAR(C4) END AS N_GRATUIT,
       CASE WHEN K4 < 10 THEN '<10' ELSE TO_CHAR(ROUND(A4, 2), 'FM99999990.00', 'NLS_NUMERIC_CHARACTERS=''. ''') END AS MOY_MNT_TOTAL_GRATUIT,
       CASE WHEN C5 < 10 THEN '<10' ELSE TO_CHAR(C5) END AS N_POUR_MEMOIRE,
       CASE WHEN K5 < 10 THEN '<10' ELSE TO_CHAR(ROUND(A5, 2), 'FM99999990.00', 'NLS_NUMERIC_CHARACTERS=''. ''') END AS MOY_MNT_TOTAL_POUR_MEMOIRE,
       CASE WHEN C7 < 10 THEN '<10' ELSE TO_CHAR(C7) END AS N_MNT_TOTAL_VIDE,
       CASE WHEN C6 < 10 THEN '<10' ELSE TO_CHAR(C6) END AS N_DEPASS_POSITIF,
       CASE WHEN N >= 10 AND C6 >= 10 AND N - C6 NOT BETWEEN 1 AND 9 AND N - C1 NOT BETWEEN 1 AND 9
            THEN TO_CHAR(ROUND(100 * C6 / N, 3), 'FM990.000', 'NLS_NUMERIC_CHARACTERS=''. ''') END AS PCT_DEPASS_POSITIF,
       CASE WHEN N < 10 THEN '<10' ELSE TO_CHAR(ROUND(S_TOT, 2), 'FM999999999990.00', 'NLS_NUMERIC_CHARACTERS=''. ''') END AS SOMME_MNT_TOTAL,
       CASE WHEN N < 10 THEN '<10' ELSE TO_CHAR(ROUND(S_ACT, 2), 'FM999999999990.00', 'NLS_NUMERIC_CHARACTERS=''. ''') END AS SOMME_MNT_ACTIVITE,
       CASE WHEN N < 10 THEN '<10' ELSE TO_CHAR(ROUND(S_MOD, 2), 'FM999999999990.00', 'NLS_NUMERIC_CHARACTERS=''. ''') END AS SOMME_MNT_MODIFICATEUR,
       CASE WHEN N < 10 THEN '<10' ELSE TO_CHAR(ROUND(S_DEP, 2), 'FM999999999990.00', 'NLS_NUMERIC_CHARACTERS=''. ''') END AS SOMME_MNT_DEPASS,
       CASE WHEN N < 10 THEN '<10' ELSE TO_CHAR(ROUND(A_ECART, 2), 'FM99999990.00', 'NLS_NUMERIC_CHARACTERS=''. ''') END AS MOY_ECART_TOTAL_MOINS_SOMME,
       CASE WHEN N >= 10 AND S_ACT <> 0
            THEN TO_CHAR(ROUND(S_TOT / S_ACT, 4), 'FM990.0000', 'NLS_NUMERIC_CHARACTERS=''. ''') END AS RAPPORT_TOTAL_SUR_ACTIVITE
FROM g
ORDER BY ANNEE;
