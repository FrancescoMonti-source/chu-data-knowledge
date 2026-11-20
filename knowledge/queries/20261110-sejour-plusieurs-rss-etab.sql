-- id: 20261110-sejour-plusieurs-rss-etab
-- system: cora
-- person_data: masked
-- purpose: étape 6 du plan (#133, enquête ghs-par-sejour), suite de 20261110-sejour-plusieurs-rss-ecarts-resultat : dans les séjours à plusieurs RSS sans séance, un RSS suit le précédent le jour même ; le guide MCO 2026 (chapitre I, § 2.1) n'admet qu'un RSS par séjour « dans une entité géographique donnée » : tester si les deux RSS ont des établissements différents (TB_SYNTH_RSS.ID_ETABLIS, lien sur TB_ETABLISSEMENT d'après dictionnaire-cora-2020) et s'ils s'enchaînent par un transfert (mode 7)
-- Oracle, schéma CORA_REC. Mêmes RSS, séjours, années et paires que 20261110-sejour-plusieurs-rss-ecarts : RSS groupés (CODE_GHM renseigné, CODE_CMD différent de '90'), DATE_FIN du 2022-01-01 au 2025-12-31 ; séjours à deux RSS ou plus, sans RSS de séance (CMD 28) ; paires d'un RSS et du suivant rangés par DATE_DEBUT.
-- Colonnes, par année : N_ETAB_DIFFERENT : les deux RSS ont des ID_ETABLIS différents (ou l'un est vide) ; N_PREC_SORTIE_7 et N_PREC_SORTIE_8 : MODE_SORTIE du RSS précédent vaut 7 (transfert) ou 8 (domicile) ; N_SUIV_ENTREE_7 et N_SUIV_ENTREE_8 : MODE_ENTREE du suivant ; N_ETAB_DIFF_ET_7_7 : établissements différents, sortie 7 et entrée 7 ; ETABLIS_DISTINCTS : valeurs distinctes de ID_ETABLIS parmi les RSS de ces séjours (des établissements, pas des personnes).
-- Le nombre de paires n'est pas redonné : il se lit dans 20261110-sejour-plusieurs-rss-ecarts-resultat, où il est masqué pour 2025.
-- Masquage : tout effectif < 10 sort en <10. Suppression secondaire (règle 4) : N_ETAB_DIFF_ET_7_7 sort en « masqué » si son écart à N_ETAB_DIFFERENT, à N_PREC_SORTIE_7 ou à N_SUIV_ENTREE_7 vaut de 1 à 9 ; aucune colonne n'est un total d'autres colonnes ; les écarts au nombre de paires ne sont pas calculables ici, ce nombre étant masqué ou visible dans l'autre résultat : les colonnes dont l'écart au nombre de paires (NP) vaut de 1 à 9 sortent en « masqué ».
WITH r AS (
  SELECT s.ID_RSS, s.ID_SEJOUR, s.DATE_DEBUT, s.DATE_FIN, s.ID_ETABLIS,
         TRIM(s.MODE_ENTREE) AS ME, TRIM(s.MODE_SORTIE) AS MS,
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
ord AS (
  SELECT m.ANNEE, r.ID_ETABLIS, r.MS,
         LEAD(r.ID_ETABLIS) OVER (PARTITION BY r.ID_SEJOUR ORDER BY r.DATE_DEBUT, r.DATE_FIN, r.ID_RSS) AS ETAB_SUIV,
         LEAD(r.ME) OVER (PARTITION BY r.ID_SEJOUR ORDER BY r.DATE_DEBUT, r.DATE_FIN, r.ID_RSS) AS ME_SUIV,
         LEAD(r.ID_RSS) OVER (PARTITION BY r.ID_SEJOUR ORDER BY r.DATE_DEBUT, r.DATE_FIN, r.ID_RSS) AS RSS_SUIV
  FROM r
  JOIN multi m ON m.ID_SEJOUR = r.ID_SEJOUR
),
a AS (
  SELECT ANNEE,
         COUNT(*) AS NP,
         SUM(CASE WHEN ID_ETABLIS IS NULL OR ETAB_SUIV IS NULL OR ID_ETABLIS <> ETAB_SUIV THEN 1 ELSE 0 END) AS ED,
         SUM(CASE WHEN MS = '7' THEN 1 ELSE 0 END) AS S7,
         SUM(CASE WHEN MS = '8' THEN 1 ELSE 0 END) AS S8,
         SUM(CASE WHEN ME_SUIV = '7' THEN 1 ELSE 0 END) AS E7,
         SUM(CASE WHEN ME_SUIV = '8' THEN 1 ELSE 0 END) AS E8,
         SUM(CASE WHEN (ID_ETABLIS IS NULL OR ETAB_SUIV IS NULL OR ID_ETABLIS <> ETAB_SUIV)
                   AND MS = '7' AND ME_SUIV = '7' THEN 1 ELSE 0 END) AS ED77
  FROM ord
  WHERE RSS_SUIV IS NOT NULL
  GROUP BY ANNEE
),
e AS (
  SELECT m.ANNEE, COUNT(DISTINCT r.ID_ETABLIS) AS NE
  FROM r
  JOIN multi m ON m.ID_SEJOUR = r.ID_SEJOUR
  GROUP BY m.ANNEE
)
SELECT '20261110-sejour-plusieurs-rss-etab' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       a.ANNEE,
       CASE WHEN a.ED < 10 THEN '<10' WHEN a.NP - a.ED BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(a.ED) END AS N_ETAB_DIFFERENT,
       CASE WHEN a.S7 < 10 THEN '<10' WHEN a.NP - a.S7 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(a.S7) END AS N_PREC_SORTIE_7,
       CASE WHEN a.S8 < 10 THEN '<10' WHEN a.NP - a.S8 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(a.S8) END AS N_PREC_SORTIE_8,
       CASE WHEN a.E7 < 10 THEN '<10' WHEN a.NP - a.E7 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(a.E7) END AS N_SUIV_ENTREE_7,
       CASE WHEN a.E8 < 10 THEN '<10' WHEN a.NP - a.E8 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(a.E8) END AS N_SUIV_ENTREE_8,
       CASE WHEN a.ED77 < 10 THEN '<10'
            WHEN a.NP - a.ED77 BETWEEN 1 AND 9 OR a.ED - a.ED77 BETWEEN 1 AND 9
              OR a.S7 - a.ED77 BETWEEN 1 AND 9 OR a.E7 - a.ED77 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(a.ED77) END AS N_ETAB_DIFF_ET_7_7,
       TO_CHAR(e.NE) AS ETABLIS_DISTINCTS
FROM a
JOIN e ON e.ANNEE = a.ANNEE
ORDER BY a.ANNEE;
