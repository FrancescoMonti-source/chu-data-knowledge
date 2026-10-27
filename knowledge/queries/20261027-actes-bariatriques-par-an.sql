-- id: 20261027-actes-bariatriques-par-an
-- system: cora
-- person_data: masked
-- purpose: compter, par code et par année depuis 2022, les séjours avec un acte de chirurgie bariatrique, et parmi eux ceux dont le patient avait déjà un tel acte dans un autre séjour des 90 jours précédents (réinterventions) ; sert à choisir les actes index et à repérer les réinterventions (étape 4 du plan, #113)
-- Oracle, schéma CORA_REC. Codes : la subdivision 07.03.02.09 de la CCAM 2026 (20261027-ccam-actes-obesite), plus tout code de V_CCAM_NV (TYPE = 'A', ccam-nv-une-ligne-par-code) dont le libellé long contient « obésité » (OB_SIT, pour l'accent). DANS_SUBDIVISION dit lequel des deux.
-- Séjour : l'acte est rattaché par TB_ACTE.ID_SEJOUR, le patient par TB_SEJOUR.ID_PATIENT ; J est le jour du premier acte du code dans le séjour. Actes lus depuis le 2021-10-01 pour voir les 90 jours qui précèdent 2022 ; années comptées de 2022 à aujourd'hui.
-- N_SEJ : séjours distincts du code et de l'année. N_SEJ_PRECEDE_90J : ceux dont le patient a un acte de la liste, n'importe quel code, dans un autre séjour, de J - 90 à J - 1.
-- Masquage : N_SEJ < 10 sort en <10 ; N_SEJ_PRECEDE_90J sort en <10 s'il est < 10, et en « masqué » si N_SEJ l'est ou si l'écart N_SEJ - N_SEJ_PRECEDE_90J est de 1 à 9 (le complément serait un petit effectif). Aucune ligne de total.
WITH codes AS (
  SELECT TRIM(v.CODE) AS CODE, v.LIBELLE_LONG,
         CASE WHEN TRIM(v.CODE) IN ('HFLC900', 'HFGC900', 'HGCC027', 'HGCA009', 'HFCC003', 'HFCA001', 'HFFC018',
                                    'HFFA011', 'HFFC004', 'HFFA001', 'HFMC006', 'HFMA010', 'HFMC007', 'HFMA009',
                                    'HFKC001', 'HFKA002', 'HFMC008', 'HFMA011', 'HFKA001')
              THEN 'oui' ELSE 'non' END AS DANS_SUBDIVISION
  FROM CORA_REC.V_CCAM_NV v
  WHERE v.TYPE = 'A'
    AND (TRIM(v.CODE) IN ('HFLC900', 'HFGC900', 'HGCC027', 'HGCA009', 'HFCC003', 'HFCA001', 'HFFC018',
                          'HFFA011', 'HFFC004', 'HFFA001', 'HFMC006', 'HFMA010', 'HFMC007', 'HFMA009',
                          'HFKC001', 'HFKA002', 'HFMC008', 'HFMA011', 'HFKA001')
         OR UPPER(v.LIBELLE_LONG) LIKE '%OB_SIT%')
),
act AS (
  SELECT a.ID_SEJOUR, s.ID_PATIENT, TRIM(a.CODE_ACTE) AS CODE, TRUNC(a.DATE_ACTE) AS J
  FROM CORA_REC.TB_ACTE a
  JOIN CORA_REC.TB_SEJOUR s ON s.ID_SEJOUR = a.ID_SEJOUR
  WHERE a.DATE_ACTE >= DATE '2021-10-01' AND a.DATE_ACTE < TRUNC(SYSDATE) + 1
    AND TRIM(a.CODE_ACTE) IN (SELECT CODE FROM codes)
),
sej AS (
  SELECT ID_SEJOUR, ID_PATIENT, CODE, MIN(J) AS J
  FROM act
  GROUP BY ID_SEJOUR, ID_PATIENT, CODE
),
flag AS (
  SELECT x.CODE, EXTRACT(YEAR FROM x.J) AS ANNEE,
         CASE WHEN EXISTS (SELECT 1 FROM act p
                           WHERE p.ID_PATIENT = x.ID_PATIENT AND p.ID_SEJOUR <> x.ID_SEJOUR
                             AND p.J >= x.J - 90 AND p.J < x.J)
              THEN 1 ELSE 0 END AS PRECEDE_90J
  FROM sej x
  WHERE x.J >= DATE '2022-01-01'
),
agg AS (
  SELECT CODE, ANNEE, COUNT(*) AS N_SEJ, SUM(PRECEDE_90J) AS N_PRE
  FROM flag
  GROUP BY CODE, ANNEE
)
SELECT '20261027-actes-bariatriques-par-an' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       c.CODE, c.DANS_SUBDIVISION, c.LIBELLE_LONG, g.ANNEE,
       CASE WHEN g.N_SEJ < 10 THEN '<10' ELSE TO_CHAR(g.N_SEJ) END AS N_SEJ,
       CASE WHEN g.N_SEJ IS NULL THEN NULL
            WHEN g.N_SEJ < 10 OR (g.N_SEJ - g.N_PRE BETWEEN 1 AND 9) THEN 'masqué'
            WHEN g.N_PRE < 10 THEN '<10'
            ELSE TO_CHAR(g.N_PRE) END AS N_SEJ_PRECEDE_90J
FROM codes c
LEFT JOIN agg g ON g.CODE = c.CODE
ORDER BY c.DANS_SUBDIVISION DESC, c.CODE, g.ANNEE;
