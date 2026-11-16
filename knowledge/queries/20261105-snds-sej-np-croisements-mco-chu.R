# id: 20261105-snds-sej-np-croisements-mco-chu
# system: snds
# person_data: masked
# purpose: comprendre ce que code SEJ_NP (séjour programmé ou non ?) en le croisant avec le mode d'entrée (ENT_MOD), la provenance (ENT_PRV), STC_URG et le type de GHM, pour définir la réadmission non programmée de l'étude de mortalité (enquête fondations-snds, #127)
# Lignes : une par combinaison de valeurs (colonne PERIODE = "SEJ_NP=..|ENT_MOD=.." etc.) pour les séjours MCO du CHU (FINESS 760780239) sortis en 2025, hors GHM 90 et hors CMD 28 (séances) ; aucune donnée de personne, comptage de séjours.
# Masquage : N_LIGNES sort en <10 sous 10 (de 0 à 9), dans le script. Pas de total.
source(file.path(Sys.getenv("DIM_SNDS_COMMUN", "~/rdata/dim/commun"), "sortie.R"))   # sortir()

croisements <- function() {
  id <- "20261105-snds-sej-np-croisements-mco-chu"
  finess <- "760780239"
  etapes <- list()
  ajouter <- function(libelle, source, f) etapes[[length(etapes) + 1]] <<- list(libelle = libelle, source = source, f = f)
  base <- "FROM %sT_MCO25B B WHERE B.ETA_NUM = '%s' AND B.GRG_GHM NOT LIKE '90%%' AND SUBSTR(B.GRG_GHM, 1, 2) <> '28'"
  croiser <- function(libelle, source, expr) ajouter(libelle, source, function(pre)
    sprintf(paste0("SELECT ", expr, " AS PERIODE, COUNT(*) AS N ", base, " GROUP BY ", expr), pre, finess))
  nv <- function(col) sprintf("NVL(TO_CHAR(B.%s), 'NULL')", col)
  croiser("SEJ_NP x ENT_MOD", "sej_np_ent_mod", paste0("'SEJ_NP=' || ", nv("SEJ_NP"), " || '|ENT_MOD=' || ", nv("ENT_MOD")))
  croiser("SEJ_NP x ENT_PRV", "sej_np_ent_prv", paste0("'SEJ_NP=' || ", nv("SEJ_NP"), " || '|ENT_PRV=' || ", nv("ENT_PRV")))
  croiser("SEJ_NP x STC_URG", "sej_np_stc_urg", paste0("'SEJ_NP=' || ", nv("SEJ_NP"), " || '|STC_URG=' || ", nv("STC_URG")))
  croiser("SEJ_NP x type de GHM (3e caractère)", "sej_np_type_ghm", paste0("'SEJ_NP=' || ", nv("SEJ_NP"), " || '|TYPE_GHM=' || NVL(SUBSTR(B.GRG_GHM, 3, 1), 'NULL')"))
  croiser("STC_URG x ENT_MOD", "stc_urg_ent_mod", paste0("'STC_URG=' || ", nv("STC_URG"), " || '|ENT_MOD=' || ", nv("ENT_MOD")))

  masque <- function(n) ifelse(is.na(n), NA_character_, ifelse(n < 10, "<10", as.character(n)))
  conn <- DBI::dbConnect(ROracle::Oracle(), dbname = "IPIAMPR2.WORLD")
  on.exit(DBI::dbDisconnect(conn), add = TRUE)
  pb <- utils::txtProgressBar(min = 0, max = length(etapes), style = 3)
  res <- list()
  for (k in seq_along(etapes)) {
    e <- etapes[[k]]; t0 <- Sys.time()
    cat(sprintf("\n[%d/%d] %s ...\n", k, length(etapes), e$libelle)); utils::flush.console()
    out <- NULL; voie <- NA_character_; err <- ""
    for (pre in c("", "PROFIL_108.")) {          # synonyme de l'utilisateur, puis vue du schema
      r <- tryCatch(DBI::dbGetQuery(conn, e$f(pre)), error = function(x) x)
      if (!inherits(r, "error")) { out <- r; voie <- if (pre == "") "synonyme" else "PROFIL_108"; err <- ""; break }
      err <- substr(gsub("[\r\n]+", " ", conditionMessage(r)), 1, 120)
    }
    if (is.null(out)) {
      res[[k]] <- data.frame(SOURCE = e$source, PERIODE = e$libelle, VOIE = NA_character_, N_LIGNES = NA_character_, ERREUR = err)
      cat("   ERREUR :", err, "\n")
    } else {
      names(out) <- toupper(names(out))
      if (!nrow(out)) out <- data.frame(PERIODE = "(aucune ligne)", N = 0)
      res[[k]] <- data.frame(SOURCE = e$source, PERIODE = as.character(out$PERIODE), VOIE = voie,
                             N_LIGNES = masque(as.numeric(out$N)), ERREUR = "")
      cat(sprintf("   ok (%s) en %.0f s\n", voie, as.numeric(difftime(Sys.time(), t0, units = "secs"))))
    }
    utils::setTxtProgressBar(pb, k)
  }
  close(pb)
  tableau <- data.frame(QUERY_ID = id, DATABASE_NAME = "IPIAMPR2.WORLD", RUN_AT = format(Sys.time(), "%Y-%m-%d %H:%M"),
                        do.call(rbind, res), row.names = NULL)
  sortir(tableau, id, entete = FALSE)
}
croisements()
