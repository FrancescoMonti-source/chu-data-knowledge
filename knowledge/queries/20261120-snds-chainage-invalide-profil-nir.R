# id: 20261120-snds-chainage-invalide-profil-nir
# system: snds
# person_data: masked
# purpose: décrire qui sont les séjours MCO à chaînage invalide, par classe de code (NIR_RET = 2, 1, 3, NIR_RET = 9 avec FHO_RET = 1, cohérence, autres) comparés aux séjours valides : sexe, âge, département de résidence, mode d'entrée et de sortie, durée ; partage des NIR_ANO_17 entre séjours ; présence d'un échantillon de NIR_ANO_17 dans IR_BEN_R (enquête chainage-invalide-mco-snds, étape 4 du plan)
# Lignes : une par (SOURCE, ANNEE, CLASSE, DIM, VALEUR). PMSI 2019, 2024 et 2025, tous établissements, sans autre filtre.
# Masquage : toute colonne N_ sort en <10 de 0 à 9, dans le script ; dans une répartition dont le total sort (une classe, une dimension),
# une seule cellule masquée entraîne le masquage de la plus petite cellule visible. Une part (PCT_) n'est donnée que si ses deux effectifs sont >= 10.
# Aucune ligne de patient n'est lue : Oracle renvoie des agrégats (le partage des NIR est agrégé par classe de nombre de séjours).
# cdk: tables-snds-vues-profil-108 (préfixe PROFIL_108.), joindre-pmsi-mco-referentiel-par-nir (NIR_ANO_17 = BEN_NIR_PSA), chainage-invalide-mco-snds-inegal-selon-etablissement
source(file.path(Sys.getenv("DIM_SNDS_COMMUN", "~/rdata/dim/commun"), "sortie.R"))   # sortir()

profil_nir <- function(annees = c(2025, 2024, 2019), annee_ir = 2025, taille_echantillon = 2000,
                       cache = "~/rdata/dim/cdk/cache_chainage_profil") {
  id <- "20261120-snds-chainage-invalide-profil-nir"
  codes <- c("NIR_RET", "NAI_RET", "SEX_RET", "SEJ_RET", "FHO_RET", "PMS_RET", "DAT_RET", "COH_NAI_RET", "COH_SEX_RET")
  classe <- paste0(
    "CASE WHEN C.ETA_NUM IS NULL THEN 'sans_ligne_C' ",
    "WHEN ", paste(sprintf("C.%s = '0'", codes), collapse = " AND "), " THEN 'valide' ",
    "WHEN C.NIR_RET = '9' AND C.FHO_RET = '1' THEN 'nir_ret_9_fho_ret_1' ",
    "WHEN C.NIR_RET = '2' THEN 'nir_ret_2' WHEN C.NIR_RET = '1' THEN 'nir_ret_1' WHEN C.NIR_RET = '3' THEN 'nir_ret_3' ",
    "WHEN C.COH_NAI_RET = '1' OR C.COH_SEX_RET = '1' THEN 'coherence' ELSE 'autre_invalide' END")
  de <- function(an) { aa <- sprintf("%02d", an %% 100)
    paste0("FROM PROFIL_108.T_MCO", aa, "B B LEFT JOIN PROFIL_108.T_MCO", aa, "C C ON B.ETA_NUM = C.ETA_NUM AND B.RSA_NUM = C.RSA_NUM") }

  sql_profil <- function(an) paste0(
    "SELECT CLASSE, SEXE, AGE_CL, DEP, ENT_MOD, SOR_MOD, DUREE, COUNT(*) AS N FROM (SELECT ", classe, " AS CLASSE, ",
    "NVL(TO_CHAR(B.COD_SEX), 'vide') AS SEXE, ",
    "CASE WHEN B.AGE_ANN IS NULL THEN 'inconnu' WHEN B.AGE_ANN < 1 THEN '0' WHEN B.AGE_ANN < 18 THEN '1-17' ",
    "WHEN B.AGE_ANN < 45 THEN '18-44' WHEN B.AGE_ANN < 65 THEN '45-64' ELSE '65+' END AS AGE_CL, ",
    "NVL(TO_CHAR(B.BDI_DEP), 'vide') AS DEP, NVL(TO_CHAR(B.ENT_MOD), 'vide') AS ENT_MOD, NVL(TO_CHAR(B.SOR_MOD), 'vide') AS SOR_MOD, ",
    "CASE WHEN B.SEJ_NBJ IS NULL THEN 'vide' WHEN B.SEJ_NBJ = 0 THEN '0' WHEN B.SEJ_NBJ < 3 THEN '1-2' ",
    "WHEN B.SEJ_NBJ < 8 THEN '3-7' ELSE '8+' END AS DUREE ", de(an), ") ",
    "GROUP BY CLASSE, SEXE, AGE_CL, DEP, ENT_MOD, SOR_MOD, DUREE")

  # Combien de séjours porte chaque NIR_ANO_17, agrégé par classe de nombre de séjours (un NIR fictif partagé en porte beaucoup).
  sql_partage <- function(an) paste0(
    "SELECT CLASSE, CASE WHEN NS = 1 THEN '1' WHEN NS < 5 THEN '2-4' WHEN NS < 10 THEN '5-9' WHEN NS < 100 THEN '10-99' ",
    "WHEN NS < 1000 THEN '100-999' ELSE '1000+' END AS NB_SEJ_PAR_NIR, COUNT(*) AS N_NIR, SUM(NS) AS N_SEJ ",
    "FROM (SELECT ", classe, " AS CLASSE, NVL(C.NIR_ANO_17, 'vide') AS NIR, COUNT(*) AS NS ", de(an),
    " GROUP BY ", classe, ", NVL(C.NIR_ANO_17, 'vide')) ",
    "GROUP BY CLASSE, CASE WHEN NS = 1 THEN '1' WHEN NS < 5 THEN '2-4' WHEN NS < 10 THEN '5-9' WHEN NS < 100 THEN '10-99' ",
    "WHEN NS < 1000 THEN '100-999' ELSE '1000+' END")

  # Échantillon : les premiers NIR_ANO_17 distincts de chaque classe (ordre alphabétique), retrouvés ou non dans IR_BEN_R.
  sql_ir <- function(an) paste0(
    "SELECT CLASSE, COUNT(*) AS N_NIR, SUM(CASE WHEN EXISTS (SELECT 1 FROM IR_BEN_R R WHERE R.BEN_NIR_PSA = S.NIR) THEN 1 ELSE 0 END) AS N_TROUVES ",
    "FROM (SELECT CLASSE, NIR, ROW_NUMBER() OVER (PARTITION BY CLASSE ORDER BY NIR) AS RN FROM (SELECT DISTINCT ", classe,
    " AS CLASSE, C.NIR_ANO_17 AS NIR ", de(an), " WHERE C.NIR_ANO_17 IS NOT NULL)) S WHERE RN <= ", taille_echantillon,
    " GROUP BY CLASSE")

  etapes <- c(lapply(annees, function(an) list(cle = paste0("profil_", an), an = an, sql = sql_profil(an))),
              lapply(annees, function(an) list(cle = paste0("partage_", an), an = an, sql = sql_partage(an))),
              list(list(cle = paste0("ir_", annee_ir), an = annee_ir, sql = sql_ir(annee_ir))))

  dir.create(path.expand(cache), showWarnings = FALSE, recursive = TRUE)
  conn <- NULL
  on.exit(if (!is.null(conn)) DBI::dbDisconnect(conn), add = TRUE)
  lus <- list(); erreurs <- character()
  for (k in seq_along(etapes)) {
    e <- etapes[[k]]
    f <- file.path(path.expand(cache), sprintf("%s_%s.rds", e$cle, substr(digest::digest(e$sql, algo = "sha256", serialize = FALSE), 1, 12)))
    cat(sprintf("\n[%d/%d] %s ... ", k, length(etapes), e$cle)); utils::flush.console()
    if (file.exists(f)) { lus[[e$cle]] <- readRDS(f); cat("(cache)\n"); next }
    if (is.null(conn)) conn <- DBI::dbConnect(ROracle::Oracle(), dbname = "IPIAMPR2.WORLD")
    t0 <- Sys.time()
    r <- tryCatch(DBI::dbGetQuery(conn, e$sql), error = function(x) x)
    if (inherits(r, "error")) { erreurs[e$cle] <- substr(gsub("[\r\n]+", " ", conditionMessage(r)), 1, 120); cat("ERREUR :", erreurs[e$cle], "\n"); next }
    names(r) <- toupper(names(r))
    for (j in intersect(c("N", "N_NIR", "N_SEJ", "N_TROUVES"), names(r))) r[[j]] <- as.numeric(r[[j]])
    tryCatch(saveRDS(r, f), error = function(x) cat("(cache non écrit : ", conditionMessage(x), ") "))
    lus[[e$cle]] <- r
    cat(sprintf("ok en %.0f s, %d lignes\n", as.numeric(difftime(Sys.time(), t0, units = "secs")), nrow(r)))
  }

  masque <- function(n) ifelse(is.na(n), NA_character_, ifelse(n < 10, "<10", format(n, scientific = FALSE, trim = TRUE)))
  masque_partition <- function(n) {
    out <- masque(n); cach <- which(n < 10)
    if (length(cach) == 1 && length(n) > 1) { j <- setdiff(order(n), cach)[1]; out[j] <- "<10" }
    out
  }
  pct <- function(a, b) ifelse(!is.na(a) & !is.na(b) & a >= 10 & b >= 10, sprintf("%.2f", 100 * a / b), NA_character_)
  ligne <- function(source, an, classe, dim, valeur, n_sej, n_nir = NA, n_trouves = NA, pct_ = NA_character_)
    data.frame(SOURCE = source, ANNEE = an, CLASSE = classe, DIM = dim, VALEUR = valeur, N_SEJ = n_sej, N_NIR = n_nir,
               N_TROUVES = n_trouves, PCT = pct_, stringsAsFactors = FALSE)
  res <- list(); ajoute <- function(x) res[[length(res) + 1]] <<- x

  for (an in annees) {
    x <- lus[[paste0("profil_", an)]]
    if (!is.null(x)) {
      tot <- tapply(x$N, x$CLASSE, sum)
      ajoute(ligne("classe", an, names(tot), "total", "", masque_partition(as.numeric(tot)), pct_ = pct(as.numeric(tot), sum(x$N))))
      for (dim in c("SEXE", "AGE_CL", "DEP", "ENT_MOD", "SOR_MOD", "DUREE")) for (cl in names(tot)) {
        y <- x[x$CLASSE == cl, ]; s <- tapply(y$N, y[[dim]], sum)
        ajoute(ligne("profil", an, cl, tolower(dim), names(s), masque_partition(as.numeric(s)), pct_ = pct(as.numeric(s), sum(y$N))))
      }
    }
    p <- lus[[paste0("partage_", an)]]
    if (!is.null(p)) for (cl in unique(p$CLASSE)) {
      y <- p[p$CLASSE == cl, ]
      # Des séjours portés par moins de 10 NIR sont une statistique sur moins de 10 personnes : masqués aussi.
      cach <- y$N_SEJ < 10 | y$N_NIR < 10
      if (sum(cach) == 1 && nrow(y) > 1) cach[setdiff(order(y$N_SEJ), which(cach))[1]] <- TRUE
      n_sej <- ifelse(cach, "<10", masque(y$N_SEJ))
      ajoute(ligne("partage_nir", an, cl, "nb_sej_par_nir", y$NB_SEJ_PAR_NIR, n_sej, masque_partition(y$N_NIR),
                   pct_ = ifelse(cach, NA_character_, pct(y$N_SEJ, sum(y$N_SEJ)))))
    }
  }
  ir <- lus[[paste0("ir_", annee_ir)]]
  if (!is.null(ir)) ajoute(ligne("echantillon_ir_ben_r", annee_ir, ir$CLASSE, "nir_trouves_dans_ir_ben_r", "", NA_character_,
                                 masque(ir$N_NIR), masque(ir$N_TROUVES), pct(ir$N_TROUVES, ir$N_NIR)))
  for (cle in names(erreurs)) ajoute(ligne("erreur", NA, cle, erreurs[[cle]], "", NA_character_))

  tableau <- data.frame(QUERY_ID = id, DATABASE_NAME = "IPIAMPR2.WORLD", RUN_AT = format(Sys.time(), "%Y-%m-%d %H:%M"),
                        do.call(rbind, res), row.names = NULL, stringsAsFactors = FALSE)
  for (j in c("N_SEJ", "N_NIR", "N_TROUVES")) tableau[[j]] <- as.character(tableau[[j]])
  sortir(tableau, id, entete = FALSE)
}
profil_nir()
