-- id: 20261015-applications-emettrices
-- system: cora
-- person_data: masked
-- purpose: pour chaque table qui porte l'application émettrice (TB_ACTE, TB_DIAG, TB_INTERVENTION), les couples ID_APPLICATION_TRANSFERT et APPLI_TRANSFERT (libellé quand la table en a un) et TYPE_TRANSFERT, avec leur nombre de lignes et leur première et dernière année, pour nommer les applications 7, 16, 0 et −3010 (kb : backlog application-codes, definition.act-origin)
-- Oracle, schéma CORA_REC. Années de DATE_ACTE, DATE_DIAG ou DATE_INTERVENTION ; PREMIERE_ANNEE et DERNIERE_ANNEE ne sortent que si le groupe compte au moins 10 lignes.
-- Masquage : chaque effectif < 10 sort en <10, et les années d'un groupe de moins de 10 lignes aussi. Pas de total.
WITH t AS (
  SELECT 'TB_ACTE' AS TABLE_SOURCE, NVL(TRIM(TO_CHAR(ID_APPLICATION_TRANSFERT)), '(vide)') AS ID_APPLI,
         '(sans colonne)' AS LIBELLE_APPLI, NVL(TRIM(TYPE_TRANSFERT), '(vide)') AS TYPE_TRANSFERT,
         EXTRACT(YEAR FROM DATE_ACTE) AS ANNEE
  FROM CORA_REC.TB_ACTE
  UNION ALL
  SELECT 'TB_DIAG', NVL(TRIM(TO_CHAR(ID_APPLICATION_TRANSFERT)), '(vide)'),
         NVL(TRIM(TO_CHAR(APPLI_TRANSFERT)), '(vide)'), NVL(TRIM(TYPE_TRANSFERT), '(vide)'),
         EXTRACT(YEAR FROM DATE_DIAG)
  FROM CORA_REC.TB_DIAG
  UNION ALL
  SELECT 'TB_INTERVENTION', NVL(TRIM(TO_CHAR(ID_APPLICATION_TRANSFERT)), '(vide)'),
         NVL(TRIM(TO_CHAR(APPLI_TRANSFERT)), '(vide)'), NVL(TRIM(TYPE_TRANSFERT), '(vide)'),
         EXTRACT(YEAR FROM DATE_INTERVENTION)
  FROM CORA_REC.TB_INTERVENTION
),
g AS (
  SELECT TABLE_SOURCE, ID_APPLI, LIBELLE_APPLI, TYPE_TRANSFERT, COUNT(*) AS N, MIN(ANNEE) AS A1, MAX(ANNEE) AS A2
  FROM t GROUP BY TABLE_SOURCE, ID_APPLI, LIBELLE_APPLI, TYPE_TRANSFERT
)
SELECT '20261015-applications-emettrices' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       TABLE_SOURCE, ID_APPLI, LIBELLE_APPLI, TYPE_TRANSFERT,
       CASE WHEN N < 10 THEN '<10' ELSE TO_CHAR(N) END AS N_LIGNES,
       CASE WHEN N < 10 THEN '<10' ELSE TO_CHAR(A1) END AS PREMIERE_ANNEE,
       CASE WHEN N < 10 THEN '<10' ELSE TO_CHAR(A2) END AS DERNIERE_ANNEE
FROM g
ORDER BY TABLE_SOURCE, ID_APPLI, LIBELLE_APPLI, TYPE_TRANSFERT;
