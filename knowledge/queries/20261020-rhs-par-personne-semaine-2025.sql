-- id: 20261020-rhs-par-personne-semaine-2025
-- system: cora
-- person_data: masked
-- purpose: pour les RHS (TB_MVT_SSR_SEM) dont la semaine débute en 2025, compter les couples personne-semaine selon le nombre de RHS qu'ils portent et leurs jours de présence, par TYPE_ACTIVITE et TYPE_HOSPIT_SSR, pour savoir si une même semaine porte plusieurs RHS en HTP (étape 3 du plan, issue 96)
-- Oracle. La personne n'apparaît pas dans le résultat : elle sert seulement à former les groupes. Un effectif de moins de 10 sort comme <10.
WITH sem AS (
  SELECT s.ID_PATIENT, s.DATE_DEBUT_SEM, s.TYPE_ACTIVITE, s.TYPE_HOSPIT_SSR,
         COUNT(*) AS NB_RHS, SUM(s.NBJ_PRES) AS NB_JOURS
  FROM CORA_REC.TB_MVT_SSR_SEM s
  WHERE s.DATE_DEBUT_SEM >= DATE '2025-01-01' AND s.DATE_DEBUT_SEM < DATE '2026-01-01'
  GROUP BY s.ID_PATIENT, s.DATE_DEBUT_SEM, s.TYPE_ACTIVITE, s.TYPE_HOSPIT_SSR
)
SELECT '20261020-rhs-par-personne-semaine-2025' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       TYPE_ACTIVITE, TYPE_HOSPIT_SSR,
       LEAST(NB_RHS, 6) AS NB_RHS_SEMAINE_6_ET_PLUS,
       LEAST(NB_JOURS, 7) AS NB_JOURS_PRESENCE_SEMAINE,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE CAST(COUNT(*) AS VARCHAR2(12)) END AS N_PERSONNE_SEMAINES
FROM sem
GROUP BY TYPE_ACTIVITE, TYPE_HOSPIT_SSR, LEAST(NB_RHS, 6), LEAST(NB_JOURS, 7)
ORDER BY TYPE_ACTIVITE, TYPE_HOSPIT_SSR, 6, 7;
