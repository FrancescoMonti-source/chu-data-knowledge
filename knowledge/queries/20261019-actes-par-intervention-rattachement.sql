-- id: 20261019-actes-par-intervention-rattachement
-- system: cora
-- person_data: masked
-- purpose: par mois de l'intervention depuis 2023 et par origine de saisie des actes, le nombre moyen d'actes par intervention selon deux niveaux de rattachement, pour tester rattachement-direct-acte-intervention-par-periode : (a) actes rattachés par TB_ACTE.NO_INTERVENTION = ID_INTERVENTION, (b) actes de site de bloc du même séjour et du même jour, sur les seules interventions uniques de leur séjour et de leur jour ; réfuté si, au niveau (b), le nombre moyen d'actes par intervention monte encore de plus de 0,2 entre 2023 et 2026 (alors la hausse est de l'activité, pas du rattachement)
-- Oracle, schéma CORA_REC. TB_INTERVENTION (DATE_INTERVENTION du 2023-01-01 au jour d'exécution) restreinte aux interventions seules dans leur couple (ID_SEJOUR, jour) ; actes de DATE_ACTE depuis 2023-01-01. MOIS : mois de DATE_INTERVENTION.
-- SAISIE : 'aucun acte' si l'intervention n'a aucun acte de site de bloc (TB_SITE.BLOC = 'O') le même jour dans son séjour ; 'saisie CORA' si l'un de ces actes a ECRAN renseigné ; sinon 'hors CORA'.
-- N_INTERVENTIONS : interventions ; N_AVEC_ACTE_DIRECT : au moins un acte par NO_INTERVENTION ; N_ACTES_DIRECTS : ces actes ; N_AVEC_ACTE_SEJOUR_JOUR : au moins un acte de bloc du même séjour et jour ; N_ACTES_SEJOUR_JOUR : ces actes. Moyennes : MOY_ACTES_DIRECT = N_ACTES_DIRECTS / N_AVEC_ACTE_DIRECT ; MOY_ACTES_SEJOUR_JOUR = N_ACTES_SEJOUR_JOUR / N_AVEC_ACTE_SEJOUR_JOUR, sorties seulement quand numérateur et dénominateur sont visibles.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N_INTERVENTIONS sort en « masqué » dès qu'un complément (N_INTERVENTIONS moins une autre colonne de comptage d'interventions) est entre 1 et 9. Aucune ligne de total. Les derniers mois sont incomplets (actes-derniers-mois-incomplets).
WITH iu AS (
  SELECT i.ID_INTERVENTION, i.ID_SEJOUR, TRUNC(i.DATE_INTERVENTION) AS JOUR,
         COUNT(*) OVER (PARTITION BY i.ID_SEJOUR, TRUNC(i.DATE_INTERVENTION)) AS NB_SJ
  FROM CORA_REC.TB_INTERVENTION i
  WHERE i.DATE_INTERVENTION >= DATE '2023-01-01'
    AND i.DATE_INTERVENTION < TRUNC(SYSDATE) + 1
    AND i.ID_SEJOUR IS NOT NULL
),
direct AS (
  SELECT NO_INTERVENTION, COUNT(*) AS ND
  FROM CORA_REC.TB_ACTE
  WHERE NO_INTERVENTION IS NOT NULL AND DATE_ACTE >= DATE '2023-01-01'
  GROUP BY NO_INTERVENTION
),
sj AS (
  SELECT x.ID_SEJOUR, TRUNC(x.DATE_ACTE) AS JOUR, COUNT(*) AS NS,
         SUM(CASE WHEN TRIM(x.ECRAN) IS NOT NULL THEN 1 ELSE 0 END) AS NE
  FROM CORA_REC.TB_ACTE x
  JOIN CORA_REC.TB_SITE si ON si.ID_SITE = x.ID_SITE AND si.BLOC = 'O'
  WHERE x.DATE_ACTE >= DATE '2023-01-01'
  GROUP BY x.ID_SEJOUR, TRUNC(x.DATE_ACTE)
),
t AS (
  SELECT TO_CHAR(iu.JOUR, 'YYYY-MM') AS MOIS,
         CASE WHEN s.NS IS NULL THEN 'aucun acte' WHEN s.NE > 0 THEN 'saisie CORA' ELSE 'hors CORA' END AS SAISIE,
         COUNT(*) AS N,
         SUM(CASE WHEN d.ND IS NOT NULL THEN 1 ELSE 0 END) AS C1,
         SUM(NVL(d.ND, 0)) AS S1,
         SUM(CASE WHEN s.NS IS NOT NULL THEN 1 ELSE 0 END) AS C2,
         SUM(NVL(s.NS, 0)) AS S2
  FROM iu
  LEFT JOIN direct d ON d.NO_INTERVENTION = iu.ID_INTERVENTION
  LEFT JOIN sj s ON s.ID_SEJOUR = iu.ID_SEJOUR AND s.JOUR = iu.JOUR
  WHERE iu.NB_SJ = 1
  GROUP BY TO_CHAR(iu.JOUR, 'YYYY-MM'),
           CASE WHEN s.NS IS NULL THEN 'aucun acte' WHEN s.NE > 0 THEN 'saisie CORA' ELSE 'hors CORA' END
)
SELECT '20261019-actes-par-intervention-rattachement' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       MOIS, SAISIE,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C1 BETWEEN 1 AND 9 OR N - C2 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N_INTERVENTIONS,
       CASE WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_AVEC_ACTE_DIRECT,
       CASE WHEN S1 < 10 THEN '<10' ELSE TO_CHAR(S1) END AS N_ACTES_DIRECTS,
       CASE WHEN C1 >= 10 AND S1 >= 10 THEN ROUND(S1 / C1, 2) END AS MOY_ACTES_DIRECT,
       CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_AVEC_ACTE_SEJOUR_JOUR,
       CASE WHEN S2 < 10 THEN '<10' ELSE TO_CHAR(S2) END AS N_ACTES_SEJOUR_JOUR,
       CASE WHEN C2 >= 10 AND S2 >= 10 THEN ROUND(S2 / C2, 2) END AS MOY_ACTES_SEJOUR_JOUR
FROM t
ORDER BY MOIS, SAISIE;
