-- id: 20261013-type-sejour-mco-un-jour
-- system: cora
-- person_data: masked
-- purpose: valeurs de TYPE_SEJOUR des séjours groupés en MCO, sortis le jour d'entrée ou non, par année de sortie (étape 4 du plan, #24)
-- Oracle, schéma CORA_REC. « Groupé en MCO » : au moins un mouvement relié à un RSS par TB_MVT → TB_MVT_RUM.
-- Années 2018-2025 : le lien par TB_MVT_RUM manque en 2016-2017 (#25).
SELECT '20261013-type-sejour-mco-un-jour' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       EXTRACT(YEAR FROM s.DATE_SORTIE) AS ANNEE_SORTIE,
       NVL(TRIM(s.TYPE_SEJOUR), '(vide)') AS TYPE_SEJOUR,
       CASE WHEN SUM(CASE WHEN TRUNC(s.DATE_SORTIE) = TRUNC(s.DATE_ENTREE) THEN 1 ELSE 0 END) < 10 THEN '<10'
            ELSE TO_CHAR(SUM(CASE WHEN TRUNC(s.DATE_SORTIE) = TRUNC(s.DATE_ENTREE) THEN 1 ELSE 0 END)) END AS N_SEJ_0J,
       CASE WHEN SUM(CASE WHEN TRUNC(s.DATE_SORTIE) > TRUNC(s.DATE_ENTREE) THEN 1 ELSE 0 END) < 10 THEN '<10'
            ELSE TO_CHAR(SUM(CASE WHEN TRUNC(s.DATE_SORTIE) > TRUNC(s.DATE_ENTREE) THEN 1 ELSE 0 END)) END AS N_SEJ_1J_PLUS
FROM CORA_REC.TB_SEJOUR s
WHERE s.DATE_SORTIE >= DATE '2018-01-01'
  AND s.DATE_SORTIE < DATE '2026-01-01'
  AND EXISTS (SELECT 1
              FROM CORA_REC.TB_MVT m
              JOIN CORA_REC.TB_MVT_RUM mr ON mr.ID_MVT = m.ID_MVT
              WHERE m.ID_SEJOUR = s.ID_SEJOUR
                AND mr.ID_RSS IS NOT NULL)
GROUP BY EXTRACT(YEAR FROM s.DATE_SORTIE), NVL(TRIM(s.TYPE_SEJOUR), '(vide)')
ORDER BY ANNEE_SORTIE, TYPE_SEJOUR;
