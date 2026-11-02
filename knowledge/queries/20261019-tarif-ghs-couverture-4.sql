-- id: 20261019-tarif-ghs-couverture-4
-- system: cora
-- person_data: masked
-- purpose: par année de fin de RSS (2022 à aujourd'hui), mesurer la part de RSS groupés dont le GHM complet (CODE_CMD || CODE_GHM) ne trouve aucune ligne de CORA_REC.PMSI_LIB_GHS_TARIF (GHS = GHM sur 6 caractères) valide à la fin du RSS, pour trancher tarif-ghs-jointure-couverture (réfuté si, pour une année, plus de 95 % des RSS MCO groupés trouvent une ligne valide ; confirmé sinon) ; la borne DATE_FIN exclusive nourrit l'AM10 (c) de referentiels-pmsi-dans-cora
-- Version allégée de 20261019-tarif-ghs-couverture-2, arrêtée par le délai de 900 s ; la version 3 a aussi dépassé le délai : sa sous-requête corrélée relisait la table de tarif (non matérialisée) pour chaque groupe. Ici la table de tarif est matérialisée une fois et la présence d'un tarif se teste par une jointure sur les couples distincts (GHM complet, fin de mois). Les RSS sont d'abord comptés par (GHM complet, GHS 9999 ou non, mois de fin) ; la table de tarif est réduite à une ligne par (GHM complet, DATE_DEBUT, DATE_FIN) ; la jointure porte sur ces quelques milliers de groupes. Une seule condition (celle du claim, borne exclusive) et un seul niveau de sortie : les variantes INCL, SANS_DATE et PAR_CODE_GHS ne sont plus mesurées. La clé du claim est le GHM complet, pas CODE_GHS : CODE_GHS ne sert qu'à repérer le GHS 9999.
-- Oracle 11g, schéma CORA_REC. RSS dont DATE_FIN va du 2022-01-01 à aujourd'hui ; groupé : CODE_GHM renseigné et CODE_CMD différent de '90'. Toutes colonnes comparées après TRIM. Ligne valide à la date d : DATE_DEBUT <= d et DATE_FIN vide ou DATE_FIN > d (borne exclusive).
-- LIMITE : l'approximation est mensuelle. La date d est le dernier jour du mois de fin du RSS (LAST_DAY), pas la date de fin exacte. Un RSS terminé avant un changement de tarif en cours de mois est donc comparé au tarif suivant : les tarifs changeant le plus souvent au 1er mars, le décompte des RSS sans tarif peut différer légèrement du décompte au jour près de 20261019-tarif-ghs-couverture-2.
-- N_RSS ; N_RSS_SANS_TARIF : RSS sans aucune ligne valide ; N_RSS_GHS_9999 : RSS dont TRIM(CODE_GHS) = '9999'. PCT_AVEC_TARIF = 100 x (N_RSS - N_RSS_SANS_TARIF) / N_RSS, seulement si numérateur et dénominateur sont visibles.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N_RSS sort en « masqué » dès que N_RSS moins N_RSS_SANS_TARIF ou N_RSS moins N_RSS_GHS_9999 vaut de 1 à 9 . Aucune ligne de total.
-- Performance : environ 800 000 RSS lus une fois et réduits à quelques milliers de groupes (GHM x mois), joints à environ 7 000 lignes de tarif distinctes ; viser moins de 2 minutes.
WITH tt AS (
  SELECT /*+ MATERIALIZE */ TRIM(GHS) AS GHM6, TRUNC(DATE_DEBUT) AS DD, TRUNC(DATE_FIN) AS DF
  FROM CORA_REC.PMSI_LIB_GHS_TARIF
  GROUP BY TRIM(GHS), TRUNC(DATE_DEBUT), TRUNC(DATE_FIN)
),
g AS (
  SELECT /*+ MATERIALIZE */ EXTRACT(YEAR FROM s.DATE_FIN) AS ANNEE,
         LAST_DAY(TRUNC(s.DATE_FIN)) AS D,
         TRIM(s.CODE_CMD) || TRIM(s.CODE_GHM) AS GHM6,
         CASE WHEN TRIM(s.CODE_GHS) = '9999' THEN 1 ELSE 0 END AS EST_9999,
         COUNT(*) AS N
  FROM CORA_REC.TB_SYNTH_RSS s
  WHERE s.DATE_FIN >= DATE '2022-01-01' AND s.DATE_FIN < TRUNC(SYSDATE) + 1
    AND TRIM(s.CODE_GHM) IS NOT NULL AND TRIM(s.CODE_CMD) <> '90'
  GROUP BY EXTRACT(YEAR FROM s.DATE_FIN), LAST_DAY(TRUNC(s.DATE_FIN)),
           TRIM(s.CODE_CMD) || TRIM(s.CODE_GHM),
           CASE WHEN TRIM(s.CODE_GHS) = '9999' THEN 1 ELSE 0 END
),
tm AS (
  SELECT DISTINCT g.GHM6, g.D
  FROM g
  JOIN tt ON tt.GHM6 = g.GHM6 AND tt.DD <= g.D AND (tt.DF IS NULL OR tt.DF > g.D)
),
gm AS (
  SELECT g.ANNEE, g.N, g.EST_9999,
         CASE WHEN tm.GHM6 IS NULL THEN 0 ELSE 1 END AS M
  FROM g
  LEFT JOIN tm ON tm.GHM6 = g.GHM6 AND tm.D = g.D
),
a AS (
  SELECT ANNEE,
         SUM(N) AS N,
         SUM(CASE WHEN M = 0 THEN N ELSE 0 END) AS S,
         SUM(CASE WHEN EST_9999 = 1 THEN N ELSE 0 END) AS C9
  FROM gm
  GROUP BY ANNEE
)
SELECT '20261019-tarif-ghs-couverture-4' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - S BETWEEN 1 AND 9 OR N - C9 BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(N) END AS N_RSS,
       CASE WHEN S < 10 THEN '<10' ELSE TO_CHAR(S) END AS N_RSS_SANS_TARIF,
       CASE WHEN C9 < 10 THEN '<10' ELSE TO_CHAR(C9) END AS N_RSS_GHS_9999,
       CASE WHEN N >= 10 AND S >= 10 AND N - S NOT BETWEEN 1 AND 9 AND N - C9 NOT BETWEEN 1 AND 9
            THEN TO_CHAR(ROUND(100 * (N - S) / N, 2), 'FM990.00', 'NLS_NUMERIC_CHARACTERS=''. ''') END AS PCT_AVEC_TARIF
FROM a
ORDER BY ANNEE;
