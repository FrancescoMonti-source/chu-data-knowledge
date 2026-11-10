-- id: 20261110-sejour-plusieurs-rss-type
-- system: cora
-- person_data: masked
-- purpose: étape 6 du plan (#133, enquête ghs-par-sejour), suite de 20261110-sejour-plusieurs-rss-resultat : les séjours à plusieurs RSS sans séance (environ 2 800 par an) n'ont presque jamais de mouvement hors RSS entre deux RSS, et leurs RSS sont séparés de plusieurs jours ; tester l'hypothèse d'une venue administrative qui couvre des hospitalisations de jour répétées
-- Oracle, schéma CORA_REC. Mêmes RSS, mêmes séjours et même année que 20261110-sejour-plusieurs-rss : RSS groupés (CODE_GHM renseigné, CODE_CMD différent de '90'), DATE_FIN du 2022-01-01 au 2025-12-31 ; séjours (ID_SEJOUR) à deux RSS ou plus ; ici, seulement ceux dont aucun RSS n'est une séance (CMD 28).
-- Niveau SEJOUR : N_SEJ ; par TRIM(TB_SEJOUR.TYPE_SEJOUR) : N_TYPE_HDJ ('HDJ'), N_TYPE_MCO ('MCO'), N_TYPE_AUTRE (autre ou vide) (type-sejour-suit-mode-hospit-um) ; N_SEJ_TOUS_RSS_0_NUIT : chacun de ses RSS a TRUNC(DATE_FIN) = TRUNC(DATE_DEBUT) ; N_SEJ_30J_PLUS : TRUNC(TB_SEJOUR.DATE_SORTIE) − TRUNC(DATE_ENTREE) >= 30 ; N_SEJ_SANS_SORTIE : DATE_SORTIE vide.
-- Niveau RSS (les RSS de ces séjours) : N_RSS ; N_RSS_0_NUIT ; parmi tous : N_RSS_CK_J (type C ou K et niveau J, chirurgie ou actes ambulatoires), N_RSS_TYPE_M (type M) (separer-ambulatoire-par-ghm) ; N_RSS_AUTRE_TYPE : les autres.
-- Masquage : tout effectif < 10 sort en <10. Suppression secondaire (règle 4) : les trois N_TYPE_* font N_SEJ, et N_RSS_CK_J, N_RSS_TYPE_M, N_RSS_AUTRE_TYPE font N_RSS : si l'un vaut de 1 à 9, le total sort en « masqué » ; N_SEJ_TOUS_RSS_0_NUIT, N_SEJ_30J_PLUS, N_SEJ_SANS_SORTIE sortent en « masqué » si leur écart à N_SEJ vaut de 1 à 9, N_RSS_0_NUIT si son écart à N_RSS vaut de 1 à 9. Aucune ligne de total.
WITH r AS (
  SELECT s.ID_RSS, s.ID_SEJOUR, s.DATE_DEBUT, s.DATE_FIN,
         TRIM(s.CODE_GHM) AS GHM4,
         CASE WHEN TRIM(s.CODE_CMD) = '28' THEN 1 ELSE 0 END AS SEANCE
  FROM CORA_REC.TB_SYNTH_RSS s
  WHERE s.DATE_FIN >= DATE '2022-01-01' AND s.DATE_FIN < DATE '2026-01-01'
    AND TRIM(s.CODE_GHM) IS NOT NULL AND TRIM(s.CODE_CMD) <> '90'
),
multi AS (
  SELECT ID_SEJOUR, EXTRACT(YEAR FROM MAX(DATE_FIN)) AS ANNEE,
         MIN(CASE WHEN TRUNC(DATE_FIN) = TRUNC(DATE_DEBUT) THEN 1 ELSE 0 END) AS TOUS_0
  FROM r
  GROUP BY ID_SEJOUR
  HAVING COUNT(*) >= 2 AND MAX(SEANCE) = 0
),
niv_sej AS (
  SELECT m.ANNEE,
         COUNT(*) AS N_SEJ,
         SUM(CASE WHEN TRIM(t.TYPE_SEJOUR) = 'HDJ' THEN 1 ELSE 0 END) AS T_HDJ,
         SUM(CASE WHEN TRIM(t.TYPE_SEJOUR) = 'MCO' THEN 1 ELSE 0 END) AS T_MCO,
         SUM(CASE WHEN TRIM(t.TYPE_SEJOUR) IS NULL OR TRIM(t.TYPE_SEJOUR) NOT IN ('HDJ', 'MCO') THEN 1 ELSE 0 END) AS T_AUTRE,
         SUM(m.TOUS_0) AS TOUS_0,
         SUM(CASE WHEN TRUNC(t.DATE_SORTIE) - TRUNC(t.DATE_ENTREE) >= 30 THEN 1 ELSE 0 END) AS D30,
         SUM(CASE WHEN t.DATE_SORTIE IS NULL THEN 1 ELSE 0 END) AS SANS_SORTIE
  FROM multi m
  JOIN CORA_REC.TB_SEJOUR t ON t.ID_SEJOUR = m.ID_SEJOUR
  GROUP BY m.ANNEE
),
niv_rss AS (
  SELECT m.ANNEE,
         COUNT(*) AS N_RSS,
         SUM(CASE WHEN TRUNC(r.DATE_FIN) = TRUNC(r.DATE_DEBUT) THEN 1 ELSE 0 END) AS R0,
         SUM(CASE WHEN SUBSTR(r.GHM4, 1, 1) IN ('C', 'K') AND SUBSTR(r.GHM4, -1) = 'J' THEN 1 ELSE 0 END) AS R_CKJ,
         SUM(CASE WHEN SUBSTR(r.GHM4, 1, 1) = 'M' THEN 1 ELSE 0 END) AS R_M,
         SUM(CASE WHEN NOT (SUBSTR(r.GHM4, 1, 1) IN ('C', 'K') AND SUBSTR(r.GHM4, -1) = 'J')
                   AND SUBSTR(r.GHM4, 1, 1) <> 'M' THEN 1 ELSE 0 END) AS R_AUTRE
  FROM r
  JOIN multi m ON m.ID_SEJOUR = r.ID_SEJOUR
  GROUP BY m.ANNEE
)
SELECT '20261110-sejour-plusieurs-rss-type' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       s.ANNEE,
       CASE WHEN s.N_SEJ < 10 THEN '<10'
            WHEN s.T_HDJ BETWEEN 1 AND 9 OR s.T_MCO BETWEEN 1 AND 9 OR s.T_AUTRE BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(s.N_SEJ) END AS N_SEJ,
       CASE WHEN s.T_HDJ < 10 THEN '<10' ELSE TO_CHAR(s.T_HDJ) END AS N_TYPE_HDJ,
       CASE WHEN s.T_MCO < 10 THEN '<10' ELSE TO_CHAR(s.T_MCO) END AS N_TYPE_MCO,
       CASE WHEN s.T_AUTRE < 10 THEN '<10' ELSE TO_CHAR(s.T_AUTRE) END AS N_TYPE_AUTRE,
       CASE WHEN s.TOUS_0 < 10 THEN '<10' WHEN s.N_SEJ - s.TOUS_0 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(s.TOUS_0) END AS N_SEJ_TOUS_RSS_0_NUIT,
       CASE WHEN s.D30 < 10 THEN '<10' WHEN s.N_SEJ - s.D30 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(s.D30) END AS N_SEJ_30J_PLUS,
       CASE WHEN s.SANS_SORTIE < 10 THEN '<10' WHEN s.N_SEJ - s.SANS_SORTIE BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(s.SANS_SORTIE) END AS N_SEJ_SANS_SORTIE,
       CASE WHEN p.N_RSS < 10 THEN '<10'
            WHEN p.R_CKJ BETWEEN 1 AND 9 OR p.R_M BETWEEN 1 AND 9 OR p.R_AUTRE BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(p.N_RSS) END AS N_RSS,
       CASE WHEN p.R0 < 10 THEN '<10' WHEN p.N_RSS - p.R0 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(p.R0) END AS N_RSS_0_NUIT,
       CASE WHEN p.R_CKJ < 10 THEN '<10' ELSE TO_CHAR(p.R_CKJ) END AS N_RSS_CK_J,
       CASE WHEN p.R_M < 10 THEN '<10' ELSE TO_CHAR(p.R_M) END AS N_RSS_TYPE_M,
       CASE WHEN p.R_AUTRE < 10 THEN '<10' ELSE TO_CHAR(p.R_AUTRE) END AS N_RSS_AUTRE_TYPE
FROM niv_sej s
JOIN niv_rss p ON p.ANNEE = s.ANNEE
ORDER BY s.ANNEE;
