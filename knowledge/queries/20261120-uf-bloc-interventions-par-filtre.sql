-- id: 20261120-uf-bloc-interventions-par-filtre
-- system: cora
-- person_data: masked
-- purpose: pour les interventions du flux OpRoom dans CORA (TB_INTERVENTION, mai 2025 au jour d'exécution), dire quels filtres d'actes de bloc retrouvent au moins un acte du même séjour et du même jour : site paramétré bloc, site non paramétré bloc mais bloc d'une intervention (endoscopie sous AG…), site d'une des UF 5508, 6510, 6196, ou mouvement d'une de ces UF ; pour arbitrer entre le filtre « mouvement » et le filtre « site » de reperer-actes-de-bloc (enquête uf-bloc-mouvement-ou-site, issue #131, étape 3 du plan)
-- Oracle, schéma CORA_REC. Interventions de DATE_INTERVENTION du 2025-05-01 au jour d'exécution, avec ID_SEJOUR renseigné. Actes de DATE_ACTE depuis le 2025-05-01, du même séjour (ID_SEJOUR) et du même jour (TRUNC) que l'intervention.
-- PERIODE : '2025-05 a 2025-12' ou '2026' (année de DATE_INTERVENTION). CODE_BLOC, LIBELLE_BLOC, BLOC_BRUT : le site ID_BLOC de l'intervention dans TB_SITE ('(vide)' si absent ou non renseigné). UF_EXECUTANTE : code de TB_UNITE de ID_UF_EXECUTANTE s'il est 5508, 6510 ou 6196, 'autre' sinon, '(vide)' si absent.
-- Indicateurs (1 ou 0) sur les actes du séjour-jour : A_SITE_BLOC (site BLOC = 'O' hors 2620 OBS SALLE NAISSANCE), A_SITE_OPROOM_NON_BLOC (site BLOC <> 'O' ou vide, qui est l'ID_BLOC d'au moins une intervention de la période), A_SITE_UF (code du site 5508, 6510 ou 6196), A_MVT_UF (mouvement de l'acte dans 5508, 6510 ou 6196), A_ACTE (au moins un acte, quel qu'il soit) ; A_DIRECT : au moins un acte avec TB_ACTE.NO_INTERVENTION = ID_INTERVENTION (quelle que soit sa date). Un même acte peut lever plusieurs indicateurs.
-- Chaque ligne est une combinaison d'indicateurs : les lignes forment une partition des interventions, sans ligne de total. Masquage : chaque effectif < 10 sort en <10 ; aucun total ni sous-total publié (règle 4).
WITH iv AS (
  SELECT i.ID_INTERVENTION, i.ID_SEJOUR, TRUNC(i.DATE_INTERVENTION) AS JOUR,
         CASE WHEN i.DATE_INTERVENTION < DATE '2026-01-01' THEN '2025-05 a 2025-12' ELSE '2026' END AS PERIODE,
         i.ID_BLOC, i.ID_UF_EXECUTANTE
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
ac AS (
  SELECT a.ID_SEJOUR, TRUNC(a.DATE_ACTE) AS JOUR,
         MAX(CASE WHEN si.BLOC = 'O' AND TRIM(si.CODE_SITE) <> '2620' THEN 1 ELSE 0 END) AS F_BLOC,
         MAX(CASE WHEN so.ID_SITE IS NOT NULL THEN 1 ELSE 0 END) AS F_OPROOM,
         MAX(CASE WHEN TRIM(si.CODE_SITE) IN ('5508', '6510', '6196') THEN 1 ELSE 0 END) AS F_SITE_UF,
         MAX(CASE WHEN TRIM(m.ID_UNITE_M) IN ('5508', '6510', '6196') THEN 1 ELSE 0 END) AS F_MVT_UF
  FROM CORA_REC.TB_ACTE a
  JOIN CORA_REC.TB_MVT m ON m.ID_MVT = a.ID_MVT
  LEFT JOIN CORA_REC.TB_SITE si ON si.ID_SITE = a.ID_SITE
  LEFT JOIN so ON so.ID_SITE = a.ID_SITE
  WHERE a.DATE_ACTE >= DATE '2025-05-01'
    AND a.ID_SEJOUR IN (SELECT ID_SEJOUR FROM iv)
  GROUP BY a.ID_SEJOUR, TRUNC(a.DATE_ACTE)
),
dr AS (
  SELECT DISTINCT a.NO_INTERVENTION
  FROM CORA_REC.TB_ACTE a
  WHERE a.NO_INTERVENTION IS NOT NULL AND a.DATE_ACTE >= DATE '2025-01-01'
),
t AS (
  SELECT iv.PERIODE,
         CASE WHEN iv.ID_BLOC IS NULL THEN '(vide)' ELSE NVL(TRIM(sb.CODE_SITE), '(vide)') END AS CODE_BLOC,
         NVL(TRIM(sb.LIBELLE_SITE), '(vide)') AS LIBELLE_BLOC,
         NVL(TRIM(TO_CHAR(sb.BLOC)), '(vide)') AS BLOC_BRUT,
         CASE WHEN iv.ID_UF_EXECUTANTE IS NULL OR u.ID_UNITE IS NULL THEN '(vide)'
              WHEN TRIM(u.CODE_UNITE) IN ('5508', '6510', '6196') THEN TRIM(u.CODE_UNITE)
              ELSE 'autre' END AS UF_EXECUTANTE,
         NVL(ac.F_BLOC, 0) AS A_SITE_BLOC,
         NVL(ac.F_OPROOM, 0) AS A_SITE_OPROOM_NON_BLOC,
         NVL(ac.F_SITE_UF, 0) AS A_SITE_UF,
         NVL(ac.F_MVT_UF, 0) AS A_MVT_UF,
         CASE WHEN ac.ID_SEJOUR IS NULL THEN 0 ELSE 1 END AS A_ACTE,
         CASE WHEN dr.NO_INTERVENTION IS NULL THEN 0 ELSE 1 END AS A_DIRECT
  FROM iv
  LEFT JOIN CORA_REC.TB_SITE sb ON sb.ID_SITE = iv.ID_BLOC
  LEFT JOIN CORA_REC.TB_UNITE u ON u.ID_UNITE = iv.ID_UF_EXECUTANTE
  LEFT JOIN ac ON ac.ID_SEJOUR = iv.ID_SEJOUR AND ac.JOUR = iv.JOUR
  LEFT JOIN dr ON dr.NO_INTERVENTION = iv.ID_INTERVENTION
)
SELECT '20261120-uf-bloc-interventions-par-filtre' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       PERIODE, CODE_BLOC, LIBELLE_BLOC, BLOC_BRUT, UF_EXECUTANTE,
       A_SITE_BLOC, A_SITE_OPROOM_NON_BLOC, A_SITE_UF, A_MVT_UF, A_ACTE, A_DIRECT,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE TO_CHAR(COUNT(*)) END AS N_INTERVENTIONS
FROM t
GROUP BY PERIODE, CODE_BLOC, LIBELLE_BLOC, BLOC_BRUT, UF_EXECUTANTE,
         A_SITE_BLOC, A_SITE_OPROOM_NON_BLOC, A_SITE_UF, A_MVT_UF, A_ACTE, A_DIRECT
ORDER BY PERIODE, CODE_BLOC, UF_EXECUTANTE, COUNT(*) DESC;
