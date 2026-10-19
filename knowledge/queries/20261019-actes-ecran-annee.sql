-- id: 20261019-actes-ecran-annee
-- system: cora
-- person_data: masked
-- purpose: par année de réalisation et par valeur de TB_ACTE.ECRAN, le volume des actes, la part portée par chaque écran, la part de sites de bloc, et la part d'actes sans marqueur d'import, pour dire (1) si ECRAN = 'BLO' couvre peu des actes de bloc saisis dans CORA (reperer-actes-de-bloc, AM7 b), (2) comment ECRAN se répartit entre écrans depuis 2021 et si ECRAN renseigné égale l'absence de marqueur d'import (epoques-codage-actes, AM8 : 10,6 % contre 10,8 % en 2024, 21,8 % contre 21,8 % en 2025) ; si les deux parts divergent de plus de 1 point, ne plus tenir l'absence de marqueur d'import pour une saisie dans CORA
-- Oracle, schéma CORA_REC. Actes de DATE_ACTE du 2021-01-01 au jour d'exécution (2026 partiel). ECRAN : valeur de TB_ACTE.ECRAN, '(vide)' si vide ; les valeurs portées par moins de 10 actes dans l'année sont regroupées sur une ligne '(autres)'.
-- N : actes ; N_SANS_IMPORT : actes sans marqueur d'import (ID_APPLICATION_TRANSFERT vide ou 0, et TYPE_TRANSFERT différent de 'R') ; N_SITE_BLOC : actes dont le site a TB_SITE.BLOC = 'O' ; N_NO_INTERVENTION : NO_INTERVENTION renseigné.
-- Colonnes _ANNEE : total de l'année pour la colonne, affiché seulement quand les cases masquées de l'année totalisent 0 ou au moins 10 (suppression secondaire, règle 4), sinon « masqué ». Les pourcentages (PCT_) sortent seulement quand le numérateur et le dénominateur sont visibles : PCT_ANNEE = N / N_ANNEE ; PCT_SANS_IMPORT_ECRAN = N_SANS_IMPORT / N (dans la ligne) ; PCT_SANS_IMPORT_TOTAL_ANNEE = N_SANS_IMPORT_ANNEE / N_ANNEE (à comparer à 100 moins PCT_ANNEE de la ligne '(vide)') ; PCT_SITE_BLOC_ANNEE = N_SITE_BLOC / N_SITE_BLOC_ANNEE.
-- Masquage : chaque effectif < 10 sort en <10 ; N sort en « masqué » dès qu'un complément (N moins une autre colonne) est entre 1 et 9.
WITH g AS (
  SELECT EXTRACT(YEAR FROM x.DATE_ACTE) AS ANNEE,
         NVL(TRIM(x.ECRAN), '(vide)') AS ECRAN,
         COUNT(*) AS N,
         SUM(CASE WHEN (x.ID_APPLICATION_TRANSFERT IS NULL OR x.ID_APPLICATION_TRANSFERT = 0)
                   AND NVL(TRIM(x.TYPE_TRANSFERT), 'x') <> 'R' THEN 1 ELSE 0 END) AS C1,
         SUM(CASE WHEN si.BLOC = 'O' THEN 1 ELSE 0 END) AS C2,
         SUM(CASE WHEN x.NO_INTERVENTION IS NOT NULL THEN 1 ELSE 0 END) AS C3
  FROM CORA_REC.TB_ACTE x
  LEFT JOIN CORA_REC.TB_SITE si ON si.ID_SITE = x.ID_SITE
  WHERE x.DATE_ACTE >= DATE '2021-01-01'
    AND x.DATE_ACTE < TRUNC(SYSDATE) + 1
  GROUP BY EXTRACT(YEAR FROM x.DATE_ACTE), NVL(TRIM(x.ECRAN), '(vide)')
),
b AS (
  SELECT ANNEE,
         CASE WHEN N < 10 THEN '(autres)' ELSE ECRAN END AS ECRAN,
         SUM(N) AS N, SUM(C1) AS C1, SUM(C2) AS C2, SUM(C3) AS C3
  FROM g
  GROUP BY ANNEE, CASE WHEN N < 10 THEN '(autres)' ELSE ECRAN END
),
r AS (
  SELECT b.ANNEE, b.ECRAN, b.N, b.C1, b.C2, b.C3,
         SUM(N) OVER (PARTITION BY ANNEE) AS NA,
         SUM(C1) OVER (PARTITION BY ANNEE) AS C1A,
         SUM(C2) OVER (PARTITION BY ANNEE) AS C2A,
         SUM(CASE WHEN N < 10 THEN N ELSE 0 END) OVER (PARTITION BY ANNEE) AS HN,
         SUM(CASE WHEN C1 < 10 THEN C1 ELSE 0 END) OVER (PARTITION BY ANNEE) AS H1,
         SUM(CASE WHEN C2 < 10 THEN C2 ELSE 0 END) OVER (PARTITION BY ANNEE) AS H2,
         CASE WHEN N >= 10 AND N - C1 NOT BETWEEN 1 AND 9 AND N - C2 NOT BETWEEN 1 AND 9 AND N - C3 NOT BETWEEN 1 AND 9
              THEN 1 ELSE 0 END AS N_OK
  FROM b
)
SELECT '20261019-actes-ecran-annee' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE, ECRAN,
       CASE WHEN N < 10 THEN '<10' WHEN N_OK = 0 THEN 'masqué' ELSE TO_CHAR(N) END AS N,
       CASE WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_SANS_IMPORT,
       CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_SITE_BLOC,
       CASE WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_NO_INTERVENTION,
       CASE WHEN HN = 0 OR HN >= 10 THEN TO_CHAR(NA) ELSE 'masqué' END AS N_ANNEE,
       CASE WHEN H1 = 0 OR H1 >= 10 THEN TO_CHAR(C1A) ELSE 'masqué' END AS N_SANS_IMPORT_ANNEE,
       CASE WHEN H2 = 0 OR H2 >= 10 THEN TO_CHAR(C2A) ELSE 'masqué' END AS N_SITE_BLOC_ANNEE,
       CASE WHEN N_OK = 1 AND (HN = 0 OR HN >= 10) THEN ROUND(100 * N / NA, 1) END AS PCT_ANNEE,
       CASE WHEN N_OK = 1 AND C1 >= 10 THEN ROUND(100 * C1 / N, 1) END AS PCT_SANS_IMPORT_ECRAN,
       CASE WHEN (HN = 0 OR HN >= 10) AND (H1 = 0 OR H1 >= 10) THEN ROUND(100 * C1A / NA, 1) END AS PCT_SANS_IMPORT_TOTAL_ANNEE,
       CASE WHEN C2 >= 10 AND (H2 = 0 OR H2 >= 10) THEN ROUND(100 * C2 / C2A, 1) END AS PCT_SITE_BLOC_ANNEE
FROM r
ORDER BY ANNEE, r.N DESC, ECRAN;
