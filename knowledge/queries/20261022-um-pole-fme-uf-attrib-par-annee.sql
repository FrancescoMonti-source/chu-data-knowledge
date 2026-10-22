-- id: 20261022-um-pole-fme-uf-attrib-par-annee
-- system: cora
-- person_data: masked
-- purpose: voir, pour les UM du pôle femme-mère-enfant (code de pôle menf), quelle UF est attribuée aux RUM chaque année, pour repérer les changements de numéro d'UF et d'UM (étape 4 du plan)
-- Oracle, schéma CORA_REC. RUM terminés de janvier à septembre de 2022 à 2026 dans une UM rattachée au pôle menf (TB_UNITE_POLE_UM) à la date de fin du RUM. Le code et le libellé de l'UM et de l'UF sont ceux du thésaurus : des structures, pas des personnes.
-- UF non renseignée (ID_UF_ATTRIB vide) : CODE_UF et LIBELLE_UF vides.
-- Masquage : chaque effectif < 10 sort en <10. Aucune ligne de total : rien ne permet de recalculer une case masquée.
WITH um_pole AS (
  SELECT DISTINCT pum.ID_UNITE_MED, pum.DATE_DEBUT, pum.DATE_FIN
  FROM CORA_REC.TB_UNITE_POLE_UM pum
  JOIN CORA_REC.TB_UNITE_POLE p ON p.ID_POLE = pum.ID_POLE
  WHERE TRIM(p.CODE_POLE) = 'menf'
), agr AS (
  SELECT EXTRACT(YEAR FROM r.DATE_FIN_RUM) AS ANNEE, r.ID_UNITE_MEDICALE, r.ID_UF_ATTRIB, COUNT(*) AS N
  FROM CORA_REC.TB_SYNTH_RUM r
  WHERE r.DATE_FIN_RUM >= DATE '2022-01-01'
    AND r.DATE_FIN_RUM < DATE '2027-01-01'
    AND EXTRACT(MONTH FROM r.DATE_FIN_RUM) <= 9
    AND EXISTS (SELECT 1 FROM um_pole f WHERE f.ID_UNITE_MED = r.ID_UNITE_MEDICALE
                AND (f.DATE_DEBUT IS NULL OR f.DATE_DEBUT <= r.DATE_FIN_RUM)
                AND (f.DATE_FIN IS NULL OR f.DATE_FIN >= r.DATE_FIN_RUM))
  GROUP BY EXTRACT(YEAR FROM r.DATE_FIN_RUM), r.ID_UNITE_MEDICALE, r.ID_UF_ATTRIB
)
SELECT '20261022-um-pole-fme-uf-attrib-par-annee' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       a.ANNEE, TRIM(um.CODE_UNITE_MED) AS CODE_UM, TRIM(um.LIBELLE_UNITE_MED) AS LIBELLE_UM,
       TRIM(uf.CODE_UNITE) AS CODE_UF, TRIM(uf.LIBELLE_UNITE) AS LIBELLE_UF,
       CASE WHEN a.N < 10 THEN '<10' ELSE TO_CHAR(a.N) END AS N_RUM
FROM agr a
LEFT JOIN CORA_REC.TB_UNITE_MEDICALE um ON um.ID_UNITE_MED = a.ID_UNITE_MEDICALE
LEFT JOIN CORA_REC.TB_UNITE uf ON uf.ID_UNITE = a.ID_UF_ATTRIB
ORDER BY CODE_UM, CODE_UF, a.ANNEE;
