-- id: 20261019-delai-saisie-actes-mois
-- system: cora
-- person_data: masked
-- purpose: par mois de réalisation, de octobre 2020 au dernier mois, et par origine de saisie, le délai entre la réalisation d'un acte (DATE_ACTE) et sa création (DATE_CREAT) en classes, pour fixer combien de derniers mois sont incomplets et tester actes-derniers-mois-incomplets (réfuté si plus de 5 % des actes d'une année complète de 2021 à 2025 sont créés plus de 90 jours après) ; les mois récents montrent aussi la bascule de saisie hors CORA vers CORA (rattachement-direct-acte-intervention-par-periode)
-- Oracle, schéma CORA_REC, TB_ACTE seule. Actes de DATE_ACTE du 2020-10-01 au jour d'exécution. MOIS : mois de DATE_ACTE. ORIGINE : 'ECRAN renseigné' (saisie dans CORA) ou 'ECRAN vide' (flux importé, hors CORA).
-- DELAI = TRUNC(DATE_CREAT) - TRUNC(DATE_ACTE) en jours. N : actes ; N_0_1J : 0 à 1 jour ; N_2_30J : 2 à 30 ; N_31_90J : 31 à 90 ; N_91_365J : 91 à 365 ; N_PLUS_1AN : plus de 365 ; N_AUTRE : DATE_CREAT vide ou antérieure à DATE_ACTE. Les classes forment une partition : plus de 90 jours = N_91_365J + N_PLUS_1AN.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N sort en « masqué » dès que les classes masquées totalisent de 1 à 9 actes (N moins la somme des classes visibles). Aucune ligne de total ; pas de pourcentage, à calculer dans l'analyse quand tout est visible.
WITH t AS (
  SELECT TO_CHAR(DATE_ACTE, 'YYYY-MM') AS MOIS,
         CASE WHEN TRIM(ECRAN) IS NOT NULL THEN 'ECRAN renseigné' ELSE 'ECRAN vide' END AS ORIGINE,
         COUNT(*) AS N,
         SUM(CASE WHEN DATE_CREAT IS NOT NULL AND TRUNC(DATE_CREAT) - TRUNC(DATE_ACTE) BETWEEN 0 AND 1 THEN 1 ELSE 0 END) AS C1,
         SUM(CASE WHEN DATE_CREAT IS NOT NULL AND TRUNC(DATE_CREAT) - TRUNC(DATE_ACTE) BETWEEN 2 AND 30 THEN 1 ELSE 0 END) AS C2,
         SUM(CASE WHEN DATE_CREAT IS NOT NULL AND TRUNC(DATE_CREAT) - TRUNC(DATE_ACTE) BETWEEN 31 AND 90 THEN 1 ELSE 0 END) AS C3,
         SUM(CASE WHEN DATE_CREAT IS NOT NULL AND TRUNC(DATE_CREAT) - TRUNC(DATE_ACTE) BETWEEN 91 AND 365 THEN 1 ELSE 0 END) AS C4,
         SUM(CASE WHEN DATE_CREAT IS NOT NULL AND TRUNC(DATE_CREAT) - TRUNC(DATE_ACTE) > 365 THEN 1 ELSE 0 END) AS C5,
         SUM(CASE WHEN DATE_CREAT IS NULL OR TRUNC(DATE_CREAT) < TRUNC(DATE_ACTE) THEN 1 ELSE 0 END) AS C6
  FROM CORA_REC.TB_ACTE
  WHERE DATE_ACTE >= DATE '2020-10-01'
    AND DATE_ACTE < TRUNC(SYSDATE) + 1
  GROUP BY TO_CHAR(DATE_ACTE, 'YYYY-MM'),
           CASE WHEN TRIM(ECRAN) IS NOT NULL THEN 'ECRAN renseigné' ELSE 'ECRAN vide' END
)
SELECT '20261019-delai-saisie-actes-mois' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       MOIS, ORIGINE,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - (CASE WHEN C1 >= 10 THEN C1 ELSE 0 END + CASE WHEN C2 >= 10 THEN C2 ELSE 0 END
                    + CASE WHEN C3 >= 10 THEN C3 ELSE 0 END + CASE WHEN C4 >= 10 THEN C4 ELSE 0 END
                    + CASE WHEN C5 >= 10 THEN C5 ELSE 0 END + CASE WHEN C6 >= 10 THEN C6 ELSE 0 END) BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N,
       CASE WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_0_1J,
       CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_2_30J,
       CASE WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_31_90J,
       CASE WHEN C4 < 10 THEN '<10' ELSE TO_CHAR(C4) END AS N_91_365J,
       CASE WHEN C5 < 10 THEN '<10' ELSE TO_CHAR(C5) END AS N_PLUS_1AN,
       CASE WHEN C6 < 10 THEN '<10' ELSE TO_CHAR(C6) END AS N_AUTRE
FROM t
ORDER BY MOIS, ORIGINE;
