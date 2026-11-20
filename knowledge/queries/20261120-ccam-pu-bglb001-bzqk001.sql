-- id: 20261120-ccam-pu-bglb001-bzqk001
-- system: cora
-- person_data: no-person-data
-- purpose: lire le prix unitaire CCAM de BGLB001 (injection intravitréenne) et de BZQK001 (OCT), par activité, phase et grille, pour valoriser en consultation externe (ACE) les séances de 20261120-z512-h353-seances-2026 (étape 4 du plan)
-- Oracle, schéma CORA_CCAM_CNAM (CCAM de la CNAM, schemas-cwprod-visibles). R_PU_BASE : AAP_COD = acte + activité + phase, APDT_MODIF = date de la version, GRILLE_COD = grille tarifaire, PU_BASE = prix unitaire de base. Toutes les versions depuis 2023, pour voir celle de 2026.
SELECT '20261120-ccam-pu-bglb001-bzqk001' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       TRIM(p.AAP_COD) AS AAP_COD,
       TO_CHAR(p.APDT_MODIF, 'YYYY-MM-DD') AS APDT_MODIF,
       p.GRILLE_COD,
       p.PU_BASE
FROM CORA_CCAM_CNAM.R_PU_BASE p
WHERE (p.AAP_COD LIKE 'BGLB001%' OR p.AAP_COD LIKE 'BZQK001%')
  AND p.APDT_MODIF >= DATE '2023-01-01'
ORDER BY TRIM(p.AAP_COD), p.GRILLE_COD, p.APDT_MODIF;
