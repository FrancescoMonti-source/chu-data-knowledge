-- id: 20261026-usip-temoin-candidats
-- system: cora
-- person_data: masked
-- purpose: chercher un groupe témoin pour la différence des différences que demande la direction (évolution de la DMS des endartériectomies carotidiennes comparée à celle d'une population qui ne passe pas par l'USIP) : pour les endartériectomies, les pontages fémoraux et les racines de GHM chirurgicales ou interventionnelles fréquentes, séjours et DMS par période, part des séjours passés par l'unité (UF 6284 avant, USIP 6281 après) et par une unité de soins critiques, âge moyen (étape 7 du plan)
-- Oracle, schéma CORA_REC. Unité : le RSS (TB_SYNTH_RSS) d'hospitalisation complète (au moins une nuit), groupé (CODE_GHM renseigné, CMD ni 90 ni 28), comme 20261023-usip-dms-valorisation-2. PERIODE d'après DATE_FIN du RSS, d'octobre à août : 2022-10 à 2023-08 (_2223), 2023-10 à 2024-08 (_2324), 2024-10 à 2025-08 (_2425), 2025-10 à 2026-08 (_2526) ; septembre écarté.
-- GROUPE, un RSS pouvant être dans plusieurs : ENDARTERIECTOMIE = un acte EBFA002, EBFA003, EBFA006, EBFA008, EBFA009, EBFA010, EBFA012, EBFA015 ou EBFA016 du séjour (TB_ACTE.ID_SEJOUR), daté entre le début et la fin du RSS ; PONTAGE FEMORAL = un acte EECA001, EECA003, EECA002, EDCA003 ou EDCA005 daté de même, hors RSS d'endartériectomie ; sinon la racine de GHM (CMD et trois premiers caractères du GHM) pour les GHM de type C ou K.
-- Une racine sort seulement si elle a au moins 50 RSS dans chacune des quatre périodes et si moins de 5 % de ses RSS passent par l'unité en 2024-2025 comme en 2025-2026 ; les deux groupes d'actes sortent toujours, comme référence.
-- PCT_UNITE : part des RSS avec un RUM dans l'UM 6284 en 2024-2025, dans l'UM 6281 en 2025-2026. PCT_SOINS_CRIT : part des RSS avec un RUM dans 6281, 6284 ou une UM de réanimation chirurgicale (regroupement REAC du référentiel ref_uf2um.txt de redsan : 2481, 6155, 6204, 6206, 6242, 6244, 6280, 6282, 6283, 6285 à 6289, 6607, 8241, 8500). UM par TB_SYNTH_RUM.ID_UNITE_MEDICALE → TB_UNITE_MEDICALE.CODE_UNITE_MED (20261023-usip-uf-structure). DMS = moyenne de TRUNC(DATE_FIN) − TRUNC(DATE_DEBUT) du RSS. AGE_MOY_2526 : âge moyen à l'entrée du RSS (TB_PATIENT.DATE_NAIS par TB_SEJOUR), en 2025-2026. LIBELLE : libellé du GHM de niveau 1 de la racine dans PMSI_LIB_GHS_TARIF au 2026-06-30, vide pour les deux groupes d'actes.
-- Masquage : N_RSS < 10 sort en <10, avec DMS et âge vides ; un pourcentage sort en <10 quand moins de 10 RSS le composent (zéro compris). Aucune ligne de total.
WITH um_u AS (
  SELECT /*+ MATERIALIZE */ ID_UNITE_MED, TRIM(CODE_UNITE_MED) AS CODE_UM
  FROM CORA_REC.TB_UNITE_MEDICALE
  WHERE TRIM(CODE_UNITE_MED) IN ('6281', '6284', '2481', '6155', '6204', '6206', '6242', '6244', '6280', '6282', '6283',
                                 '6285', '6286', '6287', '6288', '6289', '6607', '8241', '8500')
),
fl AS (
  SELECT /*+ MATERIALIZE */ ru.ID_RSS,
         MAX(CASE WHEN u.CODE_UM = '6281' THEN 1 ELSE 0 END) AS A_6281,
         MAX(CASE WHEN u.CODE_UM = '6284' THEN 1 ELSE 0 END) AS A_6284
  FROM CORA_REC.TB_SYNTH_RUM ru
  JOIN um_u u ON u.ID_UNITE_MED = ru.ID_UNITE_MEDICALE
  WHERE ru.DATE_FIN_RUM >= DATE '2022-06-01' AND ru.DATE_FIN_RUM < DATE '2026-09-01'
  GROUP BY ru.ID_RSS
),
act AS (
  SELECT /*+ MATERIALIZE */ DISTINCT a.ID_SEJOUR, TRUNC(a.DATE_ACTE) AS JOUR,
         CASE WHEN TRIM(a.CODE_ACTE) LIKE 'EBFA%' THEN 'ENDARTERIECTOMIE' ELSE 'PONTAGE FEMORAL' END AS FAMILLE
  FROM CORA_REC.TB_ACTE a
  WHERE a.DATE_ACTE >= DATE '2022-06-01' AND a.DATE_ACTE < DATE '2026-09-01'
    AND TRIM(a.CODE_ACTE) IN ('EBFA002', 'EBFA003', 'EBFA006', 'EBFA008', 'EBFA009',
                              'EBFA010', 'EBFA012', 'EBFA015', 'EBFA016',
                              'EECA001', 'EECA003', 'EECA002', 'EDCA003', 'EDCA005')
),
rss AS (
  SELECT /*+ MATERIALIZE */ r.ID_RSS, r.ID_SEJOUR, r.DATE_DEBUT, r.DATE_FIN,
         TRIM(r.CODE_CMD) || SUBSTR(TRIM(r.CODE_GHM), 1, 3) AS RACINE,
         SUBSTR(TRIM(r.CODE_GHM), 1, 1) AS TYPE_GHM,
         TRUNC(r.DATE_FIN) - TRUNC(r.DATE_DEBUT) AS NUITEES,
         CASE WHEN r.DATE_FIN >= DATE '2022-10-01' AND r.DATE_FIN < DATE '2023-09-01' THEN 1
              WHEN r.DATE_FIN >= DATE '2023-10-01' AND r.DATE_FIN < DATE '2024-09-01' THEN 2
              WHEN r.DATE_FIN >= DATE '2024-10-01' AND r.DATE_FIN < DATE '2025-09-01' THEN 3
              WHEN r.DATE_FIN >= DATE '2025-10-01' AND r.DATE_FIN < DATE '2026-09-01' THEN 4
         END AS PERIODE
  FROM CORA_REC.TB_SYNTH_RSS r
  WHERE r.DATE_FIN >= DATE '2022-10-01' AND r.DATE_FIN < DATE '2026-09-01'
    AND EXTRACT(MONTH FROM r.DATE_FIN) <> 9
    AND TRIM(r.CODE_GHM) IS NOT NULL AND TRIM(r.CODE_CMD) NOT IN ('90', '28')
    AND TRUNC(r.DATE_FIN) - TRUNC(r.DATE_DEBUT) >= 1
),
fam AS (
  SELECT /*+ MATERIALIZE */ DISTINCT x.ID_RSS, act.FAMILLE
  FROM rss x
  JOIN act ON act.ID_SEJOUR = x.ID_SEJOUR AND act.JOUR BETWEEN TRUNC(x.DATE_DEBUT) AND TRUNC(x.DATE_FIN)
),
grp AS (
  SELECT ID_RSS, RACINE AS GROUPE FROM rss WHERE TYPE_GHM IN ('C', 'K')
  UNION ALL
  SELECT ID_RSS, FAMILLE FROM fam WHERE FAMILLE = 'ENDARTERIECTOMIE'
  UNION ALL
  SELECT ID_RSS, FAMILLE FROM fam
  WHERE FAMILLE = 'PONTAGE FEMORAL'
    AND ID_RSS NOT IN (SELECT ID_RSS FROM fam WHERE FAMILLE = 'ENDARTERIECTOMIE')
),
agg AS (
  SELECT g.GROUPE,
         SUM(CASE WHEN x.PERIODE = 1 THEN 1 ELSE 0 END) AS N1,
         SUM(CASE WHEN x.PERIODE = 2 THEN 1 ELSE 0 END) AS N2,
         SUM(CASE WHEN x.PERIODE = 3 THEN 1 ELSE 0 END) AS N3,
         SUM(CASE WHEN x.PERIODE = 4 THEN 1 ELSE 0 END) AS N4,
         AVG(CASE WHEN x.PERIODE = 1 THEN x.NUITEES END) AS DMS1,
         AVG(CASE WHEN x.PERIODE = 2 THEN x.NUITEES END) AS DMS2,
         AVG(CASE WHEN x.PERIODE = 3 THEN x.NUITEES END) AS DMS3,
         AVG(CASE WHEN x.PERIODE = 4 THEN x.NUITEES END) AS DMS4,
         SUM(CASE WHEN x.PERIODE = 3 AND fl.A_6284 = 1 THEN 1 ELSE 0 END) AS U3,
         SUM(CASE WHEN x.PERIODE = 4 AND fl.A_6281 = 1 THEN 1 ELSE 0 END) AS U4,
         SUM(CASE WHEN x.PERIODE = 3 AND fl.ID_RSS IS NOT NULL THEN 1 ELSE 0 END) AS SC3,
         SUM(CASE WHEN x.PERIODE = 4 AND fl.ID_RSS IS NOT NULL THEN 1 ELSE 0 END) AS SC4,
         AVG(CASE WHEN x.PERIODE = 4 THEN FLOOR((x.DATE_DEBUT - pa.DATE_NAIS) / 365.25) END) AS AGE4,
         COUNT(CASE WHEN x.PERIODE = 4 THEN pa.DATE_NAIS END) AS NA4
  FROM grp g
  JOIN rss x ON x.ID_RSS = g.ID_RSS
  LEFT JOIN fl ON fl.ID_RSS = g.ID_RSS
  LEFT JOIN CORA_REC.TB_SEJOUR s ON s.ID_SEJOUR = x.ID_SEJOUR
  LEFT JOIN CORA_REC.TB_PATIENT pa ON pa.ID_PATIENT = s.ID_PATIENT
  WHERE x.PERIODE IS NOT NULL
  GROUP BY g.GROUPE
),
lib AS (
  SELECT SUBSTR(TRIM(t.GHS), 1, 5) AS RACINE,
         MAX(TRIM(t.LIBELLE_GHS)) KEEP (DENSE_RANK FIRST ORDER BY CASE WHEN SUBSTR(TRIM(t.GHS), 6, 1) = '1' THEN 0 ELSE 1 END) AS LIBELLE
  FROM CORA_REC.PMSI_LIB_GHS_TARIF t
  WHERE TRUNC(t.DATE_DEBUT) <= DATE '2026-06-30' AND (t.DATE_FIN IS NULL OR TRUNC(t.DATE_FIN) >= DATE '2026-06-30')
  GROUP BY SUBSTR(TRIM(t.GHS), 1, 5)
)
SELECT '20261026-usip-temoin-candidats' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       a.GROUPE, lib.LIBELLE,
       CASE WHEN a.N1 < 10 THEN '<10' ELSE TO_CHAR(a.N1) END AS N_RSS_2223,
       CASE WHEN a.N2 < 10 THEN '<10' ELSE TO_CHAR(a.N2) END AS N_RSS_2324,
       CASE WHEN a.N3 < 10 THEN '<10' ELSE TO_CHAR(a.N3) END AS N_RSS_2425,
       CASE WHEN a.N4 < 10 THEN '<10' ELSE TO_CHAR(a.N4) END AS N_RSS_2526,
       CASE WHEN a.N1 < 10 THEN NULL ELSE ROUND(a.DMS1, 1) END AS DMS_2223,
       CASE WHEN a.N2 < 10 THEN NULL ELSE ROUND(a.DMS2, 1) END AS DMS_2324,
       CASE WHEN a.N3 < 10 THEN NULL ELSE ROUND(a.DMS3, 1) END AS DMS_2425,
       CASE WHEN a.N4 < 10 THEN NULL ELSE ROUND(a.DMS4, 1) END AS DMS_2526,
       CASE WHEN a.U3 < 10 THEN '<10' ELSE TO_CHAR(ROUND(100 * a.U3 / a.N3)) END AS PCT_UNITE_2425,
       CASE WHEN a.U4 < 10 THEN '<10' ELSE TO_CHAR(ROUND(100 * a.U4 / a.N4)) END AS PCT_UNITE_2526,
       CASE WHEN a.SC3 < 10 THEN '<10' ELSE TO_CHAR(ROUND(100 * a.SC3 / a.N3)) END AS PCT_SOINS_CRIT_2425,
       CASE WHEN a.SC4 < 10 THEN '<10' ELSE TO_CHAR(ROUND(100 * a.SC4 / a.N4)) END AS PCT_SOINS_CRIT_2526,
       CASE WHEN a.NA4 < 10 THEN NULL ELSE ROUND(a.AGE4) END AS AGE_MOY_2526
FROM agg a
LEFT JOIN lib ON lib.RACINE = a.GROUPE
WHERE a.GROUPE IN ('ENDARTERIECTOMIE', 'PONTAGE FEMORAL')
   OR (LEAST(a.N1, a.N2, a.N3, a.N4) >= 50 AND a.U3 < 0.05 * a.N3 AND a.U4 < 0.05 * a.N4)
ORDER BY CASE WHEN a.GROUPE IN ('ENDARTERIECTOMIE', 'PONTAGE FEMORAL') THEN 0 ELSE 1 END, a.GROUPE
