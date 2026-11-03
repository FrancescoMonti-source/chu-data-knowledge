-- id: 20261022-rum-uf-attrib-par-annee
-- system: cora
-- person_data: masked
-- purpose: mesurer le remplissage de TB_SYNTH_RUM.ID_UF_ATTRIB par année, et la part des UF attribuées qui existent dans TB_UNITE (étape 2 du plan)
-- Oracle, schéma CORA_REC. RUM terminés de janvier à septembre de 2022 à 2026 (par année de DATE_FIN_RUM).
-- N_RUM : tous les RUM ; N_UF_RENSEIGNEE : ID_UF_ATTRIB non nul ; N_UF_DANS_TB_UNITE : ID_UF_ATTRIB trouvé dans TB_UNITE.ID_UNITE.
-- Masquage : chaque effectif < 10 sort en <10. Aucune ligne de total : rien ne permet de recalculer une case masquée.
SELECT '20261022-rum-uf-attrib-par-annee' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       EXTRACT(YEAR FROM r.DATE_FIN_RUM) AS ANNEE,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE TO_CHAR(COUNT(*)) END AS N_RUM,
       CASE WHEN COUNT(r.ID_UF_ATTRIB) < 10 THEN '<10' ELSE TO_CHAR(COUNT(r.ID_UF_ATTRIB)) END AS N_UF_RENSEIGNEE,
       CASE WHEN COUNT(u.ID_UNITE) < 10 THEN '<10' ELSE TO_CHAR(COUNT(u.ID_UNITE)) END AS N_UF_DANS_TB_UNITE
FROM CORA_REC.TB_SYNTH_RUM r
LEFT JOIN CORA_REC.TB_UNITE u ON u.ID_UNITE = r.ID_UF_ATTRIB
WHERE r.DATE_FIN_RUM >= DATE '2022-01-01'
  AND r.DATE_FIN_RUM < DATE '2027-01-01'
  AND EXTRACT(MONTH FROM r.DATE_FIN_RUM) <= 9
GROUP BY EXTRACT(YEAR FROM r.DATE_FIN_RUM)
ORDER BY 4;
