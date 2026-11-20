-- id: 20261120-code-association-bglb001-bzqk001
-- system: cora
-- person_data: masked
-- purpose: quand BGLB001 (injection intravitréenne) et BZQK001 (OCT) sont faits le même jour au même patient, lire le code d'association CCAM appliqué à chacun et son montant, par type de séjour, pour savoir si l'OCT est payé à 50 % en consultation externe (étape 4 du plan, #155)
-- Oracle, schéma CORA_REC. Actes de TB_ACTE datés de janvier 2025 à septembre 2026, reliés au séjour par le mouvement (chemin-actes-diags-par-mouvement). Couple : même patient (TB_ACTE.ID_PATIENT), même jour, les deux codes présents. Activité 1 de TB_DET_ACTE (ID_ACTIVITE = 1), hors activité non réalisée (ETAT = 'X'). Type de séjour : TB_SEJOUR.TYPE_SEJOUR tel quel (EXT, HDJ, MCO…).
-- CODE_ASSOCIATION : 1 ou vide = 100 %, 2 = 50 %, autres valeurs selon la CCAM. MOY_MNT_TOTAL : moyenne de MNT_TOTAL (montant-acte-tarif-modificateurs).
-- Masquage : si N_PATIENTS < 10, toute la ligne sort en <10. N_ACTES sort en « masqué » si son écart à N_PATIENTS vaut de 1 à 9. Aucune ligne de total.
WITH a AS (
  SELECT ac.ID_ACTE, ac.ID_PATIENT, TRUNC(ac.DATE_ACTE) AS JOUR,
         SUBSTR(ac.CODE_ACTE, 1, 7) AS CODE, m.ID_SEJOUR
  FROM CORA_REC.TB_ACTE ac
  JOIN CORA_REC.TB_MVT m ON m.ID_MVT = ac.ID_MVT
  WHERE (ac.CODE_ACTE LIKE 'BGLB001%' OR ac.CODE_ACTE LIKE 'BZQK001%')
    AND ac.DATE_ACTE >= DATE '2025-01-01' AND ac.DATE_ACTE < DATE '2026-10-01'
),
paires AS (
  SELECT ID_PATIENT, JOUR
  FROM a
  GROUP BY ID_PATIENT, JOUR
  HAVING COUNT(DISTINCT CODE) = 2
),
t AS (
  SELECT NVL(TRIM(s.TYPE_SEJOUR), '(vide)') AS TYPE_SEJOUR,
         a.CODE,
         NVL(TRIM(d.CODE_ASSOCIATION), '(vide)') AS CODE_ASSOCIATION,
         COUNT(DISTINCT a.ID_PATIENT) AS P,
         COUNT(*) AS N,
         ROUND(AVG(d.MNT_TOTAL), 2) AS MOY
  FROM a
  JOIN paires p ON p.ID_PATIENT = a.ID_PATIENT AND p.JOUR = a.JOUR
  JOIN CORA_REC.TB_DET_ACTE d ON d.ID_ACTE = a.ID_ACTE AND d.ID_ACTIVITE = 1 AND NVL(d.ETAT, ' ') <> 'X'
  LEFT JOIN CORA_REC.TB_SEJOUR s ON s.ID_SEJOUR = a.ID_SEJOUR
  GROUP BY NVL(TRIM(s.TYPE_SEJOUR), '(vide)'), a.CODE, NVL(TRIM(d.CODE_ASSOCIATION), '(vide)')
)
SELECT '20261120-code-association-bglb001-bzqk001' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       TYPE_SEJOUR, CODE, CODE_ASSOCIATION,
       CASE WHEN P < 10 THEN '<10' ELSE TO_CHAR(P) END AS N_PATIENTS,
       CASE WHEN P < 10 THEN '<10'
            WHEN N - P BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N_ACTES,
       CASE WHEN P < 10 THEN '<10' ELSE TO_CHAR(MOY) END AS MOY_MNT_TOTAL
FROM t
ORDER BY TYPE_SEJOUR, CODE, CODE_ASSOCIATION;
