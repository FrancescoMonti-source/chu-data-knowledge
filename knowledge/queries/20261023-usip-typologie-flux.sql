-- id: 20261023-usip-typologie-flux
-- system: cora
-- person_data: masked
-- purpose: décrire les patients qui passent par l'USIP (UM 6281) depuis son ouverture, et ceux de l'UF 6284 qui la précédait, par période : âge, sexe, CMD, type et racine de GHM, UM avant et après le passage, modes d'entrée et de sortie, nuits passées dans l'unité, nombre de passages, réanimation chirurgicale dans le même RSS, durée du RSS (étape 2 du plan)
-- Oracle, schéma CORA_REC. Unité : le RSS (TB_SYNTH_RSS) qui a au moins un RUM (TB_SYNTH_RUM) dans l'UM 6281 ou 6284 (TB_UNITE_MEDICALE.CODE_UNITE_MED, par ID_UNITE_MEDICALE) ; UNITE = '6281 USIP' si le RSS a un RUM dans 6281, sinon '6284 SI'. PERIODE d'après DATE_FIN du RSS, d'octobre à août : 2022-10 à 2023-08, 2023-10 à 2024-08, 2024-10 à 2025-08, 2025-10 à 2026-08 ; les mois de septembre sont écartés (choix de l'enquête usip-parcours ; septembre et octobre 2026 ne sont pas encore groupés, rss-mois-recents-non-codes).
-- Patient : TB_SYNTH_RSS.ID_SEJOUR → TB_SEJOUR.ID_PATIENT → TB_PATIENT (joindre-rss-par-id-sejour). Âge recalculé au début du RSS (age-entree-a-recalculer). SEXE de TB_PATIENT lu tel quel.
-- RUM du RSS rangés par DATE_DEBUT_RUM, DATE_FIN_RUM, ID_RUM. UM_AVANT : UM du RUM qui précède le premier RUM de l'unité, ou 'aucune (début du RSS)'. UM_APRES : UM du RUM qui suit le dernier RUM de l'unité, ou 'aucune (fin du RSS)'. NUITS_UNITE : somme de DATE_FIN_RUM − DATE_DEBUT_RUM des RUM de l'unité. REA_CHIR_MEME_RSS : un RUM dans l'UM 6282, 6283, 6285, 6288 ou 6289 (réanimation chirurgicale, 20261023-usip-uf-structure). NUITS_RSS : DATE_FIN − DATE_DEBUT du RSS (duree-sejour-journees-ou-nuitees). MODE_ENTREE et MODE_SORTIE du RSS, suivis de la provenance ou de la destination (vide si aucune) ; 9 = décès.
-- Sortie longue : une ligne par PERIODE, UNITE, AXE et MODALITE ; LIBELLE : libellé de l'UM pour UM_AVANT et UM_APRES. N_RSS : RSS.
-- Masquage : dans chaque PERIODE, UNITE et AXE, les modalités de moins de 10 RSS sont regroupées en « autres (<10 chacune) » ; tout effectif < 10 sort en <10. Suppression secondaire (règle 4) : chaque axe a le même total, qu'un axe sans case masquée donne ; quand les cases masquées d'une PERIODE, UNITE et AXE totalisent de 1 à 9, la plus grande case du groupe sort aussi en « masqué ». Aucune ligne de total.
WITH um_u AS (
  SELECT ID_UNITE_MED, TRIM(CODE_UNITE_MED) AS CODE_UM, TRIM(LIBELLE_UNITE_MED) AS LIBELLE_UM
  FROM CORA_REC.TB_UNITE_MEDICALE
),
rss AS (
  SELECT r.ID_RSS, r.ID_SEJOUR, r.DATE_DEBUT, r.DATE_FIN,
         TRIM(r.CODE_CMD) AS CMD, TRIM(r.CODE_GHM) AS GHM,
         TRIM(r.MODE_ENTREE) AS ME, TRIM(r.CODE_PROVENANCE) AS PROV,
         TRIM(r.MODE_SORTIE) AS MS, TRIM(r.CODE_DESTINATION) AS DEST,
         CASE WHEN r.DATE_FIN >= DATE '2022-10-01' AND r.DATE_FIN < DATE '2023-09-01' THEN '2022-10 à 2023-08'
              WHEN r.DATE_FIN >= DATE '2023-10-01' AND r.DATE_FIN < DATE '2024-09-01' THEN '2023-10 à 2024-08'
              WHEN r.DATE_FIN >= DATE '2024-10-01' AND r.DATE_FIN < DATE '2025-09-01' THEN '2024-10 à 2025-08'
              WHEN r.DATE_FIN >= DATE '2025-10-01' AND r.DATE_FIN < DATE '2026-09-01' THEN '2025-10 à 2026-08'
         END AS PERIODE
  FROM CORA_REC.TB_SYNTH_RSS r
  WHERE r.DATE_FIN >= DATE '2022-10-01' AND r.DATE_FIN < DATE '2026-09-01'
    AND EXTRACT(MONTH FROM r.DATE_FIN) <> 9
    AND EXISTS (SELECT 1 FROM CORA_REC.TB_SYNTH_RUM x JOIN um_u u ON u.ID_UNITE_MED = x.ID_UNITE_MEDICALE
                WHERE x.ID_RSS = r.ID_RSS AND u.CODE_UM IN ('6281', '6284'))
),
rums AS (
  SELECT ru.ID_RSS, u.CODE_UM, u.LIBELLE_UM,
         TRUNC(ru.DATE_FIN_RUM) - TRUNC(ru.DATE_DEBUT_RUM) AS NUITS,
         ROW_NUMBER() OVER (PARTITION BY ru.ID_RSS ORDER BY ru.DATE_DEBUT_RUM, ru.DATE_FIN_RUM, ru.ID_RUM) AS RG
  FROM CORA_REC.TB_SYNTH_RUM ru
  JOIN rss ON rss.ID_RSS = ru.ID_RSS
  LEFT JOIN um_u u ON u.ID_UNITE_MED = ru.ID_UNITE_MEDICALE
),
u AS (
  SELECT ID_RSS,
         MAX(CASE WHEN CODE_UM = '6281' THEN 1 ELSE 0 END) AS A_6281,
         MIN(CASE WHEN CODE_UM IN ('6281', '6284') THEN RG END) AS RG_PREMIER,
         MAX(CASE WHEN CODE_UM IN ('6281', '6284') THEN RG END) AS RG_DERNIER,
         SUM(CASE WHEN CODE_UM IN ('6281', '6284') THEN 1 ELSE 0 END) AS NB_PASSAGES,
         SUM(CASE WHEN CODE_UM IN ('6281', '6284') THEN NUITS ELSE 0 END) AS NUITS_UNITE,
         MAX(CASE WHEN CODE_UM IN ('6282', '6283', '6285', '6288', '6289') THEN 1 ELSE 0 END) AS A_REA
  FROM rums
  GROUP BY ID_RSS
),
b AS (
  SELECT rss.PERIODE,
         CASE WHEN u.A_6281 = 1 THEN '6281 USIP' ELSE '6284 SI' END AS UNITE,
         CASE WHEN pa.DATE_NAIS IS NULL THEN '(inconnu)'
              WHEN FLOOR((rss.DATE_DEBUT - pa.DATE_NAIS) / 365.25) < 18 THEN '0-17'
              WHEN FLOOR((rss.DATE_DEBUT - pa.DATE_NAIS) / 365.25) < 50 THEN '18-49'
              WHEN FLOOR((rss.DATE_DEBUT - pa.DATE_NAIS) / 365.25) < 65 THEN '50-64'
              WHEN FLOOR((rss.DATE_DEBUT - pa.DATE_NAIS) / 365.25) < 75 THEN '65-74'
              WHEN FLOOR((rss.DATE_DEBUT - pa.DATE_NAIS) / 365.25) < 85 THEN '75-84'
              ELSE '85+' END AS AGE,
         NVL(TRIM(pa.SEXE), '(vide)') AS SEXE,
         NVL(rss.CMD, '(vide)') AS CMD,
         NVL(SUBSTR(rss.GHM, 1, 1), '(vide)') AS TYPE_GHM,
         NVL(rss.CMD || SUBSTR(rss.GHM, 1, 3), '(vide)') AS RACINE_GHM,
         NVL(av.CODE_UM, 'aucune (début du RSS)') AS UM_AVANT, av.LIBELLE_UM AS LIB_AVANT,
         NVL(ap.CODE_UM, 'aucune (fin du RSS)') AS UM_APRES, ap.LIBELLE_UM AS LIB_APRES,
         NVL(rss.ME, '(vide)') || '-' || rss.PROV AS MODE_ENTREE,
         NVL(rss.MS, '(vide)') || '-' || rss.DEST AS MODE_SORTIE,
         CASE WHEN u.NUITS_UNITE <= 2 THEN TO_CHAR(u.NUITS_UNITE)
              WHEN u.NUITS_UNITE <= 4 THEN '3-4' WHEN u.NUITS_UNITE <= 9 THEN '5-9' ELSE '10+' END AS NUITS_UNITE,
         CASE WHEN u.NB_PASSAGES = 1 THEN '1' ELSE '2+' END AS NB_PASSAGES,
         CASE WHEN u.A_REA = 1 THEN 'oui' ELSE 'non' END AS REA_CHIR_MEME_RSS,
         CASE WHEN TRUNC(rss.DATE_FIN) - TRUNC(rss.DATE_DEBUT) = 0 THEN '0'
              WHEN TRUNC(rss.DATE_FIN) - TRUNC(rss.DATE_DEBUT) <= 2 THEN '1-2'
              WHEN TRUNC(rss.DATE_FIN) - TRUNC(rss.DATE_DEBUT) <= 5 THEN '3-5'
              WHEN TRUNC(rss.DATE_FIN) - TRUNC(rss.DATE_DEBUT) <= 9 THEN '6-9'
              WHEN TRUNC(rss.DATE_FIN) - TRUNC(rss.DATE_DEBUT) <= 19 THEN '10-19'
              ELSE '20+' END AS NUITS_RSS
  FROM rss
  JOIN u ON u.ID_RSS = rss.ID_RSS
  LEFT JOIN rums av ON av.ID_RSS = rss.ID_RSS AND av.RG = u.RG_PREMIER - 1
  LEFT JOIN rums ap ON ap.ID_RSS = rss.ID_RSS AND ap.RG = u.RG_DERNIER + 1
  LEFT JOIN CORA_REC.TB_SEJOUR s ON s.ID_SEJOUR = rss.ID_SEJOUR
  LEFT JOIN CORA_REC.TB_PATIENT pa ON pa.ID_PATIENT = s.ID_PATIENT
),
l AS (
  SELECT PERIODE, UNITE, 'AGE' AS AXE, AGE AS MODALITE, CAST(NULL AS VARCHAR2(100)) AS LIBELLE FROM b
  UNION ALL SELECT PERIODE, UNITE, 'SEXE', SEXE, NULL FROM b
  UNION ALL SELECT PERIODE, UNITE, 'CMD', CMD, NULL FROM b
  UNION ALL SELECT PERIODE, UNITE, 'TYPE_GHM', TYPE_GHM, NULL FROM b
  UNION ALL SELECT PERIODE, UNITE, 'RACINE_GHM', RACINE_GHM, NULL FROM b
  UNION ALL SELECT PERIODE, UNITE, 'UM_AVANT', UM_AVANT, LIB_AVANT FROM b
  UNION ALL SELECT PERIODE, UNITE, 'UM_APRES', UM_APRES, LIB_APRES FROM b
  UNION ALL SELECT PERIODE, UNITE, 'MODE_ENTREE', MODE_ENTREE, NULL FROM b
  UNION ALL SELECT PERIODE, UNITE, 'MODE_SORTIE', MODE_SORTIE, NULL FROM b
  UNION ALL SELECT PERIODE, UNITE, 'NUITS_UNITE', NUITS_UNITE, NULL FROM b
  UNION ALL SELECT PERIODE, UNITE, 'NB_PASSAGES', NB_PASSAGES, NULL FROM b
  UNION ALL SELECT PERIODE, UNITE, 'REA_CHIR_MEME_RSS', REA_CHIR_MEME_RSS, NULL FROM b
  UNION ALL SELECT PERIODE, UNITE, 'NUITS_RSS', NUITS_RSS, NULL FROM b
),
g AS (
  SELECT PERIODE, UNITE, AXE, MODALITE, MAX(LIBELLE) AS LIBELLE, COUNT(*) AS N
  FROM l
  GROUP BY PERIODE, UNITE, AXE, MODALITE
),
p AS (
  SELECT PERIODE, UNITE, AXE,
         CASE WHEN N < 10 THEN 'autres (<10 chacune)' ELSE MODALITE END AS MODALITE,
         CASE WHEN N < 10 THEN NULL ELSE LIBELLE END AS LIBELLE,
         N
  FROM g
),
q AS (
  SELECT PERIODE, UNITE, AXE, MODALITE, MAX(LIBELLE) AS LIBELLE, SUM(N) AS N
  FROM p
  GROUP BY PERIODE, UNITE, AXE, MODALITE
),
m AS (
  SELECT PERIODE, UNITE, AXE, MODALITE, LIBELLE, N,
         SUM(CASE WHEN N < 10 THEN N ELSE 0 END) OVER (PARTITION BY PERIODE, UNITE, AXE) AS CACHE,
         ROW_NUMBER() OVER (PARTITION BY PERIODE, UNITE, AXE ORDER BY N DESC, MODALITE) AS RANG
  FROM q
)
SELECT '20261023-usip-typologie-flux' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       PERIODE, UNITE, AXE, MODALITE, LIBELLE,
       CASE WHEN N < 10 THEN '<10' WHEN CACHE BETWEEN 1 AND 9 AND RANG = 1 THEN 'masqué' ELSE TO_CHAR(N) END AS N_RSS
FROM m
ORDER BY UNITE, AXE, PERIODE, N DESC, MODALITE;
