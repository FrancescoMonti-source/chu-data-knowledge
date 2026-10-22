-- id: 20261022-um-pole-fme-uf-trois-sources
-- system: cora
-- person_data: masked
-- purpose: pour les UM du pôle femme-mère-enfant (menf), voir quelle UF donnent UF_ATTRIB, ID_UNITE_HEBERG et ID_UNITE_RESP_MED des RUM, par année, pour choisir la colonne qui porte l'UF et repérer les changements de numéro (étape 3 du plan revu)
-- Oracle, schéma CORA_REC. RUM terminés de janvier à septembre de 2022 à 2026 dans une UM rattachée au pôle menf (TB_UNITE_POLE_UM) à la date de fin du RUM. Codes et libellés de structures, pas de personnes.
-- SOURCE : UF_ATTRIB (code, joint par TRIM(CODE_UNITE)), ID_UNITE_HEBERG ou ID_UNITE_RESP_MED (identifiants, joints par ID_UNITE). CODE_UF et LIBELLE_UF vides : valeur absente ou sans ligne dans TB_UNITE.
-- Masquage : chaque effectif < 10 sort en <10. Aucune ligne de total : rien ne permet de recalculer une case masquée.
WITH um_pole AS (
  SELECT DISTINCT pum.ID_UNITE_MED, pum.DATE_DEBUT, pum.DATE_FIN
  FROM CORA_REC.TB_UNITE_POLE_UM pum
  JOIN CORA_REC.TB_UNITE_POLE p ON p.ID_POLE = pum.ID_POLE
  WHERE TRIM(p.CODE_POLE) = 'menf'
), rum AS (
  SELECT EXTRACT(YEAR FROM r.DATE_FIN_RUM) AS ANNEE, r.ID_UNITE_MEDICALE,
         TRIM(r.UF_ATTRIB) AS UF_ATTRIB, r.ID_UNITE_HEBERG, r.ID_UNITE_RESP_MED
  FROM CORA_REC.TB_SYNTH_RUM r
  WHERE r.DATE_FIN_RUM >= DATE '2022-01-01'
    AND r.DATE_FIN_RUM < DATE '2027-01-01'
    AND EXTRACT(MONTH FROM r.DATE_FIN_RUM) <= 9
    AND EXISTS (SELECT 1 FROM um_pole f WHERE f.ID_UNITE_MED = r.ID_UNITE_MEDICALE
                AND (f.DATE_DEBUT IS NULL OR f.DATE_DEBUT <= r.DATE_FIN_RUM)
                AND (f.DATE_FIN IS NULL OR f.DATE_FIN >= r.DATE_FIN_RUM))
), longue AS (
  SELECT ANNEE, ID_UNITE_MEDICALE, 'UF_ATTRIB' AS SOURCE, TO_CHAR(UF_ATTRIB) AS CLE FROM rum
  UNION ALL
  SELECT ANNEE, ID_UNITE_MEDICALE, 'ID_UNITE_HEBERG', TO_CHAR(ID_UNITE_HEBERG) FROM rum
  UNION ALL
  SELECT ANNEE, ID_UNITE_MEDICALE, 'ID_UNITE_RESP_MED', TO_CHAR(ID_UNITE_RESP_MED) FROM rum
), agr AS (
  SELECT ANNEE, ID_UNITE_MEDICALE, SOURCE, CLE, COUNT(*) AS N
  FROM longue
  GROUP BY ANNEE, ID_UNITE_MEDICALE, SOURCE, CLE
)
SELECT '20261022-um-pole-fme-uf-trois-sources' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       a.ANNEE, a.SOURCE, TRIM(um.CODE_UNITE_MED) AS CODE_UM, TRIM(um.LIBELLE_UNITE_MED) AS LIBELLE_UM,
       TRIM(uf.CODE_UNITE) AS CODE_UF, TRIM(uf.LIBELLE_UNITE) AS LIBELLE_UF,
       CASE WHEN a.N < 10 THEN '<10' ELSE TO_CHAR(a.N) END AS N_RUM
FROM agr a
LEFT JOIN CORA_REC.TB_UNITE_MEDICALE um ON um.ID_UNITE_MED = a.ID_UNITE_MEDICALE
LEFT JOIN CORA_REC.TB_UNITE uf ON (a.SOURCE = 'UF_ATTRIB' AND TRIM(uf.CODE_UNITE) = a.CLE)
                               OR (a.SOURCE <> 'UF_ATTRIB' AND TO_CHAR(uf.ID_UNITE) = a.CLE)
ORDER BY a.SOURCE, CODE_UM, CODE_UF, a.ANNEE;
