-- id: 20261015-groupage-m8-hist-synth-rss
-- system: cora
-- person_data: masked
-- purpose: par mois de sortie des RSS MCO finis de janvier à août 2026 en GHM chirurgical aujourd'hui, compter ceux regroupés après l'état M8 (2026-10-02 07:47:40) et ceux dont TB_HIST_SYNTH_RSS garde une version groupée avant, pour savoir si l'historique donne le GHM à M8 (étape 1 du plan) ; et compter les RSS bloqués et ceux qui ont une ligne groupée (LIGNES_GRP), pour savoir si CORA garde la trace de l'envoi
-- Oracle, schéma CORA_REC. GHM chirurgical : CMD autre que 90 et 1er caractère de CODE_GHM = C (20261015-type-niveau-ghm-resultat).
-- Date de groupage d'une version : jour de DATE_FABRICATION, heure de HEURE_FABRICATION (dictionnaire-cora-2020, TB_SYNTH_RSS : « Date de groupage »).
-- L'historique est relié au RSS par ID_RSS.
-- N_RSS_REGROUPES_APRES_M8 : version actuelle groupée à ou après la coupure.
-- N_RSS_REGROUPES_AVEC_HIST_AVANT : parmi eux, ceux dont l'historique garde une version groupée avant la coupure.
-- N_RSS_AVEC_HIST : au moins une ligne dans TB_HIST_SYNTH_RSS. N_RSS_SANS_DATE_FAB : DATE_FABRICATION vide.
-- N_RSS_BLOQUES : DATE_ENVOI_TUTELLE (« Date de blocage ») renseignée ; N_RSS_BLOQUES_0210 : bloqués le 2 octobre 2026.
-- N_RSS_LIGNES_GRP : LIGNES_GRP (« Ligne groupée du RSS ») renseignée. Aucun contenu de LIGNES_GRP n'est lu, seulement sa présence.
-- Règle 4 : pas de colonne total, mais l'effectif chirurgical du mois se déduit de 20261015-type-niveau-ghm-resultat. Une colonne sort donc « masqué » quand l'effectif du mois moins la colonne vaut de 1 à 9 ; N_RSS_REGROUPES_AVEC_HIST_AVANT aussi quand N_RSS_REGROUPES_APRES_M8 moins elle vaut de 1 à 9, et N_RSS_BLOQUES_0210 quand N_RSS_BLOQUES moins elle vaut de 1 à 9.
WITH r AS (
  SELECT s.ID_RSS,
         TO_CHAR(s.DATE_FIN, 'YYYY-MM') AS MOIS_SORTIE,
         s.DATE_FABRICATION,
         TO_DATE(TO_CHAR(s.DATE_FABRICATION, 'YYYY-MM-DD') || ' ' || NVL(TO_CHAR(s.HEURE_FABRICATION, 'HH24:MI:SS'), '00:00:00'),
                 'YYYY-MM-DD HH24:MI:SS') AS FAB,
         s.DATE_ENVOI_TUTELLE,
         CASE WHEN s.LIGNES_GRP IS NOT NULL AND DBMS_LOB.GETLENGTH(s.LIGNES_GRP) > 0 THEN 1 ELSE 0 END AS A_LIGNES
  FROM CORA_REC.TB_SYNTH_RSS s
  WHERE s.DATE_FIN >= DATE '2026-01-01'
    AND s.DATE_FIN <  DATE '2026-09-01'
    AND TRIM(s.CODE_CMD) <> '90'
    AND SUBSTR(TRIM(s.CODE_GHM), 1, 1) = 'C'
),
h AS (
  SELECT x.ID_RSS,
         MAX(CASE WHEN TO_DATE(TO_CHAR(x.DATE_FABRICATION, 'YYYY-MM-DD') || ' ' || NVL(TO_CHAR(x.HEURE_FABRICATION, 'HH24:MI:SS'), '00:00:00'),
                               'YYYY-MM-DD HH24:MI:SS') < TIMESTAMP '2026-10-02 07:47:40'
                  THEN 1 ELSE 0 END) AS HIST_AVANT
  FROM CORA_REC.TB_HIST_SYNTH_RSS x
  WHERE x.ID_RSS IN (SELECT ID_RSS FROM r)
  GROUP BY x.ID_RSS
),
agg AS (
  SELECT r.MOIS_SORTIE,
         COUNT(*) AS NB,
         SUM(CASE WHEN r.FAB >= TIMESTAMP '2026-10-02 07:47:40' THEN 1 ELSE 0 END) AS NB_APRES,
         SUM(CASE WHEN r.FAB >= TIMESTAMP '2026-10-02 07:47:40' AND h.HIST_AVANT = 1 THEN 1 ELSE 0 END) AS NB_APRES_HIST,
         SUM(CASE WHEN h.ID_RSS IS NOT NULL THEN 1 ELSE 0 END) AS NB_HIST,
         SUM(CASE WHEN r.DATE_FABRICATION IS NULL THEN 1 ELSE 0 END) AS NB_SANS_FAB,
         SUM(CASE WHEN r.DATE_ENVOI_TUTELLE IS NOT NULL THEN 1 ELSE 0 END) AS NB_BLOQUES,
         SUM(CASE WHEN TRUNC(r.DATE_ENVOI_TUTELLE) = DATE '2026-10-02' THEN 1 ELSE 0 END) AS NB_BLOQUES_0210,
         SUM(r.A_LIGNES) AS NB_LIGNES
  FROM r
  LEFT JOIN h ON h.ID_RSS = r.ID_RSS
  GROUP BY r.MOIS_SORTIE
)
SELECT '20261015-groupage-m8-hist-synth-rss' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       MOIS_SORTIE,
       CASE WHEN NB_APRES < 10 THEN '<10' WHEN NB - NB_APRES BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(NB_APRES) END AS N_RSS_REGROUPES_APRES_M8,
       CASE WHEN NB_APRES_HIST < 10 THEN '<10'
            WHEN NB - NB_APRES_HIST BETWEEN 1 AND 9 OR NB_APRES - NB_APRES_HIST BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(NB_APRES_HIST) END AS N_RSS_REGROUPES_AVEC_HIST_AVANT,
       CASE WHEN NB_HIST < 10 THEN '<10' WHEN NB - NB_HIST BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(NB_HIST) END AS N_RSS_AVEC_HIST,
       CASE WHEN NB_SANS_FAB < 10 THEN '<10' WHEN NB - NB_SANS_FAB BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(NB_SANS_FAB) END AS N_RSS_SANS_DATE_FAB,
       CASE WHEN NB_BLOQUES < 10 THEN '<10' WHEN NB - NB_BLOQUES BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(NB_BLOQUES) END AS N_RSS_BLOQUES,
       CASE WHEN NB_BLOQUES_0210 < 10 THEN '<10'
            WHEN NB - NB_BLOQUES_0210 BETWEEN 1 AND 9 OR NB_BLOQUES - NB_BLOQUES_0210 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(NB_BLOQUES_0210) END AS N_RSS_BLOQUES_0210,
       CASE WHEN NB_LIGNES < 10 THEN '<10' WHEN NB - NB_LIGNES BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(NB_LIGNES) END AS N_RSS_LIGNES_GRP
FROM agg
ORDER BY MOIS_SORTIE;
