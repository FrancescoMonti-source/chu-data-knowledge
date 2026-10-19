-- id: 20261019-drapeaux-referentiels-2
-- system: cora
-- person_data: no-person-data
-- purpose: lister les valeurs distinctes et leur effectif pour les drapeaux des référentiels TB_UNITE (URGENCE, EXTERNE, HJ, GESTION_PMSI, REA, UHCD, AMBULATOIRE, EXT_MED_TECH, ACTIF, UF, UM, SEANCE) et TB_SITE (BLOC, ACTIF, LIEU_REAL_ACTE), pour trancher drapeaux-cora-valeurs-propres sur ces tables (réfuté si un de ces drapeaux vaut 'O' ici et 'X' ou '1' ailleurs de façon incohérente avec le claim ; sinon le claim donne la liste des valeurs propres de chaque drapeau)
-- Nouvelle version de 20261019-drapeaux-referentiels, bloquée par le script parce que la colonne N_LIGNES (petits effectifs de lignes de référentiel) ressemblait à un effectif de personnes. La colonne s'appelle maintenant LIGNES.
-- Oracle, schéma CORA_REC. Référentiels d'unités et de sites : une ligne par unité ou site, aucune donnée de personne, donc pas de masquage. Une valeur vide sort '(vide)'. Les 12 colonnes de TB_UNITE et les 3 de TB_SITE sont présentes dans 20261019-catalogue-types-colonnes-g3 (niveau DRAPEAU, VARCHAR2 de longueur 1), sans retrait.
-- Une ligne par table, drapeau et valeur : LIGNES = nombre de lignes de la table qui portent cette valeur.
WITH u AS (
  SELECT TO_CHAR(TRIM(URGENCE)) AS URGENCE, TO_CHAR(TRIM(EXTERNE)) AS EXTERNE, TO_CHAR(TRIM(HJ)) AS HJ,
         TO_CHAR(TRIM(GESTION_PMSI)) AS GESTION_PMSI, TO_CHAR(TRIM(REA)) AS REA, TO_CHAR(TRIM(UHCD)) AS UHCD,
         TO_CHAR(TRIM(AMBULATOIRE)) AS AMBULATOIRE, TO_CHAR(TRIM(EXT_MED_TECH)) AS EXT_MED_TECH,
         TO_CHAR(TRIM(ACTIF)) AS ACTIF, TO_CHAR(TRIM(UF)) AS UF, TO_CHAR(TRIM(UM)) AS UM,
         TO_CHAR(TRIM(SEANCE)) AS SEANCE
  FROM CORA_REC.TB_UNITE
),
us AS (
  SELECT 'TB_UNITE' AS TABLE_NAME, DRAPEAU, NVL(VALEUR, '(vide)') AS VALEUR
  FROM u
  UNPIVOT INCLUDE NULLS (VALEUR FOR DRAPEAU IN (URGENCE, EXTERNE, HJ, GESTION_PMSI, REA, UHCD, AMBULATOIRE, EXT_MED_TECH, ACTIF, UF, UM, SEANCE))
),
s AS (
  SELECT TO_CHAR(TRIM(BLOC)) AS BLOC, TO_CHAR(TRIM(ACTIF)) AS ACTIF, TO_CHAR(TRIM(LIEU_REAL_ACTE)) AS LIEU_REAL_ACTE
  FROM CORA_REC.TB_SITE
),
ss AS (
  SELECT 'TB_SITE' AS TABLE_NAME, DRAPEAU, NVL(VALEUR, '(vide)') AS VALEUR
  FROM s
  UNPIVOT INCLUDE NULLS (VALEUR FOR DRAPEAU IN (BLOC, ACTIF, LIEU_REAL_ACTE))
),
t AS (
  SELECT TABLE_NAME, DRAPEAU, VALEUR FROM us
  UNION ALL
  SELECT TABLE_NAME, DRAPEAU, VALEUR FROM ss
)
SELECT '20261019-drapeaux-referentiels-2' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       TABLE_NAME, DRAPEAU, VALEUR,
       TO_CHAR(COUNT(*)) AS LIGNES
FROM t
GROUP BY TABLE_NAME, DRAPEAU, VALEUR
ORDER BY TABLE_NAME, DRAPEAU, VALEUR;
