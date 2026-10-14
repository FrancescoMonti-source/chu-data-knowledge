-- id: 20261014-sejours-orphelins
-- system: cora
-- person_data: masked
-- purpose: par année d'entrée et par groupe (préadmission avec mouvement, préadmission sans mouvement, autre séjour sans mouvement), séjours sans DATE_SORTIE reliés à au moins un acte, un diagnostic, un mouvement, un RSS, ou à rien (étape 1 du plan, #32)
-- Oracle, schéma CORA_REC. Acte ou diagnostic relié : par ID_SEJOUR, ou par l'ID_MVT d'un mouvement du séjour. RSS : TB_MVT → TB_MVT_RUM.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : N_SEJ sort en « masqué » dès que l'un de ses compléments (N_SEJ moins une autre colonne) est entre 1 et 9.
WITH s AS (
  SELECT se.ID_SEJOUR,
         EXTRACT(YEAR FROM se.DATE_ENTREE) AS ANNEE_ENTREE,
         CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_MVT m WHERE m.ID_SEJOUR = se.ID_SEJOUR) THEN 1 ELSE 0 END AS A_MVT,
         CASE WHEN se.STATUT_PROG = 'P' THEN 1 ELSE 0 END AS PREADM
  FROM CORA_REC.TB_SEJOUR se
  WHERE se.DATE_SORTIE IS NULL
    AND se.DATE_ENTREE >= DATE '2014-01-01'
    AND se.DATE_ENTREE < DATE '2026-01-01'
),
g AS (
  SELECT s.ID_SEJOUR, s.ANNEE_ENTREE, s.A_MVT,
         CASE WHEN s.PREADM = 1 AND s.A_MVT = 1 THEN '1 préadmission avec mouvement'
              WHEN s.PREADM = 1 THEN '2 préadmission sans mouvement'
              ELSE '3 autre sans mouvement' END AS GROUPE
  FROM s
  WHERE s.PREADM = 1 OR s.A_MVT = 0
),
l AS (
  SELECT g.ANNEE_ENTREE, g.GROUPE, g.A_MVT,
         CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_ACTE a WHERE a.ID_SEJOUR = g.ID_SEJOUR)
                OR EXISTS (SELECT 1 FROM CORA_REC.TB_MVT m JOIN CORA_REC.TB_ACTE a ON a.ID_MVT = m.ID_MVT WHERE m.ID_SEJOUR = g.ID_SEJOUR)
              THEN 1 ELSE 0 END AS A_ACTE,
         CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_DIAG d WHERE d.ID_SEJOUR = g.ID_SEJOUR)
                OR EXISTS (SELECT 1 FROM CORA_REC.TB_MVT m JOIN CORA_REC.TB_DIAG d ON d.ID_MVT = m.ID_MVT WHERE m.ID_SEJOUR = g.ID_SEJOUR)
              THEN 1 ELSE 0 END AS A_DIAG,
         CASE WHEN EXISTS (SELECT 1 FROM CORA_REC.TB_MVT m JOIN CORA_REC.TB_MVT_RUM mr ON mr.ID_MVT = m.ID_MVT
                           WHERE m.ID_SEJOUR = g.ID_SEJOUR AND mr.ID_RSS IS NOT NULL)
              THEN 1 ELSE 0 END AS A_RSS
  FROM g
),
a AS (
  SELECT ANNEE_ENTREE, GROUPE,
         COUNT(*) AS SEJ,
         SUM(A_ACTE) AS ACTE,
         SUM(A_DIAG) AS DIAG,
         SUM(A_MVT) AS MVT,
         SUM(A_RSS) AS RSS,
         SUM(CASE WHEN A_ACTE = 0 AND A_DIAG = 0 AND A_MVT = 0 AND A_RSS = 0 THEN 1 ELSE 0 END) AS RIEN
  FROM l
  GROUP BY ANNEE_ENTREE, GROUPE
)
SELECT '20261014-sejours-orphelins' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE_ENTREE,
       GROUPE,
       CASE WHEN SEJ < 10 THEN '<10'
            WHEN SEJ - ACTE BETWEEN 1 AND 9 OR SEJ - DIAG BETWEEN 1 AND 9 OR SEJ - MVT BETWEEN 1 AND 9
              OR SEJ - RSS BETWEEN 1 AND 9 OR SEJ - RIEN BETWEEN 1 AND 9 THEN 'masqué'
            ELSE TO_CHAR(SEJ) END AS N_SEJ,
       CASE WHEN ACTE < 10 THEN '<10' ELSE TO_CHAR(ACTE) END AS N_AVEC_ACTE,
       CASE WHEN DIAG < 10 THEN '<10' ELSE TO_CHAR(DIAG) END AS N_AVEC_DIAG,
       CASE WHEN MVT < 10 THEN '<10' ELSE TO_CHAR(MVT) END AS N_AVEC_MVT,
       CASE WHEN RSS < 10 THEN '<10' ELSE TO_CHAR(RSS) END AS N_AVEC_RSS,
       CASE WHEN RIEN < 10 THEN '<10' ELSE TO_CHAR(RIEN) END AS N_RELIE_A_RIEN
FROM a
ORDER BY ANNEE_ENTREE, GROUPE;
