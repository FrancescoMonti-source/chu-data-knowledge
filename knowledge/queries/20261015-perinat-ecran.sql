-- id: 20261015-perinat-ecran
-- system: cora
-- person_data: masked
-- purpose: savoir si l'écran périnatalité de CORA (TB_PERINAT, TB_PERINAT_DET) est rempli, depuis quand, et ce que valent ses codes, avant de s'en servir pour le terme, le nombre d'enfants, les IMG et les morts in utero (étape 2 du plan, #42)
-- Oracle, schéma CORA_REC. Deux niveaux.
-- ANNEE : lignes de TB_PERINAT par année de début du mouvement (TB_PERINAT.ID_MVT → TB_MVT.ID_MVT, lien du dictionnaire), de 2014 à 2025 ; '(sans mvt)' si l'ID_MVT n'est pas dans TB_MVT.
--   N : lignes ; N_TERME, N_NB_ENFANT, N_IMG_22, N_MIU, N_VALIDE : ID_TERME_GROSSESSE, ID_NB_ENFANT, IMG_22_SEM, MORT_IN_UTERO, DATE_VALIDATION renseignés ; N_DET : au moins une ligne de TB_PERINAT_DET pour le mouvement ; N_DET_2 : au moins deux.
-- VALEURS : pour chaque colonne codée, chaque valeur et son nombre de lignes, toutes années de 2014 à 2025 ensemble.
--   Hypothèse à tester, que le dictionnaire ne donne pas : les colonnes ID_ renvoient à TB_PERINAT_NOMENC.ID_NOMENC. TYPE_NOMENC et LIBELLE_NOMENC restent vides si la valeur n'y est pas.
-- Masquage : chaque effectif < 10 sort en <10. ANNEE : N sort en « masqué » dès qu'un complément (N moins une autre colonne) est entre 1 et 9. VALEURS : si une seule valeur d'une colonne est masquée, la plus petite des autres valeurs de la colonne sort aussi en « masqué ». Aucune ligne de total.
WITH p AS (
  SELECT x.ID_MVT,
         NVL(TO_CHAR(EXTRACT(YEAR FROM m.DATE_DEBUT_MVT)), '(sans mvt)') AS ANNEE,
         x.ID_TERME_GROSSESSE, x.ID_NB_ENFANT, x.IMG_22_SEM, x.MORT_IN_UTERO,
         x.ID_ORIGINE_TRANSFERT, x.DATE_VALIDATION,
         (SELECT COUNT(*) FROM CORA_REC.TB_PERINAT_DET d WHERE d.ID_MVT = x.ID_MVT) AS NB_DET
  FROM CORA_REC.TB_PERINAT x
  LEFT JOIN CORA_REC.TB_MVT m ON m.ID_MVT = x.ID_MVT
  WHERE m.ID_MVT IS NULL
     OR (m.DATE_DEBUT_MVT >= DATE '2014-01-01' AND m.DATE_DEBUT_MVT < DATE '2026-01-01')
),
a AS (
  SELECT ANNEE,
         COUNT(*) AS N,
         SUM(CASE WHEN x.ID_TERME_GROSSESSE IS NOT NULL THEN 1 ELSE 0 END) AS C1,
         SUM(CASE WHEN x.ID_NB_ENFANT IS NOT NULL THEN 1 ELSE 0 END) AS C2,
         SUM(CASE WHEN TRIM(x.IMG_22_SEM) IS NOT NULL THEN 1 ELSE 0 END) AS C3,
         SUM(CASE WHEN TRIM(x.MORT_IN_UTERO) IS NOT NULL THEN 1 ELSE 0 END) AS C4,
         SUM(CASE WHEN x.DATE_VALIDATION IS NOT NULL THEN 1 ELSE 0 END) AS C5,
         SUM(CASE WHEN x.NB_DET >= 1 THEN 1 ELSE 0 END) AS C6,
         SUM(CASE WHEN x.NB_DET >= 2 THEN 1 ELSE 0 END) AS C7
  FROM p x
  GROUP BY ANNEE
),
v0 AS (
  SELECT 'ID_TERME_GROSSESSE' AS COLONNE, TO_CHAR(ID_TERME_GROSSESSE) AS VALEUR FROM p
  UNION ALL SELECT 'ID_NB_ENFANT', TO_CHAR(ID_NB_ENFANT) FROM p
  UNION ALL SELECT 'IMG_22_SEM', TRIM(IMG_22_SEM) FROM p
  UNION ALL SELECT 'MORT_IN_UTERO', TRIM(MORT_IN_UTERO) FROM p
  UNION ALL SELECT 'ID_ORIGINE_TRANSFERT', TO_CHAR(ID_ORIGINE_TRANSFERT) FROM p
  UNION ALL SELECT 'DET.ID_ETAT', TO_CHAR(d.ID_ETAT) FROM CORA_REC.TB_PERINAT_DET d WHERE d.ID_MVT IN (SELECT ID_MVT FROM p)
  UNION ALL SELECT 'DET.ID_POIDS', TO_CHAR(d.ID_POIDS) FROM CORA_REC.TB_PERINAT_DET d WHERE d.ID_MVT IN (SELECT ID_MVT FROM p)
),
v AS (
  SELECT COLONNE, NVL(VALEUR, '(vide)') AS VALEUR, COUNT(*) AS N
  FROM v0
  GROUP BY COLONNE, NVL(VALEUR, '(vide)')
),
vm AS (
  SELECT COLONNE, VALEUR, N,
         SUM(CASE WHEN N < 10 THEN 1 ELSE 0 END) OVER (PARTITION BY COLONNE) AS NB_MASQ,
         ROW_NUMBER() OVER (PARTITION BY COLONNE ORDER BY CASE WHEN N < 10 THEN 1 ELSE 0 END, N) AS RG_VISIBLE
  FROM v
),
nom AS (
  SELECT TO_CHAR(ID_NOMENC) AS VALEUR,
         MAX(TRIM(TYPE_NOMENC)) AS TYPE_NOMENC,
         MAX(TRIM(LIBELLE_NOMENC)) AS LIBELLE_NOMENC
  FROM CORA_REC.TB_PERINAT_NOMENC
  GROUP BY TO_CHAR(ID_NOMENC)
)
SELECT '20261015-perinat-ecran' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       NIVEAU, ANNEE, COLONNE, VALEUR, TYPE_NOMENC, LIBELLE_NOMENC,
       N, N_TERME, N_NB_ENFANT, N_IMG_22, N_MIU, N_VALIDE, N_DET, N_DET_2
FROM (
  SELECT 'ANNEE' AS NIVEAU, ANNEE, NULL AS COLONNE, NULL AS VALEUR, NULL AS TYPE_NOMENC, NULL AS LIBELLE_NOMENC,
         CASE WHEN N < 10 THEN '<10'
              WHEN N - C1 BETWEEN 1 AND 9 OR N - C2 BETWEEN 1 AND 9 OR N - C3 BETWEEN 1 AND 9 OR N - C4 BETWEEN 1 AND 9
                OR N - C5 BETWEEN 1 AND 9 OR N - C6 BETWEEN 1 AND 9 OR N - C7 BETWEEN 1 AND 9 THEN 'masqué'
              ELSE TO_CHAR(N) END AS N,
         CASE WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_TERME,
         CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_NB_ENFANT,
         CASE WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_IMG_22,
         CASE WHEN C4 < 10 THEN '<10' ELSE TO_CHAR(C4) END AS N_MIU,
         CASE WHEN C5 < 10 THEN '<10' ELSE TO_CHAR(C5) END AS N_VALIDE,
         CASE WHEN C6 < 10 THEN '<10' ELSE TO_CHAR(C6) END AS N_DET,
         CASE WHEN C7 < 10 THEN '<10' ELSE TO_CHAR(C7) END AS N_DET_2
  FROM a
  UNION ALL
  SELECT 'VALEURS', NULL, vm.COLONNE, vm.VALEUR,
         CASE WHEN vm.COLONNE LIKE '%ID_%' THEN nom.TYPE_NOMENC END,
         CASE WHEN vm.COLONNE LIKE '%ID_%' THEN nom.LIBELLE_NOMENC END,
         CASE WHEN vm.N < 10 THEN '<10'
              WHEN vm.NB_MASQ = 1 AND vm.RG_VISIBLE = 1 THEN 'masqué'
              ELSE TO_CHAR(vm.N) END,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL
  FROM vm
  LEFT JOIN nom ON nom.VALEUR = vm.VALEUR
)
ORDER BY NIVEAU, ANNEE, COLONNE, VALEUR;
