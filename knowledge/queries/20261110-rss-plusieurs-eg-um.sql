-- id: 20261110-rss-plusieurs-eg-um
-- system: cora
-- person_data: masked
-- purpose: étape 6 du plan (#133, enquête ghs-par-sejour), suite de 20261110-rss-plusieurs-eg-resultat : les RSS dont les RUM sont dans deux entités géographiques (EG) d'après l'UF d'hébergement changent presque tous d'EG par une mutation (mode 6), ce que le guide MCO 2026 (chapitre I, § 1) n'admet pas. Distinguer une erreur de codage (l'UM change d'EG) d'un hébergement dans une autre EG (même UM, ou UM de la même EG)
-- Oracle, schéma CORA_REC. Mêmes RSS que 20261110-rss-plusieurs-eg : RSS groupés (CODE_GHM renseigné, CODE_CMD différent de '90'), DATE_FIN du 2022-01-01 au 2025-12-31, année = celle de DATE_FIN, à deux RUM ou plus ; EG d'un RUM = EG de son UF d'hébergement (ID_UNITE_HEBERG, TB_EG_UNITE, si l'UF a une seule EG) ; on garde les RSS dont les RUM sont dans deux EG ou plus.
-- Pour chacun, le premier changement d'EG : le RUM qui le précède et le suivant (RUM rangés par DATE_DEBUT_RUM, DATE_FIN_RUM, ID_RUM, en sautant les RUM sans EG). UM d'un RUM : TB_SYNTH_RUM.ID_UNITE_MEDICALE. EG d'une UM, d'après dictionnaire-cora-2020 (TB_UNITE_MEDICALE n'a pas d'EG) : l'EG de ses UF (TB_UNITE_M_UNITE, tous les liens sans filtre de date, historique-rattachement-uf-um-cora), si elles sont toutes dans une seule EG.
-- CLASSE : 1_MEME_UM : les deux RUM ont la même UM (seul l'hébergement change d'EG) ; 2_UM_EG_DIFFERENTE : UM différentes, d'EG connues et différentes (changement d'EG réel codé en mutation) ; 3_UM_MEME_EG : UM différentes de la même EG ; 4_UM_EG_INCONNUE : UM absente, sans UF, ou à UF dans plusieurs EG. N_RSS : RSS de la classe.
-- Format long : une ligne par année et par classe présente.
-- Masquage : tout effectif < 10 sort en <10. Suppression secondaire (règle 4) : les classes d'une année font N_RSS_PLUSIEURS_EG de 20261110-rss-plusieurs-eg-resultat, masqué là-bas ; pour qu'il ne se retrouve pas par la somme, les deux plus petites classes de chaque année sont toujours cachées (<10 ou « masqué »). Aucune ligne de total.
WITH r AS (
  SELECT s.ID_RSS, EXTRACT(YEAR FROM s.DATE_FIN) AS ANNEE
  FROM CORA_REC.TB_SYNTH_RSS s
  WHERE s.DATE_FIN >= DATE '2022-01-01' AND s.DATE_FIN < DATE '2026-01-01'
    AND TRIM(s.CODE_GHM) IS NOT NULL AND TRIM(s.CODE_CMD) <> '90'
),
ueg AS (
  SELECT ID_UNITE, COUNT(DISTINCT ID_EG) AS NEG, MIN(ID_EG) AS ID_EG
  FROM CORA_REC.TB_EG_UNITE
  GROUP BY ID_UNITE
),
umeg AS (
  SELECT mu.ID_UNITE_MED, COUNT(DISTINCT g.ID_EG) AS NEG, MIN(g.ID_EG) AS ID_EG
  FROM CORA_REC.TB_UNITE_M_UNITE mu
  JOIN ueg g ON g.ID_UNITE = mu.ID_UNITE AND g.NEG = 1
  GROUP BY mu.ID_UNITE_MED
),
rum AS (
  SELECT u.ID_RSS, u.ID_RUM, u.DATE_DEBUT_RUM, u.DATE_FIN_RUM, u.ID_UNITE_MEDICALE AS UM,
         CASE WHEN g.NEG = 1 THEN g.ID_EG END AS EG
  FROM CORA_REC.TB_SYNTH_RUM u
  JOIN r ON r.ID_RSS = u.ID_RSS
  LEFT JOIN ueg g ON g.ID_UNITE = u.ID_UNITE_HEBERG
),
peg AS (
  SELECT ID_RSS
  FROM rum
  GROUP BY ID_RSS
  HAVING COUNT(*) >= 2 AND COUNT(DISTINCT EG) >= 2
),
seq AS (
  SELECT m.ID_RSS, m.EG, m.UM, m.DATE_DEBUT_RUM, m.DATE_FIN_RUM, m.ID_RUM,
         LEAD(m.EG) OVER (PARTITION BY m.ID_RSS ORDER BY m.DATE_DEBUT_RUM, m.DATE_FIN_RUM, m.ID_RUM) AS EG_SUIV,
         LEAD(m.UM) OVER (PARTITION BY m.ID_RSS ORDER BY m.DATE_DEBUT_RUM, m.DATE_FIN_RUM, m.ID_RUM) AS UM_SUIV
  FROM rum m
  JOIN peg p ON p.ID_RSS = m.ID_RSS
  WHERE m.EG IS NOT NULL
),
chg AS (
  SELECT ID_RSS, UM, UM_SUIV,
         ROW_NUMBER() OVER (PARTITION BY ID_RSS ORDER BY DATE_DEBUT_RUM, DATE_FIN_RUM, ID_RUM) AS RG
  FROM seq
  WHERE EG_SUIV IS NOT NULL AND EG_SUIV <> EG
),
cl AS (
  SELECT r.ANNEE,
         CASE WHEN c.UM IS NOT NULL AND c.UM = c.UM_SUIV THEN '1_MEME_UM'
              WHEN e1.NEG = 1 AND e2.NEG = 1 AND e1.ID_EG <> e2.ID_EG THEN '2_UM_EG_DIFFERENTE'
              WHEN e1.NEG = 1 AND e2.NEG = 1 AND e1.ID_EG = e2.ID_EG THEN '3_UM_MEME_EG'
              ELSE '4_UM_EG_INCONNUE' END AS CLASSE
  FROM chg c
  JOIN r ON r.ID_RSS = c.ID_RSS
  LEFT JOIN umeg e1 ON e1.ID_UNITE_MED = c.UM
  LEFT JOIN umeg e2 ON e2.ID_UNITE_MED = c.UM_SUIV
  WHERE c.RG = 1
),
a AS (
  SELECT ANNEE, CLASSE, COUNT(*) AS N
  FROM cl
  GROUP BY ANNEE, CLASSE
),
k AS (
  SELECT ANNEE, CLASSE, N,
         ROW_NUMBER() OVER (PARTITION BY ANNEE ORDER BY N, CLASSE) AS RANG
  FROM a
)
SELECT '20261110-rss-plusieurs-eg-um' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE, CLASSE,
       CASE WHEN N < 10 THEN '<10' WHEN RANG <= 2 THEN 'masqué' ELSE TO_CHAR(N) END AS N_RSS
FROM k
ORDER BY ANNEE, CLASSE;
