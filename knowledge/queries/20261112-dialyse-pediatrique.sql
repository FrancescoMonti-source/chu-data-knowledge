-- id: 20261112-dialyse-pediatrique
-- system: cora
-- person_data: masked
-- purpose: compter les séances de dialyse de 2022 à 2025 (GHM 28Z01Z à 28Z04Z, somme de NB_SEANCES) par âge le jour de la séance et selon que l'UF 5624 (PED.MED.HEMODIALYSE) héberge le RUM, et à part les suppléments de dialyse des séjours d'hospitalisation (étape 1 du plan, #135)
-- Oracle, schéma CORA_REC. RSS de TB_SYNTH_RSS finis de 2022 à 2025, par année de DATE_FIN. Séance de dialyse : CMD 28 et CODE_GHM Z01Z, Z02Z, Z03Z ou Z04Z (manuel des GHM 2026, vol. 2, CMD 28, liste D-113). Séances : somme de NB_SEANCES (un RSS peut réunir plusieurs séances, guide méthodologique MCO 2026, chap. VII).
-- Hospitalisation : RSS hors CMD 28 avec NB_DIALYSE ou NB_DIP > 0 (dialyse d'un patient hospitalisé, enregistrée en actes et suppléments, chap. VII 1°).
-- Patient : TB_SYNTH_RSS.ID_SEJOUR → TB_SEJOUR.ID_PATIENT → TB_PATIENT (joindre-rss-par-id-sejour). Âge : FLOOR((DATE_DEBUT − DATE_NAIS) / 365.25) (age-entree-a-recalculer). UF : TB_SYNTH_RUM.ID_UNITE_HEBERG → TB_UNITE.ID_UNITE (uf-du-rum-hebergement) ; « UF 5624 » si au moins un RUM du RSS y est hébergé.
-- Aucune date ni aucun âge individuel ne sort : seulement des effectifs. Un patient qui a 18 ans en cours d'année, ou qui change d'UF, compte dans deux lignes : N_PATIENTS ne s'additionne pas.
-- Masquage : si N_PATIENTS < 10 (toujours le cas pour « sans patient », où il vaut 0), toutes les colonnes d'effectif de la ligne sortent en <10 ; sinon chaque effectif de 1 à 9 sort en <10 (un zéro reste 0). Aucune ligne de total (règle 4).
WITH r AS (
  SELECT x.ID_RSS, EXTRACT(YEAR FROM x.DATE_FIN) AS ANNEE,
         CASE WHEN TRIM(x.CODE_CMD) = '28' THEN '28' || TRIM(x.CODE_GHM) ELSE 'hospitalisation' END AS GHM,
         s.ID_PATIENT,
         CASE WHEN s.ID_PATIENT IS NULL THEN '4 sans patient'
              WHEN pa.DATE_NAIS IS NULL THEN '3 naissance absente'
              WHEN FLOOR((x.DATE_DEBUT - pa.DATE_NAIS) / 365.25) < 18 THEN '1 moins de 18 ans'
              ELSE '2 18 ans ou plus' END AS AGE,
         CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_SYNTH_RUM ru
                           JOIN CORA_REC.TB_UNITE u ON u.ID_UNITE = ru.ID_UNITE_HEBERG
                           WHERE ru.ID_RSS = x.ID_RSS AND TRIM(u.CODE_UNITE) = '5624')
              THEN 'UF 5624' ELSE 'autre UF' END AS UNITE,
         NVL(x.NB_SEANCES, 0) AS SEANCES,
         NVL(x.NB_DIALYSE, 0) AS DIALYSE,
         NVL(x.NB_DIP, 0) AS DIP
  FROM CORA_REC.TB_SYNTH_RSS x
  LEFT JOIN CORA_REC.TB_SEJOUR s ON s.ID_SEJOUR = x.ID_SEJOUR
  LEFT JOIN CORA_REC.TB_PATIENT pa ON pa.ID_PATIENT = s.ID_PATIENT
  WHERE x.DATE_FIN >= DATE '2022-01-01' AND x.DATE_FIN < DATE '2026-01-01'
    AND ( (TRIM(x.CODE_CMD) = '28' AND TRIM(x.CODE_GHM) IN ('Z01Z', 'Z02Z', 'Z03Z', 'Z04Z'))
       OR (TRIM(x.CODE_CMD) <> '28' AND (NVL(x.NB_DIALYSE, 0) > 0 OR NVL(x.NB_DIP, 0) > 0)) )
),
t AS (
  SELECT ANNEE, GHM, AGE, UNITE,
         COUNT(DISTINCT ID_PATIENT) AS P,
         COUNT(*) AS R,
         SUM(SEANCES) AS S,
         SUM(DIALYSE) AS D,
         SUM(DIP) AS I
  FROM r
  GROUP BY ANNEE, GHM, AGE, UNITE
)
SELECT '20261112-dialyse-pediatrique' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE, GHM, AGE, UNITE,
       CASE WHEN P < 10 THEN '<10' ELSE TO_CHAR(P) END AS N_PATIENTS,
       CASE WHEN P < 10 OR R < 10 THEN '<10' ELSE TO_CHAR(R) END AS N_RSS,
       CASE WHEN P < 10 OR S BETWEEN 1 AND 9 THEN '<10' ELSE TO_CHAR(S) END AS NB_SEANCES,
       CASE WHEN P < 10 OR D BETWEEN 1 AND 9 THEN '<10' ELSE TO_CHAR(D) END AS NB_SUPPL_DIALYSE,
       CASE WHEN P < 10 OR I BETWEEN 1 AND 9 THEN '<10' ELSE TO_CHAR(I) END AS NB_SUPPL_DIP
FROM t
ORDER BY ANNEE, GHM, AGE, UNITE;
