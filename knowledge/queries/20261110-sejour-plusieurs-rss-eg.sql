-- id: 20261110-sejour-plusieurs-rss-eg
-- system: cora
-- person_data: masked
-- purpose: étape 6 du plan (#133, enquête ghs-par-sejour), suite de 20261110-sejour-plusieurs-rss-etab-resultat : ID_ETABLIS étant vide, tester par une autre voie si les deux RSS d'un séjour sans séance, qui s'enchaînent le jour même par un transfert (mode 7), sont dans deux entités géographiques différentes du CHU (guide MCO 2026, chapitre I, § 2.1 : un RSS par séjour « dans une entité géographique donnée »)
-- Oracle, schéma CORA_REC. Mêmes RSS, séjours et paires que 20261110-sejour-plusieurs-rss-etab : RSS groupés (CODE_GHM renseigné, CODE_CMD différent de '90'), DATE_FIN du 2022-01-01 au 2025-12-31 ; séjours à deux RSS ou plus, sans RSS de séance (CMD 28) ; année du séjour = celle de la plus grande DATE_FIN de ses RSS ; paires d'un RSS et du suivant rangés par DATE_DEBUT.
-- Années 2022 à 2024 seulement : en 2025, la somme des cellules redonnerait le nombre de paires, masqué dans 20261110-sejour-plusieurs-rss-ecarts-resultat.
-- Entité géographique (EG) d'un RSS, d'après dictionnaire-cora-2020 : ses RUM (TB_SYNTH_RUM.ID_RSS), l'UF de chaque RUM (ID_UNITE_HEBERG, identifiant de TB_UNITE, uf-du-rum-hebergement), l'EG de l'UF (TB_EG_UNITE.ID_UNITE, puis TB_EG, « Numéro de finess géographique »). EG_PREC et EG_SUIV : CODE_EG de l'EG commune à tous les RUM du RSS ; 'SANS_RUM' si le RSS n'a pas de RUM ; 'SANS_EG' si un RUM n'a pas d'UF ou si son UF n'a pas d'EG ; 'PLUSIEURS' si une UF a plusieurs EG ou si les RUM du RSS sont dans plusieurs EG. LIB_PREC, LIB_SUIV : LIBELLE_EG (des sites, pas des personnes).
-- Colonnes : ANNEE, EG_PREC, LIB_PREC, EG_SUIV, LIB_SUIV, MEME_EG (O si les deux EG sont la même, N sinon, ? si l'une n'est pas une EG), N_PAIRES. Une ligne par combinaison présente ; une combinaison absente vaut 0.
-- Masquage : tout effectif < 10 sort en <10. Suppression secondaire (règle 4) : le total d'une année est le nombre de paires, visible pour 2022 à 2024 dans 20261110-sejour-plusieurs-rss-etab-resultat (N_ETAB_DIFFERENT) ; si une seule cellule de l'année sort en <10, la plus petite des autres sort en « masqué ». Aucune ligne de total.
WITH r AS (
  SELECT s.ID_RSS, s.ID_SEJOUR, s.DATE_DEBUT, s.DATE_FIN,
         CASE WHEN TRIM(s.CODE_CMD) = '28' THEN 1 ELSE 0 END AS SEANCE
  FROM CORA_REC.TB_SYNTH_RSS s
  WHERE s.DATE_FIN >= DATE '2022-01-01' AND s.DATE_FIN < DATE '2026-01-01'
    AND TRIM(s.CODE_GHM) IS NOT NULL AND TRIM(s.CODE_CMD) <> '90'
),
multi AS (
  SELECT ID_SEJOUR, EXTRACT(YEAR FROM MAX(DATE_FIN)) AS ANNEE
  FROM r
  GROUP BY ID_SEJOUR
  HAVING COUNT(*) >= 2 AND MAX(SEANCE) = 0
),
rm AS (
  SELECT r.ID_RSS, r.ID_SEJOUR, m.ANNEE, r.DATE_DEBUT, r.DATE_FIN
  FROM r
  JOIN multi m ON m.ID_SEJOUR = r.ID_SEJOUR
  WHERE m.ANNEE <= 2024
),
ueg AS (
  SELECT ID_UNITE, COUNT(DISTINCT ID_EG) AS NEG, MIN(ID_EG) AS ID_EG
  FROM CORA_REC.TB_EG_UNITE
  GROUP BY ID_UNITE
),
rum_eg AS (
  SELECT u.ID_RSS,
         CASE WHEN u.ID_UNITE_HEBERG IS NULL OR g.NEG IS NULL THEN 1 ELSE 0 END AS SANS,
         CASE WHEN g.NEG > 1 THEN 1 ELSE 0 END AS MULT,
         g.ID_EG
  FROM CORA_REC.TB_SYNTH_RUM u
  JOIN rm ON rm.ID_RSS = u.ID_RSS
  LEFT JOIN ueg g ON g.ID_UNITE = u.ID_UNITE_HEBERG
),
rss_eg AS (
  SELECT ID_RSS, MAX(SANS) AS SANS, MAX(MULT) AS MULT,
         COUNT(DISTINCT ID_EG) AS NDIST, MIN(ID_EG) AS ID_EG
  FROM rum_eg
  GROUP BY ID_RSS
),
lab AS (
  SELECT rm.ID_RSS, rm.ID_SEJOUR, rm.ANNEE, rm.DATE_DEBUT, rm.DATE_FIN,
         CASE WHEN x.ID_RSS IS NULL THEN 'SANS_RUM'
              WHEN x.SANS = 1 THEN 'SANS_EG'
              WHEN x.MULT = 1 OR x.NDIST > 1 THEN 'PLUSIEURS'
              ELSE TRIM(e.CODE_EG) END AS EG,
         CASE WHEN x.ID_RSS IS NOT NULL AND x.SANS = 0 AND x.MULT = 0 AND x.NDIST = 1
              THEN TRIM(e.LIBELLE_EG) END AS LIB
  FROM rm
  LEFT JOIN rss_eg x ON x.ID_RSS = rm.ID_RSS
  LEFT JOIN CORA_REC.TB_EG e ON e.ID_EG = x.ID_EG
),
ord AS (
  SELECT ANNEE, EG, LIB,
         LEAD(EG) OVER (PARTITION BY ID_SEJOUR ORDER BY DATE_DEBUT, DATE_FIN, ID_RSS) AS EG_SUIV,
         LEAD(LIB) OVER (PARTITION BY ID_SEJOUR ORDER BY DATE_DEBUT, DATE_FIN, ID_RSS) AS LIB_SUIV,
         LEAD(ID_RSS) OVER (PARTITION BY ID_SEJOUR ORDER BY DATE_DEBUT, DATE_FIN, ID_RSS) AS RSS_SUIV
  FROM lab
),
c AS (
  SELECT ANNEE, EG AS EG_PREC, LIB AS LIB_PREC, EG_SUIV, LIB_SUIV, COUNT(*) AS N
  FROM ord
  WHERE RSS_SUIV IS NOT NULL
  GROUP BY ANNEE, EG, LIB, EG_SUIV, LIB_SUIV
),
k AS (
  SELECT c.ANNEE, c.EG_PREC, c.LIB_PREC, c.EG_SUIV, c.LIB_SUIV, c.N,
         SUM(CASE WHEN N < 10 THEN 1 ELSE 0 END) OVER (PARTITION BY ANNEE) AS NB_PETITES,
         ROW_NUMBER() OVER (PARTITION BY ANNEE ORDER BY CASE WHEN N < 10 THEN 1 ELSE 0 END, N, EG_PREC, EG_SUIV) AS RANG_GRANDES
  FROM c
)
SELECT '20261110-sejour-plusieurs-rss-eg' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE, EG_PREC, LIB_PREC, EG_SUIV, LIB_SUIV,
       CASE WHEN EG_PREC IN ('SANS_RUM', 'SANS_EG', 'PLUSIEURS') OR EG_SUIV IN ('SANS_RUM', 'SANS_EG', 'PLUSIEURS') THEN '?'
            WHEN EG_PREC = EG_SUIV THEN 'O' ELSE 'N' END AS MEME_EG,
       CASE WHEN N < 10 THEN '<10'
            WHEN NB_PETITES = 1 AND RANG_GRANDES = 1 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N_PAIRES
FROM k
ORDER BY ANNEE, EG_PREC, EG_SUIV;
