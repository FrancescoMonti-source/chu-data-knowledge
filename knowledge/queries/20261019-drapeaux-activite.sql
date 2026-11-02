-- id: 20261019-drapeaux-activite
-- system: cora
-- person_data: masked
-- purpose: lister les valeurs distinctes et leur effectif pour les drapeaux des tables d'activité : TB_DET_ACTE (FACTURABLE, ACTE_GRATUIT, POUR_MEMOIRE, ETAT), TB_MVT (FLAG_MVT_SITE, BLOCAGE_RSS) et TB_SYNTH_RUM (DP_MVT_RETENU), pour trancher drapeaux-cora-valeurs-propres (réfuté si un drapeau étudié vaut 'O' dans une table où il vaut 'X' ailleurs ; sinon le résultat fixe la valeur vraie de chaque drapeau : 'X' pour FLAG_MVT_SITE et DP_MVT_RETENU, 'O' pour BLOCAGE_RSS, selon le claim) ; sert aussi à lire les valeurs de FACTURABLE, ACTE_GRATUIT et POUR_MEMOIRE avant acte-non-facturable-montant-non-nul
-- Oracle, schéma CORA_REC. Colonnes d'après le dictionnaire 2020 (TB_DET_ACTE, TB_MVT, TB_SYNTH_RUM) ; à confirmer avec 20261019-catalogue-types-colonnes-g3 (niveau DRAPEAU) : si une colonne manque, retirer son bloc et le dire. Une valeur vide sort '(vide)'.
-- Périmètre : TB_DET_ACTE et TB_SYNTH_RUM sans borne de date (pas de date propre : tout l'historique) ; TB_MVT pour les mouvements dont DATE_DEBUT_MVT va du 2018-01-01 à aujourd'hui. Les combinaisons de drapeaux sont d'abord comptées dans Oracle, puis dépliées une ligne par table, drapeau et valeur.
-- N_LIGNES = nombre de lignes de la table (actes-activités, mouvements, RUM) qui portent la valeur. Aucune ligne de total ne sort : une cellule masquée ne se retrouve pas par différence.
-- Masquage : chaque effectif < 10 sort en <10 (règle 3).
WITH da AS (
  SELECT TO_CHAR(TRIM(FACTURABLE)) AS FACTURABLE, TO_CHAR(TRIM(ACTE_GRATUIT)) AS ACTE_GRATUIT,
         TO_CHAR(TRIM(POUR_MEMOIRE)) AS POUR_MEMOIRE, TO_CHAR(TRIM(ETAT)) AS ETAT, COUNT(*) AS N
  FROM CORA_REC.TB_DET_ACTE
  GROUP BY TO_CHAR(TRIM(FACTURABLE)), TO_CHAR(TRIM(ACTE_GRATUIT)), TO_CHAR(TRIM(POUR_MEMOIRE)), TO_CHAR(TRIM(ETAT))
),
dau AS (
  SELECT 'TB_DET_ACTE' AS TABLE_NAME, DRAPEAU, NVL(VALEUR, '(vide)') AS VALEUR, N
  FROM da
  UNPIVOT INCLUDE NULLS (VALEUR FOR DRAPEAU IN (FACTURABLE, ACTE_GRATUIT, POUR_MEMOIRE, ETAT))
),
mv AS (
  SELECT TO_CHAR(TRIM(FLAG_MVT_SITE)) AS FLAG_MVT_SITE, TO_CHAR(TRIM(BLOCAGE_RSS)) AS BLOCAGE_RSS, COUNT(*) AS N
  FROM CORA_REC.TB_MVT
  WHERE DATE_DEBUT_MVT >= DATE '2018-01-01' AND DATE_DEBUT_MVT < TRUNC(SYSDATE) + 1
  GROUP BY TO_CHAR(TRIM(FLAG_MVT_SITE)), TO_CHAR(TRIM(BLOCAGE_RSS))
),
mvu AS (
  SELECT 'TB_MVT' AS TABLE_NAME, DRAPEAU, NVL(VALEUR, '(vide)') AS VALEUR, N
  FROM mv
  UNPIVOT INCLUDE NULLS (VALEUR FOR DRAPEAU IN (FLAG_MVT_SITE, BLOCAGE_RSS))
),
sr AS (
  SELECT TO_CHAR(TRIM(DP_MVT_RETENU)) AS DP_MVT_RETENU, COUNT(*) AS N
  FROM CORA_REC.TB_SYNTH_RUM
  GROUP BY TO_CHAR(TRIM(DP_MVT_RETENU))
),
sru AS (
  SELECT 'TB_SYNTH_RUM' AS TABLE_NAME, 'DP_MVT_RETENU' AS DRAPEAU, NVL(DP_MVT_RETENU, '(vide)') AS VALEUR, N
  FROM sr
),
t AS (
  SELECT TABLE_NAME, DRAPEAU, VALEUR, N FROM dau
  UNION ALL
  SELECT TABLE_NAME, DRAPEAU, VALEUR, N FROM mvu
  UNION ALL
  SELECT TABLE_NAME, DRAPEAU, VALEUR, N FROM sru
),
g AS (
  SELECT TABLE_NAME, DRAPEAU, VALEUR, SUM(N) AS N
  FROM t
  GROUP BY TABLE_NAME, DRAPEAU, VALEUR
)
SELECT '20261019-drapeaux-activite' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       TABLE_NAME, DRAPEAU, VALEUR,
       CASE WHEN N < 10 THEN '<10' ELSE TO_CHAR(N) END AS N_LIGNES
FROM g
ORDER BY TABLE_NAME, DRAPEAU, VALEUR;
