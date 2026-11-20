-- id: 20261102-type-sejour-mode-hospit-um
-- system: cora
-- person_data: masked
-- purpose: TYPE_SEJOUR 'MCO' et 'HDJ' des séjours qui ont un RSS, croisé avec le mode d'hospitalisation de l'UM retenue du RSS, par année de sortie et durée (contestation de type-sejour-non-fiable)
-- Oracle, schéma CORA_REC. RSS par TB_SYNTH_RSS.ID_SEJOUR (joindre-rss-par-id-sejour) ; mode par TB_SYNTH_RSS.ID_UM_RETENU → TB_UNITE_MEDICALE.MODE_HOSPIT (C, P ou M, valeur actuelle de l'UM, sans historique).
-- Un séjour qui a plusieurs RSS d'UM de modes différents compte dans chacune de ses lignes. Sorties de 2018 à août 2026 : les RSS des mois récents peuvent manquer.
SELECT '20261102-type-sejour-mode-hospit-um' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       ANNEE_SORTIE,
       TYPE_SEJOUR,
       MODE_HOSPIT,
       CASE WHEN COUNT(DISTINCT CASE WHEN NB_NUITS = 0 THEN ID_SEJOUR END) < 10 THEN '<10'
            ELSE TO_CHAR(COUNT(DISTINCT CASE WHEN NB_NUITS = 0 THEN ID_SEJOUR END)) END AS N_SEJ_0_NUIT,
       CASE WHEN COUNT(DISTINCT CASE WHEN NB_NUITS >= 1 THEN ID_SEJOUR END) < 10 THEN '<10'
            ELSE TO_CHAR(COUNT(DISTINCT CASE WHEN NB_NUITS >= 1 THEN ID_SEJOUR END)) END AS N_SEJ_1_NUIT_PLUS
FROM (
  SELECT s.ID_SEJOUR,
         EXTRACT(YEAR FROM s.DATE_SORTIE) AS ANNEE_SORTIE,
         TRIM(s.TYPE_SEJOUR) AS TYPE_SEJOUR,
         NVL(TRIM(um.MODE_HOSPIT), '(vide)') AS MODE_HOSPIT,
         TRUNC(s.DATE_SORTIE) - TRUNC(s.DATE_ENTREE) AS NB_NUITS
  FROM CORA_REC.TB_SEJOUR s
  JOIN CORA_REC.TB_SYNTH_RSS r ON r.ID_SEJOUR = s.ID_SEJOUR
  LEFT JOIN CORA_REC.TB_UNITE_MEDICALE um ON um.ID_UNITE_MED = r.ID_UM_RETENU
  WHERE TRIM(s.TYPE_SEJOUR) IN ('MCO', 'HDJ')
    AND s.DATE_SORTIE >= DATE '2018-01-01'
    AND s.DATE_SORTIE <  DATE '2026-09-01'
)
GROUP BY ANNEE_SORTIE, TYPE_SEJOUR, MODE_HOSPIT
ORDER BY ANNEE_SORTIE, TYPE_SEJOUR, MODE_HOSPIT;
