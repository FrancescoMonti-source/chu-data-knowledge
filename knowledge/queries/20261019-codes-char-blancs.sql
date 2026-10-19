-- id: 20261019-codes-char-blancs
-- system: cora
-- person_data: masked
-- purpose: mesurer la part de valeurs de code d'unité différentes de leur TRIM (TB_UNITE.CODE_UNITE, TB_SEJOUR.UF_ENTREE, TB_MVT.ID_UNITE_M) et combien de séjours trouvent leur unité par égalité directe UF_ENTREE = CODE_UNITE contre l'égalité après TRIM des deux côtés, pour trancher codes-char-completes-de-blancs (réfuté si ces codes ne portent aucun blanc de remplissage et si l'égalité directe donne le même effectif que l'égalité après TRIM ; confirmé sinon, et l'écart est le nombre de séjours perdus en silence sans TRIM)
-- Oracle, schéma CORA_REC. Type des colonnes : 20261019-catalogue-types-colonnes-g3 (CODE_UNITE et ID_UNITE_M sont CHAR(12) d'après le dictionnaire, UF_ENTREE VARCHAR2(12)). Longueur comparée par LENGTH(x) <> LENGTH(TRIM(x)), qui compte les blancs de remplissage d'un CHAR. TB_SEJOUR : séjours dont DATE_ENTREE va du 2018-01-01 à aujourd'hui, par année d'entrée. TB_MVT : mouvements dont DATE_DEBUT_MVT va du 2018-01-01 à aujourd'hui, par année. TB_UNITE : tout le référentiel, sans année.
-- Niveaux : UNITE (N, N_DIFF_TRIM : CODE_UNITE <> TRIM), SEJOUR (N, N_UF_VIDE, N_DIFF_TRIM : UF_ENTREE <> TRIM, N_UNITE_EGAL_DIRECT : il existe une unité avec CODE_UNITE = UF_ENTREE sans TRIM, N_UNITE_EGAL_TRIM : idem avec TRIM des deux côtés), MVT (N, N_UF_VIDE, N_DIFF_TRIM : ID_UNITE_M <> TRIM, N_UNITE_EGAL_DIRECT et N_UNITE_EGAL_TRIM comme pour SEJOUR). Les colonnes qui ne s'appliquent pas à un niveau restent vides.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N sort en « masqué » dès que N moins une autre colonne vaut de 1 à 9 (N moins N_UF_VIDE, N_DIFF_TRIM ou N_UNITE_EGAL_TRIM). PCT_DIFF_TRIM n'est calculé que si N et N_DIFF_TRIM sont visibles. Aucune ligne de total.
WITH un AS (
  SELECT DISTINCT CODE_UNITE AS C_BRUT, TRIM(CODE_UNITE) AS C_TRIM
  FROM CORA_REC.TB_UNITE
),
sj AS (
  SELECT EXTRACT(YEAR FROM s.DATE_ENTREE) AS ANNEE, s.UF_ENTREE AS C_BRUT, COUNT(*) AS N
  FROM CORA_REC.TB_SEJOUR s
  WHERE s.DATE_ENTREE >= DATE '2018-01-01' AND s.DATE_ENTREE < TRUNC(SYSDATE) + 1
  GROUP BY EXTRACT(YEAR FROM s.DATE_ENTREE), s.UF_ENTREE
),
mv AS (
  SELECT EXTRACT(YEAR FROM m.DATE_DEBUT_MVT) AS ANNEE, m.ID_UNITE_M AS C_BRUT, COUNT(*) AS N
  FROM CORA_REC.TB_MVT m
  WHERE m.DATE_DEBUT_MVT >= DATE '2018-01-01' AND m.DATE_DEBUT_MVT < TRUNC(SYSDATE) + 1
  GROUP BY EXTRACT(YEAR FROM m.DATE_DEBUT_MVT), m.ID_UNITE_M
),
x AS (
  SELECT 'SEJOUR' AS NIVEAU, ANNEE, C_BRUT, N FROM sj
  UNION ALL
  SELECT 'MVT', ANNEE, C_BRUT, N FROM mv
),
xa AS (
  SELECT x.NIVEAU, x.ANNEE,
         SUM(x.N) AS N,
         SUM(CASE WHEN TRIM(x.C_BRUT) IS NULL THEN x.N ELSE 0 END) AS C_VIDE,
         SUM(CASE WHEN LENGTH(x.C_BRUT) <> LENGTH(TRIM(x.C_BRUT)) THEN x.N ELSE 0 END) AS C_DIFF,
         SUM(CASE WHEN EXISTS (SELECT 1 FROM un WHERE un.C_BRUT = x.C_BRUT) THEN x.N ELSE 0 END) AS C_DIRECT,
         SUM(CASE WHEN EXISTS (SELECT 1 FROM un WHERE un.C_TRIM = TRIM(x.C_BRUT)) THEN x.N ELSE 0 END) AS C_TRIM
  FROM x
  GROUP BY x.NIVEAU, x.ANNEE
),
ua AS (
  SELECT 'UNITE' AS NIVEAU, CAST(NULL AS NUMBER) AS ANNEE,
         COUNT(*) AS N,
         CAST(NULL AS NUMBER) AS C_VIDE,
         SUM(CASE WHEN LENGTH(C_BRUT) <> LENGTH(C_TRIM) THEN 1 ELSE 0 END) AS C_DIFF,
         CAST(NULL AS NUMBER) AS C_DIRECT, CAST(NULL AS NUMBER) AS C_TRIM
  FROM un
),
t AS (
  SELECT NIVEAU, ANNEE, N, C_VIDE, C_DIFF, C_DIRECT, C_TRIM FROM ua
  UNION ALL
  SELECT NIVEAU, ANNEE, N, C_VIDE, C_DIFF, C_DIRECT, C_TRIM FROM xa
)
SELECT '20261019-codes-char-blancs' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       NIVEAU, ANNEE,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - NVL(C_VIDE, N) BETWEEN 1 AND 9 OR N - NVL(C_TRIM, N) BETWEEN 1 AND 9
              OR N - NVL(C_DIFF, N) BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(N) END AS N,
       CASE WHEN C_VIDE IS NULL THEN NULL WHEN C_VIDE < 10 THEN '<10' ELSE TO_CHAR(C_VIDE) END AS N_UF_VIDE,
       CASE WHEN C_DIFF < 10 THEN '<10' ELSE TO_CHAR(C_DIFF) END AS N_DIFF_TRIM,
       CASE WHEN N >= 10 AND C_DIFF >= 10 AND N - NVL(C_VIDE, N) NOT BETWEEN 1 AND 9 AND N - NVL(C_TRIM, N) NOT BETWEEN 1 AND 9
                 AND N - C_DIFF NOT BETWEEN 1 AND 9
            THEN TO_CHAR(ROUND(100 * C_DIFF / N, 3)) END AS PCT_DIFF_TRIM,
       CASE WHEN C_DIRECT IS NULL THEN NULL WHEN C_DIRECT < 10 THEN '<10' ELSE TO_CHAR(C_DIRECT) END AS N_UNITE_EGAL_DIRECT,
       CASE WHEN C_TRIM IS NULL THEN NULL WHEN C_TRIM < 10 THEN '<10' ELSE TO_CHAR(C_TRIM) END AS N_UNITE_EGAL_TRIM
FROM t
ORDER BY NIVEAU, ANNEE;
