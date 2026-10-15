-- id: 20261015-sites-bloc
-- system: cora
-- person_data: masked
-- purpose: valeurs de TB_SITE.BLOC et, pour chaque site de réalisation, le nombre d'actes par année de 2022 à 2025, pour savoir si BLOC vaut seulement 'O', quels sites paramétrés bloc ne sont pas des blocs opératoires (salle de naissance) et quels sites non paramétrés bloc portent beaucoup d'actes (kb : backlog site-bloc-values, concept or-procedure, or-site-flag-incomplete ; claim reperer-actes-de-bloc)
-- Oracle, schéma CORA_REC. Référentiel des sites, avec des effectifs d'actes. Une ligne par site qui a au moins un acte de 2022 à 2025, ou qui a BLOC renseigné.
-- BLOC_BRUT : la valeur de BLOC telle quelle ('(vide)' si NULL) ; N_ACTES_AAAA : actes datés de l'année sur ce site.
-- Masquage : chaque effectif < 10 sort en <10. Pas de total : les colonnes annuelles ne s'additionnent à aucune colonne publiée.
WITH a AS (
  SELECT ID_SITE,
         SUM(CASE WHEN EXTRACT(YEAR FROM DATE_ACTE) = 2022 THEN 1 ELSE 0 END) AS A22,
         SUM(CASE WHEN EXTRACT(YEAR FROM DATE_ACTE) = 2023 THEN 1 ELSE 0 END) AS A23,
         SUM(CASE WHEN EXTRACT(YEAR FROM DATE_ACTE) = 2024 THEN 1 ELSE 0 END) AS A24,
         SUM(CASE WHEN EXTRACT(YEAR FROM DATE_ACTE) = 2025 THEN 1 ELSE 0 END) AS A25
  FROM CORA_REC.TB_ACTE
  WHERE DATE_ACTE >= DATE '2022-01-01' AND DATE_ACTE < DATE '2026-01-01' AND ID_SITE IS NOT NULL
  GROUP BY ID_SITE
)
SELECT '20261015-sites-bloc' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       TRIM(si.CODE_SITE) AS CODE_SITE,
       TRIM(si.LIBELLE_SITE) AS LIBELLE_SITE,
       NVL(TRIM(TO_CHAR(si.BLOC)), '(vide)') AS BLOC_BRUT,
       TRIM(TO_CHAR(si.ACTIF)) AS ACTIF,
       TRIM(TO_CHAR(si.LIEU_REAL_ACTE)) AS LIEU_REAL_ACTE,
       CASE WHEN NVL(a.A22, 0) < 10 THEN '<10' ELSE TO_CHAR(a.A22) END AS N_ACTES_2022,
       CASE WHEN NVL(a.A23, 0) < 10 THEN '<10' ELSE TO_CHAR(a.A23) END AS N_ACTES_2023,
       CASE WHEN NVL(a.A24, 0) < 10 THEN '<10' ELSE TO_CHAR(a.A24) END AS N_ACTES_2024,
       CASE WHEN NVL(a.A25, 0) < 10 THEN '<10' ELSE TO_CHAR(a.A25) END AS N_ACTES_2025
FROM CORA_REC.TB_SITE si
LEFT JOIN a ON a.ID_SITE = si.ID_SITE
WHERE a.ID_SITE IS NOT NULL OR si.BLOC IS NOT NULL
ORDER BY NVL(TRIM(TO_CHAR(si.BLOC)), '(vide)'), NVL(a.A25, 0) DESC, TRIM(si.CODE_SITE);
