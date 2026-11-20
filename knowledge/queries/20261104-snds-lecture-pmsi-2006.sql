-- id: 20261104-snds-lecture-pmsi-2006
-- system: snds
-- person_data: masked
-- purpose: vérifier que la vue du PMSI de 2006, sans synonyme, se lit avec le préfixe PROFIL_108 (point ouvert de tables-snds-vues-profil-108, étape 4 du plan, #127)
-- Oracle. Compte au plus 1000 lignes de chaque vue (ROWNUM), pour ne pas balayer la table : la requête teste la lecture, elle ne mesure pas le volume.
-- Lignes : PROFIL_108.T_MCO06B (2006, sans synonyme) et T_MCO07B (2007, par le synonyme de l'utilisateur), pour comparer.
-- Masquage : N_LIGNES sort en <10 sous 10 (de 0 à 9). Pas de total.
SELECT '20261104-snds-lecture-pmsi-2006' AS QUERY_ID,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS DATABASE_NAME,
       TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI') AS RUN_AT,
       t.OBJET,
       CASE WHEN t.N < 10 THEN '<10' ELSE TO_CHAR(t.N) END AS N_LIGNES
FROM (
  SELECT 'PROFIL_108.T_MCO06B' AS OBJET, COUNT(*) AS N FROM (SELECT 1 FROM PROFIL_108.T_MCO06B WHERE ROWNUM <= 1000)
  UNION ALL
  SELECT 'T_MCO07B', COUNT(*) FROM (SELECT 1 FROM T_MCO07B WHERE ROWNUM <= 1000)
) t;
