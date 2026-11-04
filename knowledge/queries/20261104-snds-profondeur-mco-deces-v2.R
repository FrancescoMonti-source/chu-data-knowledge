# id: 20261104-snds-profondeur-mco-deces-v2
# system: snds
# person_data: masked
# purpose: profondeur des tables PMSI MCO du CHU (2020 à 2025 et lots 2026) et des décès du référentiel, pour l'étude de mortalité à 90 jours après chirurgie oncologique digestive (étape 4 du plan, #127)
# Remplace 20261104-snds-profondeur-mco-deces (SQL, ORA-00980 : un synonyme invalide, sans dire lequel). Même contenu, une requête par table, avec barre de progression ;
# une table qui échoue est réessayée avec le préfixe PROFIL_108. et son erreur est notée (colonne ERREUR) au lieu d'arrêter le reste.
# Lignes : sorties du CHU (FINESS 760780239) par mois dans T_MCO20C à T_MCO25C et dans les lots T_MCO26_01C à 05C (un mois dans deux lots = recouvrement) ;
# sorties à chaînage valide par an ; sorties de mode 9 (décès) par an ; décès du référentiel IR_BEN_R par mois depuis 2024 (une seule lecture, COUNT(*) par ligne de PSA) ;
# existence de tables par noms exacts (le catalogue est très lent : jamais de motif). IR_PRS_F n'est pas lue.
# Masquage : N_LIGNES sort en <10 sous 10 (de 0 à 9), dans le script. Pas de total.
source(file.path(Sys.getenv("DIM_SNDS_COMMUN", "~/rdata/dim/commun"), "sortie.R"))   # sortir()

profondeur <- function() {
  id <- "20261104-snds-profondeur-mco-deces-v2"
  finess <- "760780239"
  etapes <- list()
  ajouter <- function(libelle, source, f) etapes[[length(etapes) + 1]] <<- list(libelle = libelle, source = source, f = f)
  an2 <- c("20", "21", "22", "23", "24", "25")
  invisible(lapply(an2, function(aa) {
    ajouter(paste0("T_MCO", aa, "C : sorties du CHU par mois"), "pmsi_chu_sorties_par_mois", function(pre)
      sprintf("SELECT TO_CHAR(C.EXE_SOI_DTF, 'YYYY-MM') AS PERIODE, COUNT(*) AS N FROM %sT_MCO%sC C WHERE C.ETA_NUM = '%s' GROUP BY TO_CHAR(C.EXE_SOI_DTF, 'YYYY-MM')", pre, aa, finess))
  }))
  invisible(lapply(1:5, function(n) {
    ajouter(sprintf("T_MCO26_%02dC : sorties du CHU par mois (lot %d)", n, n), sprintf("pmsi_chu_sorties_par_mois_lot_2026_%02d", n), function(pre)
      sprintf("SELECT TO_CHAR(C.EXE_SOI_DTF, 'YYYY-MM') AS PERIODE, COUNT(*) AS N FROM %sT_MCO26_%02dC C WHERE C.ETA_NUM = '%s' GROUP BY TO_CHAR(C.EXE_SOI_DTF, 'YYYY-MM')", pre, n, finess))
  }))
  invisible(lapply(an2, function(aa) {
    ajouter(paste0("T_MCO", aa, "C : sorties a chainage valide"), "pmsi_chu_chainage_valide_par_an", function(pre)
      sprintf("SELECT TO_CHAR(C.EXE_SOI_DTF, 'YYYY') AS PERIODE, COUNT(*) AS N FROM %sT_MCO%sC C WHERE C.ETA_NUM = '%s' AND C.NIR_RET = '0' AND C.NAI_RET = '0' AND C.SEX_RET = '0' AND C.SEJ_RET = '0' AND C.FHO_RET = '0' AND C.PMS_RET = '0' AND C.DAT_RET = '0' AND C.COH_NAI_RET = '0' AND C.COH_SEX_RET = '0' GROUP BY TO_CHAR(C.EXE_SOI_DTF, 'YYYY')", pre, aa, finess))
    ajouter(paste0("T_MCO", aa, "B : sorties de mode 9 (deces)"), "pmsi_chu_sortie_deces_par_an", function(pre)
      sprintf("SELECT '20%s' AS PERIODE, COUNT(*) AS N FROM %sT_MCO%sB B WHERE B.ETA_NUM = '%s' AND B.SOR_MOD = '9'", aa, pre, aa, finess))
  }))
  ajouter("IR_BEN_R : deces par mois depuis 2024 (la plus longue)", "ir_ben_r_deces_par_mois", function(pre)
    sprintf("SELECT TO_CHAR(R.BEN_DCD_DTE, 'YYYY-MM') AS PERIODE, COUNT(*) AS N FROM %sIR_BEN_R R WHERE R.BEN_DCD_DTE >= DATE '2024-01-01' AND R.BEN_DCD_DTE < DATE '2100-01-01' GROUP BY TO_CHAR(R.BEN_DCD_DTE, 'YYYY-MM')", pre))
  ajouter("Catalogue : tables 2025 et 2026 par noms exacts", "tables_visibles", function(pre)
    "SELECT O.OBJECT_NAME AS PERIODE, COUNT(*) AS N FROM ALL_OBJECTS O WHERE O.OBJECT_NAME IN ('T_MCO25B', 'T_MCO26B', 'T_MCO26_01B', 'T_MCO26_02B', 'T_MCO26_03B', 'T_MCO26_04B', 'T_MCO26_05B', 'T_MCO26_06B', 'T_MCO26_01C', 'T_MCO26_05C') GROUP BY O.OBJECT_NAME")

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
profondeur()
