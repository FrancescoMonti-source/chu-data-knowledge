-- id: 20261120-z511-type-diag
-- system: cora
-- person_data: masked
-- purpose: compter, de 2022 à 2025, les séjours qui portent un diagnostic Z511 selon son TYPE_DIAG (P principal, S associé, R relié, D documentaire…), pour confirmer que « Z511 en DAS » se lit TYPE_DIAG = 'S' (étape 3 du plan, #148)
-- Oracle, schéma CORA_REC. Séjours ayant un RSS de TB_SYNTH_RSS fini de 2022 à 2025 (DATE_FIN), reliés aux diagnostics par le mouvement (TB_DIAG.ID_MVT -> TB_MVT.ID_SEJOUR, chemin-actes-diags-par-mouvement). Z511 par racine, sans TRIM (code-cim10-sans-point). Dictionnaire 2020 : TYPE_DIAG P principal, S significatif (DAS), R relié, D documentaire (MCO).
-- N_SEJOURS : ID_SEJOUR distincts ayant au moins un diagnostic Z511 de ce type dans l'année du dernier RSS.
-- Masquage : N_SEJOURS < 10 sort en <10. Aucune ligne de total.
WITH j AS (
  SELECT DISTINCT EXTRACT(YEAR FROM x.DATE_FIN) AS ANNEE, NVL(d.TYPE_DIAG, '(vide)') AS TYPE_DIAG, x.ID_SEJOUR
  FROM CORA_REC.TB_SYNTH_RSS x
  JOIN CORA_REC.TB_MVT m ON m.ID_SEJOUR = x.ID_SEJOUR
  JOIN CORA_REC.TB_DIAG d ON d.ID_MVT = m.ID_MVT
  WHERE x.DATE_FIN >= DATE '2022-01-01' AND x.DATE_FIN < DATE '2026-01-01'
    AND d.CODE_DIAG LIKE 'Z511%'
)
SELECT '20261120-z511-type-diag' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE, TYPE_DIAG,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE TO_CHAR(COUNT(*)) END AS N_SEJOURS
FROM j
GROUP BY ANNEE, TYPE_DIAG
ORDER BY ANNEE, TYPE_DIAG;
