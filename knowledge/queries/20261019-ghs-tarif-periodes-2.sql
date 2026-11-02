-- id: 20261019-ghs-tarif-periodes-2
-- system: cora
-- person_data: no-person-data
-- purpose: décrire les périodes de validité de CORA_REC.PMSI_LIB_GHS_TARIF par couple GHM-GHS : part de DATE_FIN vide, doublons de période, écart entre DATE_FIN d'une ligne et DATE_DEBUT de la suivante, pour fixer la borne de DATE_FIN (exclusive si l'écart vaut 0 jour, inclusive si 1 jour) et nourrir tarif-ghs-jointure-couverture et l'AM10 (c) de referentiels-pmsi-dans-cora
-- Nouvelle version de 20261019-ghs-tarif-periodes, qui a échoué en ORA-00937. La cause exacte n'est pas désignée par le message ; le SELECT agrégé du niveau RESUME portait une sous-requête scalaire (comptage des couples) et le niveau ECART répétait l'expression CASE dans SELECT et GROUP BY. Ici chaque SELECT agrégé ne contient que des agrégats ou les colonnes de son GROUP BY : le comptage des couples est un bloc à part, joint par CROSS JOIN après l'agrégation, et la classe d'écart est calculée dans un bloc avant d'être regroupée.
-- Oracle 11g, schéma CORA_REC. Référentiel national, aucune donnée de personne : pas de masquage. Colonnes de PMSI_LIB_GHS_TARIF d'après 20261015-catalogue-referentiels-resultat : GHS (GHM complet sur 6 caractères), CODE_GHS, TYPE_ACTIVITE, DATE_DEBUT, DATE_FIN, PRIX. Couple = TRIM(GHS), TRIM(CODE_GHS), TRIM(TYPE_ACTIVITE) ; lignes triées par DATE_DEBUT dans le couple. Toutes les lignes de la table, sans borne de date. Dates comparées après TRUNC.
-- Les colonnes de comptage ne s'appellent pas N_… ni NB_… (garde-fou du script sur les petits nombres).
-- Niveau RESUME (une ligne) : LIGNES, COUPLES, DATE_FIN_VIDE, DATE_DEBUT_VIDE, FIN_AVANT_DEBUT, DATE_FIN_AVEC_HEURE (DATE_FIN avec une heure non nulle), DOUBLONS_PERIODE (lignes qui partagent leur couple et leur DATE_DEBUT avec une autre), DATE_DEBUT_MIN et DATE_DEBUT_MAX.
-- Niveau ECART (une ligne par classe) : pour chaque ligne qui a une suivante dans son couple, ECART_JOURS = DATE_DEBUT de la suivante - DATE_FIN ; CLASSE_ECART : 'chevauchement' (< 0), '0 jour' (borne exclusive : la ligne suivante commence le jour de la DATE_FIN), '1 jour' (borne inclusive : la DATE_FIN est la veille), '2 jours ou plus' (trou), 'DATE_FIN vide avec suivante' (période ouverte suivie d'une autre ligne) ; LIGNES = nombre de lignes de cette classe.
WITH t AS (
  SELECT TRIM(GHS) AS GHM6, TRIM(CODE_GHS) AS GHS_NUM, TRIM(TYPE_ACTIVITE) AS TYPE_ACT,
         TRUNC(DATE_DEBUT) AS DD, TRUNC(DATE_FIN) AS DF,
         CASE WHEN DATE_FIN IS NOT NULL AND DATE_FIN <> TRUNC(DATE_FIN) THEN 1 ELSE 0 END AS FIN_HEURE
  FROM CORA_REC.PMSI_LIB_GHS_TARIF
),
l AS (
  SELECT GHM6, GHS_NUM, TYPE_ACT, DD, DF, FIN_HEURE,
         LEAD(DD) OVER (PARTITION BY GHM6, GHS_NUM, TYPE_ACT ORDER BY DD) AS DD_SUIV,
         COUNT(*) OVER (PARTITION BY GHM6, GHS_NUM, TYPE_ACT, DD) AS MEME_DEBUT
  FROM t
),
cp AS (
  SELECT COUNT(*) AS COUPLES
  FROM (SELECT DISTINCT GHM6, GHS_NUM, TYPE_ACT FROM t)
),
r1 AS (
  SELECT COUNT(*) AS LIGNES,
         SUM(CASE WHEN DF IS NULL THEN 1 ELSE 0 END) AS FIN_VIDE,
         SUM(CASE WHEN DD IS NULL THEN 1 ELSE 0 END) AS DEBUT_VIDE,
         SUM(CASE WHEN DF < DD THEN 1 ELSE 0 END) AS FIN_AVANT_DEBUT,
         SUM(FIN_HEURE) AS FIN_HEURE,
         SUM(CASE WHEN MEME_DEBUT > 1 THEN 1 ELSE 0 END) AS DOUBLONS,
         MIN(DD) AS DEBUT_MIN,
         MAX(DD) AS DEBUT_MAX
  FROM l
),
e0 AS (
  SELECT CASE WHEN DF IS NULL THEN 'DATE_FIN vide avec suivante'
              WHEN DD_SUIV - DF < 0 THEN 'chevauchement'
              WHEN DD_SUIV - DF = 0 THEN '0 jour'
              WHEN DD_SUIV - DF = 1 THEN '1 jour'
              ELSE '2 jours ou plus' END AS CLASSE_ECART
  FROM l
  WHERE DD_SUIV IS NOT NULL
),
e1 AS (
  SELECT CLASSE_ECART, COUNT(*) AS LIGNES
  FROM e0
  GROUP BY CLASSE_ECART
),
resume AS (
  SELECT r1.LIGNES, cp.COUPLES, r1.FIN_VIDE, r1.DEBUT_VIDE, r1.FIN_AVANT_DEBUT, r1.FIN_HEURE,
         r1.DOUBLONS, r1.DEBUT_MIN, r1.DEBUT_MAX
  FROM r1 CROSS JOIN cp
)
SELECT '20261019-ghs-tarif-periodes-2' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       'RESUME' AS NIVEAU, CAST(NULL AS VARCHAR2(40)) AS CLASSE_ECART,
       TO_CHAR(LIGNES) AS LIGNES, TO_CHAR(COUPLES) AS COUPLES,
       TO_CHAR(FIN_VIDE) AS DATE_FIN_VIDE, TO_CHAR(DEBUT_VIDE) AS DATE_DEBUT_VIDE,
       TO_CHAR(FIN_AVANT_DEBUT) AS FIN_AVANT_DEBUT, TO_CHAR(FIN_HEURE) AS DATE_FIN_AVEC_HEURE,
       TO_CHAR(DOUBLONS) AS DOUBLONS_PERIODE,
       TO_CHAR(DEBUT_MIN, 'YYYY-MM-DD') AS DATE_DEBUT_MIN, TO_CHAR(DEBUT_MAX, 'YYYY-MM-DD') AS DATE_DEBUT_MAX
FROM resume
UNION ALL
SELECT '20261019-ghs-tarif-periodes-2', SYS_CONTEXT('USERENV', 'DB_NAME'), TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI'),
       'ECART', CLASSE_ECART, TO_CHAR(LIGNES), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM e1
ORDER BY 4, 5;
