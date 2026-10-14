-- id: 20261014-epoques-actes
-- system: cora
-- person_data: masked
-- purpose: par mois et par application d'origine, le volume des actes et des diagnostics, pour dater les reprises d'historique et le début du codage contemporain, et mesurer les colonnes d'acte qui dépendent de l'époque ou de l'écran de saisie : site vide, site de bloc, NO_INTERVENTION, NO_INTERVENTION_CCAM, ECRAN (kb : act-history-epochs, act-origin, act-site-missing-2021, surgical-acts-coded-in-cora, no-intervention-bloc-screen-only, convention.intervention-id-no-intervention-ccam ; #24)
-- Oracle, schéma CORA_REC. Mois de DATE_ACTE ou de DATE_DIAG, de 2014-01 à 2025-12. APPLICATION : ID_APPLICATION_TRANSFERT en texte, 'aucune' s'il est vide.
-- Niveau ACTES : N, puis N_TRANSFERT_R (TYPE_TRANSFERT = 'R'), N_ECRAN (ECRAN renseigné), N_SITE_VIDE (ID_SITE vide), N_SITE_BLOC (site avec TB_SITE.BLOC = 'O'), N_NO_INTERVENTION, N_NO_INTERVENTION_CCAM (renseignés). Niveau DIAGS : N et N_TRANSFERT_R seulement.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N sort en « masqué » dès qu'un complément (N moins une autre colonne) est entre 1 et 9. Aucune ligne de total.
WITH a AS (
  SELECT 'ACTES' AS NIVEAU,
         TO_CHAR(x.DATE_ACTE, 'YYYY-MM') AS MOIS,
         NVL(TRIM(TO_CHAR(x.ID_APPLICATION_TRANSFERT)), 'aucune') AS APPLICATION,
         COUNT(*) AS N,
         SUM(CASE WHEN TRIM(x.TYPE_TRANSFERT) = 'R' THEN 1 ELSE 0 END) AS C1,
         SUM(CASE WHEN TRIM(x.ECRAN) IS NOT NULL THEN 1 ELSE 0 END) AS C2,
         SUM(CASE WHEN x.ID_SITE IS NULL THEN 1 ELSE 0 END) AS C3,
         SUM(CASE WHEN si.BLOC = 'O' THEN 1 ELSE 0 END) AS C4,
         SUM(CASE WHEN x.NO_INTERVENTION IS NOT NULL THEN 1 ELSE 0 END) AS C5,
         SUM(CASE WHEN x.NO_INTERVENTION_CCAM IS NOT NULL THEN 1 ELSE 0 END) AS C6
  FROM CORA_REC.TB_ACTE x
  LEFT JOIN CORA_REC.TB_SITE si ON si.ID_SITE = x.ID_SITE
  WHERE x.DATE_ACTE >= DATE '2014-01-01'
    AND x.DATE_ACTE < DATE '2026-01-01'
  GROUP BY TO_CHAR(x.DATE_ACTE, 'YYYY-MM'), NVL(TRIM(TO_CHAR(x.ID_APPLICATION_TRANSFERT)), 'aucune')
),
d AS (
  SELECT 'DIAGS' AS NIVEAU,
         TO_CHAR(x.DATE_DIAG, 'YYYY-MM') AS MOIS,
         NVL(TRIM(TO_CHAR(x.ID_APPLICATION_TRANSFERT)), 'aucune') AS APPLICATION,
         COUNT(*) AS N,
         SUM(CASE WHEN TRIM(x.TYPE_TRANSFERT) = 'R' THEN 1 ELSE 0 END) AS C1,
         NULL AS C2, NULL AS C3, NULL AS C4, NULL AS C5, NULL AS C6
  FROM CORA_REC.TB_DIAG x
  WHERE x.DATE_DIAG >= DATE '2014-01-01'
    AND x.DATE_DIAG < DATE '2026-01-01'
  GROUP BY TO_CHAR(x.DATE_DIAG, 'YYYY-MM'), NVL(TRIM(TO_CHAR(x.ID_APPLICATION_TRANSFERT)), 'aucune')
),
t AS (
  SELECT NIVEAU, MOIS, APPLICATION, N, C1, C2, C3, C4, C5, C6 FROM a
  UNION ALL
  SELECT NIVEAU, MOIS, APPLICATION, N, C1, C2, C3, C4, C5, C6 FROM d
)
SELECT '20261014-epoques-actes' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       NIVEAU, MOIS, APPLICATION,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C1 BETWEEN 1 AND 9 OR N - NVL(C2, N) BETWEEN 1 AND 9 OR N - NVL(C3, N) BETWEEN 1 AND 9
              OR N - NVL(C4, N) BETWEEN 1 AND 9 OR N - NVL(C5, N) BETWEEN 1 AND 9 OR N - NVL(C6, N) BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N,
       CASE WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_TRANSFERT_R,
       CASE WHEN C2 IS NULL THEN NULL WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_ECRAN,
       CASE WHEN C3 IS NULL THEN NULL WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_SITE_VIDE,
       CASE WHEN C4 IS NULL THEN NULL WHEN C4 < 10 THEN '<10' ELSE TO_CHAR(C4) END AS N_SITE_BLOC,
       CASE WHEN C5 IS NULL THEN NULL WHEN C5 < 10 THEN '<10' ELSE TO_CHAR(C5) END AS N_NO_INTERVENTION,
       CASE WHEN C6 IS NULL THEN NULL WHEN C6 < 10 THEN '<10' ELSE TO_CHAR(C6) END AS N_NO_INTERVENTION_CCAM
FROM t
ORDER BY NIVEAU, MOIS, APPLICATION;
