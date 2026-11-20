-- id: 20261104-snds-familles-tables
-- system: snds
-- person_data: no-person-data
-- purpose: vérifier que ROracle se connecte au portail (IPIAMPR2.WORLD) et voir, pour les familles de tables du schéma du HDH (schema-snds-20260427), sous quel propriétaire et quel type d'objet le profil 108 les voit, et pour quelles années du PMSI (étapes 2 à 4 du plan, #127)
-- Oracle. Lit seulement le catalogue (ALL_OBJECTS), filtré sur les préfixes des tables du schéma du HDH : aucune donnée de table. Remplace 20261104-snds-objets-visibles, jamais allée au bout (plus de 20 minutes sur tout le catalogue, 2026-11-04).
-- Exécutée depuis R par executer_requete_cdk() de DIM-code (src/snds_r/requete_cdk.R).
-- FAMILLE : le nom de l'objet, l'année à deux chiffres des tables du PMSI remplacée par aa (T_MCO23B devient T_MCOaaB), comme dans le schéma du HDH.
-- NB_OBJETS : nombre d'objets de la famille (un par année pour le PMSI). AN_MIN, AN_MAX : années à deux chiffres extrêmes, vides hors PMSI.
SELECT '20261104-snds-familles-tables' AS QUERY_ID,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS DATABASE_NAME,
       TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI') AS RUN_AT,
       f.OWNER, f.OBJECT_TYPE, f.FAMILLE,
       COUNT(*) AS NB_OBJETS, MIN(f.AN) AS AN_MIN, MAX(f.AN) AS AN_MAX
FROM (
  SELECT o.OWNER, o.OBJECT_TYPE,
         REGEXP_REPLACE(o.OBJECT_NAME, '^(T_(MCO|SSR|HAD|RIP|SUP))[0-9]{2}', '\1aa') AS FAMILLE,
         CASE WHEN REGEXP_LIKE(o.OBJECT_NAME, '^T_(MCO|SSR|HAD|RIP|SUP)[0-9]{2}')
              THEN TO_NUMBER(SUBSTR(o.OBJECT_NAME, 6, 2)) END AS AN
  FROM ALL_OBJECTS o
  WHERE o.OBJECT_TYPE IN ('TABLE', 'VIEW', 'SYNONYM')
    AND (o.OBJECT_NAME LIKE 'T\_MCO%' ESCAPE '\' OR o.OBJECT_NAME LIKE 'T\_SSR%' ESCAPE '\'
      OR o.OBJECT_NAME LIKE 'T\_HAD%' ESCAPE '\' OR o.OBJECT_NAME LIKE 'T\_RIP%' ESCAPE '\'
      OR o.OBJECT_NAME LIKE 'T\_SUP%' ESCAPE '\' OR o.OBJECT_NAME LIKE 'ER\_%' ESCAPE '\'
      OR o.OBJECT_NAME LIKE 'IR\_%' ESCAPE '\' OR o.OBJECT_NAME LIKE 'KI\_%' ESCAPE '\'
      OR o.OBJECT_NAME LIKE 'CRTO\_%' ESCAPE '\' OR o.OBJECT_NAME LIKE 'DE\_DEP%' ESCAPE '\'
      OR o.OBJECT_NAME LIKE 'DA\_PRA%' ESCAPE '\')
) f
GROUP BY f.OWNER, f.OBJECT_TYPE, f.FAMILLE
ORDER BY f.FAMILLE, f.OWNER, f.OBJECT_TYPE;
