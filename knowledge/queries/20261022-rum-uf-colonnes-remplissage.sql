-- id: 20261022-rum-uf-colonnes-remplissage
-- system: cora
-- person_data: masked
-- purpose: trouver quelle colonne de TB_SYNTH_RUM donne l'UF du RUM, ID_UF_ATTRIB étant vide (20261022-rum-uf-attrib-par-annee) : mesurer, par année, le remplissage de UF_ATTRIB (code, VARCHAR2), ID_UNITE_HEBERG et ID_UNITE_RESP_MED (identifiants), et si leur valeur se joint à TB_UNITE (étape 2 du plan revu)
-- Oracle, schéma CORA_REC. RUM terminés de janvier à septembre de 2022 à 2026 (par année de DATE_FIN_RUM).
-- N_RUM : tous les RUM. Pour chaque colonne, N_<COL>_RENSEIGNE : valeur non vide (après TRIM pour UF_ATTRIB) ; N_<COL>_DANS_TB_UNITE : valeur trouvée dans TB_UNITE (TRIM(CODE_UNITE) pour UF_ATTRIB, ID_UNITE pour les deux autres).
-- Masquage : chaque effectif < 10 sort en <10. Aucune ligne de total : rien ne permet de recalculer une case masquée.
SELECT '20261022-rum-uf-colonnes-remplissage' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       EXTRACT(YEAR FROM r.DATE_FIN_RUM) AS ANNEE,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE TO_CHAR(COUNT(*)) END AS N_RUM,
       CASE WHEN COUNT(TRIM(r.UF_ATTRIB)) BETWEEN 1 AND 9 THEN '<10' ELSE TO_CHAR(COUNT(TRIM(r.UF_ATTRIB))) END AS N_UF_ATTRIB_RENSEIGNE,
       CASE WHEN COUNT(u1.ID_UNITE) BETWEEN 1 AND 9 THEN '<10' ELSE TO_CHAR(COUNT(u1.ID_UNITE)) END AS N_UF_ATTRIB_DANS_TB_UNITE,
       CASE WHEN COUNT(r.ID_UNITE_HEBERG) BETWEEN 1 AND 9 THEN '<10' ELSE TO_CHAR(COUNT(r.ID_UNITE_HEBERG)) END AS N_HEBERG_RENSEIGNE,
       CASE WHEN COUNT(u2.ID_UNITE) BETWEEN 1 AND 9 THEN '<10' ELSE TO_CHAR(COUNT(u2.ID_UNITE)) END AS N_HEBERG_DANS_TB_UNITE,
       CASE WHEN COUNT(r.ID_UNITE_RESP_MED) BETWEEN 1 AND 9 THEN '<10' ELSE TO_CHAR(COUNT(r.ID_UNITE_RESP_MED)) END AS N_RESP_MED_RENSEIGNE,
       CASE WHEN COUNT(u3.ID_UNITE) BETWEEN 1 AND 9 THEN '<10' ELSE TO_CHAR(COUNT(u3.ID_UNITE)) END AS N_RESP_MED_DANS_TB_UNITE
FROM CORA_REC.TB_SYNTH_RUM r
LEFT JOIN CORA_REC.TB_UNITE u1 ON TRIM(u1.CODE_UNITE) = TRIM(r.UF_ATTRIB)
LEFT JOIN CORA_REC.TB_UNITE u2 ON u2.ID_UNITE = r.ID_UNITE_HEBERG
LEFT JOIN CORA_REC.TB_UNITE u3 ON u3.ID_UNITE = r.ID_UNITE_RESP_MED
WHERE r.DATE_FIN_RUM >= DATE '2022-01-01'
  AND r.DATE_FIN_RUM < DATE '2027-01-01'
  AND EXTRACT(MONTH FROM r.DATE_FIN_RUM) <= 9
GROUP BY EXTRACT(YEAR FROM r.DATE_FIN_RUM)
ORDER BY 4;
