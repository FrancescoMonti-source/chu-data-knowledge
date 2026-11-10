-- id: 20261110-rss-plusieurs-eg
-- system: cora
-- person_data: masked
-- purpose: étape 6 du plan (#133, enquête ghs-par-sejour), suite de 20261110-sejour-plusieurs-rss-eg-resultat : le guide MCO 2026 (chapitre I, § 1) fait deux séjours-patients, donc deux RSS, d'une prise en charge dans deux entités géographiques ; compter, sur tous les RSS et pas seulement les séjours à plusieurs RSS, ceux dont les RUM sont dans plusieurs entités géographiques, et le mode de sortie du RUM au changement d'entité
-- Oracle, schéma CORA_REC. RSS groupés (CODE_GHM renseigné, CODE_CMD différent de '90'), DATE_FIN du 2022-01-01 au 2025-12-31, année = celle de DATE_FIN ; seuls les RSS à deux RUM ou plus (TB_SYNTH_RUM.ID_RSS) sont comptés.
-- Entité géographique (EG) d'un RUM, d'après dictionnaire-cora-2020 : son UF (ID_UNITE_HEBERG, identifiant de TB_UNITE, uf-du-rum-hebergement), puis TB_EG_UNITE. Une UF qui a une seule EG donne cette EG ; une UF qui en a plusieurs, ou aucune, ne donne pas d'EG.
-- Colonnes, par année : N_RSS_MULTI_RUM : RSS à deux RUM ou plus ; N_RSS_PLUSIEURS_EG : parmi eux, RSS dont les RUM qui ont une EG sont dans deux EG ou plus ; découpé selon le séjour (ID_SEJOUR) en N_PEG_SEJOUR_1_RSS (le séjour n'a que ce RSS) et N_PEG_SEJOUR_N_RSS (le séjour a d'autres RSS) ; et selon MODE_SORTIE du RUM qui précède le premier changement d'EG (RUM rangés par DATE_DEBUT_RUM, DATE_FIN_RUM, ID_RUM, en sautant les RUM sans EG) en N_PEG_SORTIE_6 (mutation), N_PEG_SORTIE_7 (transfert), N_PEG_SORTIE_AUTRE ; N_RSS_UF_PLUSIEURS_EG : RSS dont un RUM a une UF à plusieurs EG ; N_RSS_UF_SANS_EG : RSS dont un RUM n'a pas d'UF ou une UF sans EG. Thésaurus, pas des personnes, non masqués : N_EG (lignes de TB_EG), N_UF_PLUSIEURS_EG (UF de TB_EG_UNITE à plusieurs EG), N_UF_SANS_EG (UF de TB_UNITE absentes de TB_EG_UNITE).
-- Masquage : tout effectif < 10 sort en <10. Suppression secondaire (règle 4) : N_RSS_PLUSIEURS_EG a deux découpages (séjour ; mode de sortie) et est inclus dans N_RSS_MULTI_RUM. Il sort en « masqué » si une part d'un découpage est < 10 ou si son écart à N_RSS_MULTI_RUM vaut de 1 à 9 ; alors, dans chaque découpage sans part < 10, la plus petite part sort aussi en « masqué », pour que la somme des parts ne le redonne pas. N_RSS_UF_PLUSIEURS_EG et N_RSS_UF_SANS_EG sortent en « masqué » si leur écart à N_RSS_MULTI_RUM vaut de 1 à 9. Aucune ligne de total.
WITH r AS (
  SELECT s.ID_RSS, s.ID_SEJOUR, EXTRACT(YEAR FROM s.DATE_FIN) AS ANNEE
  FROM CORA_REC.TB_SYNTH_RSS s
  WHERE s.DATE_FIN >= DATE '2022-01-01' AND s.DATE_FIN < DATE '2026-01-01'
    AND TRIM(s.CODE_GHM) IS NOT NULL AND TRIM(s.CODE_CMD) <> '90'
),
nsej AS (
  SELECT ID_SEJOUR, COUNT(*) AS NRSS_SEJ
  FROM r
  GROUP BY ID_SEJOUR
),
ueg AS (
  SELECT ID_UNITE, COUNT(DISTINCT ID_EG) AS NEG, MIN(ID_EG) AS ID_EG
  FROM CORA_REC.TB_EG_UNITE
  GROUP BY ID_UNITE
),
rum AS (
  SELECT u.ID_RSS, u.ID_RUM, u.DATE_DEBUT_RUM, u.DATE_FIN_RUM,
         TRIM(u.MODE_SORTIE) AS MS,
         CASE WHEN u.ID_UNITE_HEBERG IS NULL OR g.NEG IS NULL THEN 1 ELSE 0 END AS SANS,
         CASE WHEN g.NEG > 1 THEN 1 ELSE 0 END AS MULT,
         CASE WHEN g.NEG = 1 THEN g.ID_EG END AS EG
  FROM CORA_REC.TB_SYNTH_RUM u
  JOIN r ON r.ID_RSS = u.ID_RSS
  LEFT JOIN ueg g ON g.ID_UNITE = u.ID_UNITE_HEBERG
),
multi_rum AS (
  SELECT ID_RSS, MAX(SANS) AS SANS, MAX(MULT) AS MULT, COUNT(DISTINCT EG) AS NDIST
  FROM rum
  GROUP BY ID_RSS
  HAVING COUNT(*) >= 2
),
seq AS (
  SELECT ID_RSS, EG, MS, DATE_DEBUT_RUM, DATE_FIN_RUM, ID_RUM,
         LEAD(EG) OVER (PARTITION BY ID_RSS ORDER BY DATE_DEBUT_RUM, DATE_FIN_RUM, ID_RUM) AS EG_SUIV
  FROM rum
  WHERE EG IS NOT NULL
),
chg AS (
  SELECT ID_RSS, MS,
         ROW_NUMBER() OVER (PARTITION BY ID_RSS ORDER BY DATE_DEBUT_RUM, DATE_FIN_RUM, ID_RUM) AS RG
  FROM seq
  WHERE EG_SUIV IS NOT NULL AND EG_SUIV <> EG
),
x AS (
  SELECT r.ANNEE, m.SANS, m.MULT,
         CASE WHEN m.NDIST >= 2 THEN 1 ELSE 0 END AS PEG,
         n.NRSS_SEJ, c.MS
  FROM multi_rum m
  JOIN r ON r.ID_RSS = m.ID_RSS
  JOIN nsej n ON n.ID_SEJOUR = r.ID_SEJOUR
  LEFT JOIN chg c ON c.ID_RSS = m.ID_RSS AND c.RG = 1
),
a AS (
  SELECT ANNEE,
         COUNT(*) AS NM,
         SUM(PEG) AS NP,
         SUM(CASE WHEN PEG = 1 AND NRSS_SEJ = 1 THEN 1 ELSE 0 END) AS S1,
         SUM(CASE WHEN PEG = 1 AND NRSS_SEJ > 1 THEN 1 ELSE 0 END) AS SN,
         SUM(CASE WHEN PEG = 1 AND MS = '6' THEN 1 ELSE 0 END) AS M6,
         SUM(CASE WHEN PEG = 1 AND MS = '7' THEN 1 ELSE 0 END) AS M7,
         SUM(CASE WHEN PEG = 1 AND (MS IS NULL OR MS NOT IN ('6', '7')) THEN 1 ELSE 0 END) AS MA,
         SUM(MULT) AS UM,
         SUM(SANS) AS US
  FROM x
  GROUP BY ANNEE
),
f AS (
  SELECT a.ANNEE, a.NM, a.NP, a.S1, a.SN, a.M6, a.M7, a.MA, a.UM, a.US,
         CASE WHEN a.S1 < 10 OR a.SN < 10 THEN 1 ELSE 0 END AS PETIT_SEJ,
         CASE WHEN a.M6 < 10 OR a.M7 < 10 OR a.MA < 10 THEN 1 ELSE 0 END AS PETIT_MS,
         CASE WHEN a.S1 < 10 OR a.SN < 10 OR a.M6 < 10 OR a.M7 < 10 OR a.MA < 10
                   OR a.NM - a.NP BETWEEN 1 AND 9 THEN 1 ELSE 0 END AS MASQ_NP,
         LEAST(a.M6, a.M7, a.MA) AS MIN_MS
  FROM a
),
u AS (
  SELECT (SELECT COUNT(*) FROM CORA_REC.TB_EG) AS N_EG,
         (SELECT COUNT(*) FROM ueg WHERE NEG > 1) AS N_UF_PLUSIEURS_EG,
         (SELECT COUNT(*) FROM CORA_REC.TB_UNITE t
           WHERE NOT EXISTS (SELECT 1 FROM CORA_REC.TB_EG_UNITE e WHERE e.ID_UNITE = t.ID_UNITE)) AS N_UF_SANS_EG
  FROM DUAL
)
SELECT '20261110-rss-plusieurs-eg' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       f.ANNEE,
       CASE WHEN f.NM < 10 THEN '<10' ELSE TO_CHAR(f.NM) END AS N_RSS_MULTI_RUM,
       CASE WHEN f.NP < 10 THEN '<10' WHEN f.MASQ_NP = 1 THEN 'masqué' ELSE TO_CHAR(f.NP) END AS N_RSS_PLUSIEURS_EG,
       CASE WHEN f.S1 < 10 THEN '<10'
            WHEN f.MASQ_NP = 1 AND f.PETIT_SEJ = 0 AND f.S1 <= f.SN THEN 'masqué'
            ELSE TO_CHAR(f.S1) END AS N_PEG_SEJOUR_1_RSS,
       CASE WHEN f.SN < 10 THEN '<10'
            WHEN f.MASQ_NP = 1 AND f.PETIT_SEJ = 0 AND f.SN < f.S1 THEN 'masqué'
            ELSE TO_CHAR(f.SN) END AS N_PEG_SEJOUR_N_RSS,
       CASE WHEN f.M6 < 10 THEN '<10'
            WHEN f.MASQ_NP = 1 AND f.PETIT_MS = 0 AND f.M6 = f.MIN_MS THEN 'masqué'
            ELSE TO_CHAR(f.M6) END AS N_PEG_SORTIE_6,
       CASE WHEN f.M7 < 10 THEN '<10'
            WHEN f.MASQ_NP = 1 AND f.PETIT_MS = 0 AND f.M7 = f.MIN_MS AND f.M6 <> f.MIN_MS THEN 'masqué'
            ELSE TO_CHAR(f.M7) END AS N_PEG_SORTIE_7,
       CASE WHEN f.MA < 10 THEN '<10'
            WHEN f.MASQ_NP = 1 AND f.PETIT_MS = 0 AND f.MA = f.MIN_MS AND f.M6 <> f.MIN_MS AND f.M7 <> f.MIN_MS THEN 'masqué'
            ELSE TO_CHAR(f.MA) END AS N_PEG_SORTIE_AUTRE,
       CASE WHEN f.UM < 10 THEN '<10' WHEN f.NM - f.UM BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(f.UM) END AS N_RSS_UF_PLUSIEURS_EG,
       CASE WHEN f.US < 10 THEN '<10' WHEN f.NM - f.US BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(f.US) END AS N_RSS_UF_SANS_EG,
       TO_CHAR(u.N_EG) AS N_EG,
       TO_CHAR(u.N_UF_PLUSIEURS_EG) AS N_UF_PLUSIEURS_EG,
       TO_CHAR(u.N_UF_SANS_EG) AS N_UF_SANS_EG
FROM f
CROSS JOIN u
ORDER BY f.ANNEE;
