-- id: 20261019-lignes-par-numero-oproom
-- system: cora
-- person_data: masked
-- purpose: par année, combien de lignes de TB_INTERVENTION partagent le même numéro avant le tiret de NO_INTERVENTION_EXT (le numéro OpRoom I_KEY), pour chiffrer « une intervention peut avoir plusieurs lignes » (chainer-oproom-cora, AM6 : 99,1 % une ligne, 0,8 % deux, 0,1 % trois en 2025) ; si la part à plusieurs lignes dépasse quelques pour cent, la jointure doit dédoublonner par numéro avant de compter des interventions
-- Oracle, schéma CORA_REC, TB_INTERVENTION seule. Lignes dont NO_INTERVENTION_EXT contient un tiret, de DATE_INTERVENTION du 2023-11-01 au jour d'exécution. Le numéro est le texte avant le premier tiret ; il ne sort jamais, seulement des effectifs. ANNEE : année de la première ligne du numéro. NB_LIGNES : 1, 2, 3 ou '4 et plus'.
-- N_NUMEROS : numéros distincts ayant ce nombre de lignes. N_NUMEROS_ANNEE : numéros distincts de l'année, affiché seulement quand les cases masquées de l'année totalisent 0 ou au moins 10 (suppression secondaire, règle 4), sinon « masqué ». PCT_ANNEE = N_NUMEROS / N_NUMEROS_ANNEE, sorti seulement quand les deux sont visibles.
-- Masquage : chaque effectif < 10 sort en <10. Aucune ligne de total.
WITH n AS (
  SELECT SUBSTR(TRIM(NO_INTERVENTION_EXT), 1, INSTR(TRIM(NO_INTERVENTION_EXT), '-') - 1) AS NUM,
         COUNT(*) AS NB,
         EXTRACT(YEAR FROM MIN(DATE_INTERVENTION)) AS ANNEE
  FROM CORA_REC.TB_INTERVENTION
  WHERE INSTR(TRIM(NO_INTERVENTION_EXT), '-') > 1
    AND DATE_INTERVENTION >= DATE '2023-11-01'
    AND DATE_INTERVENTION < TRUNC(SYSDATE) + 1
  GROUP BY SUBSTR(TRIM(NO_INTERVENTION_EXT), 1, INSTR(TRIM(NO_INTERVENTION_EXT), '-') - 1)
),
g AS (
  SELECT ANNEE,
         CASE WHEN NB >= 4 THEN '4 et plus' ELSE TO_CHAR(NB) END AS NB_LIGNES,
         COUNT(*) AS N
  FROM n
  GROUP BY ANNEE, CASE WHEN NB >= 4 THEN '4 et plus' ELSE TO_CHAR(NB) END
),
r AS (
  SELECT g.ANNEE, g.NB_LIGNES, g.N,
         SUM(N) OVER (PARTITION BY ANNEE) AS NA,
         SUM(CASE WHEN N < 10 THEN N ELSE 0 END) OVER (PARTITION BY ANNEE) AS H
  FROM g
)
SELECT '20261019-lignes-par-numero-oproom' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE, NB_LIGNES,
       CASE WHEN N < 10 THEN '<10' ELSE TO_CHAR(N) END AS N_NUMEROS,
       CASE WHEN H = 0 OR H >= 10 THEN TO_CHAR(NA) ELSE 'masqué' END AS N_NUMEROS_ANNEE,
       CASE WHEN N >= 10 AND (H = 0 OR H >= 10) THEN ROUND(100 * N / NA, 2) END AS PCT_ANNEE
FROM r
ORDER BY ANNEE, NB_LIGNES;
