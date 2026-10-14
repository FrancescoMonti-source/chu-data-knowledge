-- id: 20261014-entrees-futures
-- system: cora
-- person_data: masked
-- purpose: séjours dont DATE_ENTREE est postérieure au jour de l'exécution : combien, à quel horizon, et s'ils sont déjà exclus par exclure-sejours-sans-sortie-orphelins (préadmission ou sans mouvement, sans DATE_SORTIE) (kb : future-entry-dates, #24)
-- Oracle, schéma CORA_REC. HORIZON : écart entre DATE_ENTREE et le jour de l'exécution, en tranches (moins d'un mois, 1 à 3 mois, 3 à 12 mois, 1 à 5 ans, plus de 5 ans).
-- Pour chaque horizon : N_SEJ, puis les séjours préadmission (STATUT_PROG = 'P'), avec DATE_SORTIE, avec au moins un mouvement, et ceux que le filtre de exclure-sejours-sans-sortie-orphelins ne retire pas (N_RESTANTS).
-- Masquage : chaque effectif < 10 sort en <10. Aucune ligne de total ; N_SEJ ne sort qu'en « masqué » si l'un des compléments (N_SEJ moins une colonne) est entre 1 et 9 (règle 4).
WITH s AS (
  SELECT CASE WHEN se.DATE_ENTREE < ADD_MONTHS(TRUNC(SYSDATE), 1) THEN '1 moins d''un mois'
              WHEN se.DATE_ENTREE < ADD_MONTHS(TRUNC(SYSDATE), 3) THEN '2 1 à 3 mois'
              WHEN se.DATE_ENTREE < ADD_MONTHS(TRUNC(SYSDATE), 12) THEN '3 3 à 12 mois'
              WHEN se.DATE_ENTREE < ADD_MONTHS(TRUNC(SYSDATE), 60) THEN '4 1 à 5 ans'
              ELSE '5 plus de 5 ans' END AS HORIZON,
         CASE WHEN se.STATUT_PROG = 'P' THEN 1 ELSE 0 END AS PREADM,
         CASE WHEN se.DATE_SORTIE IS NOT NULL THEN 1 ELSE 0 END AS AVEC_SORTIE,
         CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_MVT m WHERE m.ID_SEJOUR = se.ID_SEJOUR) THEN 1 ELSE 0 END AS AVEC_MVT
  FROM CORA_REC.TB_SEJOUR se
  WHERE se.DATE_ENTREE >= TRUNC(SYSDATE) + 1
),
a AS (
  SELECT HORIZON,
         COUNT(*) AS SEJ,
         SUM(PREADM) AS PRE,
         SUM(AVEC_SORTIE) AS SOR,
         SUM(AVEC_MVT) AS MVT,
         SUM(CASE WHEN AVEC_SORTIE = 1 OR (PREADM = 0 AND AVEC_MVT = 1) THEN 1 ELSE 0 END) AS RES
  FROM s
  GROUP BY HORIZON
)
SELECT '20261014-entrees-futures' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       HORIZON,
       CASE WHEN SEJ < 10 THEN '<10'
            WHEN SEJ - PRE BETWEEN 1 AND 9 OR SEJ - SOR BETWEEN 1 AND 9 OR SEJ - MVT BETWEEN 1 AND 9 OR SEJ - RES BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(SEJ) END AS N_SEJ,
       CASE WHEN PRE < 10 THEN '<10' ELSE TO_CHAR(PRE) END AS N_PREADM,
       CASE WHEN SOR < 10 THEN '<10' ELSE TO_CHAR(SOR) END AS N_AVEC_SORTIE,
       CASE WHEN MVT < 10 THEN '<10' ELSE TO_CHAR(MVT) END AS N_AVEC_MVT,
       CASE WHEN RES < 10 THEN '<10' ELSE TO_CHAR(RES) END AS N_RESTANTS
FROM a
ORDER BY HORIZON;
