-- id: 20261023-usip-mvt-rum-par-mois
-- system: cora
-- person_data: masked
-- purpose: dater l'ouverture de l'USIP (UF 6281) et tester trois hypothèses de l'issue : le code 6281 n'avait pas d'activité avant l'USIP ; chaque mouvement dans 6281 a un RUM ; l'activité de l'UF 6284 (surveillance continue post-opératoire) baisse quand celle de 6281 commence. Dit aussi à quelle UM vont les RUM hébergés à l'USIP (étape 1 du plan)
-- Oracle, schéma CORA_REC. Du 2022-01-01 à aujourd'hui. GROUPE_UF : '6281', '6284', 'autres 628x' (6280 et 6282 à 6289), 'hors 628x'.
-- Deux vues. MVT : mouvements de TB_MVT dans une UF 628x (TRIM(ID_UNITE_M), joindre-uf-par-code), par mois de DATE_DEBUT_MVT ; CODE_UM vide. N : mouvements ; N_SEJ : séjours distincts ; N_AVEC_RUM : mouvements présents dans TB_MVT_RUM ; N_OUVERT : mouvements sans DATE_FIN_MVT ; MEDIANE_HEURES : médiane de HEURE_FIN_MVT − HEURE_DEBUT_MVT en heures, sur les mouvements clos (date-et-heure-dans-deux-colonnes). RUM : RUM de TB_SYNTH_RUM dont l'UF d'hébergement (ID_UNITE_HEBERG joint à TB_UNITE.ID_UNITE, piste de l'enquête uf-um-rum, #100) ou l'UM (ID_UNITE_MEDICALE joint à TB_UNITE_MEDICALE.ID_UNITE_MED) a un code 628x, par mois de DATE_FIN_RUM (colonne lue par 20261022-rum-uf-colonnes-remplissage, enquête uf-um-rum) ; GROUPE_UF d'après l'UF d'hébergement, CODE_UM = code de l'UM du RUM. N : RUM ; N_SEJ : séjours distincts ; les autres colonnes sont vides.
-- Masquage : chaque effectif < 10 sort en <10, et la médiane est vide quand elle porte sur moins de 10 mouvements. Suppression secondaire (règle 4) : N sort en « masqué » quand N − N_AVEC_RUM ou N − N_OUVERT vaut de 1 à 9 (mouvements sans RUM, mouvements clos). Aucune ligne de total.
WITH mvt AS (
  SELECT CASE WHEN TRIM(m.ID_UNITE_M) IN ('6281', '6284') THEN TRIM(m.ID_UNITE_M) ELSE 'autres 628x' END AS GROUPE_UF,
         TO_CHAR(m.DATE_DEBUT_MVT, 'YYYY-MM') AS MOIS,
         m.ID_SEJOUR,
         CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_MVT_RUM mr WHERE mr.ID_MVT = m.ID_MVT) THEN 1 ELSE 0 END AS AVEC_RUM,
         CASE WHEN m.DATE_FIN_MVT IS NULL THEN 1 ELSE 0 END AS OUVERT,
         CASE WHEN m.DATE_FIN_MVT IS NOT NULL THEN (m.HEURE_FIN_MVT - m.HEURE_DEBUT_MVT) * 24 END AS HEURES
  FROM CORA_REC.TB_MVT m
  WHERE TRIM(m.ID_UNITE_M) LIKE '628_'
    AND m.DATE_DEBUT_MVT >= DATE '2022-01-01' AND m.DATE_DEBUT_MVT < TRUNC(SYSDATE) + 1
),
va AS (
  SELECT 'MVT' AS VUE, GROUPE_UF, CAST(NULL AS VARCHAR2(10)) AS CODE_UM, MOIS,
         COUNT(*) AS N, COUNT(DISTINCT ID_SEJOUR) AS N_SEJ,
         SUM(AVEC_RUM) AS N_AVEC_RUM, SUM(OUVERT) AS N_OUVERT,
         COUNT(HEURES) AS N_CLOS, MEDIAN(HEURES) AS MED
  FROM mvt
  GROUP BY GROUPE_UF, MOIS
),
rum AS (
  SELECT CASE WHEN TRIM(uf.CODE_UNITE) IN ('6281', '6284') THEN TRIM(uf.CODE_UNITE)
              WHEN TRIM(uf.CODE_UNITE) LIKE '628_' THEN 'autres 628x'
              ELSE 'hors 628x' END AS GROUPE_UF,
         NVL(TRIM(um.CODE_UNITE_MED), '(vide)') AS CODE_UM,
         TO_CHAR(r.DATE_FIN_RUM, 'YYYY-MM') AS MOIS,
         r.ID_SEJOUR
  FROM CORA_REC.TB_SYNTH_RUM r
  LEFT JOIN CORA_REC.TB_UNITE uf ON uf.ID_UNITE = r.ID_UNITE_HEBERG
  LEFT JOIN CORA_REC.TB_UNITE_MEDICALE um ON um.ID_UNITE_MED = r.ID_UNITE_MEDICALE
  WHERE r.DATE_FIN_RUM >= DATE '2022-01-01' AND r.DATE_FIN_RUM < TRUNC(SYSDATE) + 1
    AND (TRIM(uf.CODE_UNITE) LIKE '628_' OR TRIM(um.CODE_UNITE_MED) LIKE '628_')
),
vb AS (
  SELECT 'RUM' AS VUE, GROUPE_UF, CODE_UM, MOIS,
         COUNT(*) AS N, COUNT(DISTINCT ID_SEJOUR) AS N_SEJ,
         CAST(NULL AS NUMBER) AS N_AVEC_RUM, CAST(NULL AS NUMBER) AS N_OUVERT,
         CAST(NULL AS NUMBER) AS N_CLOS, CAST(NULL AS NUMBER) AS MED
  FROM rum
  GROUP BY GROUPE_UF, CODE_UM, MOIS
),
t AS (
  SELECT VUE, GROUPE_UF, CODE_UM, MOIS, N, N_SEJ, N_AVEC_RUM, N_OUVERT, N_CLOS, MED FROM va
  UNION ALL
  SELECT VUE, GROUPE_UF, CODE_UM, MOIS, N, N_SEJ, N_AVEC_RUM, N_OUVERT, N_CLOS, MED FROM vb
)
SELECT '20261023-usip-mvt-rum-par-mois' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       VUE, GROUPE_UF, CODE_UM, MOIS,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - N_AVEC_RUM BETWEEN 1 AND 9 OR N - N_OUVERT BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N,
       CASE WHEN N_SEJ < 10 THEN '<10' ELSE TO_CHAR(N_SEJ) END AS N_SEJ,
       CASE WHEN N_AVEC_RUM BETWEEN 1 AND 9 THEN '<10' ELSE TO_CHAR(N_AVEC_RUM) END AS N_AVEC_RUM,
       CASE WHEN N_OUVERT BETWEEN 1 AND 9 THEN '<10' ELSE TO_CHAR(N_OUVERT) END AS N_OUVERT,
       CASE WHEN N_CLOS >= 10 THEN ROUND(MED, 1) END AS MEDIANE_HEURES
FROM t
ORDER BY VUE, GROUPE_UF, CODE_UM, MOIS;
