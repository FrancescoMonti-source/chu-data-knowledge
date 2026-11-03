-- id: 20261026-um-uf-hebergeante-par-annee-tous-poles
-- system: cora
-- person_data: masked
-- purpose: pour toutes les UM, voir par année quelle UF héberge les RUM (ID_UNITE_HEBERG) et si l'UF hébergeante d'une même UM change d'une année à l'autre, pour savoir si uf-hebergeante-change-en-2026 vaut hors du pôle FME et avant 2026 (enquête uf-um-rum, étape 5)
-- Oracle, schéma CORA_REC. RUM terminés de janvier à septembre de 2022 à 2026, tous pôles. Codes et libellés de structures, pas de personnes.
-- Masquage : chaque effectif < 10 sort en <10 ; une UF hébergeante qui n'apparaît que sous <10 une année peut donc manquer d'un détail. Aucune ligne de total : rien ne permet de recalculer une case masquée.
WITH rum AS (
  SELECT EXTRACT(YEAR FROM r.DATE_FIN_RUM) AS ANNEE, r.ID_UNITE_MEDICALE, r.ID_UNITE_HEBERG
  FROM CORA_REC.TB_SYNTH_RUM r
  WHERE r.DATE_FIN_RUM >= DATE '2022-01-01'
    AND r.DATE_FIN_RUM < DATE '2027-01-01'
    AND EXTRACT(MONTH FROM r.DATE_FIN_RUM) <= 9
), agr AS (
  SELECT ANNEE, ID_UNITE_MEDICALE, ID_UNITE_HEBERG, COUNT(*) AS N
  FROM rum
  GROUP BY ANNEE, ID_UNITE_MEDICALE, ID_UNITE_HEBERG
)
SELECT '20261026-um-uf-hebergeante-par-annee-tous-poles' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       a.ANNEE, TRIM(um.CODE_UNITE_MED) AS CODE_UM, TRIM(um.LIBELLE_UNITE_MED) AS LIBELLE_UM,
       TRIM(uf.CODE_UNITE) AS CODE_UF, TRIM(uf.LIBELLE_UNITE) AS LIBELLE_UF,
       CASE WHEN a.N < 10 THEN '<10' ELSE TO_CHAR(a.N) END AS N_RUM
FROM agr a
LEFT JOIN CORA_REC.TB_UNITE_MEDICALE um ON um.ID_UNITE_MED = a.ID_UNITE_MEDICALE
LEFT JOIN CORA_REC.TB_UNITE uf ON uf.ID_UNITE = a.ID_UNITE_HEBERG
ORDER BY CODE_UM, CODE_UF, a.ANNEE;
