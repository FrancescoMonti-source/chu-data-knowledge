-- id: 20261015-separateur-lignes-grp
-- system: cora
-- person_data: masked
-- purpose: pour les RSS MCO à plusieurs RUM finis de janvier à août 2026, trouver ce qui sépare les lignes des RUM dans TB_SYNTH_RSS.LIGNES_GRP, pour lire les DAS de tous les RSS à M8 et pas seulement ceux à un seul RUM (étape 2 du plan)
-- Oracle, schéma CORA_REC. Aucun contenu de LIGNES_GRP ne sort : seulement des longueurs et des codes de caractères de contrôle.
-- Longueur attendue de la 1re ligne : 205 + 8 nDA + 8 nDAD + 32 nZA, lus en 134-140 (20261015-forme-lignes-grp-resultat).
-- Début de la 2e ligne : 2e occurrence des 12 premiers caractères (version de classification, CMD, GHM, filler, format du RSS), communs aux RUM d'un RSS.
-- ECART : position du début de la 2e ligne moins (longueur attendue + 1) ; 0 = pas de séparateur, 1 ou 2 = séparateur d'autant de caractères ; 'sans_2e_ligne' si les 12 caractères ne reviennent pas.
-- SEPARATEUR : codes ASCII des caractères de l'écart s'ils sont des caractères de contrôle (code < 32) ; 'imprimable' sinon ; 'aucun' si l'écart vaut 0.
-- N_RSS_LONGUEUR_TOTALE_OK : la longueur totale de LIGNES_GRP vaut NB_RUM fois (longueur de la 1re ligne + écart), à 2 caractères près ; seulement un repère, les RUM n'ont pas tous la même longueur.
-- Règle 4 : pas de colonne total ni de ligne total.
WITH r AS (
  SELECT s.NB_RUM,
         DBMS_LOB.GETLENGTH(s.LIGNES_GRP) AS LONG_TOT,
         DBMS_LOB.SUBSTR(s.LIGNES_GRP, 4000, 1) AS DEBUT
  FROM CORA_REC.TB_SYNTH_RSS s
  WHERE s.DATE_FIN >= DATE '2026-01-01'
    AND s.DATE_FIN <  DATE '2026-09-01'
    AND s.NB_RUM > 1
    AND s.LIGNES_GRP IS NOT NULL
    AND DBMS_LOB.GETLENGTH(s.LIGNES_GRP) > 0
),
p AS (
  SELECT NB_RUM, LONG_TOT, DEBUT,
         CASE WHEN REGEXP_LIKE(SUBSTR(DEBUT, 134, 7), '^[0-9]{7}$')
              THEN 205 + 8 * TO_NUMBER(SUBSTR(DEBUT, 134, 2)) + 8 * TO_NUMBER(SUBSTR(DEBUT, 136, 2)) + 32 * TO_NUMBER(SUBSTR(DEBUT, 138, 3)) END AS L1,
         INSTR(DEBUT, SUBSTR(DEBUT, 1, 12), 2) AS P2
  FROM r
),
c AS (
  SELECT NB_RUM, LONG_TOT, L1, P2,
         CASE WHEN L1 IS NULL OR P2 = 0 THEN NULL ELSE P2 - L1 - 1 END AS ECART_N,
         CASE WHEN L1 IS NOT NULL AND P2 - L1 - 1 BETWEEN 1 AND 2 THEN SUBSTR(DEBUT, L1 + 1, P2 - L1 - 1) END AS SEP
  FROM p
),
d AS (
  SELECT NB_RUM, LONG_TOT, L1, ECART_N,
         CASE WHEN L1 IS NULL THEN 'nda_illisible'
              WHEN P2 = 0 THEN 'sans_2e_ligne'
              WHEN ECART_N BETWEEN 0 AND 2 THEN TO_CHAR(ECART_N)
              ELSE 'autre' END AS ECART,
         CASE WHEN ECART_N = 0 THEN 'aucun'
              WHEN SEP IS NULL THEN 'sans_objet'
              WHEN ASCII(SUBSTR(SEP, 1, 1)) < 32 AND (LENGTH(SEP) = 1 OR ASCII(SUBSTR(SEP, 2, 1)) < 32)
                THEN TO_CHAR(ASCII(SUBSTR(SEP, 1, 1))) || CASE WHEN LENGTH(SEP) = 2 THEN '+' || TO_CHAR(ASCII(SUBSTR(SEP, 2, 1))) END
              ELSE 'imprimable' END AS SEPARATEUR
  FROM c
),
agg AS (
  SELECT ECART, SEPARATEUR,
         COUNT(*) AS NB,
         SUM(CASE WHEN ECART_N IS NOT NULL AND ABS(LONG_TOT - NB_RUM * (L1 + ECART_N)) <= 2 THEN 1 ELSE 0 END) AS NB_TOT_OK
  FROM d
  GROUP BY ECART, SEPARATEUR
)
SELECT '20261015-separateur-lignes-grp' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ECART,
       SEPARATEUR,
       CASE WHEN NB < 10 THEN '<10' ELSE TO_CHAR(NB) END AS N_RSS,
       CASE WHEN NB_TOT_OK < 10 THEN '<10' WHEN NB - NB_TOT_OK BETWEEN 1 AND 9 THEN 'masqué' ELSE TO_CHAR(NB_TOT_OK) END AS N_RSS_LONGUEUR_TOTALE_OK
FROM agg
ORDER BY ECART, SEPARATEUR;
