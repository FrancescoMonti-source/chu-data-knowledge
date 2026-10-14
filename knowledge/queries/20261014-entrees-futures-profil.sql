-- id: 20261014-entrees-futures-profil
-- system: cora
-- person_data: masked
-- purpose: dire ce que sont les séjours à date d'entrée future (20261014-entrees-futures-resultat) : préadmissions ou non (STATUT_PROG), type de séjour, mouvements commencés dans le futur, RUM, RSS (et RSS fini dans le futur), actes, diagnostics ; et rapporter leur nombre aux séjours entrés depuis le 1er janvier et dans les 30 derniers jours (kb : future-entry-dates, #24)
-- Oracle, schéma CORA_REC. Acte ou diagnostic relié : par ID_SEJOUR, ou par l'ID_MVT d'un mouvement du séjour. RUM : une ligne de TB_MVT_RUM pour un mouvement du séjour ; RSS : TB_MVT → TB_MVT_RUM → TB_SYNTH_RSS.
-- NIVEAU FUTUR : une ligne par HORIZON (moins d'un mois, un mois ou plus), STATUT_PROG et TYPE_SEJOUR. NIVEAU REFERENCE : séjours entrés du 1er janvier au jour de l'exécution, et dans les 30 jours qui le précèdent (N_SEJ seulement).
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N_SEJ sort en « masqué » dès qu'un complément (N_SEJ moins une autre colonne) est entre 1 et 9. Aucune ligne de total.
WITH f AS (
  SELECT se.ID_SEJOUR,
         CASE WHEN se.DATE_ENTREE < ADD_MONTHS(TRUNC(SYSDATE), 1) THEN '1 moins d''un mois' ELSE '2 un mois ou plus' END AS HORIZON,
         NVL(TRIM(se.STATUT_PROG), '(vide)') AS STATUT_PROG,
         NVL(TRIM(se.TYPE_SEJOUR), '(vide)') AS TYPE_SEJOUR,
         CASE WHEN se.DATE_SORTIE IS NOT NULL THEN 1 ELSE 0 END AS SOR
  FROM CORA_REC.TB_SEJOUR se
  WHERE se.DATE_ENTREE >= TRUNC(SYSDATE) + 1
),
g AS (
  SELECT f.HORIZON, f.STATUT_PROG, f.TYPE_SEJOUR, f.SOR,
         CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_MVT m WHERE m.ID_SEJOUR = f.ID_SEJOUR)
               AND NOT EXISTS (SELECT 1 FROM CORA_REC.TB_MVT m WHERE m.ID_SEJOUR = f.ID_SEJOUR AND m.DATE_DEBUT_MVT < TRUNC(SYSDATE) + 1)
              THEN 1 ELSE 0 END AS MVT_FUTURS,
         CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_MVT m JOIN CORA_REC.TB_MVT_RUM mr ON mr.ID_MVT = m.ID_MVT WHERE m.ID_SEJOUR = f.ID_SEJOUR)
              THEN 1 ELSE 0 END AS RUM,
         CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_MVT m JOIN CORA_REC.TB_MVT_RUM mr ON mr.ID_MVT = m.ID_MVT
                           JOIN CORA_REC.TB_SYNTH_RSS r ON r.ID_RSS = mr.ID_RSS WHERE m.ID_SEJOUR = f.ID_SEJOUR)
              THEN 1 ELSE 0 END AS RSS,
         CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_MVT m JOIN CORA_REC.TB_MVT_RUM mr ON mr.ID_MVT = m.ID_MVT
                           JOIN CORA_REC.TB_SYNTH_RSS r ON r.ID_RSS = mr.ID_RSS
                           WHERE m.ID_SEJOUR = f.ID_SEJOUR AND r.DATE_FIN >= TRUNC(SYSDATE) + 1)
              THEN 1 ELSE 0 END AS RSS_FUTUR,
         CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_ACTE a WHERE a.ID_SEJOUR = f.ID_SEJOUR)
                OR EXISTS (SELECT 1 FROM CORA_REC.TB_MVT m JOIN CORA_REC.TB_ACTE a ON a.ID_MVT = m.ID_MVT WHERE m.ID_SEJOUR = f.ID_SEJOUR)
              THEN 1 ELSE 0 END AS ACTE,
         CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_DIAG d WHERE d.ID_SEJOUR = f.ID_SEJOUR)
                OR EXISTS (SELECT 1 FROM CORA_REC.TB_MVT m JOIN CORA_REC.TB_DIAG d ON d.ID_MVT = m.ID_MVT WHERE m.ID_SEJOUR = f.ID_SEJOUR)
              THEN 1 ELSE 0 END AS DIAG
  FROM f
),
a AS (
  SELECT 'FUTUR' AS NIVEAU, HORIZON, STATUT_PROG, TYPE_SEJOUR,
         COUNT(*) AS SEJ, SUM(SOR) AS SOR, SUM(MVT_FUTURS) AS MVF, SUM(RUM) AS RUM,
         SUM(RSS) AS RSS, SUM(RSS_FUTUR) AS RSF, SUM(ACTE) AS ACT, SUM(DIAG) AS DIA
  FROM g
  GROUP BY HORIZON, STATUT_PROG, TYPE_SEJOUR
  UNION ALL
  SELECT 'REFERENCE', 'entrées du 1er janvier à aujourd''hui', NULL, NULL, COUNT(*), NULL, NULL, NULL, NULL, NULL, NULL, NULL
  FROM CORA_REC.TB_SEJOUR
  WHERE DATE_ENTREE >= TRUNC(SYSDATE, 'YYYY') AND DATE_ENTREE < TRUNC(SYSDATE) + 1
  UNION ALL
  SELECT 'REFERENCE', 'entrées des 30 derniers jours', NULL, NULL, COUNT(*), NULL, NULL, NULL, NULL, NULL, NULL, NULL
  FROM CORA_REC.TB_SEJOUR
  WHERE DATE_ENTREE >= TRUNC(SYSDATE) - 29 AND DATE_ENTREE < TRUNC(SYSDATE) + 1
)
SELECT '20261014-entrees-futures-profil' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       NIVEAU, HORIZON, STATUT_PROG, TYPE_SEJOUR,
       CASE WHEN SEJ < 10 THEN '<10'
            WHEN NIVEAU = 'FUTUR' AND (SEJ - SOR BETWEEN 1 AND 9 OR SEJ - MVF BETWEEN 1 AND 9 OR SEJ - RUM BETWEEN 1 AND 9
                                       OR SEJ - RSS BETWEEN 1 AND 9 OR SEJ - RSF BETWEEN 1 AND 9 OR SEJ - ACT BETWEEN 1 AND 9
                                       OR SEJ - DIA BETWEEN 1 AND 9) THEN 'masqué'
            ELSE TO_CHAR(SEJ) END AS N_SEJ,
       CASE WHEN SOR IS NULL THEN NULL WHEN SOR < 10 THEN '<10' ELSE TO_CHAR(SOR) END AS N_AVEC_SORTIE,
       CASE WHEN MVF IS NULL THEN NULL WHEN MVF < 10 THEN '<10' ELSE TO_CHAR(MVF) END AS N_MVT_TOUS_FUTURS,
       CASE WHEN RUM IS NULL THEN NULL WHEN RUM < 10 THEN '<10' ELSE TO_CHAR(RUM) END AS N_AVEC_RUM,
       CASE WHEN RSS IS NULL THEN NULL WHEN RSS < 10 THEN '<10' ELSE TO_CHAR(RSS) END AS N_AVEC_RSS,
       CASE WHEN RSF IS NULL THEN NULL WHEN RSF < 10 THEN '<10' ELSE TO_CHAR(RSF) END AS N_RSS_FIN_FUTURE,
       CASE WHEN ACT IS NULL THEN NULL WHEN ACT < 10 THEN '<10' ELSE TO_CHAR(ACT) END AS N_AVEC_ACTE,
       CASE WHEN DIA IS NULL THEN NULL WHEN DIA < 10 THEN '<10' ELSE TO_CHAR(DIA) END AS N_AVEC_DIAG
FROM a
ORDER BY NIVEAU, HORIZON, STATUT_PROG, TYPE_SEJOUR;
