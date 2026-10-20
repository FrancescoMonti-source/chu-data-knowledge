-- id: 20261019-ccam-nv-vue
-- system: cora
-- person_data: no-person-data
-- purpose: mesurer, dans le référentiel CORA_REC.V_CCAM_NV seul, combien de codes portent plusieurs lignes (toutes lignes, puis par valeur de TYPE, dont 'A'), pour trancher la moitié « référentiel » de ccam-nv-plusieurs-lignes-par-code (réfuté si CODE est unique pour TYPE = 'A' ; confirmé sinon, et le maximum de lignes par code dit l'ampleur) ; première des deux requêtes qui remplacent 20261019-ccam-nv-doublons (la jointure aux actes est dans 20261019-ccam-nv-actes)
-- Oracle 11g, schéma CORA_REC. Colonnes CODE et TYPE (VARCHAR2) de V_CCAM_NV vérifiées par 20261019-catalogue-objets-g3 (niveau COLONNE). Référentiel de codes d'actes : aucune donnée de personne, comptages de lignes parfois inférieurs à 10 sans enjeu de confidentialité, donc pas de masquage.
-- Les colonnes de comptage ne s'appellent pas N_… ni NB_… : le garde-fou du script les prendrait pour des effectifs de personnes.
-- Une ligne par valeur de TYPE (niveau TYPE, '(vide)' si TYPE vide) et une ligne 'TOUS' (niveau TOUS, toutes lignes). LIGNES : lignes de la vue ; CODES : codes distincts (TRIM(CODE)) ; CODES_PLUSIEURS : codes à plus d'une ligne ; MAX_LIGNES_PAR_CODE : maximum ; LIGNES_CODE_VIDE : lignes dont CODE est vide.
WITH m AS (
  SELECT NVL(TRIM(v.TYPE), '(vide)') AS TYPE_LIGNE, TRIM(v.CODE) AS CODE, COUNT(*) AS L
  FROM CORA_REC.V_CCAM_NV v
  GROUP BY NVL(TRIM(v.TYPE), '(vide)'), TRIM(v.CODE)
),
mt AS (
  SELECT TRIM(v.CODE) AS CODE, COUNT(*) AS L
  FROM CORA_REC.V_CCAM_NV v
  GROUP BY TRIM(v.CODE)
),
r AS (
  SELECT 'TOUS' AS NIVEAU, 'TOUS' AS TYPE_LIGNE,
         SUM(L) AS LIGNES, COUNT(*) AS CODES,
         SUM(CASE WHEN L > 1 THEN 1 ELSE 0 END) AS CODES_PLUSIEURS,
         MAX(L) AS MAX_LIGNES,
         SUM(CASE WHEN CODE IS NULL THEN L ELSE 0 END) AS LIGNES_VIDES
  FROM mt
  UNION ALL
  SELECT 'TYPE', TYPE_LIGNE,
         SUM(L), COUNT(*),
         SUM(CASE WHEN L > 1 THEN 1 ELSE 0 END),
         MAX(L),
         SUM(CASE WHEN CODE IS NULL THEN L ELSE 0 END)
  FROM m
  GROUP BY TYPE_LIGNE
)
SELECT '20261019-ccam-nv-vue' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       NIVEAU, TYPE_LIGNE,
       TO_CHAR(LIGNES) AS LIGNES,
       TO_CHAR(CODES) AS CODES,
       TO_CHAR(CODES_PLUSIEURS) AS CODES_PLUSIEURS,
       TO_CHAR(MAX_LIGNES) AS MAX_LIGNES_PAR_CODE,
       TO_CHAR(LIGNES_VIDES) AS LIGNES_CODE_VIDE
FROM r
ORDER BY NIVEAU DESC, TYPE_LIGNE;
