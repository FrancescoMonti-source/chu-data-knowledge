-- id: 20261019-actes-origine-saisie-mois
-- system: cora
-- person_data: masked
-- purpose: par mois de réalisation et par origine de saisie (application émettrice, ECRAN renseigné ou non, TYPE_TRANSFERT), le volume des actes depuis octobre 2020 et la part rattachée par TB_ACTE.NO_INTERVENTION, pour montrer la bascule hors CORA (surtout CDP2, application 10) vers la saisie dans CORA (en partie depuis 2025, presque tout depuis 2026) ; sert rattachement-direct-acte-intervention-par-periode (si le rattachement ne monte que dans les lignes ECRAN = O, la hausse suit l'origine de saisie), epoques-codage-actes (AM8 : ECRAN renseigné contre absence de marqueur d'import, c'est-à-dire application « aucune » et TYPE_TRANSFERT « (vide) ») et grouper-actes-par-no-intervention-ccam
-- Oracle, schéma CORA_REC, TB_ACTE seule. Actes de DATE_ACTE du 2020-10-01 au jour d'exécution. MOIS : mois de DATE_ACTE.
-- APPLICATION : ID_APPLICATION_TRANSFERT en texte, 'aucune' s'il est vide ; ECRAN_RENSEIGNE : 'O' si ECRAN est renseigné, 'N' sinon ; TYPE_TRANSFERT : sa valeur, '(vide)' s'il est vide.
-- N : actes ; N_NO_INTERVENTION : NO_INTERVENTION renseigné ; N_NO_INTERVENTION_CCAM : NO_INTERVENTION_CCAM renseigné.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N sort en « masqué » dès qu'un complément (N moins une autre colonne) est entre 1 et 9. Aucune ligne de total. Les derniers mois sont incomplets (actes-derniers-mois-incomplets) : lire avec la requête de délai de saisie.
WITH t AS (
  SELECT TO_CHAR(DATE_ACTE, 'YYYY-MM') AS MOIS,
         NVL(TRIM(TO_CHAR(ID_APPLICATION_TRANSFERT)), 'aucune') AS APPLICATION,
         CASE WHEN TRIM(ECRAN) IS NOT NULL THEN 'O' ELSE 'N' END AS ECRAN_RENSEIGNE,
         NVL(TRIM(TYPE_TRANSFERT), '(vide)') AS TYPE_TRANSFERT,
         COUNT(*) AS N,
         SUM(CASE WHEN NO_INTERVENTION IS NOT NULL THEN 1 ELSE 0 END) AS C1,
         SUM(CASE WHEN NO_INTERVENTION_CCAM IS NOT NULL THEN 1 ELSE 0 END) AS C2
  FROM CORA_REC.TB_ACTE
  WHERE DATE_ACTE >= DATE '2020-10-01'
    AND DATE_ACTE < TRUNC(SYSDATE) + 1
  GROUP BY TO_CHAR(DATE_ACTE, 'YYYY-MM'),
           NVL(TRIM(TO_CHAR(ID_APPLICATION_TRANSFERT)), 'aucune'),
           CASE WHEN TRIM(ECRAN) IS NOT NULL THEN 'O' ELSE 'N' END,
           NVL(TRIM(TYPE_TRANSFERT), '(vide)')
)
SELECT '20261019-actes-origine-saisie-mois' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       MOIS, APPLICATION, ECRAN_RENSEIGNE, TYPE_TRANSFERT,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C1 BETWEEN 1 AND 9 OR N - C2 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N,
       CASE WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_NO_INTERVENTION,
       CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_NO_INTERVENTION_CCAM
FROM t
ORDER BY MOIS, APPLICATION, ECRAN_RENSEIGNE, TYPE_TRANSFERT;
