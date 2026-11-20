-- id: 20261120-uf-bloc-site-par-annee-application
-- system: cora
-- person_data: masked
-- purpose: pour les actes portés par un mouvement des UF 5508, 6510 et 6196, savoir par année et par application d'origine (flux CPage ou saisie dans CORA) si le site de l'acte est renseigné, s'il est le site de l'UF, un site paramétré bloc ou un autre site : le site manque-t-il avant 2026, ce qui justifierait de passer par l'UF du mouvement (issue #131, question 1 ; suite de 20261120-uf-bloc-filtre-mouvement-site)
-- Oracle, schéma CORA_REC. Actes datés de 2022 à aujourd'hui. APPLICATION : ID_APPLICATION_TRANSFERT en texte, 'aucune' s'il est vide. Quatre catégories qui partagent les actes de chaque ligne : N_SITE_VIDE (ID_SITE vide), N_SITE_EGAL_UF (le code du site est celui de l'UF), N_SITE_BLOC_AUTRE (site paramétré bloc, BLOC = 'O', autre que le site de l'UF), N_SITE_NON_BLOC_AUTRE (tout autre site).
-- Masquage : chaque effectif < 10 sort en <10. Pas de total ni d'effectif d'ensemble : une cellule masquée ne se recalcule pas.
SELECT '20261120-uf-bloc-site-par-annee-application' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       TO_CHAR(a.DATE_ACTE, 'YYYY') AS ANNEE,
       TRIM(m.ID_UNITE_M) AS CODE_UF,
       NVL(TRIM(TO_CHAR(a.ID_APPLICATION_TRANSFERT)), 'aucune') AS APPLICATION,
       CASE WHEN SUM(CASE WHEN a.ID_SITE IS NULL THEN 1 ELSE 0 END) < 10 THEN '<10'
            ELSE TO_CHAR(SUM(CASE WHEN a.ID_SITE IS NULL THEN 1 ELSE 0 END)) END AS N_SITE_VIDE,
       CASE WHEN SUM(CASE WHEN a.ID_SITE IS NOT NULL AND TRIM(si.CODE_SITE) = TRIM(m.ID_UNITE_M) THEN 1 ELSE 0 END) < 10 THEN '<10'
            ELSE TO_CHAR(SUM(CASE WHEN a.ID_SITE IS NOT NULL AND TRIM(si.CODE_SITE) = TRIM(m.ID_UNITE_M) THEN 1 ELSE 0 END)) END AS N_SITE_EGAL_UF,
       CASE WHEN SUM(CASE WHEN a.ID_SITE IS NOT NULL AND TRIM(si.CODE_SITE) <> TRIM(m.ID_UNITE_M) AND si.BLOC = 'O' THEN 1 ELSE 0 END) < 10 THEN '<10'
            ELSE TO_CHAR(SUM(CASE WHEN a.ID_SITE IS NOT NULL AND TRIM(si.CODE_SITE) <> TRIM(m.ID_UNITE_M) AND si.BLOC = 'O' THEN 1 ELSE 0 END)) END AS N_SITE_BLOC_AUTRE,
       CASE WHEN SUM(CASE WHEN a.ID_SITE IS NOT NULL AND TRIM(si.CODE_SITE) <> TRIM(m.ID_UNITE_M) AND NVL(si.BLOC, 'N') <> 'O' THEN 1 ELSE 0 END) < 10 THEN '<10'
            ELSE TO_CHAR(SUM(CASE WHEN a.ID_SITE IS NOT NULL AND TRIM(si.CODE_SITE) <> TRIM(m.ID_UNITE_M) AND NVL(si.BLOC, 'N') <> 'O' THEN 1 ELSE 0 END)) END AS N_SITE_NON_BLOC_AUTRE
FROM CORA_REC.TB_ACTE a
JOIN CORA_REC.TB_MVT m ON m.ID_MVT = a.ID_MVT
LEFT JOIN CORA_REC.TB_SITE si ON si.ID_SITE = a.ID_SITE
WHERE a.DATE_ACTE >= DATE '2022-01-01'
  AND TRIM(m.ID_UNITE_M) IN ('5508', '6510', '6196')
GROUP BY TO_CHAR(a.DATE_ACTE, 'YYYY'), TRIM(m.ID_UNITE_M), NVL(TRIM(TO_CHAR(a.ID_APPLICATION_TRANSFERT)), 'aucune')
ORDER BY TO_CHAR(a.DATE_ACTE, 'YYYY'), TRIM(m.ID_UNITE_M), NVL(TRIM(TO_CHAR(a.ID_APPLICATION_TRANSFERT)), 'aucune');
