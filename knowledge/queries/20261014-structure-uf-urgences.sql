-- id: 20261014-structure-uf-urgences
-- system: cora
-- person_data: no-person-data
-- purpose: rattachement UF → UM → pôle des UF d'urgences et de leurs pôles, avec les paramètres d'urgence de TB_UNITE (ORDRE_RPU, TYPE_AUTORISATION, TYPE_ACTIVITE), pour voir si la structure de CORA peut remplacer la liste d'UF de reperer-passage-urgences (étape 12 du plan, #24)
-- Oracle, schéma CORA_REC. Référentiels seulement : aucune table de séjour ni de personne. ID_MED_RESP (médecin responsable) n'est pas lu.
-- UF retenues : la liste de reperer-passage-urgences (EN_LISTE = 'O') ; les UF qui ont URGENCE = 'O', un ORDRE_RPU autre que '0' ou TYPE_AUTORISATION = '07' ; toutes les UF des pôles qui contiennent une UF de la liste.
-- Une ligne par UF et par lien UF → UM → pôle : les liens ont des dates de validité, une UF peut en avoir plusieurs.
WITH liste AS (
  SELECT '5701' AS CODE FROM DUAL UNION ALL SELECT '5802' FROM DUAL UNION ALL SELECT '5709' FROM DUAL
  UNION ALL SELECT '5015' FROM DUAL UNION ALL SELECT '5010' FROM DUAL UNION ALL SELECT '5720' FROM DUAL
  UNION ALL SELECT '5705' FROM DUAL UNION ALL SELECT '8012' FROM DUAL UNION ALL SELECT '8013' FROM DUAL
  UNION ALL SELECT '8014' FROM DUAL UNION ALL SELECT '8005' FROM DUAL UNION ALL SELECT '8000' FROM DUAL
  UNION ALL SELECT '5654' FROM DUAL UNION ALL SELECT '5703' FROM DUAL
),
lien AS (
  SELECT umu.ID_UNITE,
         TRIM(um.CODE_UNITE_MED) AS CODE_UM,
         TRIM(um.LIBELLE_UNITE_MED) AS LIBELLE_UM,
         TO_CHAR(umu.DATE_DEBUT, 'YYYY-MM-DD') AS UM_DEBUT,
         TO_CHAR(umu.DATE_FIN, 'YYYY-MM-DD') AS UM_FIN,
         TRIM(p.CODE_POLE) AS CODE_POLE,
         p.LIBELLE_POLE,
         TO_CHAR(pum.DATE_DEBUT, 'YYYY-MM-DD') AS POLE_DEBUT,
         TO_CHAR(pum.DATE_FIN, 'YYYY-MM-DD') AS POLE_FIN
  FROM CORA_REC.TB_UNITE_M_UNITE umu
  JOIN CORA_REC.TB_UNITE_MEDICALE um ON um.ID_UNITE_MED = umu.ID_UNITE_MED
  LEFT JOIN CORA_REC.TB_UNITE_POLE_UM pum ON pum.ID_UNITE_MED = um.ID_UNITE_MED
  LEFT JOIN CORA_REC.TB_UNITE_POLE p ON p.ID_POLE = pum.ID_POLE
),
poles AS (
  SELECT DISTINCT l.CODE_POLE
  FROM lien l
  JOIN CORA_REC.TB_UNITE u ON u.ID_UNITE = l.ID_UNITE
  WHERE TRIM(u.CODE_UNITE) IN (SELECT CODE FROM liste)
    AND l.CODE_POLE IS NOT NULL
),
cand AS (
  SELECT u.ID_UNITE
  FROM CORA_REC.TB_UNITE u
  WHERE TRIM(u.CODE_UNITE) IN (SELECT CODE FROM liste)
     OR u.URGENCE = 'O'
     OR NVL(TRIM(u.ORDRE_RPU), '0') <> '0'
     OR TRIM(u.TYPE_AUTORISATION) = '07'
  UNION
  SELECT l.ID_UNITE FROM lien l WHERE l.CODE_POLE IN (SELECT CODE_POLE FROM poles)
)
SELECT '20261014-structure-uf-urgences' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       TRIM(u.CODE_UNITE) AS CODE_UF,
       u.LIBELLE_UNITE AS LIBELLE_UF,
       CASE WHEN TRIM(u.CODE_UNITE) IN (SELECT CODE FROM liste) THEN 'O' ELSE 'N' END AS EN_LISTE,
       u.ACTIF,
       u.URGENCE,
       u.UHCD,
       u.EXTERNE,
       TRIM(u.ORDRE_RPU) AS ORDRE_RPU,
       TRIM(u.TYPE_AUTORISATION) AS TYPE_AUTORISATION,
       TRIM(u.TYPE_ACTIVITE) AS TYPE_ACTIVITE,
       TRIM(pere.CODE_UNITE) AS CODE_UF_PERE,
       l.CODE_UM, l.LIBELLE_UM, l.UM_DEBUT, l.UM_FIN,
       l.CODE_POLE, l.LIBELLE_POLE, l.POLE_DEBUT, l.POLE_FIN
FROM cand c
JOIN CORA_REC.TB_UNITE u ON u.ID_UNITE = c.ID_UNITE
LEFT JOIN CORA_REC.TB_UNITE pere ON pere.ID_UNITE = u.ID_PERE
LEFT JOIN lien l ON l.ID_UNITE = u.ID_UNITE
ORDER BY l.CODE_POLE, TRIM(u.CODE_UNITE), l.UM_DEBUT, l.POLE_DEBUT;
