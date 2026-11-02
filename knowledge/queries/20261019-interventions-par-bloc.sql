-- id: 20261019-interventions-par-bloc
-- system: cora
-- person_data: masked
-- purpose: les blocs portés par TB_INTERVENTION.ID_BLOC (lien vers TB_SITE) et leurs interventions par année, pour dire combien de blocs distincts le flux compte (17 attendus, libellés « BLOC SPE… » et endoscopie) et que le bloc se lit par ID_BLOC et non par NO_INTERV_DOSSIER_BLOC (interventions-cora-flux-oproom, AM5 a) ; si le nombre de blocs ou leurs libellés diffèrent, corriger le claim
-- Oracle, schéma CORA_REC. Référentiel des sites de bloc avec des effectifs d'interventions. Une ligne par site apparaissant comme ID_BLOC d'au moins une intervention de DATE_INTERVENTION depuis 2023-01-01, plus une ligne '(ID_BLOC absent)'.
-- CODE_SITE, LIBELLE_SITE, BLOC : le site tel que TB_SITE le décrit (BLOC '(vide)' si NULL). N_INTERV_AAAA : interventions de l'année sur ce bloc ; 2026 est partiel.
-- Masquage : chaque effectif < 10 sort en <10. Pas de total : les colonnes annuelles ne s'additionnent à aucune colonne publiée.
WITH a AS (
  SELECT i.ID_BLOC,
         SUM(CASE WHEN EXTRACT(YEAR FROM i.DATE_INTERVENTION) = 2023 THEN 1 ELSE 0 END) AS A23,
         SUM(CASE WHEN EXTRACT(YEAR FROM i.DATE_INTERVENTION) = 2024 THEN 1 ELSE 0 END) AS A24,
         SUM(CASE WHEN EXTRACT(YEAR FROM i.DATE_INTERVENTION) = 2025 THEN 1 ELSE 0 END) AS A25,
         SUM(CASE WHEN EXTRACT(YEAR FROM i.DATE_INTERVENTION) = 2026 THEN 1 ELSE 0 END) AS A26
  FROM CORA_REC.TB_INTERVENTION i
  WHERE i.DATE_INTERVENTION >= DATE '2023-01-01'
    AND i.DATE_INTERVENTION < TRUNC(SYSDATE) + 1
  GROUP BY i.ID_BLOC
)
SELECT '20261019-interventions-par-bloc' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       CASE WHEN a.ID_BLOC IS NULL THEN '(ID_BLOC absent)' ELSE NVL(TRIM(si.CODE_SITE), '(site introuvable)') END AS CODE_SITE,
       TRIM(si.LIBELLE_SITE) AS LIBELLE_SITE,
       NVL(TRIM(TO_CHAR(si.BLOC)), '(vide)') AS BLOC,
       CASE WHEN a.A23 < 10 THEN '<10' ELSE TO_CHAR(a.A23) END AS N_INTERV_2023,
       CASE WHEN a.A24 < 10 THEN '<10' ELSE TO_CHAR(a.A24) END AS N_INTERV_2024,
       CASE WHEN a.A25 < 10 THEN '<10' ELSE TO_CHAR(a.A25) END AS N_INTERV_2025,
       CASE WHEN a.A26 < 10 THEN '<10' ELSE TO_CHAR(a.A26) END AS N_INTERV_2026
FROM a
LEFT JOIN CORA_REC.TB_SITE si ON si.ID_SITE = a.ID_BLOC
ORDER BY CASE WHEN a.ID_BLOC IS NULL THEN 1 ELSE 0 END, a.A25 DESC, TRIM(si.CODE_SITE);
