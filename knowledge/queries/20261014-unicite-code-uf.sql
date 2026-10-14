-- id: 20261014-unicite-code-uf
-- system: cora
-- person_data: masked
-- purpose: savoir si un code d'UF (TB_UNITE.CODE_UNITE) a plusieurs lignes dans TB_UNITE, combien de séjours une jointure par code dupliquerait, et sur quelle table se joint TB_MVT.ID_UNITE_M (kb : uf-label-join-duplicates, #24)
-- Oracle, schéma CORA_REC. Trois niveaux, une ligne par niveau et par modalité :
--   CODES : codes d'UF selon leur nombre de lignes dans TB_UNITE (1, 2, 3 ou plus) ; parmi eux, ceux dont les lignes ont des libellés différents, ou dont plus d'une ligne est active ; et les codes qui ne sont égaux qu'après TRIM.
--   SEJOURS : par année d'entrée depuis 2018, séjours dont UF_ENTREE trouve 0, 1 ou plusieurs lignes de TB_UNITE par égalité de code (avec et sans TRIM).
--   MOUVEMENTS : par année de début depuis 2018, mouvements dont ID_UNITE_M existe comme TB_UNITE.ID_UNITE, comme TB_UNITE_MEDICALE.ID_UNITE_MED, les deux, ou aucun.
-- Colonnes N_A, N_B, N_C : pour CODES, les codes dont les lignes ont des libellés différents (N_A), plus d'une ligne active (N_B), plusieurs écritures égales après TRIM (N_C) ; pour SEJOURS, la même répartition 0 ligne (N_A), 1 ligne (N_B), plusieurs lignes (N_C) mais par égalité de code sans TRIM ; vides pour MOUVEMENTS.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : pour SEJOURS, N_A + N_B + N_C = N, donc N sort en « masqué » dès que l'un des trois est entre 1 et 9.
WITH u AS (
  SELECT TRIM(CODE_UNITE) AS CODE,
         COUNT(*) AS NB_LIGNES,
         COUNT(DISTINCT CODE_UNITE) AS NB_ECRITURES,
         COUNT(DISTINCT LIBELLE_UNITE) AS NB_LIBELLES,
         SUM(CASE WHEN ACTIF = 'O' THEN 1 ELSE 0 END) AS NB_ACTIFS
  FROM CORA_REC.TB_UNITE
  GROUP BY TRIM(CODE_UNITE)
),
codes AS (
  SELECT 'CODES' AS NIVEAU,
         NULL AS ANNEE,
         CASE WHEN NB_LIGNES = 1 THEN '1 ligne' WHEN NB_LIGNES = 2 THEN '2 lignes' ELSE '3 lignes ou plus' END AS MODALITE,
         COUNT(*) AS NB,
         SUM(CASE WHEN NB_LIBELLES > 1 THEN 1 ELSE 0 END) AS NB_A,
         SUM(CASE WHEN NB_ACTIFS > 1 THEN 1 ELSE 0 END) AS NB_B,
         SUM(CASE WHEN NB_ECRITURES > 1 THEN 1 ELSE 0 END) AS NB_C
  FROM u
  GROUP BY CASE WHEN NB_LIGNES = 1 THEN '1 ligne' WHEN NB_LIGNES = 2 THEN '2 lignes' ELSE '3 lignes ou plus' END
),
brut AS (
  SELECT CODE_UNITE, COUNT(*) AS NB_LIGNES
  FROM CORA_REC.TB_UNITE
  GROUP BY CODE_UNITE
),
sej AS (
  SELECT 'SEJOURS' AS NIVEAU,
         EXTRACT(YEAR FROM s.DATE_ENTREE) AS ANNEE,
         CASE WHEN NVL(u.NB_LIGNES, 0) = 0 THEN '0 ligne' WHEN u.NB_LIGNES = 1 THEN '1 ligne' ELSE 'plusieurs lignes' END AS MODALITE,
         COUNT(*) AS NB,
         SUM(CASE WHEN NVL(b.NB_LIGNES, 0) = 0 THEN 1 ELSE 0 END) AS NB_A,
         SUM(CASE WHEN b.NB_LIGNES = 1 THEN 1 ELSE 0 END) AS NB_B,
         SUM(CASE WHEN b.NB_LIGNES > 1 THEN 1 ELSE 0 END) AS NB_C
  FROM CORA_REC.TB_SEJOUR s
  LEFT JOIN u ON u.CODE = TRIM(s.UF_ENTREE)
  LEFT JOIN brut b ON b.CODE_UNITE = s.UF_ENTREE
  WHERE s.DATE_ENTREE >= DATE '2018-01-01'
    AND s.DATE_ENTREE < DATE '2026-01-01'
  GROUP BY EXTRACT(YEAR FROM s.DATE_ENTREE),
           CASE WHEN NVL(u.NB_LIGNES, 0) = 0 THEN '0 ligne' WHEN u.NB_LIGNES = 1 THEN '1 ligne' ELSE 'plusieurs lignes' END
),
mvt AS (
  SELECT 'MOUVEMENTS' AS NIVEAU,
         EXTRACT(YEAR FROM m.DATE_DEBUT_MVT) AS ANNEE,
         CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_UNITE x WHERE x.ID_UNITE = m.ID_UNITE_M)
              THEN CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_UNITE_MEDICALE y WHERE y.ID_UNITE_MED = m.ID_UNITE_M)
                        THEN 'TB_UNITE et TB_UNITE_MEDICALE' ELSE 'TB_UNITE seulement' END
              ELSE CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_UNITE_MEDICALE y WHERE y.ID_UNITE_MED = m.ID_UNITE_M)
                        THEN 'TB_UNITE_MEDICALE seulement' ELSE 'aucune' END
         END AS MODALITE,
         1 AS UN
  FROM CORA_REC.TB_MVT m
  WHERE m.DATE_DEBUT_MVT >= DATE '2018-01-01'
    AND m.DATE_DEBUT_MVT < DATE '2026-01-01'
),
mvt_agg AS (
  SELECT NIVEAU, ANNEE, MODALITE, COUNT(*) AS NB, NULL AS NB_A, NULL AS NB_B, NULL AS NB_C
  FROM mvt
  GROUP BY NIVEAU, ANNEE, MODALITE
),
r AS (
  SELECT NIVEAU, ANNEE, MODALITE, NB, NB_A, NB_B, NB_C FROM codes
  UNION ALL SELECT NIVEAU, ANNEE, MODALITE, NB, NB_A, NB_B, NB_C FROM sej
  UNION ALL SELECT NIVEAU, ANNEE, MODALITE, NB, NB_A, NB_B, NB_C FROM mvt_agg
)
SELECT '20261014-unicite-code-uf' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       NIVEAU, ANNEE, MODALITE,
       CASE WHEN NB < 10 THEN '<10'
            WHEN NIVEAU = 'SEJOURS' AND (NB_A BETWEEN 1 AND 9 OR NB_B BETWEEN 1 AND 9 OR NB_C BETWEEN 1 AND 9) THEN 'masqué'
            ELSE TO_CHAR(NB) END AS N,
       CASE WHEN NB_A IS NULL THEN NULL WHEN NB_A < 10 THEN '<10' ELSE TO_CHAR(NB_A) END AS N_A,
       CASE WHEN NB_B IS NULL THEN NULL WHEN NB_B < 10 THEN '<10' ELSE TO_CHAR(NB_B) END AS N_B,
       CASE WHEN NB_C IS NULL THEN NULL WHEN NB_C < 10 THEN '<10' ELSE TO_CHAR(NB_C) END AS N_C
FROM r
ORDER BY CASE NIVEAU WHEN 'CODES' THEN 1 WHEN 'SEJOURS' THEN 2 ELSE 3 END, ANNEE, MODALITE;
