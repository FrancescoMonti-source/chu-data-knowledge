-- id: 20261019-dates-creation-actes-reprises
-- system: cora
-- person_data: masked
-- purpose: pour les actes réalisés de 2014 à 2020, la distance entre l'année de réalisation et l'année de création (DATE_CREAT), pour tester dates-creation-actes-avant-2020-sont-des-reprises (réfuté si plus de 10 % des actes de 2014, 2015 ou 2018 sont créés l'année de leur réalisation ou la suivante) et situer la limite d'octobre 2020 mois par mois ; si le résultat contredit le claim, DATE_CREAT peut servir de date de saisie avant octobre 2020
-- Oracle, schéma CORA_REC, TB_ACTE seule. Actes de DATE_ACTE du 2014-01-01 au 2020-12-31. PERIODE : année de DATE_ACTE avant 2018, mois de DATE_ACTE de 2018-01 à 2020-12. APPLICATION : ID_APPLICATION_TRANSFERT en texte, 'aucune' s'il est vide.
-- N : actes ; N_CREE_MEME_ANNEE : année de DATE_CREAT = année de DATE_ACTE ; N_CREE_ANNEE_SUIVANTE : année de DATE_CREAT = année de DATE_ACTE + 1 ; N_PLUS_1AN : DATE_CREAT plus de 365 jours après DATE_ACTE ; N_CREAT_VIDE : DATE_CREAT vide.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N sort en « masqué » dès qu'un complément (N moins une autre colonne) est entre 1 et 9. Aucune ligne de total.
WITH t AS (
  SELECT CASE WHEN DATE_ACTE < DATE '2018-01-01' THEN TO_CHAR(DATE_ACTE, 'YYYY') ELSE TO_CHAR(DATE_ACTE, 'YYYY-MM') END AS PERIODE,
         NVL(TRIM(TO_CHAR(ID_APPLICATION_TRANSFERT)), 'aucune') AS APPLICATION,
         COUNT(*) AS N,
         SUM(CASE WHEN DATE_CREAT IS NOT NULL AND EXTRACT(YEAR FROM DATE_CREAT) = EXTRACT(YEAR FROM DATE_ACTE) THEN 1 ELSE 0 END) AS C1,
         SUM(CASE WHEN DATE_CREAT IS NOT NULL AND EXTRACT(YEAR FROM DATE_CREAT) = EXTRACT(YEAR FROM DATE_ACTE) + 1 THEN 1 ELSE 0 END) AS C2,
         SUM(CASE WHEN DATE_CREAT IS NOT NULL AND TRUNC(DATE_CREAT) - TRUNC(DATE_ACTE) > 365 THEN 1 ELSE 0 END) AS C3,
         SUM(CASE WHEN DATE_CREAT IS NULL THEN 1 ELSE 0 END) AS C4
  FROM CORA_REC.TB_ACTE
  WHERE DATE_ACTE >= DATE '2014-01-01'
    AND DATE_ACTE < DATE '2021-01-01'
  GROUP BY CASE WHEN DATE_ACTE < DATE '2018-01-01' THEN TO_CHAR(DATE_ACTE, 'YYYY') ELSE TO_CHAR(DATE_ACTE, 'YYYY-MM') END,
           NVL(TRIM(TO_CHAR(ID_APPLICATION_TRANSFERT)), 'aucune')
)
SELECT '20261019-dates-creation-actes-reprises' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       PERIODE, APPLICATION,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C1 BETWEEN 1 AND 9 OR N - C2 BETWEEN 1 AND 9 OR N - C3 BETWEEN 1 AND 9 OR N - C4 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N,
       CASE WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_CREE_MEME_ANNEE,
       CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_CREE_ANNEE_SUIVANTE,
       CASE WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_PLUS_1AN,
       CASE WHEN C4 < 10 THEN '<10' ELSE TO_CHAR(C4) END AS N_CREAT_VIDE
FROM t
ORDER BY PERIODE, APPLICATION;
