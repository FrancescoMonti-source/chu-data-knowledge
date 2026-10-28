-- id: 20261027-statut-prog-urgences-mco
-- system: cora
-- person_data: masked
-- purpose: dire si TB_SEJOUR.STATUT_PROG = 'A' (passé par une préadmission, d'après le dictionnaire CORA 2020) peut repérer une hospitalisation programmée : sa répartition parmi les séjours MCO avec RSS, selon qu'ils entrent ou non par une UF d'urgences (étape 5 du plan, #113)
-- Oracle, schéma CORA_REC. Séjours de TB_SEJOUR sortis (DATE_SORTIE renseignée), reliés à un RSS par TB_SYNTH_RSS.ID_SEJOUR (joindre-rss-par-id-sejour), entrés du 2022-01-01 au 2025-12-31, par année d'entrée.
-- UF d'urgences : 5701, 5802, 5709, 5015, 5010 et 5720, les UF qui reçoivent les passages (drapeau-urgence-uf-non-fiable, unreviewed) ; aucun champ du séjour ne repère les urgences (sejour-sans-signal-urgences).
-- URGENCES : « UF d'entrée d'urgences » si TB_SEJOUR.UF_ENTREE en est une ; sinon « séjour d'urgences la veille ou le jour même » si un autre séjour du même patient est entré par une de ces UF le jour de l'entrée ou la veille ; sinon « aucune urgence repérée ».
-- NUIT : « au moins une nuit » si le jour de sortie suit le jour d'entrée, sinon « sans nuit ».
-- N_SEJ : séjours distincts. Masquage : chaque effectif < 10 sort en <10. Les cases sont disjointes ; aucune ligne de total.
WITH urg AS (
  SELECT s.ID_PATIENT, TRUNC(s.DATE_ENTREE) AS J
  FROM CORA_REC.TB_SEJOUR s
  WHERE TRIM(s.UF_ENTREE) IN ('5701', '5802', '5709', '5015', '5010', '5720')
    AND s.DATE_ENTREE >= DATE '2021-12-31' AND s.DATE_ENTREE < DATE '2026-01-01'
),
mco AS (
  SELECT s.ID_SEJOUR, s.ID_PATIENT, s.DATE_ENTREE, s.DATE_SORTIE, s.UF_ENTREE, s.STATUT_PROG
  FROM CORA_REC.TB_SEJOUR s
  WHERE s.DATE_SORTIE IS NOT NULL
    AND s.DATE_ENTREE >= DATE '2022-01-01' AND s.DATE_ENTREE < DATE '2026-01-01'
    AND EXISTS (SELECT 1 FROM CORA_REC.TB_SYNTH_RSS r WHERE r.ID_SEJOUR = s.ID_SEJOUR)
),
cl AS (
  SELECT EXTRACT(YEAR FROM m.DATE_ENTREE) AS ANNEE_ENTREE,
         NVL(TRIM(m.STATUT_PROG), '(vide)') AS STATUT_PROG,
         CASE WHEN TRIM(m.UF_ENTREE) IN ('5701', '5802', '5709', '5015', '5010', '5720')
                THEN '1 UF d''entrée d''urgences'
              WHEN EXISTS (SELECT 1 FROM urg u
                           WHERE u.ID_PATIENT = m.ID_PATIENT
                             AND u.J BETWEEN TRUNC(m.DATE_ENTREE) - 1 AND TRUNC(m.DATE_ENTREE))
                THEN '2 séjour d''urgences la veille ou le jour même'
              ELSE '3 aucune urgence repérée' END AS URGENCES,
         CASE WHEN TRUNC(m.DATE_SORTIE) > TRUNC(m.DATE_ENTREE) THEN 'au moins une nuit' ELSE 'sans nuit' END AS NUIT
  FROM mco m
)
SELECT '20261027-statut-prog-urgences-mco' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE_ENTREE, NUIT, URGENCES, STATUT_PROG,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE TO_CHAR(COUNT(*)) END AS N_SEJ
FROM cl
GROUP BY ANNEE_ENTREE, NUIT, URGENCES, STATUT_PROG
ORDER BY ANNEE_ENTREE, NUIT, URGENCES, STATUT_PROG;
