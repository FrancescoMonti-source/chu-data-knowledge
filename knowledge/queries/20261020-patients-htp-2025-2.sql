-- id: 20261020-patients-htp-2025-2
-- system: cora
-- person_data: masked
-- purpose: compter les patients distincts ayant au moins un RHS de HTP (TYPE_HOSPIT_SSR = 2) en 2025, selon deux bornes de période (semaine débutant en 2025, semaine ayant au moins un jour en 2025), et ceux qui ont au moins une semaine à plusieurs RHS, pour vérifier l'ordre de grandeur attendu d'environ 158 patients (issue 96)
-- Oracle. Version 2 : la v1 mélangeait des sous-requêtes et des agrégats (ORA-00937) ; les trois comptages sont maintenant calculés à part. Les patients ne sortent pas : seuls des comptages sortent. Un effectif de moins de 10 sort comme <10.
WITH rhs AS (
  SELECT s.ID_PATIENT, s.DATE_DEBUT_SEM, s.DATE_FIN_SEM
  FROM CORA_REC.TB_MVT_SSR_SEM s
  WHERE s.TYPE_HOSPIT_SSR = 2
),
debut AS (
  SELECT COUNT(DISTINCT ID_PATIENT) AS N FROM rhs
  WHERE DATE_DEBUT_SEM >= DATE '2025-01-01' AND DATE_DEBUT_SEM < DATE '2026-01-01'
),
chevauche AS (
  SELECT COUNT(DISTINCT ID_PATIENT) AS N FROM rhs
  WHERE DATE_FIN_SEM >= DATE '2025-01-01' AND DATE_DEBUT_SEM < DATE '2026-01-01'
),
multi AS (
  SELECT COUNT(DISTINCT ID_PATIENT) AS N FROM (
    SELECT ID_PATIENT, DATE_DEBUT_SEM FROM rhs
    WHERE DATE_DEBUT_SEM >= DATE '2025-01-01' AND DATE_DEBUT_SEM < DATE '2026-01-01'
    GROUP BY ID_PATIENT, DATE_DEBUT_SEM HAVING COUNT(*) > 1
  )
)
SELECT '20261020-patients-htp-2025-2' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       CASE WHEN debut.N < 10 THEN '<10' ELSE CAST(debut.N AS VARCHAR2(12)) END AS N_PATIENTS_SEMAINE_DEBUT_2025,
       CASE WHEN chevauche.N < 10 THEN '<10' ELSE CAST(chevauche.N AS VARCHAR2(12)) END AS N_PATIENTS_SEMAINE_CHEVAUCHE_2025,
       CASE WHEN multi.N < 10 THEN '<10' ELSE CAST(multi.N AS VARCHAR2(12)) END AS N_PATIENTS_SEMAINE_MULTI_RHS
FROM debut, chevauche, multi;
