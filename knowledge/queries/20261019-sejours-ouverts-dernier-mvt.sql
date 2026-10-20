-- id: 20261019-sejours-ouverts-dernier-mvt
-- system: cora
-- person_data: masked
-- purpose: pour les séjours sans DATE_SORTIE (ouverts) comme pour les séjours clos, mesurer l'écart en jours entre le début du dernier mouvement et DATE_ENTREE, et croiser avec MODE_SORTIE vide ou renseigné, pour borner dernier-mouvement-date-la-sortie (le substitut par le dernier mouvement ne vaut que pour les séjours clos ; amendement : pour les séjours ouverts le début du dernier mouvement tombe à 0-1 jour de l'entrée) et mode-sortie-du-sejour (MODE_SORTIE vide pour presque tous les séjours sans sortie, renseigné pour 84 % des séjours clos). Si l'écart des séjours ouverts dépasse 1 jour pour une part notable, l'amendement est faux et le substitut vaut moins.
-- Oracle 11g, schéma CORA_REC. Séjours entrés du 2018-01-01 à aujourd'hui, par année d'entrée, hors préadmissions (STATUT_PROG = 'P') et hors séjours sans mouvement. ETAT : 'ouvert' (sans DATE_SORTIE) ou 'clos'. Dernier mouvement : le plus tardif par DATE_DEBUT_MVT, HEURE_DEBUT_MVT, ID_MVT. ECART_JOURS : TRUNC(début du dernier mouvement) − TRUNC(DATE_ENTREE), en classes '<0', '0', '1', '2-7', '8-30', '31+'.
-- Colonnes : ANNEE, ETAT, MODE_SORTIE_VIDE (oui, non), ECART_JOURS, N (séjours), PCT_ETAT (part dans l'année et l'état, vide quand N est masqué).
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : quand les cases masquées d'une année et d'un état totalisent de 1 à 9, la plus grande case du groupe sort aussi en « masqué ». Aucune ligne de total.
WITH dm AS (
  SELECT ID_SEJOUR,
         MAX(TRUNC(DATE_DEBUT_MVT)) KEEP (DENSE_RANK LAST ORDER BY DATE_DEBUT_MVT, HEURE_DEBUT_MVT, ID_MVT) AS DEB
  FROM CORA_REC.TB_MVT
  GROUP BY ID_SEJOUR
),
f AS (
  SELECT EXTRACT(YEAR FROM se.DATE_ENTREE) AS ANNEE,
         CASE WHEN se.DATE_SORTIE IS NULL THEN 'ouvert' ELSE 'clos' END AS ETAT,
         CASE WHEN TRIM(se.MODE_SORTIE) IS NULL THEN 'oui' ELSE 'non' END AS MODE_SORTIE_VIDE,
         CASE WHEN dm.DEB IS NULL THEN '(vide)'
              WHEN dm.DEB - TRUNC(se.DATE_ENTREE) < 0 THEN '<0'
              WHEN dm.DEB - TRUNC(se.DATE_ENTREE) = 0 THEN '0'
              WHEN dm.DEB - TRUNC(se.DATE_ENTREE) = 1 THEN '1'
              WHEN dm.DEB - TRUNC(se.DATE_ENTREE) <= 7 THEN '2-7'
              WHEN dm.DEB - TRUNC(se.DATE_ENTREE) <= 30 THEN '8-30'
              ELSE '31+' END AS ECART_JOURS
  FROM CORA_REC.TB_SEJOUR se
  JOIN dm ON dm.ID_SEJOUR = se.ID_SEJOUR
  WHERE se.DATE_ENTREE >= DATE '2018-01-01' AND se.DATE_ENTREE < TRUNC(SYSDATE) + 1
    AND NVL(se.STATUT_PROG, '-') <> 'P'
),
g AS (
  SELECT ANNEE, ETAT, MODE_SORTIE_VIDE, ECART_JOURS, COUNT(*) AS N
  FROM f
  GROUP BY ANNEE, ETAT, MODE_SORTIE_VIDE, ECART_JOURS
),
m AS (
  SELECT ANNEE, ETAT, MODE_SORTIE_VIDE, ECART_JOURS, N,
         SUM(N) OVER (PARTITION BY ANNEE, ETAT) AS TOT,
         SUM(CASE WHEN N < 10 THEN N ELSE 0 END) OVER (PARTITION BY ANNEE, ETAT) AS CACHE,
         ROW_NUMBER() OVER (PARTITION BY ANNEE, ETAT ORDER BY N DESC, MODE_SORTIE_VIDE, ECART_JOURS) AS RANG
  FROM g
)
SELECT '20261019-sejours-ouverts-dernier-mvt' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE, ETAT, MODE_SORTIE_VIDE, ECART_JOURS,
       CASE WHEN N < 10 THEN '<10' WHEN CACHE BETWEEN 1 AND 9 AND RANG = 1 THEN 'masqué' ELSE TO_CHAR(N) END AS N,
       CASE WHEN N < 10 OR (CACHE BETWEEN 1 AND 9 AND RANG = 1) THEN NULL ELSE ROUND(100 * N / TOT, 2) END AS PCT_ETAT
FROM m
ORDER BY ANNEE, ETAT, MODE_SORTIE_VIDE, ECART_JOURS;
