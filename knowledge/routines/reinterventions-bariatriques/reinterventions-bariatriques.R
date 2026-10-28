# id: reinterventions-bariatriques
# system: cora
# purpose: compter, par année de l'intervention, les réhospitalisations MCO non programmées de J1 à J90 avec un acte de complication de grade Clavien-Dindo III ou IV après une sleeve ou un bypass, le nombre que demande le questionnaire sur l'obésité (#113) ; sur demande, la liste des séjours concernés, pour les vérifier en dossier
# La méthode, les paramètres et les limites : README.md, à côté de ce fichier.
# R de base et DBI. Le résultat reste à l'hôpital (method/queries.md, « Une routine »).

reinterventions_bariatriques <- function(connexion, annees = 2022:2025,
                                         actes_index = c("HFFC018", "HFFA011", "HFCC003", "HFCA001"),
                                         masquer = TRUE, sejours = FALSE) {
  stopifnot(is.function(connexion), length(annees) > 0, annees == round(annees), length(actes_index) > 0)
  if (sejours && masquer) stop("La liste des séjours ne se masque pas : la demander avec masquer = FALSE, pour soi seul à l'hôpital.")
  ancien <- options(width = 400)
  on.exit(options(ancien))

  # Les listes de la requête 20261028-retours-j90-grade, tirées de la table S3 de Tzedakis et al. 2026
  # Grade IV : les actes de grade IV de S3, forfaits de réanimation compris
  grade_4 <- c("ABQP001", "DCJB001", "DCJB002", "DCJA001", "DERP004", "DERP005", "DFNF001", "DKMD001", "DKMD002", "EQCF001",
               "GLJF010", "EPLF005", "EQQP004", "EQLF002", "EQLF003", "EQLF005", "EQMP001", "EQQP013", "FELF001", "FELF003",
               "FELF004", "FELF005", "FELF012", "FEJF001", "FEJF002", "JVJF002", "JVJF003", "JVJF005", "JVJF006", "JVJF007",
               "JVJB002", "YYYY020", "YYYY015", "YYYY004", "GLLD003", "GLLD004", "GLLD007", "GLLD008", "GLLD009", "GLLD012",
               "GLLD019", "GLLD015", "EQMF003", "GLLD021", "GLQP015")
  # Grade III : les actes de grade III gardés de S3, puis les actes ajoutés pour la chirurgie bariatrique
  grade_3 <- c("DDAF004", "DDAF006", "DDAF007", "DDAF008", "DDAF010", "DDQH009", "DDQH012", "DDQH013", "DDQH014", "DDQH015",
               "EDLF006", "EDPF004", "EDLF007", "EDLF004", "EDLF008", "EDLF005", "DGLF001", "DGLF002", "DGLF005", "DGLF012",
               "EDPF003", "EDPF002", "DGSA005", "EDSF006", "EDSF008", "EDSF012", "EDSF014", "EDSF015", "EDSF016", "EDSF009",
               "EDSF001", "EDSF005", "FFSA001", "EHSF001", "EDNF003", "EDJF002", "EDCA001", "EDCA002", "EDCC015", "EDPA002",
               "DGCA001", "EDFA009", "EDFA010", "EDKA003", "DHCA001", "EHCA008", "ELFA001", "EDSA001", "EDSA003", "EDFA002",
               "EDFA005", "EHFA001", "GGHB001", "GGJB001", "GGJB002", "GGJB005", "GGLB006", "GGJC001", "GGJC002", "GGJA001",
               "GGJA002", "GGJA003", "GGJA004", "GGJB006", "GGJB007", "HECA004", "HFCA003", "HGCA002", "HHCA001", "HHCC001",
               "HHMA002", "HFCC001", "HJCA001", "HJCD002", "HELE002", "HEAE001", "HEAE002", "HEAE003", "HEAH001", "HEKE001",
               "HFAE001", "HFAH001", "HEGE003", "HGEC001", "HFPA001", "HFCA002", "HFCA004", "HFCB001", "HFCH001", "HFFA005",
               "HFFA006", "HFFA009", "HFFA002", "HFFA003", "HFFC001", "HFFA008", "HGPA005", "HGPA001", "HESE001", "HESE002",
               "HGLA001", "HGFA003", "HGFA004", "HGFA005", "HGFA007", "HGFA013", "HGPA002", "HGFC014", "HGCA007", "HHCA002",
               "HGCA005", "HGPA003", "HGCA001", "HGCA004", "HGCA008", "HGCC026", "HGCC003", "HHCC007", "HHFC296", "HHCA003",
               "HHFA026", "HHFA005", "HHFA021", "HHFA024", "HJFA002", "HJFA005", "HJFA006", "HJFA011", "HHFA030", "HJJA001",
               "HJSA001", "HJSD001", "FFFA001", "FFFA002", "FFFC001", "FFFC420", "FFJA001", "HLHJ004", "HLJA001", "HLHH002",
               "HLJC001", "HNFA012", "HNJA001", "HNJC001", "HNCA006", "HPHB003", "HPJB001", "ZZJH001", "ZZJH002", "ZZJH003",
               "ZZJH005", "ZZJH006", "ZZJH007", "ZZJH008", "ZZJJ004", "ZZJJ008", "ZZJJ013", "ZZJJ005", "ZZJJ006", "ZZJJ010",
               "ZCJA002", "ZCJA004", "ZCJC001", "ZCJD001", "ZCJA001", "ZCJA005", "JFJA001", "JFJC001", "ZCQC002", "ZCQA001",
               "LLCA005", "LLMA008", "LMMA004", "LMMA010", "LMMC015", "LMSA002", "HGPA004", "HGPC015", "HPPA002", "HPPC003",
               "JAFA002", "JAFA023", "JACA002", "JACH001", "JACH002", "JACH003", "JCAD001", "JCAE001", "JCAH001", "JCCA003",
               "JCCA012", "JCEA002", "JCEA003", "JCLD001", "JCLE001", "JCLE002", "JCLE003", "JCSA001", "JCSA004", "JCSA005",
               "JCLH001", "JCFA001", "JCFA009", "JDCA003", "JDSA002", "JDJD002", "JDJE001", "ZCJA003", "ZZJJ002", "ZZJJ003",
               "ZZJJ007", "QZJA011", "QZJA023",
               "HFLH002", "HGLE001", "HGKE001", "HGGE001", "HFLE001", "HFFC012", "HFFC002", "HFFC017", "HFMA005", "HFCC022",
               "HFCC002", "HGCC031", "HGFC021", "HGFC016", "HGPC006", "HGCC015", "HFLC900", "HFGC900", "HGCC027", "HGCA009",
               "HFCC003", "HFCA001", "HFFC018", "HFFA011", "HFFC004", "HFFA001", "HFMC006", "HFMA010", "HFMC007", "HFMA009",
               "HFKC001", "HFKA002", "HFMC008", "HFMA011", "HFKA001")
  uf_urgences <- c("5701", "5802", "5709", "5015", "5010", "5720")

  liste <- function(codes) paste0("'", codes, "'", collapse = ", ")
  annees <- sort(unique(as.integer(annees)))
  debut <- paste0("DATE '", min(annees), "-01-01'")
  fin <- paste0("DATE '", max(annees) + 1, "-01-01'")
  # Le séjour d'urgences de la veille d'un retour entré jusqu'à fin mars de l'année suivante
  fin_urg <- paste0("DATE '", max(annees) + 1, "-05-01'")
  # Un acte de grade IV compte dès J0 + 4 dans le séjour index (DELTA_IV), dès l'entrée dans un retour
  acte_grade <- paste0("((TRIM(a.CODE_ACTE) IN (", liste(grade_4), ") AND TRUNC(a.DATE_ACTE) >= t.JD + t.DELTA_IV)
       OR TRIM(a.CODE_ACTE) IN (", liste(grade_3), "))")

  # PROG : 0 le séjour index ; pour un retour, 1 entré par une UF d'urgences, 2 séjour d'urgences la veille
  # ou le jour même, 3 sans urgence et créé le jour d'entrée ou après, 4 créé avant le jour d'entrée
  ctes <- paste0("
WITH idx AS (
  SELECT a.ID_SEJOUR, s.ID_PATIENT, TRUNC(s.DATE_SORTIE) AS SORTIE, MIN(TRUNC(a.DATE_ACTE)) AS J0,
         EXTRACT(YEAR FROM MIN(TRUNC(a.DATE_ACTE))) AS ANNEE
  FROM CORA_REC.TB_ACTE a
  JOIN CORA_REC.TB_SEJOUR s ON s.ID_SEJOUR = a.ID_SEJOUR
  WHERE TRIM(a.CODE_ACTE) IN (", liste(actes_index), ")
    AND a.DATE_ACTE >= ", debut, " AND a.DATE_ACTE < ", fin, "
    AND s.DATE_SORTIE IS NOT NULL
    AND EXISTS (SELECT 1 FROM CORA_REC.TB_SYNTH_RSS r WHERE r.ID_SEJOUR = s.ID_SEJOUR)
  GROUP BY a.ID_SEJOUR, s.ID_PATIENT, TRUNC(s.DATE_SORTIE)
  HAVING EXTRACT(YEAR FROM MIN(TRUNC(a.DATE_ACTE))) IN (", paste(annees, collapse = ", "), ")
),
urg AS (
  SELECT s.ID_PATIENT, TRUNC(s.DATE_ENTREE) AS J
  FROM CORA_REC.TB_SEJOUR s
  WHERE TRIM(s.UF_ENTREE) IN (", liste(uf_urgences), ")
    AND s.DATE_ENTREE >= ", debut, " AND s.DATE_ENTREE < ", fin_urg, "
),
ret AS (
  SELECT i.ID_SEJOUR AS ID_INDEX, i.ANNEE, r.ID_SEJOUR, TRUNC(r.DATE_ENTREE) AS JD, 0 AS DELTA_IV,
         CASE WHEN TRIM(r.UF_ENTREE) IN (", liste(uf_urgences), ") THEN 1
              WHEN EXISTS (SELECT 1 FROM urg u
                           WHERE u.ID_PATIENT = r.ID_PATIENT
                             AND u.J BETWEEN TRUNC(r.DATE_ENTREE) - 1 AND TRUNC(r.DATE_ENTREE)) THEN 2
              WHEN TRUNC(r.DATE_CREAT) < TRUNC(r.DATE_ENTREE) THEN 4
              ELSE 3 END AS PROG
  FROM idx i
  JOIN CORA_REC.TB_SEJOUR r ON r.ID_PATIENT = i.ID_PATIENT AND r.ID_SEJOUR <> i.ID_SEJOUR
  WHERE TRUNC(r.DATE_ENTREE) BETWEEN i.J0 + 1 AND i.J0 + 90
    AND TRUNC(r.DATE_ENTREE) >= i.SORTIE
    AND r.DATE_SORTIE IS NOT NULL
    AND EXISTS (SELECT 1 FROM CORA_REC.TB_SYNTH_RSS x WHERE x.ID_SEJOUR = r.ID_SEJOUR)
  UNION ALL
  SELECT i.ID_SEJOUR, i.ANNEE, i.ID_SEJOUR, i.J0 + 1, 3, 0
  FROM idx i
),
gr AS (
  SELECT t.ID_INDEX, t.ANNEE, t.ID_SEJOUR, t.PROG,
         MAX(CASE WHEN ", acte_grade, " THEN 1 ELSE 0 END) AS GRADE_3_4
  FROM ret t
  LEFT JOIN CORA_REC.TB_ACTE a ON a.ID_SEJOUR = t.ID_SEJOUR AND TRUNC(a.DATE_ACTE) >= t.JD
  GROUP BY t.ID_INDEX, t.ANNEE, t.ID_SEJOUR, t.PROG
)")
  sql_comptes <- paste0(ctes, "
SELECT ANNEE,
       COUNT(DISTINCT CASE WHEN PROG = 0 THEN ID_INDEX END) AS N_INTERVENTIONS,
       COUNT(DISTINCT CASE WHEN PROG > 0 THEN ID_SEJOUR END) AS N_RETOURS,
       COUNT(DISTINCT CASE WHEN PROG IN (1, 2, 3) THEN ID_SEJOUR END) AS N_RETOURS_NON_PROGRAMMES,
       COUNT(DISTINCT CASE WHEN PROG IN (1, 2, 3) AND GRADE_3_4 = 1 THEN ID_SEJOUR END) AS N_REINTERVENTIONS,
       COUNT(DISTINCT CASE WHEN PROG IN (1, 2) AND GRADE_3_4 = 1 THEN ID_SEJOUR END) AS N_REINTERVENTIONS_URGENCES,
       COUNT(DISTINCT CASE WHEN PROG IN (1, 2, 3) AND GRADE_3_4 = 1 THEN ID_INDEX END) AS N_INTERVENTIONS_REPRISES,
       COUNT(DISTINCT CASE WHEN PROG = 0 AND GRADE_3_4 = 1 THEN ID_INDEX END) AS N_COMPLICATIONS_SEJOUR_INDEX
FROM gr
GROUP BY ANNEE")
  # Une ligne par retour et par acte de grade III ou IV, avec son libellé (ccam-nv-une-ligne-par-code) ; R les réunit par retour
  sql_sejours <- paste0(ctes, "
SELECT t.ANNEE, t.ID_INDEX, t.ID_SEJOUR, TRIM(si.NO_SEJOUR) AS NO_SEJOUR_INDEX, TO_CHAR(i.J0, 'YYYY-MM-DD') AS DATE_INTERVENTION,
       TRIM(sr.NO_SEJOUR) AS NO_SEJOUR_RETOUR, TO_CHAR(t.JD, 'YYYY-MM-DD') AS DATE_ENTREE_RETOUR, t.JD - i.J0 AS JOUR, t.PROG,
       TRIM(a.CODE_ACTE) AS CODE_ACTE, TRIM(v.LIBELLE_LONG) AS LIBELLE,
       CASE WHEN TRIM(a.CODE_ACTE) IN (", liste(grade_4), ") THEN 4 ELSE 3 END AS GRADE
FROM ret t
JOIN idx i ON i.ID_SEJOUR = t.ID_INDEX
JOIN CORA_REC.TB_SEJOUR si ON si.ID_SEJOUR = t.ID_INDEX
JOIN CORA_REC.TB_SEJOUR sr ON sr.ID_SEJOUR = t.ID_SEJOUR
JOIN CORA_REC.TB_ACTE a ON a.ID_SEJOUR = t.ID_SEJOUR AND TRUNC(a.DATE_ACTE) >= t.JD
LEFT JOIN CORA_REC.V_CCAM_NV v ON TRIM(v.CODE) = TRIM(a.CODE_ACTE) AND v.TYPE = 'A'
WHERE t.PROG > 0 AND ", acte_grade)

  con <- connexion()
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  n <- DBI::dbGetQuery(con, sql_comptes)
  base <- DBI::dbGetQuery(con, "SELECT SYS_CONTEXT('USERENV', 'DB_NAME') AS DB FROM DUAL")[[1]]
  names(n) <- toupper(names(n))
  comptes <- c("N_INTERVENTIONS", "N_RETOURS", "N_RETOURS_NON_PROGRAMMES", "N_REINTERVENTIONS",
               "N_REINTERVENTIONS_URGENCES", "N_INTERVENTIONS_REPRISES", "N_COMPLICATIONS_SEJOUR_INDEX")
  # Une année sans intervention a une ligne, à zéro
  n <- merge(data.frame(ANNEE = annees), n, all.x = TRUE)
  for (k in comptes) n[[k]] <- ifelse(is.na(n[[k]]), 0, as.numeric(n[[k]]))

  masque <- function(x, parent = NULL) {
    if (!masquer) return(as.character(x))
    out <- ifelse(x < 10, "<10", as.character(x))
    if (!is.null(parent)) out[x >= 10 & (parent - x) >= 1 & (parent - x) <= 9] <- "masqué"
    out
  }
  # Chaque compte est une partie d'un autre : son parent
  parents <- c(N_RETOURS = "N_INTERVENTIONS", N_RETOURS_NON_PROGRAMMES = "N_RETOURS",
               N_REINTERVENTIONS = "N_RETOURS_NON_PROGRAMMES", N_REINTERVENTIONS_URGENCES = "N_REINTERVENTIONS",
               N_INTERVENTIONS_REPRISES = "N_REINTERVENTIONS", N_COMPLICATIONS_SEJOUR_INDEX = "N_INTERVENTIONS")
  res <- data.frame(ANNEE = n$ANNEE, N_INTERVENTIONS = masque(n$N_INTERVENTIONS), stringsAsFactors = FALSE)
  for (k in names(parents)) res[[k]] <- masque(n[[k]], parent = if (k == "N_RETOURS") NULL else n[[parents[[k]]]])
  # Les retours vont jusqu'à fin mars de l'année suivante, et les deux derniers mois ne sont pas codés
  res$COMPLETE <- ifelse(Sys.Date() >= as.Date(paste0(res$ANNEE + 1, "-07-01")), "oui", "non")
  run_at <- format(Sys.time(), "%Y-%m-%d %H:%M")

  cat("Base :", base, "| exécutée le", run_at, "| masque :", if (masquer) "oui" else "non", "\n")
  cat("Réponse au questionnaire : la colonne N_REINTERVENTIONS, une ligne par année de l'intervention.\n\n")
  print(res, right = FALSE, row.names = FALSE)
  cat("\n",
      "N_INTERVENTIONS : séjours avec une sleeve ou un bypass dans l'année (actes ", paste(actes_index, collapse = ", "), ").\n",
      "N_RETOURS : autres séjours MCO du même patient, entrés de J1 à J90 après l'intervention.\n",
      "N_RETOURS_NON_PROGRAMMES : ceux qui n'ont pas été créés dans CORA avant leur jour d'entrée.\n",
      "N_REINTERVENTIONS : ceux-ci, avec au moins un acte de grade III ou IV. C'est le nombre du questionnaire.\n",
      "N_REINTERVENTIONS_URGENCES : parmi elles, celles entrées par les urgences : le minimum sûr. Les autres sont à vérifier en dossier (sejours = TRUE).\n",
      "N_INTERVENTIONS_REPRISES : interventions suivies d'au moins une réintervention (si l'unité est le patient).\n",
      "N_COMPLICATIONS_SEJOUR_INDEX : interventions avec un acte de grade III ou IV dans leur propre séjour ; hors réponse.\n",
      "COMPLETE : non, si les retours de la fin de l'année ne sont pas encore tous codés.\n", sep = "")
  res <- data.frame(DATABASE_NAME = base, RUN_AT = run_at, MASQUE = if (masquer) "oui" else "non", res,
                    stringsAsFactors = FALSE)
  if (!sejours) return(invisible(list(comptes = res, sejours = NULL)))

  l <- DBI::dbGetQuery(con, sql_sejours)
  names(l) <- toupper(names(l))
  cle <- paste(l$ID_INDEX, l$ID_SEJOUR)
  s <- l[!duplicated(cle), c("ANNEE", "NO_SEJOUR_INDEX", "DATE_INTERVENTION", "NO_SEJOUR_RETOUR",
                             "DATE_ENTREE_RETOUR", "JOUR", "PROG")]
  k <- cle[!duplicated(cle)]
  s$GRADE <- as.numeric(tapply(l$GRADE, cle, max)[k])
  acte <- ifelse(is.na(l$LIBELLE) | l$LIBELLE == "", l$CODE_ACTE, paste0(l$CODE_ACTE, " : ", l$LIBELLE))
  s$ACTES <- as.character(tapply(acte, cle, function(x) paste(sort(unique(x)), collapse = " ; "))[k])
  s$ENTREE <- c("1" = "par une UF d'urgences", "2" = "après un séjour d'urgences la veille ou le jour même",
                "3" = "sans urgence, créé le jour de l'entrée ou après", "4" = "créé avant le jour d'entrée")[as.character(s$PROG)]
  s$DANS_LA_REPONSE <- ifelse(s$PROG %in% 1:3, "oui", "non")
  s$A_VERIFIER <- ifelse(s$PROG == 3, "oui : un séjour programmé sans préadmission ?", "")
  s$PROG <- NULL
  s <- s[order(s$ANNEE, s$DATE_INTERVENTION, s$DATE_ENTREE_RETOUR), ]
  cat("\nSéjours concernés : un retour de J1 à J90 avec un acte de grade III ou IV, par ligne. Cette liste reste à l'hôpital.\n\n")
  print(s, right = FALSE, row.names = FALSE)
  invisible(list(comptes = res, sejours = s))
}
