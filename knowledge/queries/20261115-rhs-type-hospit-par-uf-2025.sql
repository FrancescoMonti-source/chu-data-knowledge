-- id: 20261115-rhs-type-hospit-par-uf-2025
-- system: cora
-- person_data: masked
-- purpose: vérifier que TYPE_HOSPIT_SSR = 2 désigne bien l'hospitalisation à temps partiel (claim htp-smr-type-hospit-ssr) : compter les RHS dont la semaine débute en 2025 par TYPE_HOSPIT_SSR et par UF du mouvement, pour voir si les RHS de type 2 sont dans des unités d'hôpital de jour et ceux de type 1 dans des unités avec lits
-- Oracle, schéma CORA_REC. L'UF est celle du mouvement du RHS (TB_MVT.ID_UNITE_M, un code, joint à TB_UNITE par TRIM(CODE_UNITE) : claim joindre-uf-par-code).
-- Masquage : un effectif de moins de 10 sort en <10. Dans chaque type, dès qu'une case est en <10, la plus petite case de 10 ou plus sort en « masqué » : les totaux par type sont déjà connus (20261020-rhs-htp-colonnes-2025-resultat) et permettraient sinon de recalculer une case seule. Aucune ligne de total.
WITH c AS (
  SELECT s.TYPE_HOSPIT_SSR,
         TRIM(m.ID_UNITE_M) AS CODE_UF,
         COUNT(*) AS N
  FROM CORA_REC.TB_MVT_SSR_SEM s
  LEFT JOIN CORA_REC.TB_MVT m ON m.ID_MVT = s.ID_MVT
  WHERE s.DATE_DEBUT_SEM >= DATE '2025-01-01' AND s.DATE_DEBUT_SEM < DATE '2026-01-01'
  GROUP BY s.TYPE_HOSPIT_SSR, TRIM(m.ID_UNITE_M)
),
r AS (
  SELECT c.TYPE_HOSPIT_SSR,
         c.CODE_UF,
         c.N,
         SUM(CASE WHEN c.N < 10 THEN 1 ELSE 0 END) OVER (PARTITION BY c.TYPE_HOSPIT_SSR) AS NB_PETITES,
         ROW_NUMBER() OVER (PARTITION BY c.TYPE_HOSPIT_SSR ORDER BY CASE WHEN c.N < 10 THEN 1 ELSE 0 END, c.N) AS RANG
  FROM c
)
SELECT '20261115-rhs-type-hospit-par-uf-2025' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       r.TYPE_HOSPIT_SSR,
       r.CODE_UF,
       u.LIBELLE_UNITE,
       CASE WHEN r.N < 10 THEN '<10'
            WHEN r.NB_PETITES >= 1 AND r.RANG = 1 THEN 'masqué'
            ELSE TO_CHAR(r.N) END AS N_RHS
FROM r
LEFT JOIN CORA_REC.TB_UNITE u ON TRIM(u.CODE_UNITE) = r.CODE_UF
ORDER BY r.TYPE_HOSPIT_SSR, r.CODE_UF;
