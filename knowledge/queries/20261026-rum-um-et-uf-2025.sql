-- id: 20261026-rum-um-et-uf-2025
-- system: cora
-- person_data: masked
-- purpose: vérifier ce que portent les colonnes d'unité d'un RUM : ID_UNITE_MEDICALE est-il une UM, ID_UNITE_HEBERG une UF, liée à cette UM, et la même que l'UF de ses mouvements (TB_MVT_RUM, TB_MVT.ID_UNITE_M) (étape « TB_UNITE, UF et UM » du plan, issue #108)
-- Oracle, schéma CORA_REC. RUM terminés de janvier à septembre 2025 (par DATE_FIN_RUM, comme 20261022-rum-uf-colonnes-remplissage). Un RUM compte une fois dans chaque colonne.
-- N_UM_DANS_TB_UNITE_MEDICALE : ID_UNITE_MEDICALE égal à un ID_UNITE_MED. N_UM_EGAL_ID_TB_UNITE : le même nombre égal à un TB_UNITE.ID_UNITE (test que l'identifiant d'UM n'est pas un identifiant d'UF).
-- N_HEBERG_DANS_TB_UNITE : ID_UNITE_HEBERG égal à un TB_UNITE.ID_UNITE. N_HEBERG_EGAL_ID_UM : égal à un ID_UNITE_MED (test inverse).
-- N_HEBERG_LIEE_A_L_UM_DU_RUM : une ligne de TB_UNITE_M_UNITE (à une date quelconque) relie l'UF d'hébergement à l'UM du RUM.
-- N_HEBERG_EGALE_UF_D_UN_MVT : le code de l'UF d'hébergement est TRIM(ID_UNITE_M) d'un mouvement du RUM (TB_MVT_RUM, puis TB_MVT).
-- Masquage : chaque effectif de 1 à 9 sort en <10. Aucune ligne de total.
SELECT '20261026-rum-um-et-uf-2025' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE TO_CHAR(COUNT(*)) END AS N_RUM,
       CASE WHEN COUNT(um.ID_UNITE_MED) BETWEEN 1 AND 9 THEN '<10' ELSE TO_CHAR(COUNT(um.ID_UNITE_MED)) END AS N_UM_DANS_TB_UNITE_MEDICALE,
       CASE WHEN COUNT(ua.ID_UNITE) BETWEEN 1 AND 9 THEN '<10' ELSE TO_CHAR(COUNT(ua.ID_UNITE)) END AS N_UM_EGAL_ID_TB_UNITE,
       CASE WHEN COUNT(uh.ID_UNITE) BETWEEN 1 AND 9 THEN '<10' ELSE TO_CHAR(COUNT(uh.ID_UNITE)) END AS N_HEBERG_DANS_TB_UNITE,
       CASE WHEN COUNT(uh2.ID_UNITE_MED) BETWEEN 1 AND 9 THEN '<10' ELSE TO_CHAR(COUNT(uh2.ID_UNITE_MED)) END AS N_HEBERG_EGAL_ID_UM,
       CASE WHEN SUM(CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_UNITE_M_UNITE l
                                       WHERE l.ID_UNITE = r.ID_UNITE_HEBERG AND l.ID_UNITE_MED = r.ID_UNITE_MEDICALE)
                          THEN 1 ELSE 0 END) BETWEEN 1 AND 9 THEN '<10'
            ELSE TO_CHAR(SUM(CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_UNITE_M_UNITE l
                                               WHERE l.ID_UNITE = r.ID_UNITE_HEBERG AND l.ID_UNITE_MED = r.ID_UNITE_MEDICALE)
                                  THEN 1 ELSE 0 END)) END AS N_HEBERG_LIEE_A_L_UM_DU_RUM,
       CASE WHEN SUM(CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_MVT_RUM mr
                                       JOIN CORA_REC.TB_MVT m ON m.ID_MVT = mr.ID_MVT
                                       WHERE mr.ID_RUM = r.ID_RUM AND TRIM(m.ID_UNITE_M) = TRIM(uh.CODE_UNITE))
                          THEN 1 ELSE 0 END) BETWEEN 1 AND 9 THEN '<10'
            ELSE TO_CHAR(SUM(CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_MVT_RUM mr
                                               JOIN CORA_REC.TB_MVT m ON m.ID_MVT = mr.ID_MVT
                                               WHERE mr.ID_RUM = r.ID_RUM AND TRIM(m.ID_UNITE_M) = TRIM(uh.CODE_UNITE))
                                  THEN 1 ELSE 0 END)) END AS N_HEBERG_EGALE_UF_D_UN_MVT
FROM CORA_REC.TB_SYNTH_RUM r
LEFT JOIN CORA_REC.TB_UNITE_MEDICALE um ON um.ID_UNITE_MED = r.ID_UNITE_MEDICALE
LEFT JOIN CORA_REC.TB_UNITE ua ON ua.ID_UNITE = r.ID_UNITE_MEDICALE
LEFT JOIN CORA_REC.TB_UNITE uh ON uh.ID_UNITE = r.ID_UNITE_HEBERG
LEFT JOIN CORA_REC.TB_UNITE_MEDICALE uh2 ON uh2.ID_UNITE_MED = r.ID_UNITE_HEBERG
WHERE r.DATE_FIN_RUM >= DATE '2025-01-01'
  AND r.DATE_FIN_RUM < DATE '2026-01-01'
  AND EXTRACT(MONTH FROM r.DATE_FIN_RUM) <= 9;
