-- id: 20261028-retours-j90-grade
-- system: cora
-- person_data: masked
-- purpose: compter les réhospitalisations MCO de J1 à J90 après une chirurgie bariatrique de 2022 à 2025, par signal de programmation et par grade Clavien-Dindo tiré des actes, et les complications du séjour index ; sert à choisir la définition de « non programmée » et à relire la liste d'actes sur des effectifs (étape 6 du plan, #113)
-- Oracle, schéma CORA_REC. Index : un séjour sorti, relié à un RSS (joindre-rss-par-id-sejour), avec un acte HFFC018, HFFA011 (sleeve), HFCC003 ou HFCA001 (bypass) réalisé du 2022-01-01 au 2025-12-31 (20261028-actes-bariatriques-par-an-resultat : les autres actes de la subdivision sont rares ou absents). J0 : le jour du premier de ces actes dans le séjour.
-- Retour : un autre séjour du même patient, sorti, relié à un RSS, entré de J0 + 1 à J0 + 90 et au plus tôt le jour de sortie du séjour index. Un séjour peut être le retour de deux index ; un événement peut faire deux séjours (une UHCD puis un service).
-- PROGRAMMATION du retour : les classes d'urgences de 20261027-statut-prog-urgences-mco (mêmes UF), puis, sans urgence, « créé avant le jour d'entrée » ou non, d'après TB_SEJOUR.DATE_CREAT (20261028-delai-creation-sejour-mco-resultat). Classe « 0 séjour index » : les actes du séjour index lui-même, à partir de J0 + 1.
-- GRADE : le plus haut signal parmi les actes du séjour (TB_ACTE.ID_SEJOUR), par listes tirées de la table S3 de Tzedakis et al. 2026 (DOI 10.1097/SLA.0000000000007105), adaptées à la chirurgie bariatrique. « 4 » : actes de grade IV de S3. « 3 liste » : actes de grade III gardés. « 3 ajout » : actes absents de S3 (endoprothèses de l'estomac et du duodénum, gestes par cœlioscopie, actes bariatriques en reprise). « 3 variante biliaire » : actes biliaires de S3, gardés à part (lithiase après amaigrissement). « retiré » : actes de S3 retirés (diagnostiques ou sans lien probable). « aucun acte des listes ». Dans le séjour index, grade III dès J0 + 1 et grade IV dès J0 + 4, comme l'article ; dans un retour, dès son entrée.
-- N_SEJ : séjours de la ligne (retours, ou séjours index pour la classe 0). N_INDEX : séjours index distincts dont un séjour est dans la ligne.
-- Masquage : N_SEJ < 10 sort en <10 ; N_INDEX sort en <10 s'il est < 10, et en « masqué » si N_SEJ l'est ou si N_SEJ - N_INDEX est de 1 à 9. La classe 0 ne sort pas la ligne « aucun acte des listes » : avec elle, ses lignes feraient le total des séjours index. Aucune ligne de total, années regroupées.
WITH idx_act AS (
  SELECT a.ID_SEJOUR, s.ID_PATIENT, TRUNC(s.DATE_SORTIE) AS SORTIE, MIN(TRUNC(a.DATE_ACTE)) AS J0
  FROM CORA_REC.TB_ACTE a
  JOIN CORA_REC.TB_SEJOUR s ON s.ID_SEJOUR = a.ID_SEJOUR
  WHERE TRIM(a.CODE_ACTE) IN ('HFFC018', 'HFFA011', 'HFCC003', 'HFCA001')
    AND a.DATE_ACTE >= DATE '2022-01-01' AND a.DATE_ACTE < DATE '2026-01-01'
    AND s.DATE_SORTIE IS NOT NULL
    AND EXISTS (SELECT 1 FROM CORA_REC.TB_SYNTH_RSS r WHERE r.ID_SEJOUR = s.ID_SEJOUR)
  GROUP BY a.ID_SEJOUR, s.ID_PATIENT, TRUNC(s.DATE_SORTIE)
),
urg AS (
  SELECT s.ID_PATIENT, TRUNC(s.DATE_ENTREE) AS J
  FROM CORA_REC.TB_SEJOUR s
  WHERE TRIM(s.UF_ENTREE) IN ('5701', '5802', '5709', '5015', '5010', '5720')
    AND s.DATE_ENTREE >= DATE '2022-01-01' AND s.DATE_ENTREE < DATE '2026-05-01'
),
ret AS (
  SELECT i.ID_SEJOUR AS ID_INDEX, r.ID_SEJOUR, TRUNC(r.DATE_ENTREE) AS JD, 0 AS DELTA_IV,
         CASE WHEN TRIM(r.UF_ENTREE) IN ('5701', '5802', '5709', '5015', '5010', '5720')
                THEN '1 UF d''entrée d''urgences'
              WHEN EXISTS (SELECT 1 FROM urg u
                           WHERE u.ID_PATIENT = r.ID_PATIENT
                             AND u.J BETWEEN TRUNC(r.DATE_ENTREE) - 1 AND TRUNC(r.DATE_ENTREE))
                THEN '2 séjour d''urgences la veille ou le jour même'
              WHEN TRUNC(r.DATE_CREAT) < TRUNC(r.DATE_ENTREE) THEN '4 sans urgence, créé avant le jour d''entrée'
              ELSE '3 sans urgence, créé le jour d''entrée ou après' END AS PROGRAMMATION
  FROM idx_act i
  JOIN CORA_REC.TB_SEJOUR r ON r.ID_PATIENT = i.ID_PATIENT AND r.ID_SEJOUR <> i.ID_SEJOUR
  WHERE TRUNC(r.DATE_ENTREE) BETWEEN i.J0 + 1 AND i.J0 + 90
    AND TRUNC(r.DATE_ENTREE) >= i.SORTIE
    AND r.DATE_SORTIE IS NOT NULL
    AND EXISTS (SELECT 1 FROM CORA_REC.TB_SYNTH_RSS x WHERE x.ID_SEJOUR = r.ID_SEJOUR)
  UNION ALL
  SELECT i.ID_SEJOUR, i.ID_SEJOUR, i.J0 + 1, 3, '0 séjour index'
  FROM idx_act i
),
act0 AS (
  SELECT t.ID_INDEX, t.ID_SEJOUR, t.PROGRAMMATION, t.JD, t.DELTA_IV, TRUNC(a.DATE_ACTE) AS JA,
         CASE WHEN TRIM(a.CODE_ACTE) IN ('ABQP001', 'DCJB001', 'DCJB002', 'DCJA001', 'DERP004', 'DERP005', 'DFNF001', 'DKMD001', 'DKMD002', 'EQCF001',
                                 'GLJF010', 'EPLF005', 'EQQP004', 'EQLF002', 'EQLF003', 'EQLF005', 'EQMP001', 'EQQP013', 'FELF001', 'FELF003',
                                 'FELF004', 'FELF005', 'FELF012', 'FEJF001', 'FEJF002', 'JVJF002', 'JVJF003', 'JVJF005', 'JVJF006', 'JVJF007',
                                 'JVJB002', 'YYYY020', 'YYYY015', 'YYYY004', 'GLLD003', 'GLLD004', 'GLLD007', 'GLLD008', 'GLLD009', 'GLLD012',
                                 'GLLD019', 'GLLD015', 'EQMF003', 'GLLD021', 'GLQP015') THEN 'IV'
              WHEN TRIM(a.CODE_ACTE) IN ('DDAF004', 'DDAF006', 'DDAF007', 'DDAF008', 'DDAF010', 'DDQH009', 'DDQH012', 'DDQH013', 'DDQH014', 'DDQH015',
                                 'EDLF006', 'EDPF004', 'EDLF007', 'EDLF004', 'EDLF008', 'EDLF005', 'DGLF001', 'DGLF002', 'DGLF005', 'DGLF012',
                                 'EDPF003', 'EDPF002', 'DGSA005', 'EDSF006', 'EDSF008', 'EDSF012', 'EDSF014', 'EDSF015', 'EDSF016', 'EDSF009',
                                 'EDSF001', 'EDSF005', 'FFSA001', 'EHSF001', 'EDNF003', 'EDJF002', 'EDCA001', 'EDCA002', 'EDCC015', 'EDPA002',
                                 'DGCA001', 'EDFA009', 'EDFA010', 'EDKA003', 'DHCA001', 'EHCA008', 'ELFA001', 'EDSA001', 'EDSA003', 'EDFA002',
                                 'EDFA005', 'EHFA001', 'GGHB001', 'GGJB001', 'GGJB002', 'GGJB005', 'GGLB006', 'GGJC001', 'GGJC002', 'GGJA001',
                                 'GGJA002', 'GGJA003', 'GGJA004', 'GGJB006', 'GGJB007', 'HECA004', 'HFCA003', 'HGCA002', 'HHCA001', 'HHCC001',
                                 'HHMA002', 'HFCC001', 'HJCA001', 'HJCD002', 'HELE002', 'HEAE001', 'HEAE002', 'HEAE003', 'HEAH001', 'HEKE001',
                                 'HFAE001', 'HFAH001', 'HEGE003', 'HGEC001', 'HFPA001', 'HFCA002', 'HFCA004', 'HFCB001', 'HFCH001', 'HFFA005',
                                 'HFFA006', 'HFFA009', 'HFFA002', 'HFFA003', 'HFFC001', 'HFFA008', 'HGPA005', 'HGPA001', 'HESE001', 'HESE002',
                                 'HGLA001', 'HGFA003', 'HGFA004', 'HGFA005', 'HGFA007', 'HGFA013', 'HGPA002', 'HGFC014', 'HGCA007', 'HHCA002',
                                 'HGCA005', 'HGPA003', 'HGCA001', 'HGCA004', 'HGCA008', 'HGCC026', 'HGCC003', 'HHCC007', 'HHFC296', 'HHCA003',
                                 'HHFA026', 'HHFA005', 'HHFA021', 'HHFA024', 'HJFA002', 'HJFA005', 'HJFA006', 'HJFA011', 'HHFA030', 'HJJA001',
                                 'HJSA001', 'HJSD001', 'FFFA001', 'FFFA002', 'FFFC001', 'FFFC420', 'FFJA001', 'HLHJ004', 'HLJA001', 'HLHH002',
                                 'HLJC001', 'HNFA012', 'HNJA001', 'HNJC001', 'HNCA006', 'HPHB003', 'HPJB001', 'ZZJH001', 'ZZJH002', 'ZZJH003',
                                 'ZZJH005', 'ZZJH006', 'ZZJH007', 'ZZJH008', 'ZZJJ004', 'ZZJJ008', 'ZZJJ013', 'ZZJJ005', 'ZZJJ006', 'ZZJJ010',
                                 'ZCJA002', 'ZCJA004', 'ZCJC001', 'ZCJD001', 'ZCJA001', 'ZCJA005', 'JFJA001', 'JFJC001', 'ZCQC002', 'ZCQA001',
                                 'LLCA005', 'LLMA008', 'LMMA004', 'LMMA010', 'LMMC015', 'LMSA002', 'HGPA004', 'HGPC015', 'HPPA002', 'HPPC003',
                                 'JAFA002', 'JAFA023', 'JACA002', 'JACH001', 'JACH002', 'JACH003', 'JCAD001', 'JCAE001', 'JCAH001', 'JCCA003',
                                 'JCCA012', 'JCEA002', 'JCEA003', 'JCLD001', 'JCLE001', 'JCLE002', 'JCLE003', 'JCSA001', 'JCSA004', 'JCSA005',
                                 'JCLH001', 'JCFA001', 'JCFA009', 'JDCA003', 'JDSA002', 'JDJD002', 'JDJE001', 'ZCJA003', 'ZZJJ002', 'ZZJJ003',
                                 'ZZJJ007', 'QZJA011', 'QZJA023') THEN 'III'
              WHEN TRIM(a.CODE_ACTE) IN ('HFLH002', 'HGLE001', 'HGKE001', 'HGGE001', 'HFLE001', 'HFFC012', 'HFFC002', 'HFFC017', 'HFMA005', 'HFCC022',
                                 'HFCC002', 'HGCC031', 'HGFC021', 'HGFC016', 'HGPC006', 'HGCC015', 'HFLC900', 'HFGC900', 'HGCC027', 'HGCA009',
                                 'HFCC003', 'HFCA001', 'HFFC018', 'HFFA011', 'HFFC004', 'HFFA001', 'HFMC006', 'HFMA010', 'HFMC007', 'HFMA009',
                                 'HFKC001', 'HFKA002', 'HFMC008', 'HFMA011', 'HFKA001') THEN 'ADD'
              WHEN TRIM(a.CODE_ACTE) IN ('HMGE001', 'HMGH002', 'HMGH003', 'HMJH001', 'HMJH002', 'HMJH003', 'HMJH004', 'HMJH005', 'HMJH006', 'HMJH007',
                                 'HMKE001', 'HMKE002', 'HMKH001', 'HMLE002', 'HMLE003', 'HMLH001', 'HMLH002', 'HMLH003', 'HMMA001', 'HMMA002',
                                 'HMPE001', 'HMAE001', 'HMAE002', 'HMAH001', 'HMAH002', 'HMQH003', 'HMQH005', 'HMQH007', 'HMGE002', 'HMCA009',
                                 'HMCH001', 'HMFC003', 'HMFA005') THEN 'VAR'
              WHEN TRIM(a.CODE_ACTE) IN ('DGQH003', 'DGQH004', 'EDQH003', 'EDQH006', 'EDQH007', 'EDQH008', 'EDQH001', 'EDQH005', 'DGQH001', 'DGQH002',
                                 'HMQH004', 'HMQH006', 'HMQE001', 'HMQG002', 'YYYY400', 'HMQJ002', 'HMQH002', 'ZCQC001', 'AHLH002', 'NBCA006') THEN 'RET' END AS GRP
  FROM ret t
  LEFT JOIN CORA_REC.TB_ACTE a ON a.ID_SEJOUR = t.ID_SEJOUR AND TRUNC(a.DATE_ACTE) >= t.JD
),
act AS (
  SELECT ID_INDEX, ID_SEJOUR, PROGRAMMATION,
         MAX(CASE WHEN GRP = 'IV' AND JA >= JD + DELTA_IV THEN 1 ELSE 0 END) AS F_IV,
         MAX(CASE WHEN GRP = 'III' THEN 1 ELSE 0 END) AS F_III,
         MAX(CASE WHEN GRP = 'ADD' THEN 1 ELSE 0 END) AS F_ADD,
         MAX(CASE WHEN GRP = 'VAR' THEN 1 ELSE 0 END) AS F_VAR,
         MAX(CASE WHEN GRP = 'RET' THEN 1 ELSE 0 END) AS F_RET
  FROM act0
  GROUP BY ID_INDEX, ID_SEJOUR, PROGRAMMATION
),
cl AS (
  SELECT ID_INDEX, ID_SEJOUR, PROGRAMMATION,
         CASE WHEN F_IV = 1 THEN '4'
              WHEN F_III = 1 THEN '3 liste'
              WHEN F_ADD = 1 THEN '3 ajout'
              WHEN F_VAR = 1 THEN '3 variante biliaire'
              WHEN F_RET = 1 THEN 'retiré'
              ELSE 'aucun acte des listes' END AS GRADE
  FROM act
),
agg AS (
  SELECT PROGRAMMATION, GRADE, COUNT(DISTINCT ID_SEJOUR) AS N_SEJ, COUNT(DISTINCT ID_INDEX) AS N_IDX
  FROM cl
  WHERE NOT (PROGRAMMATION = '0 séjour index' AND GRADE = 'aucun acte des listes')
  GROUP BY PROGRAMMATION, GRADE
)
SELECT '20261028-retours-j90-grade' AS query_id,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
       TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI') AS run_at,
       PROGRAMMATION, GRADE,
       CASE WHEN N_SEJ < 10 THEN '<10' ELSE TO_CHAR(N_SEJ) END AS N_SEJ,
       CASE WHEN N_SEJ < 10 OR (N_SEJ - N_IDX BETWEEN 1 AND 9) THEN 'masqué'
            WHEN N_IDX < 10 THEN '<10'
            ELSE TO_CHAR(N_IDX) END AS N_INDEX
FROM agg
ORDER BY PROGRAMMATION, GRADE;
