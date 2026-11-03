-- id: 20261022-um-pole-fme-lien-um-uf-dates
-- system: cora
-- person_data: no-person-data
-- purpose: lire le rattachement UM-UF avec ses dates (TB_UNITE_M_UNITE.DATE_DEBUT, DATE_FIN) pour les UM du pôle menf, afin de dater les changements de numéro (par exemple UF 5622 et 5623 rattachées aux UM 5618 et 5619) (étape 4 du plan revu)
-- Oracle, schéma CORA_REC. Structure seulement : codes, libellés et dates de rattachement du thésaurus, aucune donnée de personne ni de séjour. UM rattachées au pôle menf à un moment de 2022 à 2026.
SELECT '20261022-um-pole-fme-lien-um-uf-dates' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       TRIM(um.CODE_UNITE_MED) AS CODE_UM, TRIM(um.LIBELLE_UNITE_MED) AS LIBELLE_UM,
       TRIM(uf.CODE_UNITE) AS CODE_UF, TRIM(uf.LIBELLE_UNITE) AS LIBELLE_UF, uf.ACTIF AS UF_ACTIVE,
       TO_CHAR(l.DATE_DEBUT, 'YYYY-MM-DD') AS DEBUT_LIEN_UM_UF, TO_CHAR(l.DATE_FIN, 'YYYY-MM-DD') AS FIN_LIEN_UM_UF
FROM CORA_REC.TB_UNITE_MEDICALE um
LEFT JOIN CORA_REC.TB_UNITE_M_UNITE l ON l.ID_UNITE_MED = um.ID_UNITE_MED
LEFT JOIN CORA_REC.TB_UNITE uf ON uf.ID_UNITE = l.ID_UNITE
WHERE um.ID_UNITE_MED IN (
  SELECT pum.ID_UNITE_MED
  FROM CORA_REC.TB_UNITE_POLE_UM pum
  JOIN CORA_REC.TB_UNITE_POLE p ON p.ID_POLE = pum.ID_POLE
  WHERE TRIM(p.CODE_POLE) = 'menf'
    AND (pum.DATE_FIN IS NULL OR pum.DATE_FIN >= DATE '2022-01-01')
    AND (pum.DATE_DEBUT IS NULL OR pum.DATE_DEBUT < DATE '2027-01-01')
)
ORDER BY CODE_UM, CODE_UF, l.DATE_DEBUT;
