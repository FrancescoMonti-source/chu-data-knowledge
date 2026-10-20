-- id: 20261019-concordance-ccam-acte-intervention
-- system: cora
-- person_data: masked
-- purpose: pour les actes rattachés à une intervention par TB_ACTE.NO_INTERVENTION, par mois de réalisation depuis 2023, dire si leur NO_INTERVENTION_CCAM est celui de l'intervention (TB_INTERVENTION.NO_INTERVENTION_CCAM), pour tester concordance-no-intervention-ccam-acte-intervention (réfuté si plus de 5 % des actes rattachés ont un NO_INTERVENTION_CCAM différent en 2025) ; si le résultat est plus mauvais, regrouper sur TB_ACTE.NO_INTERVENTION_CCAM reste vrai mais la jointure par ce numéro ne s'autorise plus
-- Oracle, schéma CORA_REC. Actes de DATE_ACTE du 2023-01-01 au jour d'exécution dont NO_INTERVENTION est renseigné, joints à TB_INTERVENTION par ID_INTERVENTION = NO_INTERVENTION. MOIS : mois de DATE_ACTE.
-- Les classes forment une partition de N. N : actes rattachés ; N_INTERV_INTROUVABLE : NO_INTERVENTION sans intervention correspondante ; N_CCAM_ACTE_VIDE : NO_INTERVENTION_CCAM de l'acte vide ; N_CCAM_INTERV_VIDE : celui de l'intervention est vide et celui de l'acte renseigné ; N_CCAM_IDENTIQUE : les deux renseignés et égaux ; N_CCAM_DIFFERENT : les deux renseignés et différents.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N sort en « masqué » dès que les classes masquées totalisent de 1 à 9 actes. Aucune ligne de total ; pas de pourcentage, à calculer par année quand tout est visible.
WITH t AS (
  SELECT TO_CHAR(a.DATE_ACTE, 'YYYY-MM') AS MOIS,
         COUNT(*) AS N,
         SUM(CASE WHEN i.ID_INTERVENTION IS NULL THEN 1 ELSE 0 END) AS C1,
         SUM(CASE WHEN i.ID_INTERVENTION IS NOT NULL AND a.NO_INTERVENTION_CCAM IS NULL THEN 1 ELSE 0 END) AS C2,
         SUM(CASE WHEN i.ID_INTERVENTION IS NOT NULL AND a.NO_INTERVENTION_CCAM IS NOT NULL AND i.NO_INTERVENTION_CCAM IS NULL THEN 1 ELSE 0 END) AS C3,
         SUM(CASE WHEN i.ID_INTERVENTION IS NOT NULL AND a.NO_INTERVENTION_CCAM IS NOT NULL AND i.NO_INTERVENTION_CCAM = a.NO_INTERVENTION_CCAM THEN 1 ELSE 0 END) AS C4,
         SUM(CASE WHEN i.ID_INTERVENTION IS NOT NULL AND a.NO_INTERVENTION_CCAM IS NOT NULL AND i.NO_INTERVENTION_CCAM <> a.NO_INTERVENTION_CCAM THEN 1 ELSE 0 END) AS C5
  FROM CORA_REC.TB_ACTE a
  LEFT JOIN CORA_REC.TB_INTERVENTION i ON i.ID_INTERVENTION = a.NO_INTERVENTION
  WHERE a.NO_INTERVENTION IS NOT NULL
    AND a.DATE_ACTE >= DATE '2023-01-01'
    AND a.DATE_ACTE < TRUNC(SYSDATE) + 1
  GROUP BY TO_CHAR(a.DATE_ACTE, 'YYYY-MM')
)
SELECT '20261019-concordance-ccam-acte-intervention' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       MOIS,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - (CASE WHEN C1 >= 10 THEN C1 ELSE 0 END + CASE WHEN C2 >= 10 THEN C2 ELSE 0 END
                    + CASE WHEN C3 >= 10 THEN C3 ELSE 0 END + CASE WHEN C4 >= 10 THEN C4 ELSE 0 END
                    + CASE WHEN C5 >= 10 THEN C5 ELSE 0 END) BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N,
       CASE WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_INTERV_INTROUVABLE,
       CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_CCAM_ACTE_VIDE,
       CASE WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_CCAM_INTERV_VIDE,
       CASE WHEN C4 < 10 THEN '<10' ELSE TO_CHAR(C4) END AS N_CCAM_IDENTIQUE,
       CASE WHEN C5 < 10 THEN '<10' ELSE TO_CHAR(C5) END AS N_CCAM_DIFFERENT
FROM t
ORDER BY MOIS;
