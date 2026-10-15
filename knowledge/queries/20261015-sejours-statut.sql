-- id: 20261015-sejours-statut
-- system: cora
-- person_data: masked
-- purpose: par année d'entrée, les valeurs de TB_SEJOUR.STATUT et ETAT_ADM_DOSSIER pour les séjours clos et pour les séjours restés ouverts, pour savoir si CORA marque ces séjours (clôture, blocage, annulation) et si les écarts d'une année à l'autre viennent de campagnes de clôture (#33, test 3)
-- Oracle, schéma CORA_REC. Séjours entrés de 2018 à 2025, hors préadmissions et hors séjours sans mouvement. ETAT : 'ouvert' (sans DATE_SORTIE) ou 'clos'. N_DATE_BLOCAGE : séjours dont DATE_BLOCAGE est renseignée.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : quand les cases masquées d'une année et d'un état totalisent de 1 à 9, la plus grande case du groupe sort aussi en « masqué » ; N sort aussi en « masqué » si N − N_DATE_BLOCAGE est entre 1 et 9. Aucune ligne de total.
WITH s AS (
  SELECT EXTRACT(YEAR FROM se.DATE_ENTREE) AS ANNEE,
         CASE WHEN se.DATE_SORTIE IS NULL THEN 'ouvert' ELSE 'clos' END AS ETAT,
         NVL(TRIM(TO_CHAR(se.STATUT)), '(vide)') AS STATUT,
         NVL(TRIM(TO_CHAR(se.ETAT_ADM_DOSSIER)), '(vide)') AS ETAT_ADM_DOSSIER,
         CASE WHEN se.DATE_BLOCAGE IS NOT NULL THEN 1 ELSE 0 END AS BLQ
  FROM CORA_REC.TB_SEJOUR se
  WHERE se.DATE_ENTREE >= DATE '2018-01-01' AND se.DATE_ENTREE < DATE '2026-01-01'
    AND NVL(se.STATUT_PROG, '-') <> 'P'
    AND EXISTS (SELECT 1 FROM CORA_REC.TB_MVT m WHERE m.ID_SEJOUR = se.ID_SEJOUR)
),
g AS (
  SELECT ANNEE, ETAT, STATUT, ETAT_ADM_DOSSIER, COUNT(*) AS N, SUM(BLQ) AS B FROM s
  GROUP BY ANNEE, ETAT, STATUT, ETAT_ADM_DOSSIER
),
r AS (
  SELECT ANNEE, ETAT, STATUT, ETAT_ADM_DOSSIER, N, B,
         SUM(CASE WHEN N < 10 THEN N ELSE 0 END) OVER (PARTITION BY ANNEE, ETAT) AS CACHE,
         ROW_NUMBER() OVER (PARTITION BY ANNEE, ETAT ORDER BY N DESC, STATUT, ETAT_ADM_DOSSIER) AS RANG
  FROM g
)
SELECT '20261015-sejours-statut' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE, ETAT, STATUT, ETAT_ADM_DOSSIER,
       CASE WHEN N < 10 THEN '<10' WHEN (CACHE BETWEEN 1 AND 9 AND RANG = 1) OR N - B BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(N) END AS N,
       CASE WHEN B < 10 THEN '<10' ELSE TO_CHAR(B) END AS N_DATE_BLOCAGE
FROM r
ORDER BY ANNEE, ETAT, RANG;
