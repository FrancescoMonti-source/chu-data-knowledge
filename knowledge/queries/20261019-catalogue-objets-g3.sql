-- id: 20261019-catalogue-objets-g3
-- system: cora
-- person_data: no-person-data
-- purpose: chercher dans le catalogue de tous les schémas visibles les objets V_CCAM_NV/CCAM_NV, V_UTIL/UTIL, PMSI_CCAM_ICR et toute table ICR, FG_DP_EXCLUANT, CIM_DP_EXCLU, CIM_LISTE_DIAG_EXCLU et CIM_HIERARCHIE, avec leurs colonnes, pour trancher vue-v-util-remplace-util (V_UTIL présente, UTIL absente ?), icr-version-unique-couverture (une table ICR lisible ?), AM10 de referentiels-pmsi-dans-cora (les trois tables d'exclusion et CIM_HIERARCHIE.CMA existent-elles ?) et fixer les noms de colonnes de V_CCAM_NV avant ccam-nv-plusieurs-lignes-par-code
-- Oracle. Lit seulement le catalogue (ALL_OBJECTS, ALL_TABLES, ALL_TAB_COLUMNS) : aucune donnée de table, aucun nom ni identifiant de personnel. Schémas non maintenus par Oracle. Seuls les objets visibles par le compte de la personne apparaissent : un objet absent ici est absent ou illisible pour ce compte.
-- Deux niveaux : OBJET (propriétaire, type, état, NUM_ROWS d'après les statistiques Oracle pour une table), COLONNE (nom, type et longueur des colonnes de V_CCAM_NV, CCAM_NV, V_UTIL, UTIL, PMSI_CCAM_ICR et CIM_HIERARCHIE ; les colonnes des autres objets ne sont pas listées).
-- Noms cherchés (insensible à la casse) : V_CCAM_NV, CCAM_NV, V_UTIL, UTIL, FG_DP_EXCLUANT, CIM_DP_EXCLU, CIM_LISTE_DIAG_EXCLU, CIM_HIERARCHIE, PMSI_CCAM_ICR, et tout nom qui contient le mot ICR entre soulignés ou en bord de nom.
-- Si la requête sort aucune ligne OBJET pour un nom, il n'est pas visible : c'est la réponse.
WITH objets AS (
  SELECT o.OWNER, o.OBJECT_NAME AS OBJET, o.OBJECT_TYPE AS TYPE_OBJET, o.STATUS AS ETAT
  FROM ALL_OBJECTS o
  JOIN ALL_USERS u ON u.USERNAME = o.OWNER AND u.ORACLE_MAINTAINED = 'N'
  WHERE o.OBJECT_TYPE IN ('TABLE', 'VIEW', 'SYNONYM', 'MATERIALIZED VIEW')
    AND (UPPER(o.OBJECT_NAME) IN ('V_CCAM_NV', 'CCAM_NV', 'V_UTIL', 'UTIL', 'FG_DP_EXCLUANT', 'CIM_DP_EXCLU',
                                  'CIM_LISTE_DIAG_EXCLU', 'CIM_HIERARCHIE', 'PMSI_CCAM_ICR')
         OR REGEXP_LIKE(o.OBJECT_NAME, '(^|_)ICR(_|$)', 'i'))
)
SELECT '20261019-catalogue-objets-g3' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       r.NIVEAU, r.OWNER, r.OBJET, r.TYPE_OBJET, r.ETAT, r.COLONNE, r.TYPE_DONNEE, r.LONGUEUR, r.LIGNES_STATS
FROM (
  SELECT 'OBJET' AS NIVEAU, o.OWNER, o.OBJET, o.TYPE_OBJET, o.ETAT,
         NULL AS COLONNE, NULL AS TYPE_DONNEE, NULL AS LONGUEUR, t.NUM_ROWS AS LIGNES_STATS
  FROM objets o
  LEFT JOIN ALL_TABLES t ON t.OWNER = o.OWNER AND t.TABLE_NAME = o.OBJET AND o.TYPE_OBJET = 'TABLE'
  UNION ALL
  SELECT 'COLONNE', o.OWNER, o.OBJET, o.TYPE_OBJET, NULL,
         c.COLUMN_NAME, c.DATA_TYPE, c.DATA_LENGTH, NULL
  FROM objets o
  JOIN ALL_TAB_COLUMNS c ON c.OWNER = o.OWNER AND c.TABLE_NAME = o.OBJET
  WHERE o.TYPE_OBJET IN ('TABLE', 'VIEW', 'MATERIALIZED VIEW')
    AND UPPER(o.OBJET) IN ('V_CCAM_NV', 'CCAM_NV', 'V_UTIL', 'UTIL', 'PMSI_CCAM_ICR', 'CIM_HIERARCHIE')
) r
ORDER BY r.OWNER, r.OBJET, CASE r.NIVEAU WHEN 'OBJET' THEN 1 ELSE 2 END, r.COLONNE;
