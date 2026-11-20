-- id: 20261022-fme-binomes-ghm-dp-pole-par-annee
-- system: cora
-- person_data: masked
-- purpose: dire si des binômes GHM × DP à effectif élevé en 2025 disparaissent vraiment du pôle femme-mère-enfant en 2026, ou si seule leur UF d'hébergement change (étape 6 du plan revu de l'enquête uf-um-rum, constat de Pierre sur l'étude DIM-code dms_fme)
-- Oracle, schéma CORA_REC. Mêmes séjours que l'étude dms_fme : RSS MCO d'au moins une nuit, hors CMD 28, sortis de janvier à septembre de 2022 à 2026, avec au moins un RUM dans une UM du pôle menf à la date de fin du RUM (les UM 5010 et 5015 ne qualifient pas un séjour). Une ligne par année, GHM (CMD + code) et diagnostic principal à 3 caractères ; pas d'UF, donc un séjour compte une seule fois.
-- Masquage : N_RSS < 10 sort en <10 et NB_NUITEES est alors NULL. Aucune ligne de total : rien ne permet de recalculer une case masquée.
WITH um_fme AS (
  SELECT DISTINCT pum.ID_UNITE_MED, pum.DATE_DEBUT, pum.DATE_FIN,
         CASE WHEN TRIM(ume.CODE_UNITE_MED) IN ('5010', '5015') THEN 0 ELSE 1 END AS QUALIFIE
  FROM CORA_REC.TB_UNITE_POLE_UM pum
  JOIN CORA_REC.TB_UNITE_POLE p ON p.ID_POLE = pum.ID_POLE
  JOIN CORA_REC.TB_UNITE_MEDICALE ume ON ume.ID_UNITE_MED = pum.ID_UNITE_MED
  WHERE TRIM(p.CODE_POLE) = 'menf'
), rss AS (
  SELECT r.ID_RSS, EXTRACT(YEAR FROM r.DATE_FIN) AS ANNEE, TRIM(r.CODE_CMD) || TRIM(r.CODE_GHM) AS GHM,
         SUBSTR(TRIM(r.DP_RETENU), 1, 3) AS DP3, r.DUREE_SEJOUR
  FROM CORA_REC.TB_SYNTH_RSS r
  WHERE r.DATE_FIN >= DATE '2022-01-01' AND r.DATE_FIN < DATE '2027-01-01'
    AND EXTRACT(MONTH FROM r.DATE_FIN) <= 9
    AND r.DUREE_SEJOUR >= 1 AND TRIM(r.CODE_CMD) <> '28'
), sej AS (
  SELECT rss.ID_RSS, rss.ANNEE, rss.GHM, rss.DP3, rss.DUREE_SEJOUR
  FROM rss
  WHERE EXISTS (SELECT 1 FROM CORA_REC.TB_SYNTH_RUM u JOIN um_fme f ON f.ID_UNITE_MED = u.ID_UNITE_MEDICALE AND f.QUALIFIE = 1
                 AND (f.DATE_DEBUT IS NULL OR f.DATE_DEBUT <= u.DATE_FIN_RUM)
                 AND (f.DATE_FIN IS NULL OR f.DATE_FIN >= u.DATE_FIN_RUM)
                WHERE u.ID_RSS = rss.ID_RSS)
), agr AS (
  SELECT ANNEE, GHM, DP3, COUNT(*) AS N, SUM(DUREE_SEJOUR) AS NUITEES
  FROM sej
  GROUP BY ANNEE, GHM, DP3
)
SELECT '20261022-fme-binomes-ghm-dp-pole-par-annee' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE, GHM, DP3,
       CASE WHEN N < 10 THEN '<10' ELSE TO_CHAR(N) END AS N_RSS,
       CASE WHEN N < 10 THEN NULL ELSE NUITEES END AS NB_NUITEES
FROM agr
ORDER BY ANNEE, GHM, DP3
