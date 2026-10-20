-- id: 20261019-ghs-tarif-periodes
-- system: cora
-- person_data: no-person-data
-- purpose: décrire les périodes de validité de CORA_REC.PMSI_LIB_GHS_TARIF par couple GHM-GHS : part de DATE_FIN vide, doublons de période, écart entre DATE_FIN d'une ligne et DATE_DEBUT de la suivante, pour fixer la borne de DATE_FIN (exclusive si l'écart vaut 0 jour, inclusive si 1 jour) et nourrir tarif-ghs-jointure-couverture et l'AM10 (c) de referentiels-pmsi-dans-cora
-- Oracle, schéma CORA_REC. Référentiel national, aucune donnée de personne : pas de masquage. Colonnes de PMSI_LIB_GHS_TARIF d'après 20261015-catalogue-referentiels-resultat : GHS (GHM complet sur 6 caractères), CODE_GHS, TYPE_ACTIVITE, DATE_DEBUT, DATE_FIN, PRIX. Couple = TRIM(GHS), TRIM(CODE_GHS), TRIM(TYPE_ACTIVITE) ; lignes triées par DATE_DEBUT dans le couple. Toutes les lignes de la table, sans borne de date. Dates comparées après TRUNC.
-- Niveau RESUME (une ligne) : N_LIGNES, N_COUPLES, N_DATE_FIN_VIDE, N_DATE_DEBUT_VIDE, N_FIN_AVANT_DEBUT, N_DATE_FIN_AVEC_HEURE (DATE_FIN avec une heure non nulle), N_DOUBLONS_PERIODE (lignes qui partagent leur couple et leur DATE_DEBUT avec une autre), DATE_DEBUT_MIN et DATE_DEBUT_MAX.
-- Niveau ECART (une ligne par valeur) : pour chaque ligne qui a une suivante dans son couple, ECART_JOURS = DATE_DEBUT de la suivante − DATE_FIN ; CLASSE_ECART : 'chevauchement' (< 0), '0 jour' (borne exclusive : la ligne suivante commence le jour de la DATE_FIN), '1 jour' (borne inclusive : la DATE_FIN est la veille), '2 jours ou plus' (trou), 'DATE_FIN vide avec suivante' (période ouverte suivie d'une autre ligne) ; N_LIGNES = nombre de lignes de cette classe.
WITH t AS (
  SELECT TRIM(GHS) AS GHM6, TRIM(CODE_GHS) AS GHS_NUM, TRIM(TYPE_ACTIVITE) AS TYPE_ACT,
         TRUNC(DATE_DEBUT) AS DD, TRUNC(DATE_FIN) AS DF,
         CASE WHEN DATE_FIN IS NOT NULL AND DATE_FIN <> TRUNC(DATE_FIN) THEN 1 ELSE 0 END AS FIN_HEURE
  FROM CORA_REC.PMSI_LIB_GHS_TARIF
),
l AS (
  SELECT t.GHM6, t.GHS_NUM, t.TYPE_ACT, t.DD, t.DF, t.FIN_HEURE,
         LEAD(DD) OVER (PARTITION BY GHM6, GHS_NUM, TYPE_ACT ORDER BY DD) AS DD_SUIV,
         COUNT(*) OVER (PARTITION BY GHM6, GHS_NUM, TYPE_ACT, DD) AS N_MEME_DEBUT
  FROM t
),
resume AS (
  SELECT COUNT(*) AS N_LIGNES,
         (SELECT COUNT(*) FROM (SELECT DISTINCT GHM6, GHS_NUM, TYPE_ACT FROM t)) AS N_COUPLES,
         SUM(CASE WHEN DF IS NULL THEN 1 ELSE 0 END) AS N_FIN_VIDE,
         SUM(CASE WHEN DD IS NULL THEN 1 ELSE 0 END) AS N_DEBUT_VIDE,
         SUM(CASE WHEN DF < DD THEN 1 ELSE 0 END) AS N_FIN_AVANT_DEBUT,
         SUM(FIN_HEURE) AS N_FIN_HEURE,
         SUM(CASE WHEN N_MEME_DEBUT > 1 THEN 1 ELSE 0 END) AS N_DOUBLONS,
         MIN(DD) AS DEBUT_MIN, MAX(DD) AS DEBUT_MAX
  FROM l
),
ecart AS (
  SELECT CASE WHEN DF IS NULL THEN 'DATE_FIN vide avec suivante'
              WHEN DD_SUIV - DF < 0 THEN 'chevauchement'
              WHEN DD_SUIV - DF = 0 THEN '0 jour'
              WHEN DD_SUIV - DF = 1 THEN '1 jour'
              ELSE '2 jours ou plus' END AS CLASSE_ECART,
         COUNT(*) AS N
  FROM l
  WHERE DD_SUIV IS NOT NULL
  GROUP BY CASE WHEN DF IS NULL THEN 'DATE_FIN vide avec suivante'
                WHEN DD_SUIV - DF < 0 THEN 'chevauchement'
                WHEN DD_SUIV - DF = 0 THEN '0 jour'
                WHEN DD_SUIV - DF = 1 THEN '1 jour'
                ELSE '2 jours ou plus' END
)
SELECT '20261019-ghs-tarif-periodes' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       'RESUME' AS NIVEAU, CAST(NULL AS VARCHAR2(40)) AS CLASSE_ECART,
       TO_CHAR(N_LIGNES) AS N_LIGNES, TO_CHAR(N_COUPLES) AS N_COUPLES,
       TO_CHAR(N_FIN_VIDE) AS N_DATE_FIN_VIDE, TO_CHAR(N_DEBUT_VIDE) AS N_DATE_DEBUT_VIDE,
       TO_CHAR(N_FIN_AVANT_DEBUT) AS N_FIN_AVANT_DEBUT, TO_CHAR(N_FIN_HEURE) AS N_DATE_FIN_AVEC_HEURE,
       TO_CHAR(N_DOUBLONS) AS N_DOUBLONS_PERIODE,
       TO_CHAR(DEBUT_MIN, 'YYYY-MM-DD') AS DATE_DEBUT_MIN, TO_CHAR(DEBUT_MAX, 'YYYY-MM-DD') AS DATE_DEBUT_MAX
FROM resume
UNION ALL
SELECT '20261019-ghs-tarif-periodes', SYS_CONTEXT('USERENV', 'DB_NAME'), TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI'),
       'ECART', CLASSE_ECART, TO_CHAR(N), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM ecart
ORDER BY 4, 5;
