# id: 20261120-snds-chainage-invalide-mco
# system: snds
# person_data: masked
# purpose: décrire les séjours MCO dont un code retour du chaînage (T_MCOaaC) n'est pas à 0 : combien, quels codes, quelles années, quels types de séjours, quels établissements, et au CHU (enquête chainage-invalide-mco-snds, étape 2 du plan)
# Lignes : une par (SOURCE, ANNEE, DIM1, DIM2). Comptages de séjours de T_MCOaaB (LEFT JOIN T_MCOaaC), 2008 à 2025, tous établissements, sans aucun filtre.
# Un séjour est « invalide » si l'un des codes retour du filtre HDH n'est pas '0' (NULL compris) : NIR, NAI, SEX, SEJ, FHO, PMS, DAT, et COH_NAI, COH_SEX depuis 2013.
# Masquage : toute colonne N_ sort en <10 de 0 à 9, dans le script ; dans une partition dont le total sort, une seule cellule masquée
# entraîne le masquage de la plus petite cellule visible (suppression secondaire). Une part (PCT_) n'est donnée que si ses deux effectifs sont >= 10.
# Les lignes lues restent des agrégats (par établissement, combinaison de codes, type, âge) ; un cache .rds par année dans ~/rdata/dim/cdk/cache_chainage.
# cdk: tables-snds-vues-profil-108 (préfixe PROFIL_108.), roracle-fonctionne-portail-snds
source(file.path(Sys.getenv("DIM_SNDS_COMMUN", "~/rdata/dim/commun"), "sortie.R"))   # sortir()

chainage_invalide <- function(annees = 2025:2008, cache = "~/rdata/dim/cdk/cache_chainage") {
  id <- "20261120-snds-chainage-invalide-mco"
  chu <- "760780239"
  codes_tous <- c("NIR_RET", "NAI_RET", "SEX_RET", "SEJ_RET", "FHO_RET", "PMS_RET", "DAT_RET", "COH_NAI_RET", "COH_SEX_RET")

  # Une lecture par année : agrégat par établissement x combinaison des codes x type de séjour x âge x NIR x SEJ_TYP.
  sql_annee <- function(an) {
    aa <- sprintf("%02d", an %% 100)
    codes <- if (an >= 2013) codes_tous else codes_tous[1:7]
    combo <- paste(sprintf("NVL(TO_CHAR(C.%s), '.')", codes), collapse = " || '|' || ")
    if (an < 2013) combo <- paste0(combo, " || '|-|-'")   # COH_* absents avant 2013 : '-' = sans objet
    paste0(
      "SELECT ETA_NUM, COMBO, TYPE_SEJ, AGE_CL, NIR_FORME, SEJ_TYP_B, COUNT(*) AS N FROM (SELECT B.ETA_NUM AS ETA_NUM, ",
      "CASE WHEN C.ETA_NUM IS NULL THEN 'sans_ligne_C' ELSE ", combo, " END AS COMBO, ",
      "CASE WHEN SUBSTR(B.GRG_GHM, 1, 2) = '90' THEN 'erreur_90' WHEN SUBSTR(B.GRG_GHM, 1, 2) = '28' THEN 'seances_28' ",
      "WHEN SUBSTR(B.GRG_GHM, 1, 2) = '15' THEN 'nouveau_nes_15' WHEN SUBSTR(B.GRG_GHM, 1, 2) = '14' THEN 'obstetrique_14' ",
      "WHEN SUBSTR(B.GRG_GHM, 3, 1) = 'C' THEN 'chirurgical_C' WHEN SUBSTR(B.GRG_GHM, 3, 1) = 'K' THEN 'interventionnel_K' ",
      "WHEN SUBSTR(B.GRG_GHM, 3, 1) = 'M' THEN 'medical_M' ELSE 'autre' END AS TYPE_SEJ, ",
      "CASE WHEN B.AGE_ANN IS NULL THEN 'inconnu' WHEN B.AGE_ANN < 1 THEN '0' WHEN B.AGE_ANN < 18 THEN '1-17' ",
      "WHEN B.AGE_ANN < 65 THEN '18-64' ELSE '65+' END AS AGE_CL, ",
      "CASE WHEN C.NIR_ANO_17 IS NULL THEN 'null' WHEN UPPER(SUBSTR(C.NIR_ANO_17, 1, 5)) = 'XXXXX' THEN 'xxx_fictif' ELSE 'autre' END AS NIR_FORME, ",
      "CASE WHEN B.SEJ_TYP = 'B' THEN 'B' ELSE 'non_B' END AS SEJ_TYP_B ",
      "FROM PROFIL_108.T_MCO", aa, "B B LEFT JOIN PROFIL_108.T_MCO", aa, "C C ON B.ETA_NUM = C.ETA_NUM AND B.RSA_NUM = C.RSA_NUM) ",
      "GROUP BY ETA_NUM, COMBO, TYPE_SEJ, AGE_CL, NIR_FORME, SEJ_TYP_B")
  }

  dir.create(path.expand(cache), showWarnings = FALSE, recursive = TRUE)
  conn <- NULL
  on.exit(if (!is.null(conn)) DBI::dbDisconnect(conn), add = TRUE)
  lus <- list(); erreurs <- character()
  for (k in seq_along(annees)) {
    an <- annees[k]; sql <- sql_annee(an)
    f <- file.path(path.expand(cache), sprintf("%d_%s.rds", an, substr(digest::digest(sql, algo = "sha256", serialize = FALSE), 1, 12)))
    cat(sprintf("\n[%d/%d] PMSI MCO %d ... ", k, length(annees), an)); utils::flush.console()
    if (file.exists(f)) { lus[[as.character(an)]] <- readRDS(f); cat("(cache)\n"); next }
    if (is.null(conn)) conn <- DBI::dbConnect(ROracle::Oracle(), dbname = "IPIAMPR2.WORLD")
    t0 <- Sys.time()
    r <- tryCatch(DBI::dbGetQuery(conn, sql), error = function(e) e)
    if (inherits(r, "error")) {
      erreurs[as.character(an)] <- substr(gsub("[\r\n]+", " ", conditionMessage(r)), 1, 120)
      cat("ERREUR :", erreurs[as.character(an)], "\n"); next
    }
    names(r) <- toupper(names(r)); r$N <- as.numeric(r$N); r$ANNEE <- an
    tryCatch(saveRDS(r, f), error = function(e) cat("(cache non écrit : ", conditionMessage(e), ") "))
    lus[[as.character(an)]] <- r
    cat(sprintf("ok en %.0f s, %d lignes d'agrégat\n", as.numeric(difftime(Sys.time(), t0, units = "secs")), nrow(r)))
  }
  if (!length(lus)) stop("Aucune année lue.")
  d <- do.call(rbind, lus)
  ok <- function(x) x == "0" | x == "-"                      # '-' : code sans objet cette année-là
  parts <- strsplit(ifelse(d$COMBO == "sans_ligne_C", paste(rep(".", 9), collapse = "|"), d$COMBO), "|", fixed = TRUE)
  m <- do.call(rbind, parts); colnames(m) <- codes_tous
  d$INVALIDE <- !apply(m, 1, function(v) all(ok(v)))
  # Libellé lisible de la combinaison : les codes non nuls seulement (NULL écrit « vide »).
  d$CODES_NON_NULS <- ifelse(d$COMBO == "sans_ligne_C", "sans_ligne_C", apply(m, 1, function(v) {
    i <- which(!ok(v)); if (!length(i)) "tous_0" else if (all(v[i] == ".")) "tous_vide" else paste0(codes_tous[i], "=", ifelse(v[i] == ".", "vide", v[i]), collapse = " ")
  }))

  masque <- function(n) ifelse(is.na(n), NA_character_, ifelse(n < 10, "<10", format(n, scientific = FALSE, trim = TRUE)))
  # Partition dont le total sort : si une seule cellule est masquée, masquer aussi la plus petite visible.
  masque_partition <- function(n) {
    out <- masque(n); cach <- which(n < 10)
    if (length(cach) == 1 && length(n) > 1) { j <- setdiff(order(n), cach)[1]; out[j] <- "<10" }
    out
  }
  pct <- function(a, b) ifelse(a >= 10 & b >= 10 & b > 0, sprintf("%.2f", 100 * a / b), NA_character_)
  ligne <- function(source, annee, dim1, dim2, n_sej, n_inv, n_sej_m = masque(n_sej), n_inv_m = masque(n_inv))
    data.frame(SOURCE = source, ANNEE = annee, DIM1 = dim1, DIM2 = dim2, N_SEJ = n_sej_m, N_INVALIDE = n_inv_m,
               PCT_INVALIDE = pct(n_inv, n_sej), stringsAsFactors = FALSE)
  res <- list()
  ajoute <- function(x) res[[length(res) + 1]] <<- x

  for (an in sort(unique(d$ANNEE))) {
    x <- d[d$ANNEE == an, ]
    tot <- sum(x$N); inv <- sum(x$N[x$INVALIDE])
    hdh <- !(x$TYPE_SEJ == "erreur_90") & x$SEJ_TYP_B == "non_B"
    ajoute(rbind(ligne("annee", an, "tous", "", tot, inv),
                 ligne("annee", an, "hors_GHM90_hors_SEJ_TYP_B", "", sum(x$N[hdh]), sum(x$N[hdh & x$INVALIDE]))))

    # Chaque code : séjours où il n'est pas '0' (NULL et sans ligne C compris), par valeur.
    for (j in seq_along(codes_tous)) {
      v <- ifelse(x$COMBO == "sans_ligne_C", "sans_ligne_C", m[d$ANNEE == an, j])
      v <- ifelse(v == ".", "vide", v)
      sel <- !(v %in% c("0", "-", "sans_ligne_C"))   # les séjours sans ligne C sortent dans « combinaison »
      if (!any(sel)) next
      s <- tapply(x$N[sel], v[sel], sum)
      ajoute(data.frame(SOURCE = "code_valeur", ANNEE = an, DIM1 = codes_tous[j], DIM2 = names(s), N_SEJ = masque_partition(as.numeric(s)),
                        N_INVALIDE = masque_partition(as.numeric(s)), PCT_INVALIDE = pct(as.numeric(s), tot), stringsAsFactors = FALSE))
    }

    # Combinaisons de codes non nuls : les 15 plus fréquentes parmi les invalides.
    s <- sort(tapply(x$N[x$INVALIDE], x$CODES_NON_NULS[x$INVALIDE], sum), decreasing = TRUE)
    if (length(s)) { s <- head(s, 15)
      ajoute(data.frame(SOURCE = "combinaison", ANNEE = an, DIM1 = names(s), DIM2 = "", N_SEJ = masque(as.numeric(s)),
                        N_INVALIDE = masque(as.numeric(s)), PCT_INVALIDE = pct(as.numeric(s), inv), stringsAsFactors = FALSE)) }

    # Par type de séjour, classe d'âge, forme du NIR_ANO_17, SEJ_TYP : séjours et invalides (deux partitions du total).
    for (dim in c("TYPE_SEJ", "AGE_CL", "NIR_FORME", "SEJ_TYP_B")) {
      a <- tapply(x$N, x[[dim]], sum); b <- tapply(x$N * x$INVALIDE, x[[dim]], sum)[names(a)]
      ajoute(data.frame(SOURCE = tolower(dim), ANNEE = an, DIM1 = names(a), DIM2 = "", N_SEJ = masque_partition(as.numeric(a)),
                        N_INVALIDE = masque_partition(as.numeric(b)), PCT_INVALIDE = pct(as.numeric(b), as.numeric(a)), stringsAsFactors = FALSE))
    }

    # Établissements (ETA_NUM, FINESS public) : concentration, puis les 20 qui portent le plus de séjours invalides.
    e_n <- tapply(x$N, x$ETA_NUM, sum); e_i <- tapply(x$N * x$INVALIDE, x$ETA_NUM, sum)[names(e_n)]
    p <- e_i / e_n; o <- order(-e_i)
    cum <- unname(cumsum(e_i[o])) / max(inv, 1)
    conc <- c(nb_etablissements = length(e_n), nb_etab_avec_invalide = sum(e_i > 0),
              nb_etab_pct_invalide_sup_10 = sum(p > 0.10), nb_etab_pct_invalide_sup_50 = sum(p > 0.50),
              part_invalides_top_10_etab = round(100 * cum[min(10, length(cum))], 1),
              part_invalides_top_50_etab = round(100 * cum[min(50, length(cum))], 1),
              nb_etab_pour_80pct_invalides = which(cum >= 0.8)[1],
              pct_invalide_median_etab_100_sej_ou_plus = round(100 * stats::median(p[e_n >= 100]), 2))
    ajoute(data.frame(SOURCE = "concentration", ANNEE = an, DIM1 = names(conc), DIM2 = as.character(unname(conc)),
                      N_SEJ = NA_character_, N_INVALIDE = NA_character_, PCT_INVALIDE = NA_character_, stringsAsFactors = FALSE))
    top <- head(o, 20)
    princ <- vapply(names(e_n)[top], function(eta) {
      y <- x[x$ETA_NUM == eta & x$INVALIDE, ]; s <- tapply(y$N, y$CODES_NON_NULS, sum); names(s)[which.max(s)] }, "")
    ajoute(data.frame(SOURCE = "etablissement_top20", ANNEE = an, DIM1 = names(e_n)[top], DIM2 = princ,
                      N_SEJ = masque(as.numeric(e_n[top])), N_INVALIDE = masque(as.numeric(e_i[top])),
                      PCT_INVALIDE = pct(as.numeric(e_i[top]), as.numeric(e_n[top])), stringsAsFactors = FALSE))

    # CHU de Rouen : combinaisons de codes, partition de ses séjours.
    y <- x[x$ETA_NUM == chu, ]
    if (nrow(y)) {
      s <- tapply(y$N, y$CODES_NON_NULS, sum)
      ajoute(data.frame(SOURCE = "chu_rouen", ANNEE = an, DIM1 = names(s), DIM2 = "", N_SEJ = masque_partition(as.numeric(s)),
                        N_INVALIDE = ifelse(names(s) == "tous_0", "0", masque_partition(as.numeric(s))),
                        PCT_INVALIDE = pct(as.numeric(s), sum(y$N)), stringsAsFactors = FALSE))
    }
  }
  for (a in names(erreurs))
    ajoute(data.frame(SOURCE = "erreur", ANNEE = as.integer(a), DIM1 = erreurs[[a]], DIM2 = "", N_SEJ = NA_character_,
                      N_INVALIDE = NA_character_, PCT_INVALIDE = NA_character_, stringsAsFactors = FALSE))

  tableau <- data.frame(QUERY_ID = id, DATABASE_NAME = "IPIAMPR2.WORLD", RUN_AT = format(Sys.time(), "%Y-%m-%d %H:%M"),
                        do.call(rbind, res), row.names = NULL, stringsAsFactors = FALSE)
  sortir(tableau, id, entete = FALSE)
}
chainage_invalide()
