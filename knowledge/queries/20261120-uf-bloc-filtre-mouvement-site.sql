-- id: 20261120-uf-bloc-filtre-mouvement-site
-- system: cora
-- person_data: masked
-- purpose: pour les UF 5508, 6510 et 6196, comparer en 2025 les actes pris par le filtre « UF du mouvement » (TB_MVT.ID_UNITE_M, la requête de reperer-actes-de-bloc) et par le filtre « site de l'acte » (TB_ACTE.ID_SITE, TB_SITE.CODE_SITE, ce que comptait la preuve 20261015-sites-bloc-resultat) : combien d'actes sont pris par les deux, par le mouvement seul, par le site seul (issue #131, question 1)
-- Oracle, schéma CORA_REC. Actes datés de 2025. Pour chaque UF u de la liste, trois lignes de filtre : MOUVEMENT_ET_SITE (le mouvement est dans u et le site de l'acte a le code u), MOUVEMENT_SEUL (le mouvement est dans u, le site de l'acte est autre ou vide), SITE_SEUL (le site de l'acte a le code u, le mouvement est dans une autre UF).
-- CODE_SITE_ACTE, LIBELLE_SITE_ACTE et BLOC_BRUT_SITE disent où l'acte est fait ('(vide)' : acte sans site, ou BLOC non renseigné) ; UF_MOUVEMENT dit où le patient est hospitalisé. Un acte dont le mouvement est dans 5508 et le site dans 6510 compte deux fois : MOUVEMENT_SEUL pour 5508 et SITE_SEUL pour 6510.
-- Masquage : chaque effectif < 10 sort en <10. Pas de total : aucune colonne ne permet de recalculer une cellule masquée.
WITH liste AS (
  SELECT '5508' AS UF FROM DUAL UNION ALL SELECT '6510' FROM DUAL UNION ALL SELECT '6196' FROM DUAL
),
x AS (
  SELECT TRIM(m.ID_UNITE_M) AS UF_MVT,
         NVL(TRIM(si.CODE_SITE), '(vide)') AS CODE_SITE,
         NVL(TRIM(si.LIBELLE_SITE), '(vide)') AS LIBELLE_SITE,
         NVL(TRIM(TO_CHAR(si.BLOC)), '(vide)') AS BLOC_BRUT
  FROM CORA_REC.TB_ACTE a
  JOIN CORA_REC.TB_MVT m ON m.ID_MVT = a.ID_MVT
  LEFT JOIN CORA_REC.TB_SITE si ON si.ID_SITE = a.ID_SITE
  WHERE a.DATE_ACTE >= DATE '2025-01-01' AND a.DATE_ACTE < DATE '2026-01-01'
    AND (TRIM(m.ID_UNITE_M) IN (SELECT UF FROM liste) OR TRIM(si.CODE_SITE) IN (SELECT UF FROM liste))
),
g AS (
  SELECT l.UF AS CODE_UF,
         CASE WHEN x.CODE_SITE = l.UF THEN 'MOUVEMENT_ET_SITE' ELSE 'MOUVEMENT_SEUL' END AS FILTRE,
         x.CODE_SITE, x.LIBELLE_SITE, x.BLOC_BRUT, x.UF_MVT AS UF_MOUVEMENT, COUNT(*) AS N
  FROM x JOIN liste l ON x.UF_MVT = l.UF
  GROUP BY l.UF, CASE WHEN x.CODE_SITE = l.UF THEN 'MOUVEMENT_ET_SITE' ELSE 'MOUVEMENT_SEUL' END,
           x.CODE_SITE, x.LIBELLE_SITE, x.BLOC_BRUT, x.UF_MVT
  UNION ALL
  SELECT l.UF, 'SITE_SEUL', x.CODE_SITE, x.LIBELLE_SITE, x.BLOC_BRUT, NVL(x.UF_MVT, '(vide)'), COUNT(*)
  FROM x JOIN liste l ON x.CODE_SITE = l.UF
  WHERE x.UF_MVT <> l.UF OR x.UF_MVT IS NULL
  GROUP BY l.UF, x.CODE_SITE, x.LIBELLE_SITE, x.BLOC_BRUT, NVL(x.UF_MVT, '(vide)')
)
SELECT '20261120-uf-bloc-filtre-mouvement-site' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       CODE_UF, FILTRE, CODE_SITE AS CODE_SITE_ACTE, LIBELLE_SITE AS LIBELLE_SITE_ACTE,
       BLOC_BRUT AS BLOC_BRUT_SITE, UF_MOUVEMENT,
       CASE WHEN N < 10 THEN '<10' ELSE TO_CHAR(N) END AS N_ACTES_2025
FROM g
ORDER BY CODE_UF, FILTRE, N DESC, CODE_SITE, UF_MOUVEMENT;
