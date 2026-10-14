-- id: 20261014-interventions-cora
-- system: cora
-- person_data: masked
-- purpose: par mois et par application d'origine, les interventions de TB_INTERVENTION : depuis quand la table se remplit, quelle part vient du flux OpRoom, et ce qui est renseigné (NO_INTERVENTION_EXT, type d'intervention, entrée en salle, actes reliés par TB_ACTE.NO_INTERVENTION) (kb : intervention-table-is-oproom-flow, #24)
-- Oracle, schéma CORA_REC. Mois de DATE_INTERVENTION, de 2014-01 au mois de l'exécution. APPLICATION : ID_APPLICATION_TRANSFERT en texte, 'aucune' s'il est vide.
-- N : interventions ; N_NO_EXT : NO_INTERVENTION_EXT renseigné ; N_TYPE : ID_TYPE_INTERVENTION renseigné ; N_ENTREE_SALLE : ENTREE_EN_SALLE renseigné ; N_ACTES_LIES : au moins un acte avec TB_ACTE.NO_INTERVENTION = ID_INTERVENTION.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N sort en « masqué » dès qu'un complément (N moins une autre colonne) est entre 1 et 9. Aucune ligne de total.
WITH liees AS (
  SELECT DISTINCT TRIM(TO_CHAR(NO_INTERVENTION)) AS ID
  FROM CORA_REC.TB_ACTE
  WHERE NO_INTERVENTION IS NOT NULL
),
t AS (
  SELECT TO_CHAR(i.DATE_INTERVENTION, 'YYYY-MM') AS MOIS,
         NVL(TRIM(TO_CHAR(i.ID_APPLICATION_TRANSFERT)), 'aucune') AS APPLICATION,
         COUNT(*) AS N,
         SUM(CASE WHEN TRIM(i.NO_INTERVENTION_EXT) IS NOT NULL THEN 1 ELSE 0 END) AS C1,
         SUM(CASE WHEN i.ID_TYPE_INTERVENTION IS NOT NULL THEN 1 ELSE 0 END) AS C2,
         SUM(CASE WHEN i.ENTREE_EN_SALLE IS NOT NULL THEN 1 ELSE 0 END) AS C3,
         SUM(CASE WHEN l.ID IS NOT NULL THEN 1 ELSE 0 END) AS C4
  FROM CORA_REC.TB_INTERVENTION i
  LEFT JOIN liees l ON l.ID = TRIM(TO_CHAR(i.ID_INTERVENTION))
  WHERE i.DATE_INTERVENTION >= DATE '2014-01-01'
    AND i.DATE_INTERVENTION < TRUNC(SYSDATE) + 1
  GROUP BY TO_CHAR(i.DATE_INTERVENTION, 'YYYY-MM'), NVL(TRIM(TO_CHAR(i.ID_APPLICATION_TRANSFERT)), 'aucune')
)
SELECT '20261014-interventions-cora' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       MOIS, APPLICATION,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C1 BETWEEN 1 AND 9 OR N - C2 BETWEEN 1 AND 9 OR N - C3 BETWEEN 1 AND 9 OR N - C4 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N,
       CASE WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_NO_EXT,
       CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_TYPE,
       CASE WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_ENTREE_SALLE,
       CASE WHEN C4 < 10 THEN '<10' ELSE TO_CHAR(C4) END AS N_ACTES_LIES
FROM t
ORDER BY MOIS, APPLICATION;
