-- id: 20261019-transfert-mco-smr-meme-jour
-- system: cora
-- person_data: masked
-- purpose: pour transfert-smr-interne-meme-jour, compter par année, côté MCO puis côté SMR, les rapprochements d'un séjour MCO et d'un séjour SMR du même patient le jour civil de la sortie MCO (même jour) ou le lendemain (+1 jour), croisés avec MODE_SORTIE du séjour MCO (6 mutation, 7 transfert), CODE_DESTINATION '2' et MODE_ENTREE du séjour SMR. Réfuté si élargir à +1 jour ajoute plus de 10 % de rapprochements, ou si moins de 90 % des séjours SMR précédés d'une sortie MCO du même patient le même jour portent le mode 6 ; sinon le même jour est la règle et le mode 6 seul ne suffit pas à repérer les transferts
-- Oracle 11g, schéma CORA_REC. La jointure sur le patient (ID_PATIENT) reste dans Oracle ; la sortie ne contient que des agrégats par année, aucun identifiant. Séjour MCO : séjour de TB_SEJOUR sorti du 2017-12-31 à aujourd'hui, hors préadmission, avec au moins un RSS par TB_SYNTH_RSS.ID_SEJOUR. Séjour SMR : séjour hors préadmission entré du 2018-01-01 à aujourd'hui avec TYPE_SEJOUR 'SSR' ou 'SMR' (hypothèse de type-sejour-smr-et-ssr ; à relire après 20261019-type-sejour-ssr-smr). Jour civil : TRUNC(DATE_SORTIE) pour le MCO, TRUNC(DATE_ENTREE) pour le SMR.
-- Deux vues. MCO : séjours MCO sortis de 2018 à aujourd'hui dont MODE_SORTIE est 6 ou 7, ou CODE_DESTINATION est '2', ou un séjour SMR du même patient commence le jour de la sortie ou le lendemain ; ANNEE = année de sortie ; DIM_1 = MODE_SORTIE, DIM_2 = destination '2' (oui, non), DIM_3 = séjour SMR le même jour (oui, non), DIM_4 = séjour SMR le lendemain (oui, non). SMR : tous les séjours SMR entrés de 2018 à aujourd'hui ; ANNEE = année d'entrée ; DIM_1 = MODE_ENTREE du séjour SMR, DIM_2 = sortie MCO du même patient le même jour (aucune, mode 6, mode 7, autre mode), DIM_3 = destination '2' sur cette sortie MCO (oui, non, sans objet), DIM_4 = sortie MCO du même patient la veille (oui, non). N : séjours.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : dans chaque vue, quand les cases masquées d'une année totalisent de 1 à 9, la plus grande case de l'année sort aussi en « masqué ». Aucune ligne de total ; pas de pourcentage, calculé après lecture des cases visibles.
WITH mco AS (
  SELECT s.ID_PATIENT, TRUNC(s.DATE_SORTIE) AS DJ,
         NVL(TRIM(s.MODE_SORTIE), '(vide)') AS MS,
         NVL(TRIM(s.CODE_DESTINATION), '(vide)') AS CD
  FROM CORA_REC.TB_SEJOUR s
  WHERE s.DATE_SORTIE >= DATE '2017-12-31' AND s.DATE_SORTIE < TRUNC(SYSDATE) + 1
    AND NVL(s.STATUT_PROG, '-') <> 'P'
    AND EXISTS (SELECT 1 FROM CORA_REC.TB_SYNTH_RSS r WHERE r.ID_SEJOUR = s.ID_SEJOUR)
),
smr AS (
  SELECT s.ID_PATIENT, TRUNC(s.DATE_ENTREE) AS DJ,
         NVL(TRIM(s.MODE_ENTREE), '(vide)') AS ME
  FROM CORA_REC.TB_SEJOUR s
  WHERE s.DATE_ENTREE >= DATE '2018-01-01' AND s.DATE_ENTREE < TRUNC(SYSDATE) + 1
    AND NVL(s.STATUT_PROG, '-') <> 'P'
    AND TRIM(s.TYPE_SEJOUR) IN ('SSR', 'SMR')
),
smr_j AS (
  SELECT DISTINCT ID_PATIENT, DJ FROM smr
),
mco_j AS (
  SELECT ID_PATIENT, DJ,
         MAX(CASE WHEN MS = '6' THEN 1 ELSE 0 END) AS F6,
         MAX(CASE WHEN MS = '7' THEN 1 ELSE 0 END) AS F7,
         MAX(CASE WHEN CD = '2' THEN 1 ELSE 0 END) AS FD2
  FROM mco
  GROUP BY ID_PATIENT, DJ
),
va AS (
  SELECT 'MCO' AS VUE, EXTRACT(YEAR FROM m.DJ) AS ANNEE,
         m.MS AS DIM_1,
         CASE WHEN m.CD = '2' THEN 'oui' ELSE 'non' END AS DIM_2,
         CASE WHEN j0.DJ IS NOT NULL THEN 'oui' ELSE 'non' END AS DIM_3,
         CASE WHEN j1.DJ IS NOT NULL THEN 'oui' ELSE 'non' END AS DIM_4,
         COUNT(*) AS N
  FROM mco m
  LEFT JOIN smr_j j0 ON j0.ID_PATIENT = m.ID_PATIENT AND j0.DJ = m.DJ
  LEFT JOIN smr_j j1 ON j1.ID_PATIENT = m.ID_PATIENT AND j1.DJ = m.DJ + 1
  WHERE m.DJ >= DATE '2018-01-01'
    AND (m.MS IN ('6', '7') OR m.CD = '2' OR j0.DJ IS NOT NULL OR j1.DJ IS NOT NULL)
  GROUP BY EXTRACT(YEAR FROM m.DJ), m.MS,
           CASE WHEN m.CD = '2' THEN 'oui' ELSE 'non' END,
           CASE WHEN j0.DJ IS NOT NULL THEN 'oui' ELSE 'non' END,
           CASE WHEN j1.DJ IS NOT NULL THEN 'oui' ELSE 'non' END
),
vb AS (
  SELECT 'SMR' AS VUE, EXTRACT(YEAR FROM s.DJ) AS ANNEE,
         s.ME AS DIM_1,
         CASE WHEN x0.DJ IS NULL THEN 'aucune'
              WHEN x0.F6 = 1 THEN 'mode 6'
              WHEN x0.F7 = 1 THEN 'mode 7'
              ELSE 'autre mode' END AS DIM_2,
         CASE WHEN x0.DJ IS NULL THEN 'sans objet'
              WHEN x0.FD2 = 1 THEN 'oui' ELSE 'non' END AS DIM_3,
         CASE WHEN x1.DJ IS NOT NULL THEN 'oui' ELSE 'non' END AS DIM_4,
         COUNT(*) AS N
  FROM smr s
  LEFT JOIN mco_j x0 ON x0.ID_PATIENT = s.ID_PATIENT AND x0.DJ = s.DJ
  LEFT JOIN mco_j x1 ON x1.ID_PATIENT = s.ID_PATIENT AND x1.DJ = s.DJ - 1
  GROUP BY EXTRACT(YEAR FROM s.DJ), s.ME,
           CASE WHEN x0.DJ IS NULL THEN 'aucune'
                WHEN x0.F6 = 1 THEN 'mode 6'
                WHEN x0.F7 = 1 THEN 'mode 7'
                ELSE 'autre mode' END,
           CASE WHEN x0.DJ IS NULL THEN 'sans objet'
                WHEN x0.FD2 = 1 THEN 'oui' ELSE 'non' END,
           CASE WHEN x1.DJ IS NOT NULL THEN 'oui' ELSE 'non' END
),
c AS (
  SELECT VUE, ANNEE, DIM_1, DIM_2, DIM_3, DIM_4, N FROM va
  UNION ALL
  SELECT VUE, ANNEE, DIM_1, DIM_2, DIM_3, DIM_4, N FROM vb
),
m AS (
  SELECT VUE, ANNEE, DIM_1, DIM_2, DIM_3, DIM_4, N,
         SUM(CASE WHEN N < 10 THEN N ELSE 0 END) OVER (PARTITION BY VUE, ANNEE) AS CACHE,
         ROW_NUMBER() OVER (PARTITION BY VUE, ANNEE ORDER BY N DESC, DIM_1, DIM_2, DIM_3, DIM_4) AS RANG
  FROM c
)
SELECT '20261019-transfert-mco-smr-meme-jour' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       VUE, ANNEE, DIM_1, DIM_2, DIM_3, DIM_4,
       CASE WHEN N < 10 THEN '<10' WHEN CACHE BETWEEN 1 AND 9 AND RANG = 1 THEN 'masqué' ELSE TO_CHAR(N) END AS N
FROM m
ORDER BY VUE, ANNEE, DIM_1, DIM_2, DIM_3, DIM_4;
