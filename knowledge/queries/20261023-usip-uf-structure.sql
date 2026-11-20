-- id: 20261023-usip-uf-structure
-- system: cora
-- person_data: no-person-data
-- purpose: lire dans les thésaurus la structure des UF 6280 à 6289 (réanimation chirurgicale, surveillance continue post-opératoire 6284, USIP 6281) et des UF de chirurgie digestive (UM CGCD de redsan : 2605, 2615, 2642, 2663, 2668, 6300, 6310, 6311, 6320, 6330, 6340, 8840) : libellé, actif, drapeau REA, et chaque rattachement à une UM avec ses dates et son autorisation ; dit si l'UF 6281 existait avant l'USIP, à quelle UM PMSI ses RUM vont, et sous quelle autorisation (étape 1 du plan)
-- Oracle, schéma CORA_REC. Thésaurus d'unités : aucune donnée de personne. Jointure UF par ID_UNITE (TB_UNITE_M_UNITE.ID_UNITE = TB_UNITE.ID_UNITE) et UM par ID_UNITE_MED, colonnes lues dans le catalogue 20261022-uf-um-catalogue (enquête uf-um-rum, #100) ; CODE_UNITE se joint sans TRIM (codes-cora-pas-en-char), TRIM gardé par prudence.
-- Une ligne par UF et par rattachement UF-UM (une ligne à UM vide si l'UF n'a aucun rattachement) : CODE_UF, LIBELLE_UF, UF_ACTIF, UF_REA, CODE_UM, LIBELLE_UM, UM_ACTIF, DATE_DEBUT_LIEN, DATE_FIN_LIEN, TYPE_AUTORISATION (HIST_TYPE_AUTORISATION), DATE_EFFET_AUTORISATION, LITS_AUTORISES (HIST_NB_LIT_AUTORISATION).
SELECT '20261023-usip-uf-structure' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       TRIM(u.CODE_UNITE) AS CODE_UF,
       u.LIBELLE_UNITE AS LIBELLE_UF,
       u.ACTIF AS UF_ACTIF,
       u.REA AS UF_REA,
       TRIM(um.CODE_UNITE_MED) AS CODE_UM,
       um.LIBELLE_UNITE_MED AS LIBELLE_UM,
       um.ACTIF AS UM_ACTIF,
       TO_CHAR(l.DATE_DEBUT, 'YYYY-MM-DD') AS DATE_DEBUT_LIEN,
       TO_CHAR(l.DATE_FIN, 'YYYY-MM-DD') AS DATE_FIN_LIEN,
       l.HIST_TYPE_AUTORISATION AS TYPE_AUTORISATION,
       TO_CHAR(l.HIST_DATE_EFFET_AUTORISATION, 'YYYY-MM-DD') AS DATE_EFFET_AUTORISATION,
       l.HIST_NB_LIT_AUTORISATION AS LITS_AUTORISES
FROM CORA_REC.TB_UNITE u
LEFT JOIN CORA_REC.TB_UNITE_M_UNITE l ON l.ID_UNITE = u.ID_UNITE
LEFT JOIN CORA_REC.TB_UNITE_MEDICALE um ON um.ID_UNITE_MED = l.ID_UNITE_MED
WHERE TRIM(u.CODE_UNITE) LIKE '628_'
   OR TRIM(u.CODE_UNITE) IN ('2605', '2615', '2642', '2663', '2668', '6300', '6310',
                             '6311', '6320', '6330', '6340', '8840')
ORDER BY TRIM(u.CODE_UNITE), l.DATE_DEBUT;
