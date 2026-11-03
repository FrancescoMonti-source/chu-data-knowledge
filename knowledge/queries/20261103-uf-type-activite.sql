-- id: 20261103-uf-type-activite
-- system: cora
-- person_data: no-person-data
-- purpose: compter les UF de TB_UNITE par type d'activité (TYPE_ACTIVITE, libellé de TB_THES_TYPE_ACTIVITE) : seul attribut des UF qui s'approche d'une spécialité, à comparer à ce que Pierre entend par spécialité (issue « schemas-cora »)
-- Oracle, schéma CORA_REC. Référentiels seulement (TB_UNITE, TB_THES_TYPE_ACTIVITE), aucune donnée de personne ni de séjour : un effectif de UF, pas de personnes. Par prudence, tout effectif de 1 à 9 sort <10 (règle 3).
-- Les UF dont TYPE_ACTIVITE est vide ou absent du thésaurus sont comptées à part (code vide ou libellé « inconnu »).
SELECT '20261103-uf-type-activite' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       NVL(TRIM(u.TYPE_ACTIVITE), '(vide)') AS TYPE_ACTIVITE,
       NVL(MAX(t.LIB_TYPE_ACTIVITE), 'inconnu du thésaurus') AS LIBELLE,
       u.ACTIF AS UF_ACTIVE,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE TO_CHAR(COUNT(*)) END AS N_UF
FROM CORA_REC.TB_UNITE u
LEFT JOIN CORA_REC.TB_THES_TYPE_ACTIVITE t ON TRIM(t.CODE_TYPE_ACTIVITE) = TRIM(u.TYPE_ACTIVITE)
GROUP BY NVL(TRIM(u.TYPE_ACTIVITE), '(vide)'), u.ACTIF
ORDER BY 4, 6;
