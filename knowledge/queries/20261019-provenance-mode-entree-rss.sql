-- id: 20261019-provenance-mode-entree-rss
-- system: cora
-- person_data: masked
-- purpose: pour chaque année de fin de RSS, tous RSS MCO de TB_SYNTH_RSS, le croisement de CODE_PROVENANCE et de MODE_ENTREE, pour tester provenance-urgences-rupture-2023 (réfuté si la part de CODE_PROVENANCE = '5' reste du même ordre en 2024 qu'en 2021-2022 ; sinon on ne repère plus les entrées par les urgences avec ce code depuis 2023). Le dictionnaire (TB_MODE_ES_ADMIN.CODE_DEST_PROV) donne 5 = service d'urgence pour une provenance ; MODE_ENTREE ne prend que 0, 6, 7, 8 (TB_SEJOUR.txt) et ne désigne donc pas les urgences : le croisement dit seulement quels modes d'entrée portent la provenance 5.
-- Oracle 11g, schéma CORA_REC. RSS dont DATE_FIN va du 2018-01-01 à aujourd'hui, par année de DATE_FIN. Valeurs vides en « (vide) ».
-- Colonnes : ANNEE, CODE_PROVENANCE, MODE_ENTREE, N (RSS), PCT_ANNEE (part de la ligne dans l'année, vide quand N est masqué).
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : quand les cases masquées d'une année totalisent de 1 à 9, la plus grande case de l'année sort aussi en « masqué ». Aucune ligne de total.
WITH g AS (
  SELECT EXTRACT(YEAR FROM DATE_FIN) AS ANNEE,
         NVL(TRIM(TO_CHAR(CODE_PROVENANCE)), '(vide)') AS CODE_PROVENANCE,
         NVL(TRIM(TO_CHAR(MODE_ENTREE)), '(vide)') AS MODE_ENTREE,
         COUNT(*) AS N
  FROM CORA_REC.TB_SYNTH_RSS
  WHERE DATE_FIN >= DATE '2018-01-01' AND DATE_FIN < TRUNC(SYSDATE) + 1
  GROUP BY EXTRACT(YEAR FROM DATE_FIN),
           NVL(TRIM(TO_CHAR(CODE_PROVENANCE)), '(vide)'),
           NVL(TRIM(TO_CHAR(MODE_ENTREE)), '(vide)')
),
m AS (
  SELECT ANNEE, CODE_PROVENANCE, MODE_ENTREE, N,
         SUM(N) OVER (PARTITION BY ANNEE) AS TOT,
         SUM(CASE WHEN N < 10 THEN N ELSE 0 END) OVER (PARTITION BY ANNEE) AS CACHE,
         ROW_NUMBER() OVER (PARTITION BY ANNEE ORDER BY N DESC, CODE_PROVENANCE, MODE_ENTREE) AS RANG
  FROM g
)
SELECT '20261019-provenance-mode-entree-rss' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE, CODE_PROVENANCE, MODE_ENTREE,
       CASE WHEN N < 10 THEN '<10' WHEN CACHE BETWEEN 1 AND 9 AND RANG = 1 THEN 'masqué' ELSE TO_CHAR(N) END AS N,
       CASE WHEN N < 10 OR (CACHE BETWEEN 1 AND 9 AND RANG = 1) THEN NULL ELSE ROUND(100 * N / TOT, 2) END AS PCT_ANNEE
FROM m
ORDER BY ANNEE, CODE_PROVENANCE, MODE_ENTREE;
