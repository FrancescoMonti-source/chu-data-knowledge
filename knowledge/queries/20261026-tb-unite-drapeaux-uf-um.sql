-- id: 20261026-tb-unite-drapeaux-uf-um
-- system: cora
-- person_data: no-person-data
-- purpose: savoir si TB_UNITE contient des UF et des UM : compter ses lignes selon les drapeaux UF et UM (obsolètes dans le dictionnaire), la présence d'un parent (ID_PERE) et l'existence d'une UM de même code dans TB_UNITE_MEDICALE (étape « TB_UNITE, UF et UM » du plan, issue #108)
-- Oracle, schéma CORA_REC. Référentiels seulement. Une ligne par combinaison ; N_CODES est un nombre de codes d'unité, jamais de personnes.
WITH um AS (
  SELECT DISTINCT TRIM(CODE_UNITE_MED) AS CODE FROM CORA_REC.TB_UNITE_MEDICALE
),
fils AS (
  SELECT DISTINCT ID_PERE FROM CORA_REC.TB_UNITE WHERE ID_PERE IS NOT NULL
)
SELECT '20261026-tb-unite-drapeaux-uf-um' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       NVL(TRIM(u.UF), 'vide') AS DRAPEAU_UF,
       NVL(TRIM(u.UM), 'vide') AS DRAPEAU_UM,
       NVL(TRIM(u.ACTIF), 'vide') AS ACTIF,
       CASE WHEN u.ID_PERE IS NULL THEN 'sans parent' ELSE 'avec parent' END AS PARENT,
       CASE WHEN f.ID_PERE IS NULL THEN 'sans fils' ELSE 'avec fils' END AS FILS,
       CASE WHEN um.CODE IS NULL THEN 'pas de code d''UM identique' ELSE 'code d''UM identique' END AS UM_DE_MEME_CODE,
       COUNT(*) AS N_CODES
FROM CORA_REC.TB_UNITE u
LEFT JOIN um ON um.CODE = TRIM(u.CODE_UNITE)
LEFT JOIN fils f ON f.ID_PERE = u.ID_UNITE
GROUP BY NVL(TRIM(u.UF), 'vide'), NVL(TRIM(u.UM), 'vide'), NVL(TRIM(u.ACTIF), 'vide'),
         CASE WHEN u.ID_PERE IS NULL THEN 'sans parent' ELSE 'avec parent' END,
         CASE WHEN f.ID_PERE IS NULL THEN 'sans fils' ELSE 'avec fils' END,
         CASE WHEN um.CODE IS NULL THEN 'pas de code d''UM identique' ELSE 'code d''UM identique' END
ORDER BY 4, 5, 6, 7, 8, 9;
