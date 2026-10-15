-- id: 20261015-forme-no-intervention-ext
-- system: cora
-- person_data: masked
-- purpose: la forme de TB_INTERVENTION.NO_INTERVENTION_EXT, qui n'est pas « 10 chiffres-suffixe » comme le dit la kb (20261015-interventions-numeros-resultat), pour savoir comment la rapprocher de OR_INTERVENTIONS.I_ID d'OpRoom (kb : links/oproom-cora, backlog i-id-prefix-match, #24)
-- Oracle, schéma CORA_REC. FORME : le numéro où chaque chiffre devient 9 et chaque lettre A (un numéro ne sort jamais) ; LONGUEUR : sa longueur. Interventions depuis novembre 2023.
-- Masquage : chaque effectif < 10 sort en <10, et une forme portée par moins de 10 interventions sort en « (rare) ». Suppression secondaire (règle 4) : quand les cases masquées totalisent de 1 à 9, la plus grande case sort aussi en « masqué ». Aucune ligne de total.
WITH f AS (
  SELECT REGEXP_REPLACE(REGEXP_REPLACE(TRIM(NO_INTERVENTION_EXT), '[0-9]', '9'), '[A-Za-z]', 'A') AS FORME,
         LENGTH(TRIM(NO_INTERVENTION_EXT)) AS LONGUEUR,
         NVL(TRIM(TO_CHAR(ID_APPLICATION_TRANSFERT)), '(vide)') AS APPLI
  FROM CORA_REC.TB_INTERVENTION
  WHERE DATE_INTERVENTION >= DATE '2023-11-01'
),
g AS (
  SELECT NVL(FORME, '(vide)') AS FORME, LONGUEUR, APPLI, COUNT(*) AS N FROM f GROUP BY NVL(FORME, '(vide)'), LONGUEUR, APPLI
),
r AS (
  SELECT FORME, LONGUEUR, APPLI, N,
         SUM(CASE WHEN N < 10 THEN N ELSE 0 END) OVER () AS CACHE,
         ROW_NUMBER() OVER (ORDER BY N DESC, FORME) AS RANG
  FROM g
)
SELECT '20261015-forme-no-intervention-ext' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       CASE WHEN N < 10 THEN '(rare)' ELSE FORME END AS FORME,
       CASE WHEN N < 10 THEN NULL ELSE LONGUEUR END AS LONGUEUR,
       APPLI,
       CASE WHEN N < 10 THEN '<10' WHEN CACHE BETWEEN 1 AND 9 AND RANG = 1 THEN 'masqué' ELSE TO_CHAR(N) END AS N
FROM r
ORDER BY RANG;
