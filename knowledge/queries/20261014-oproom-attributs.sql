-- id: 20261014-oproom-attributs
-- system: oproom
-- person_data: masked
-- purpose: par année de début, ce que portent les interventions réalisées d'OpRoom : état, demande, spécialité et type d'hospitalisation de l'intervention contre ceux de la demande, salle virtuelle, bloc non renseigné, chirurgien, procédures supplémentaires, exclusion du temps de référence ; puis la répartition des valeurs de HOSP, HOSP_DEMANDE, PRIORITE, PRIORITE_DEMANDE, ANESTHESIE et TYPE_SALLE (kb : request-and-intervention, hosptype-is-declarative, reference-cutting-time-is-planning ; #39, étape 2)
-- SQLite, sur l'extraction de QBLOCP par requete_oproom.py (table INTERVENTIONS, valeurs en texte, vide = NULL ; table META : BASE, EXTRAIT_LE), chargée par scripts/cdk/executer_requetes_cdk.py de DIM-code. Ne lit ni NO_ADMISSION ni CHIRURGIEN_KEY.
-- Niveau ANNEE : N, puis N_ETAT_2, N_ETAT_4, N_SANS_DEMANDE (DATE_DEMANDE vide), N_SPEC_EGALE (SPEC = SPEC_DEMANDE), N_HOSP_EGAL (HOSP = HOSP_DEMANDE), N_HOSP_VIDE, N_SALLE_VIRTUELLE, N_BLOC_NON_RENSEIGNE, N_SANS_CHIRURGIEN, N_PLUSIEURS_CHIRURGIENS, N_PROC_SUPPL (au moins une procédure supplémentaire), N_EXCLU_REF (EXCLU_TEMPS_REFERENCE = 1).
-- Niveau VALEURS : par année, VARIABLE et VALEUR ('(vide)' sans valeur), N seulement.
-- Masquage : chaque effectif < 10 sort en <10. Suppression secondaire (règle 4) : au niveau ANNEE, N sort en « masqué » dès qu'un complément (N moins une autre colonne) est entre 1 et 9 ; au niveau VALEURS, quand les cases masquées d'une année et d'une variable totalisent de 1 à 9, la plus grande case de ce groupe sort aussi en « masqué ». Aucune ligne de total.
WITH i AS (
  SELECT substr(DEBUT, 1, 4) AS ANNEE, ETAT, DATE_DEMANDE, SPEC, SPEC_DEMANDE, HOSP, HOSP_DEMANDE,
         PRIORITE, PRIORITE_DEMANDE, ANESTHESIE, TYPE_SALLE, SALLE_VIRTUELLE, BLOC,
         NB_CHIRURGIENS, NB_PROC_SUPPL, EXCLU_TEMPS_REFERENCE
  FROM INTERVENTIONS WHERE DEBUT IS NOT NULL
),
a AS (
  SELECT ANNEE, COUNT(*) AS N,
         SUM(ETAT = '2') AS C1, SUM(ETAT = '4') AS C2, SUM(DATE_DEMANDE IS NULL) AS C3,
         SUM(SPEC = SPEC_DEMANDE) AS C4, SUM(HOSP = HOSP_DEMANDE) AS C5, SUM(HOSP IS NULL) AS C6,
         SUM(SALLE_VIRTUELLE = '1') AS C7, SUM(BLOC = 'Non renseigné') AS C8,
         SUM(CAST(NB_CHIRURGIENS AS INTEGER) = 0) AS C9, SUM(CAST(NB_CHIRURGIENS AS INTEGER) > 1) AS C10,
         SUM(CAST(NB_PROC_SUPPL AS INTEGER) > 0) AS C11, SUM(EXCLU_TEMPS_REFERENCE = '1') AS C12
  FROM i GROUP BY ANNEE
),
v AS (
  SELECT ANNEE, 'HOSP' AS VARIABLE, IFNULL(HOSP, '(vide)') AS VALEUR FROM i
  UNION ALL SELECT ANNEE, 'HOSP_DEMANDE', IFNULL(HOSP_DEMANDE, '(vide)') FROM i
  UNION ALL SELECT ANNEE, 'PRIORITE', IFNULL(PRIORITE, '(vide)') FROM i
  UNION ALL SELECT ANNEE, 'PRIORITE_DEMANDE', IFNULL(PRIORITE_DEMANDE, '(vide)') FROM i
  UNION ALL SELECT ANNEE, 'ANESTHESIE', IFNULL(ANESTHESIE, '(vide)') FROM i
  UNION ALL SELECT ANNEE, 'TYPE_SALLE', IFNULL(TYPE_SALLE, '(vide)') FROM i
),
vc AS (
  SELECT ANNEE, VARIABLE, VALEUR, COUNT(*) AS N FROM v GROUP BY ANNEE, VARIABLE, VALEUR
),
vm AS (
  SELECT ANNEE, VARIABLE, VALEUR, N,
         SUM(CASE WHEN N < 10 THEN N ELSE 0 END) OVER (PARTITION BY ANNEE, VARIABLE) AS CACHE,
         ROW_NUMBER() OVER (PARTITION BY ANNEE, VARIABLE ORDER BY N DESC, VALEUR) AS RANG
  FROM vc
),
m AS (SELECT BASE || ' (extraction du ' || EXTRAIT_LE || ')' AS DB FROM META)
SELECT '20261014-oproom-attributs' AS query_id, (SELECT DB FROM m) AS database_name,
       strftime('%Y-%m-%d %H:%M', 'now', 'localtime') AS run_at,
       'ANNEE' AS NIVEAU, ANNEE, NULL AS VARIABLE, NULL AS VALEUR,
       CASE WHEN N < 10 THEN '<10'
            WHEN N - C1 BETWEEN 1 AND 9 OR N - C2 BETWEEN 1 AND 9 OR N - C3 BETWEEN 1 AND 9 OR N - C4 BETWEEN 1 AND 9
              OR N - C5 BETWEEN 1 AND 9 OR N - C6 BETWEEN 1 AND 9 OR N - C7 BETWEEN 1 AND 9 OR N - C8 BETWEEN 1 AND 9
              OR N - C9 BETWEEN 1 AND 9 OR N - C10 BETWEEN 1 AND 9 OR N - C11 BETWEEN 1 AND 9 OR N - C12 BETWEEN 1 AND 9
            THEN 'masqué' ELSE CAST(N AS TEXT) END AS N,
       CASE WHEN C1 < 10 THEN '<10' ELSE CAST(C1 AS TEXT) END AS N_ETAT_2,
       CASE WHEN C2 < 10 THEN '<10' ELSE CAST(C2 AS TEXT) END AS N_ETAT_4,
       CASE WHEN C3 < 10 THEN '<10' ELSE CAST(C3 AS TEXT) END AS N_SANS_DEMANDE,
       CASE WHEN C4 < 10 THEN '<10' ELSE CAST(C4 AS TEXT) END AS N_SPEC_EGALE,
       CASE WHEN C5 < 10 THEN '<10' ELSE CAST(C5 AS TEXT) END AS N_HOSP_EGAL,
       CASE WHEN C6 < 10 THEN '<10' ELSE CAST(C6 AS TEXT) END AS N_HOSP_VIDE,
       CASE WHEN C7 < 10 THEN '<10' ELSE CAST(C7 AS TEXT) END AS N_SALLE_VIRTUELLE,
       CASE WHEN C8 < 10 THEN '<10' ELSE CAST(C8 AS TEXT) END AS N_BLOC_NON_RENSEIGNE,
       CASE WHEN C9 < 10 THEN '<10' ELSE CAST(C9 AS TEXT) END AS N_SANS_CHIRURGIEN,
       CASE WHEN C10 < 10 THEN '<10' ELSE CAST(C10 AS TEXT) END AS N_PLUSIEURS_CHIRURGIENS,
       CASE WHEN C11 < 10 THEN '<10' ELSE CAST(C11 AS TEXT) END AS N_PROC_SUPPL,
       CASE WHEN C12 < 10 THEN '<10' ELSE CAST(C12 AS TEXT) END AS N_EXCLU_REF
FROM a
UNION ALL
SELECT '20261014-oproom-attributs', (SELECT DB FROM m), strftime('%Y-%m-%d %H:%M', 'now', 'localtime'),
       'VALEURS', ANNEE, VARIABLE, VALEUR,
       CASE WHEN N < 10 THEN '<10' WHEN CACHE BETWEEN 1 AND 9 AND RANG = 1 THEN 'masqué' ELSE CAST(N AS TEXT) END,
       NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM vm
ORDER BY NIVEAU, ANNEE, VARIABLE, VALEUR;
