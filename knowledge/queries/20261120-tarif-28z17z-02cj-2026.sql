-- id: 20261120-tarif-28z17z-02cj-2026
-- system: cora
-- person_data: no-person-data
-- purpose: lire les tarifs GHS valides de janvier à septembre 2026 du GHM 28Z17Z (séances de chimiothérapie pour affection non tumorale) et des GHM chirurgicaux ophtalmologiques en ambulatoire 02C..J, pour valoriser les séances de 20261120-z512-h353-seances-2026 au tarif actuel et recodées (étape 3 du plan)
-- Oracle, schéma CORA_REC. Une ligne par couple GHM + GHS et par période de validité (tarif-ghs-par-ghm-et-code-ghs) ; N_LIGNES, MIN_PRIX et MAX_PRIX montrent un couple qui aurait deux lignes pour la même période.
SELECT '20261120-tarif-28z17z-02cj-2026' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       TRIM(t.GHS) AS GHM,
       TRIM(t.CODE_GHS) AS GHS,
       TO_CHAR(t.DATE_DEBUT, 'YYYY-MM-DD') AS DATE_DEBUT,
       TO_CHAR(t.DATE_FIN, 'YYYY-MM-DD') AS DATE_FIN,
       COUNT(t.PRIX) AS N_LIGNES,
       MIN(t.PRIX) AS MIN_PRIX,
       MAX(t.PRIX) AS MAX_PRIX
FROM CORA_REC.PMSI_LIB_GHS_TARIF t
WHERE (TRIM(t.GHS) = '28Z17Z' OR TRIM(t.GHS) LIKE '02C__J')
  AND t.DATE_DEBUT < DATE '2026-10-01'
  AND t.DATE_FIN >= DATE '2026-01-01'
GROUP BY TRIM(t.GHS), TRIM(t.CODE_GHS), t.DATE_DEBUT, t.DATE_FIN
ORDER BY TRIM(t.GHS), TRIM(t.CODE_GHS), t.DATE_DEBUT;
