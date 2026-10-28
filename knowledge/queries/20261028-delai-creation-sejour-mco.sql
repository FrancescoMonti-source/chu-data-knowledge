-- id: 20261028-delai-creation-sejour-mco
-- system: cora
-- person_data: masked
-- purpose: dire si l'écart entre la création du séjour dans CORA (TB_SEJOUR.DATE_CREAT) et son entrée sépare les hospitalisations programmées des autres, puisque STATUT_PROG ne le fait pas (20261028-statut-prog-urgences-mco-resultat) ; même population et mêmes classes d'urgences que l'étape 5 (étape 5 revue, #113)
-- Oracle, schéma CORA_REC. Séjours de TB_SEJOUR sortis (DATE_SORTIE renseignée), reliés à un RSS par TB_SYNTH_RSS.ID_SEJOUR (joindre-rss-par-id-sejour), entrés du 2022-01-01 au 2025-12-31, par année d'entrée.
-- DATE_CREAT : « date de création de cet enregistrement » (dictionnaire CORA 2020, TB_SEJOUR, champ 40). Les préadmissions sont dans CORA avant l'entrée (20261014-entrees-futures-profil-resultat) : un séjour programmé devrait être créé avant le jour d'entrée, un séjour entré par les urgences le jour même.
-- URGENCES et NUIT : les classes de 20261027-statut-prog-urgences-mco, mêmes UF d'urgences (5701, 5802, 5709, 5015, 5010, 5720).
-- DELAI_CREATION : jours entre le jour de création et le jour d'entrée.
-- N_SEJ : séjours distincts. Masquage : chaque effectif < 10 sort en <10. Les cases sont disjointes, sans ligne de total. Mais 20261028-statut-prog-urgences-mco-resultat donne, pour plusieurs groupes année x nuit x urgences, le total exact du groupe : dans un groupe où une seule case est sous 10, la plus petite des autres sort en « masqué », pour que la case sous 10 ne se retrouve pas par différence.
WITH urg AS (
  SELECT s.ID_PATIENT, TRUNC(s.DATE_ENTREE) AS J
  FROM CORA_REC.TB_SEJOUR s
  WHERE TRIM(s.UF_ENTREE) IN ('5701', '5802', '5709', '5015', '5010', '5720')
    AND s.DATE_ENTREE >= DATE '2021-12-31' AND s.DATE_ENTREE < DATE '2026-01-01'
),
mco AS (
  SELECT s.ID_SEJOUR, s.ID_PATIENT, s.DATE_ENTREE, s.DATE_SORTIE, s.UF_ENTREE, s.DATE_CREAT
  FROM CORA_REC.TB_SEJOUR s
  WHERE s.DATE_SORTIE IS NOT NULL
    AND s.DATE_ENTREE >= DATE '2022-01-01' AND s.DATE_ENTREE < DATE '2026-01-01'
    AND EXISTS (SELECT 1 FROM CORA_REC.TB_SYNTH_RSS r WHERE r.ID_SEJOUR = s.ID_SEJOUR)
),
cl AS (
  SELECT EXTRACT(YEAR FROM m.DATE_ENTREE) AS ANNEE_ENTREE,
         CASE WHEN TRUNC(m.DATE_SORTIE) > TRUNC(m.DATE_ENTREE) THEN 'au moins une nuit' ELSE 'sans nuit' END AS NUIT,
         CASE WHEN TRIM(m.UF_ENTREE) IN ('5701', '5802', '5709', '5015', '5010', '5720')
                THEN '1 UF d''entrée d''urgences'
              WHEN EXISTS (SELECT 1 FROM urg u
                           WHERE u.ID_PATIENT = m.ID_PATIENT
                             AND u.J BETWEEN TRUNC(m.DATE_ENTREE) - 1 AND TRUNC(m.DATE_ENTREE))
                THEN '2 séjour d''urgences la veille ou le jour même'
              ELSE '3 aucune urgence repérée' END AS URGENCES,
         CASE WHEN m.DATE_CREAT IS NULL THEN '(vide)'
              WHEN TRUNC(m.DATE_CREAT) > TRUNC(m.DATE_ENTREE) + 7 THEN '7 créé plus de 7 jours après l''entrée'
              WHEN TRUNC(m.DATE_CREAT) > TRUNC(m.DATE_ENTREE) THEN '6 créé 1 à 7 jours après l''entrée'
              WHEN TRUNC(m.DATE_CREAT) = TRUNC(m.DATE_ENTREE) THEN '5 créé le jour de l''entrée'
              WHEN TRUNC(m.DATE_CREAT) = TRUNC(m.DATE_ENTREE) - 1 THEN '4 créé la veille'
              WHEN TRUNC(m.DATE_CREAT) >= TRUNC(m.DATE_ENTREE) - 7 THEN '3 créé 2 à 7 jours avant'
              WHEN TRUNC(m.DATE_CREAT) >= TRUNC(m.DATE_ENTREE) - 30 THEN '2 créé 8 à 30 jours avant'
              ELSE '1 créé plus de 30 jours avant' END AS DELAI_CREATION
  FROM mco m
),
agg AS (
  SELECT ANNEE_ENTREE, NUIT, URGENCES, DELAI_CREATION, COUNT(*) AS N
  FROM cl
  GROUP BY ANNEE_ENTREE, NUIT, URGENCES, DELAI_CREATION
),
rang AS (
  SELECT a.ANNEE_ENTREE, a.NUIT, a.URGENCES, a.DELAI_CREATION, a.N,
         SUM(CASE WHEN a.N < 10 THEN 1 ELSE 0 END) OVER (PARTITION BY a.ANNEE_ENTREE, a.NUIT, a.URGENCES) AS N_PETITES,
         ROW_NUMBER() OVER (PARTITION BY a.ANNEE_ENTREE, a.NUIT, a.URGENCES
                            ORDER BY CASE WHEN a.N < 10 THEN 1 ELSE 0 END, a.N) AS RANG_GRANDES
  FROM agg a
)
SELECT '20261028-delai-creation-sejour-mco' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE_ENTREE, NUIT, URGENCES, DELAI_CREATION,
       CASE WHEN N < 10 THEN '<10'
            WHEN N_PETITES = 1 AND RANG_GRANDES = 1 THEN 'masqué'
            ELSE TO_CHAR(N) END AS N_SEJ
FROM rang
ORDER BY ANNEE_ENTREE, NUIT, URGENCES, DELAI_CREATION;
