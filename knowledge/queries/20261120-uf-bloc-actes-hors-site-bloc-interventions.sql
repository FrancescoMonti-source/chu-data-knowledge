-- id: 20261120-uf-bloc-actes-hors-site-bloc-interventions
-- system: cora
-- person_data: masked
-- purpose: pour les actes que le filtre « site paramétré bloc » ne prend pas et qu'un filtre candidat ajouterait (mouvement dans 5508, 6510 ou 6196 ; site de l'une de ces UF ; site non paramétré bloc mais bloc d'une intervention OpRoom), dire, site par site, combien appartiennent à une intervention OpRoom de CORA : rattachés par NO_INTERVENTION, ou dans un séjour-jour qui a une intervention ; pour arbitrer entre le filtre « mouvement » et le filtre « site » de reperer-actes-de-bloc (enquête uf-bloc-mouvement-ou-site, issue #131, étape 4 du plan)
-- Oracle, schéma CORA_REC. Actes de DATE_ACTE du 2025-05-01 au jour d'exécution, dont le site n'est pas paramétré bloc (NVL(BLOC, 'N') <> 'O' ou site vide) et qui remplissent au moins une des trois conditions. Interventions : TB_INTERVENTION de DATE_INTERVENTION depuis le 2025-05-01, avec ID_SEJOUR renseigné.
-- PERIODE : '2025-05 a 2025-12' ou '2026'. UF_MOUVEMENT : 5508, 6510, 6196, ou 'autre UF'. CATEGORIE_SITE : 'site OpRoom non bloc' (le site est l'ID_BLOC d'au moins une intervention de la période), sinon 'site UF' (code 5508, 6510 ou 6196), sinon 'autre site'. CODE_SITE_ACTE, LIBELLE_SITE_ACTE : le site de l'acte ('(vide)' sans site).
-- Quatre colonnes qui partagent les actes de chaque ligne : N_DIRECT_ET_SEJOUR_JOUR (NO_INTERVENTION renvoie à une intervention de TB_INTERVENTION, et le séjour-jour a une intervention), N_DIRECT_SEUL (rattaché par NO_INTERVENTION, sans intervention le même jour dans le séjour), N_SEJOUR_JOUR_SEUL (pas de rattachement par NO_INTERVENTION, mais une intervention le même jour dans le séjour), N_AUCUNE_INTERVENTION.
-- Masquage : chaque effectif < 10 sort en <10. Pas de total ni d'effectif d'ensemble par ligne : une cellule masquée ne se recalcule pas. Les lignes de moins de 10 actes en tout ne sortent pas.
WITH iv AS (
  SELECT i.ID_SEJOUR, TRUNC(i.DATE_INTERVENTION) AS JOUR, i.ID_BLOC
  FROM CORA_REC.TB_INTERVENTION i
  WHERE i.DATE_INTERVENTION >= DATE '2025-05-01'
    AND i.DATE_INTERVENTION < TRUNC(SYSDATE) + 1
    AND i.ID_SEJOUR IS NOT NULL
),
so AS (
  SELECT DISTINCT iv.ID_BLOC AS ID_SITE
  FROM iv JOIN CORA_REC.TB_SITE s ON s.ID_SITE = iv.ID_BLOC
  WHERE NVL(TRIM(TO_CHAR(s.BLOC)), 'N') <> 'O'
),
sj AS (
  SELECT DISTINCT ID_SEJOUR, JOUR FROM iv
),
x AS (
  SELECT CASE WHEN a.DATE_ACTE < DATE '2026-01-01' THEN '2025-05 a 2025-12' ELSE '2026' END AS PERIODE,
         CASE WHEN TRIM(m.ID_UNITE_M) IN ('5508', '6510', '6196') THEN TRIM(m.ID_UNITE_M) ELSE 'autre UF' END AS UF_MOUVEMENT,
         CASE WHEN so.ID_SITE IS NOT NULL THEN 'site OpRoom non bloc'
              WHEN TRIM(si.CODE_SITE) IN ('5508', '6510', '6196') THEN 'site UF'
              ELSE 'autre site' END AS CATEGORIE_SITE,
         NVL(TRIM(si.CODE_SITE), '(vide)') AS CODE_SITE_ACTE,
         NVL(TRIM(si.LIBELLE_SITE), '(vide)') AS LIBELLE_SITE_ACTE,
         CASE WHEN ti.ID_INTERVENTION IS NOT NULL THEN 1 ELSE 0 END AS D,
         CASE WHEN sj.ID_SEJOUR IS NOT NULL THEN 1 ELSE 0 END AS S
  FROM CORA_REC.TB_ACTE a
  JOIN CORA_REC.TB_MVT m ON m.ID_MVT = a.ID_MVT
  LEFT JOIN CORA_REC.TB_SITE si ON si.ID_SITE = a.ID_SITE
  LEFT JOIN so ON so.ID_SITE = a.ID_SITE
  LEFT JOIN sj ON sj.ID_SEJOUR = a.ID_SEJOUR AND sj.JOUR = TRUNC(a.DATE_ACTE)
  LEFT JOIN CORA_REC.TB_INTERVENTION ti ON ti.ID_INTERVENTION = a.NO_INTERVENTION
  WHERE a.DATE_ACTE >= DATE '2025-05-01'
    AND a.DATE_ACTE < TRUNC(SYSDATE) + 1
    AND NVL(TRIM(TO_CHAR(si.BLOC)), 'N') <> 'O'
    AND (TRIM(m.ID_UNITE_M) IN ('5508', '6510', '6196')
         OR TRIM(si.CODE_SITE) IN ('5508', '6510', '6196')
         OR so.ID_SITE IS NOT NULL)
),
g AS (
  SELECT PERIODE, UF_MOUVEMENT, CATEGORIE_SITE, CODE_SITE_ACTE, LIBELLE_SITE_ACTE,
         SUM(CASE WHEN D = 1 AND S = 1 THEN 1 ELSE 0 END) AS C_DS,
         SUM(CASE WHEN D = 1 AND S = 0 THEN 1 ELSE 0 END) AS C_D,
         SUM(CASE WHEN D = 0 AND S = 1 THEN 1 ELSE 0 END) AS C_S,
         SUM(CASE WHEN D = 0 AND S = 0 THEN 1 ELSE 0 END) AS C_0,
         COUNT(*) AS C_TOT
  FROM x
  GROUP BY PERIODE, UF_MOUVEMENT, CATEGORIE_SITE, CODE_SITE_ACTE, LIBELLE_SITE_ACTE
)
SELECT '20261120-uf-bloc-actes-hors-site-bloc-interventions' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       PERIODE, UF_MOUVEMENT, CATEGORIE_SITE, CODE_SITE_ACTE, LIBELLE_SITE_ACTE,
       CASE WHEN C_DS < 10 THEN '<10' ELSE TO_CHAR(C_DS) END AS N_DIRECT_ET_SEJOUR_JOUR,
       CASE WHEN C_D < 10 THEN '<10' ELSE TO_CHAR(C_D) END AS N_DIRECT_SEUL,
       CASE WHEN C_S < 10 THEN '<10' ELSE TO_CHAR(C_S) END AS N_SEJOUR_JOUR_SEUL,
       CASE WHEN C_0 < 10 THEN '<10' ELSE TO_CHAR(C_0) END AS N_AUCUNE_INTERVENTION
FROM g
WHERE C_TOT >= 10
ORDER BY PERIODE, UF_MOUVEMENT, CATEGORIE_SITE, C_TOT DESC, CODE_SITE_ACTE;
