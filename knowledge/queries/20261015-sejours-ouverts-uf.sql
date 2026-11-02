-- id: 20261015-sejours-ouverts-uf
-- system: cora
-- person_data: masked
-- purpose: par année d'entrée et par UF du dernier mouvement, les séjours restés ouverts (sans DATE_SORTIE, hors préadmissions, avec au moins un mouvement) parmi tous les séjours de l'UF, et ce qu'ils portent : un seul mouvement, mouvement encore ouvert, acte, diagnostic, mouvement commencé il y a plus d'un an (#33, tests 1, 2 et 4)
-- Oracle, schéma CORA_REC. Séjours entrés de 2018 à 2025, hors préadmissions (STATUT_PROG = 'P') et hors séjours sans mouvement (exclure-sejours-sans-sortie-orphelins). Dernier mouvement : le plus tardif par DATE_DEBUT_MVT, HEURE_DEBUT_MVT, ID_MVT ; UF : son code (joindre-uf-par-code). Acte ou diagnostic : par l'ID_MVT d'un mouvement du séjour.
-- UF : le code de l'UF quand l'année compte au moins 10 séjours ouverts dans cette UF, sinon « autres UF ». N_SEJ : séjours de l'UF ; N_OUVERTS ; puis, parmi les ouverts : N_UN_MVT, N_DERNIER_MVT_OUVERT (DATE_FIN_MVT vide), N_AVEC_ACTE, N_AVEC_DIAG, N_MVT_PLUS_1_AN (dernier mouvement commencé plus d'un an avant l'exécution).
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N_SEJ sort en « masqué » si N_SEJ − N_OUVERTS est entre 1 et 9 ; N_OUVERTS sort en « masqué » si N_OUVERTS moins une autre colonne est entre 1 et 9. Aucune ligne de total.
WITH mv AS (
  SELECT ID_SEJOUR,
         COUNT(*) AS NB_MVT,
         MAX(TRIM(ID_UNITE_M)) KEEP (DENSE_RANK LAST ORDER BY DATE_DEBUT_MVT, HEURE_DEBUT_MVT, ID_MVT) AS UF,
         MAX(CASE WHEN DATE_FIN_MVT IS NULL THEN 1 ELSE 0 END) KEEP (DENSE_RANK LAST ORDER BY DATE_DEBUT_MVT, HEURE_DEBUT_MVT, ID_MVT) AS OUVERT,
         MAX(DATE_DEBUT_MVT) AS DERNIER_DEBUT
  FROM CORA_REC.TB_MVT GROUP BY ID_SEJOUR
),
ac AS (SELECT DISTINCT m.ID_SEJOUR FROM CORA_REC.TB_MVT m JOIN CORA_REC.TB_ACTE a ON a.ID_MVT = m.ID_MVT),
dg AS (SELECT DISTINCT m.ID_SEJOUR FROM CORA_REC.TB_MVT m JOIN CORA_REC.TB_DIAG d ON d.ID_MVT = m.ID_MVT),
s AS (
  SELECT EXTRACT(YEAR FROM se.DATE_ENTREE) AS ANNEE, mv.UF,
         CASE WHEN se.DATE_SORTIE IS NULL THEN 1 ELSE 0 END AS OUV,
         CASE WHEN se.DATE_SORTIE IS NULL AND mv.NB_MVT = 1 THEN 1 ELSE 0 END AS UN,
         CASE WHEN se.DATE_SORTIE IS NULL AND mv.OUVERT = 1 THEN 1 ELSE 0 END AS MO,
         CASE WHEN se.DATE_SORTIE IS NULL AND ac.ID_SEJOUR IS NOT NULL THEN 1 ELSE 0 END AS AC,
         CASE WHEN se.DATE_SORTIE IS NULL AND dg.ID_SEJOUR IS NOT NULL THEN 1 ELSE 0 END AS DG,
         CASE WHEN se.DATE_SORTIE IS NULL AND mv.DERNIER_DEBUT < ADD_MONTHS(TRUNC(SYSDATE), -12) THEN 1 ELSE 0 END AS VX
  FROM CORA_REC.TB_SEJOUR se
  JOIN mv ON mv.ID_SEJOUR = se.ID_SEJOUR
  LEFT JOIN ac ON ac.ID_SEJOUR = se.ID_SEJOUR
  LEFT JOIN dg ON dg.ID_SEJOUR = se.ID_SEJOUR
  WHERE se.DATE_ENTREE >= DATE '2018-01-01' AND se.DATE_ENTREE < DATE '2026-01-01'
    AND NVL(se.STATUT_PROG, '-') <> 'P'
),
u AS (
  SELECT ANNEE, UF, COUNT(*) AS N, SUM(OUV) AS O, SUM(UN) AS C1, SUM(MO) AS C2, SUM(AC) AS C3, SUM(DG) AS C4, SUM(VX) AS C5
  FROM s GROUP BY ANNEE, UF
),
g AS (
  SELECT ANNEE, CASE WHEN O >= 10 THEN UF ELSE 'autres UF' END AS UF,
         SUM(N) AS N, SUM(O) AS O, SUM(C1) AS C1, SUM(C2) AS C2, SUM(C3) AS C3, SUM(C4) AS C4, SUM(C5) AS C5
  FROM u GROUP BY ANNEE, CASE WHEN O >= 10 THEN UF ELSE 'autres UF' END
)
SELECT '20261015-sejours-ouverts-uf' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE, UF,
       CASE WHEN N < 10 THEN '<10' WHEN N - O BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(N) END AS N_SEJ,
       CASE WHEN O < 10 THEN '<10'
            WHEN O - C1 BETWEEN 1 AND 9 OR O - C2 BETWEEN 1 AND 9 OR O - C3 BETWEEN 1 AND 9 OR O - C4 BETWEEN 1 AND 9 OR O - C5 BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(O) END AS N_OUVERTS,
       CASE WHEN C1 < 10 THEN '<10' ELSE TO_CHAR(C1) END AS N_UN_MVT,
       CASE WHEN C2 < 10 THEN '<10' ELSE TO_CHAR(C2) END AS N_DERNIER_MVT_OUVERT,
       CASE WHEN C3 < 10 THEN '<10' ELSE TO_CHAR(C3) END AS N_AVEC_ACTE,
       CASE WHEN C4 < 10 THEN '<10' ELSE TO_CHAR(C4) END AS N_AVEC_DIAG,
       CASE WHEN C5 < 10 THEN '<10' ELSE TO_CHAR(C5) END AS N_MVT_PLUS_1_AN
FROM g
ORDER BY ANNEE, CASE WHEN UF = 'autres UF' THEN 1 ELSE 0 END, O DESC;
