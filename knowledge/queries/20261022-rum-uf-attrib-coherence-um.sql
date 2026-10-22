-- id: 20261022-rum-uf-attrib-coherence-um
-- system: cora
-- person_data: masked
-- purpose: savoir si l'UF attribuée à un RUM (TB_SYNTH_RUM.ID_UF_ATTRIB) est une des UF rattachées à l'UM du RUM (TB_UNITE_M_UNITE), et si les UM n'ont qu'une UF ou plusieurs (étape 3 du plan)
-- Oracle, schéma CORA_REC. RUM terminés de janvier à septembre de 2022 à 2026, par année de DATE_FIN_RUM. Le lien UM-UF est lu sans date (le dictionnaire annonce des dates sur ce lien : la requête de l'étape 1 les confirme).
-- MODALITE : « UF liée à l'UM » (ID_UF_ATTRIB figure parmi les UF rattachées à l'UM du RUM), « UF non liée à l'UM » (renseignée mais absente de ces UF), « UF non renseignée ». NB_UF_UM : nombre d'UF rattachées à l'UM du RUM, jamais leurs codes.
-- Masquage : chaque effectif < 10 sort en <10. Aucune ligne de total : rien ne permet de recalculer une case masquée.
WITH nb AS (
  SELECT ID_UNITE_MED, COUNT(DISTINCT ID_UNITE) AS NB_UF_UM
  FROM CORA_REC.TB_UNITE_M_UNITE
  GROUP BY ID_UNITE_MED
), rum AS (
  SELECT EXTRACT(YEAR FROM r.DATE_FIN_RUM) AS ANNEE,
         CASE WHEN r.ID_UF_ATTRIB IS NULL THEN 'UF non renseignée'
              WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_UNITE_M_UNITE l
                           WHERE l.ID_UNITE_MED = r.ID_UNITE_MEDICALE AND l.ID_UNITE = r.ID_UF_ATTRIB) THEN 'UF liée à l''UM'
              ELSE 'UF non liée à l''UM' END AS MODALITE,
         NVL(nb.NB_UF_UM, 0) AS NB_UF_UM
  FROM CORA_REC.TB_SYNTH_RUM r
  LEFT JOIN nb ON nb.ID_UNITE_MED = r.ID_UNITE_MEDICALE
  WHERE r.DATE_FIN_RUM >= DATE '2022-01-01'
    AND r.DATE_FIN_RUM < DATE '2027-01-01'
    AND EXTRACT(MONTH FROM r.DATE_FIN_RUM) <= 9
)
SELECT '20261022-rum-uf-attrib-coherence-um' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE, MODALITE, NB_UF_UM,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE TO_CHAR(COUNT(*)) END AS N_RUM
FROM rum
GROUP BY ANNEE, MODALITE, NB_UF_UM
ORDER BY ANNEE, MODALITE, NB_UF_UM;
