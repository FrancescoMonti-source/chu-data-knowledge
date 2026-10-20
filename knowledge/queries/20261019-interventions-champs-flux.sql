-- id: 20261019-interventions-champs-flux
-- system: cora
-- person_data: masked
-- purpose: par mois de l'intervention et application d'origine, le remplissage des colonnes de TB_INTERVENTION que interventions-cora-flux-oproom affirme (AM5) : NO_INTERV_DOSSIER_BLOC jamais renseigné, ID_BLOC presque toujours présent, NO_INTERVENTION_EXT vide pour peu d'interventions, NO_INTERVENTION_CCAM renseigné pour 40 à 90 % selon le mois (concordance-no-intervention-ccam-acte-intervention), et les trois heures de chronologie (ENTREE_EN_SALLE, DEBUT_INTERVENTION, FIN_INTERVENTION) qui départagent le claim et le rapport de DIM-code sur l'état « chronologie complète » ; le calendrier du flux complet se lit sur N par application
-- Oracle, schéma CORA_REC, TB_INTERVENTION seule. Interventions de DATE_INTERVENTION du 2023-01-01 au jour d'exécution. APPLICATION : ID_APPLICATION_TRANSFERT en texte, 'aucune' s'il est vide.
-- N : interventions ; N_DOSSIER_BLOC : NO_INTERV_DOSSIER_BLOC renseigné ; N_ID_BLOC_ABSENT : ID_BLOC vide ; N_NO_EXT_VIDE : NO_INTERVENTION_EXT vide ; N_CCAM_RENSEIGNE : NO_INTERVENTION_CCAM renseigné ; N_ENTREE_SALLE, N_DEBUT_INTERV, N_FIN_INTERV : heure renseignée ; N_CHRONO_COMPLETE : les trois heures renseignées.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N sort en « masqué » dès qu'un complément (N moins une autre colonne) est entre 1 et 9. Aucune ligne de total.
WITH t AS (
  SELECT TO_CHAR(DATE_INTERVENTION, 'YYYY-MM') AS MOIS,
         NVL(TRIM(TO_CHAR(ID_APPLICATION_TRANSFERT)), 'aucune') AS APPLICATION,
         COUNT(*) AS N,
         SUM(CASE WHEN TRIM(NO_INTERV_DOSSIER_BLOC) IS NOT NULL THEN 1 ELSE 0 END) AS C1,
         SUM(CASE WHEN ID_BLOC IS NULL THEN 1 ELSE 0 END) AS C2,
         SUM(CASE WHEN TRIM(NO_INTERVENTION_EXT) IS NULL THEN 1 ELSE 0 END) AS C3,
         SUM(CASE WHEN NO_INTERVENTION_CCAM IS NOT NULL THEN 1 ELSE 0 END) AS C4,
         SUM(CASE WHEN ENTREE_EN_SALLE IS NOT NULL THEN 1 ELSE 0 END) AS C5,
         SUM(CASE WHEN DEBUT_INTERVENTION IS NOT NULL THEN 1 ELSE 0 END) AS C6,
         SUM(CASE WHEN FIN_INTERVENTION IS NOT NULL THEN 1 ELSE 0 END) AS C7,
         SUM(CASE WHEN ENTREE_EN_SALLE IS NOT NULL AND DEBUT_INTERVENTION IS NOT NULL AND FIN_INTERVENTION IS NOT NULL THEN 1 ELSE 0 END) AS C8
  FROM CORA_REC.TB_INTERVENTION
  WHERE DATE_INTERVENTION >= DATE '2023-01-01'
    AND DATE_INTERVENTION < TRUNC(SYSDATE) + 1
  GROUP BY TO_CHAR(DATE_INTERVENTION, 'YYYY-MM'), NVL(TRIM(TO_CHAR(ID_APPLICATION_TRANSFERT)), 'aucune')
)
SELECT '20261019-interventions-champs-flux' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       MOIS, APPLICATION,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C1 BETWEEN 1 AND 9 OR N - C2 BETWEEN 1 AND 9 OR N - C3 BETWEEN 1 AND 9 OR N - C4 BETWEEN 1 AND 9
              OR N - C5 BETWEEN 1 AND 9 OR N - C6 BETWEEN 1 AND 9 OR N - C7 BETWEEN 1 AND 9 OR N - C8 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N,
       CASE WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_DOSSIER_BLOC,
       CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_ID_BLOC_ABSENT,
       CASE WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_NO_EXT_VIDE,
       CASE WHEN C4 < 10 THEN '<10' ELSE TO_CHAR(C4) END AS N_CCAM_RENSEIGNE,
       CASE WHEN C5 < 10 THEN '<10' ELSE TO_CHAR(C5) END AS N_ENTREE_SALLE,
       CASE WHEN C6 < 10 THEN '<10' ELSE TO_CHAR(C6) END AS N_DEBUT_INTERV,
       CASE WHEN C7 < 10 THEN '<10' ELSE TO_CHAR(C7) END AS N_FIN_INTERV,
       CASE WHEN C8 < 10 THEN '<10' ELSE TO_CHAR(C8) END AS N_CHRONO_COMPLETE
FROM t
ORDER BY MOIS, APPLICATION;
