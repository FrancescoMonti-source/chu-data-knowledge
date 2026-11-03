-- id: 20261103-mfs-enfant-mere-22sa
-- system: cora
-- person_data: masked
-- purpose: expliquer pourquoi les séjours d'enfant P95+1 (DP) dépassent les séjours de mère Z3710 (DAS), par exemple 66 contre 24 en 2023 (20261102-codes-mortinatalite-detail-resultat). Hypothèse : des RUM d'enfant existent sous 22 SA et 500 g, où aucun RUM n'est attendu, et leur mère a un séjour d'avortement sans Z37 (20261103-mortnes-pas-de-rum-moins-22sa, 20261103-mortnes-mere-avortement-moins-22sa, 20261103-mortnes-moins-22sa-500g). Même mesure pour l'IMG (P95+0 contre Z3711). Étape 5 du plan, #42.
-- Oracle, schéma CORA_REC. Diagnostics de TB_DIAG rattachés à un mouvement (chemin-actes-diags-par-mouvement), datés par le début du mouvement (dater-diagnostic-par-mouvement), de 2019 à 2025 (extensions de P95 et Z37 depuis 2019, 20261102-mortnes-p95-extensions).
-- Lignes : CODE × ANNEE, pour quatre codes au rang où le texte les attend : P95+0 et P95+1 en DP (TYPE_DIAG 'P', séjour de l'enfant), Z3710 et Z3711 en DAS (TYPE_DIAG 'S', séjour de la mère). Codes comparés tels que CORA les stocke (20261102-codes-mortinatalite-detail-resultat). N : séjours (TB_MVT.ID_SEJOUR) ; il refait N de 20261102-codes-mortinatalite-detail-resultat, ce qui sert de contrôle.
-- Colonnes, sur le séjour : N_SA_VIDE, N_SA_MOINS_22, N_SA_22_PLUS : plus grande SEM_AMENORHEE des mouvements, vide ou 0, 1 à 21, 22 et plus.
-- Séjours d'enfant seulement (vides sur les lignes Z37) : N_POIDS_500 : plus grand POIDS_RUM (grammes) des mouvements >= 500 ; N_HORS_REGLE : SEM_AMENORHEE 1 à 21 et poids < 500 ou absent, cas où aucun RUM d'enfant n'est attendu ;
-- N_MERE_TROUVEE : TB_SEJOUR.NO_SEJOUR_DOSSIER_MERE est le NO_SEJOUR d'un séjour de CORA ; parmi eux, N_MERE_Z37 : ce séjour de la mère porte un code Z37 (tout rang) ; N_MERE_O03_O04 : il porte un code O03 ou O04 (avortement spontané ou médical, tout rang).
-- Masquage : chaque effectif < 10 sort en <10. N est déjà public (même valeur que la preuve du 02/11), donc la suppression secondaire porte sur les colonnes : une colonne sort en « masqué » quand N moins elle est entre 1 et 9 ; N_HORS_REGLE aussi quand N_SA_MOINS_22 moins elle est entre 1 et 9 ; N_MERE_Z37 et N_MERE_O03_O04 aussi quand N_MERE_TROUVEE moins elles est entre 1 et 9. Les trois classes de SEM_AMENORHEE font N à elles trois : si l'une est entre 1 et 9, aucune ne sort, ni N_HORS_REGLE qui pourrait redonner N_SA_MOINS_22. Aucune ligne de total.
WITH dx AS (
  SELECT DISTINCT m.ID_SEJOUR,
         REPLACE(TRIM(d.CODE_DIAG), '.', '') AS CODE,
         EXTRACT(YEAR FROM m.DATE_DEBUT_MVT) AS ANNEE
  FROM CORA_REC.TB_DIAG d
  JOIN CORA_REC.TB_MVT m ON m.ID_MVT = d.ID_MVT
  WHERE ((REPLACE(TRIM(d.CODE_DIAG), '.', '') IN ('P95+0', 'P95+1') AND TRIM(d.TYPE_DIAG) = 'P')
      OR (REPLACE(TRIM(d.CODE_DIAG), '.', '') IN ('Z3710', 'Z3711') AND TRIM(d.TYPE_DIAG) = 'S'))
    AND m.DATE_DEBUT_MVT >= DATE '2019-01-01'
    AND m.DATE_DEBUT_MVT < DATE '2026-01-01'
),
mv AS (
  SELECT ID_SEJOUR,
         MAX(SEM_AMENORHEE) AS SA_MAX,
         MAX(POIDS_RUM) AS POIDS_MAX
  FROM CORA_REC.TB_MVT
  WHERE ID_SEJOUR IN (SELECT ID_SEJOUR FROM dx)
  GROUP BY ID_SEJOUR
),
mere AS (
  SELECT TRIM(s.NO_SEJOUR) AS NO_SEJ,
         MAX(CASE WHEN REPLACE(TRIM(d.CODE_DIAG), '.', '') LIKE 'Z37%' THEN 1 ELSE 0 END) AS Z37,
         MAX(CASE WHEN REPLACE(TRIM(d.CODE_DIAG), '.', '') LIKE 'O03%'
                    OR REPLACE(TRIM(d.CODE_DIAG), '.', '') LIKE 'O04%' THEN 1 ELSE 0 END) AS O03_O04
  FROM CORA_REC.TB_SEJOUR s
  LEFT JOIN CORA_REC.TB_MVT m ON m.ID_SEJOUR = s.ID_SEJOUR
  LEFT JOIN CORA_REC.TB_DIAG d ON d.ID_MVT = m.ID_MVT
  WHERE TRIM(s.NO_SEJOUR) IN (
    SELECT TRIM(s2.NO_SEJOUR_DOSSIER_MERE)
    FROM CORA_REC.TB_SEJOUR s2
    WHERE s2.ID_SEJOUR IN (SELECT ID_SEJOUR FROM dx))
  GROUP BY TRIM(s.NO_SEJOUR)
),
sj AS (
  SELECT dx.CODE, dx.ANNEE, dx.ID_SEJOUR,
         CASE WHEN dx.CODE LIKE 'P95%' THEN 1 ELSE 0 END AS ENFANT,
         mv.SA_MAX, mv.POIDS_MAX,
         CASE WHEN mere.NO_SEJ IS NOT NULL THEN 1 ELSE 0 END AS MERE_TROUVEE,
         NVL(mere.Z37, 0) AS MERE_Z37,
         NVL(mere.O03_O04, 0) AS MERE_O03_O04
  FROM dx
  JOIN CORA_REC.TB_SEJOUR s ON s.ID_SEJOUR = dx.ID_SEJOUR
  LEFT JOIN mv ON mv.ID_SEJOUR = dx.ID_SEJOUR
  LEFT JOIN mere ON mere.NO_SEJ = TRIM(s.NO_SEJOUR_DOSSIER_MERE)
),
t AS (
  SELECT CODE, ANNEE, MAX(ENFANT) AS ENFANT,
         COUNT(DISTINCT ID_SEJOUR) AS N,
         COUNT(DISTINCT CASE WHEN NVL(SA_MAX, 0) <= 0 THEN ID_SEJOUR END) AS C1,
         COUNT(DISTINCT CASE WHEN SA_MAX BETWEEN 1 AND 21 THEN ID_SEJOUR END) AS C2,
         COUNT(DISTINCT CASE WHEN SA_MAX >= 22 THEN ID_SEJOUR END) AS C3,
         COUNT(DISTINCT CASE WHEN POIDS_MAX >= 500 THEN ID_SEJOUR END) AS C4,
         COUNT(DISTINCT CASE WHEN SA_MAX BETWEEN 1 AND 21 AND NVL(POIDS_MAX, 0) < 500 THEN ID_SEJOUR END) AS C5,
         COUNT(DISTINCT CASE WHEN MERE_TROUVEE = 1 THEN ID_SEJOUR END) AS C6,
         COUNT(DISTINCT CASE WHEN MERE_Z37 = 1 THEN ID_SEJOUR END) AS C7,
         COUNT(DISTINCT CASE WHEN MERE_O03_O04 = 1 THEN ID_SEJOUR END) AS C8
  FROM sj
  GROUP BY CODE, ANNEE
)
SELECT '20261103-mfs-enfant-mere-22sa' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       CODE, ANNEE,
       CASE WHEN N < 10 THEN '<10' ELSE TO_CHAR(N) END AS N,
       CASE WHEN C1 BETWEEN 1 AND 9 OR C2 BETWEEN 1 AND 9 OR C3 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(C1) END AS N_SA_VIDE,
       CASE WHEN C1 BETWEEN 1 AND 9 OR C2 BETWEEN 1 AND 9 OR C3 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(C2) END AS N_SA_MOINS_22,
       CASE WHEN C1 BETWEEN 1 AND 9 OR C2 BETWEEN 1 AND 9 OR C3 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(C3) END AS N_SA_22_PLUS,
       CASE WHEN ENFANT = 0 THEN NULL
            WHEN C4 < 10 THEN '<10'
            WHEN N - C4 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(C4) END AS N_POIDS_500,
       CASE WHEN ENFANT = 0 THEN NULL
            WHEN C5 < 10 THEN '<10'
            WHEN N - C5 BETWEEN 1 AND 9 OR C2 - C5 BETWEEN 1 AND 9
              OR C1 BETWEEN 1 AND 9 OR C2 BETWEEN 1 AND 9 OR C3 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(C5) END AS N_HORS_REGLE,
       CASE WHEN ENFANT = 0 THEN NULL
            WHEN C6 < 10 THEN '<10'
            WHEN N - C6 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(C6) END AS N_MERE_TROUVEE,
       CASE WHEN ENFANT = 0 THEN NULL
            WHEN C7 < 10 THEN '<10'
            WHEN N - C7 BETWEEN 1 AND 9 OR C6 - C7 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(C7) END AS N_MERE_Z37,
       CASE WHEN ENFANT = 0 THEN NULL
            WHEN C8 < 10 THEN '<10'
            WHEN N - C8 BETWEEN 1 AND 9 OR C6 - C8 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(C8) END AS N_MERE_O03_O04
FROM t
ORDER BY CODE, ANNEE;
