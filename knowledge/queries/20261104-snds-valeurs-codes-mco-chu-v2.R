# id: 20261104-snds-valeurs-codes-mco-chu-v2
# system: snds
# person_data: masked
# purpose: valeurs des codes du PMSI MCO du CHU utiles à l'étude de mortalité (SEJ_NP, STC_URG, ENT_MOD, SOR_MOD, SEJ_TYP) et clé de jointure PMSI-référentiel (étape 4 du plan, #127)
# Remplace 20261104-snds-valeurs-codes-mco-chu (SQL) : même contenu, une requête par étape, barre de progression, repli PROFIL_108., erreur notée par étape.
# Lignes : une par variable et valeur (colonne PERIODE = la valeur) pour les séjours du CHU (FINESS 760780239) en 2025 ; nir_ano_17_dans_ir_ben_r : au plus 5000 NIR_ANO_17 distincts de ces séjours (NIR valide), comptés selon qu'ils sont ou non un BEN_NIR_PSA d'IR_BEN_R (une seule lecture bornée de IR_BEN_R). IR_PRS_F n'est pas lue.
# Masquage : N_LIGNES sort en <10 sous 10 (de 0 à 9), dans le script. Pas de total.
source(file.path(Sys.getenv("DIM_SNDS_COMMUN", "~/rdata/dim/commun"), "sortie.R"))   # sortir()

valeurs <- function() {
  id <- "20261104-snds-valeurs-codes-mco-chu-v2"
  finess <- "760780239"
  etapes <- list()
  ajouter <- function(libelle, source, f) etapes[[length(etapes) + 1]] <<- list(libelle = libelle, source = source, f = f)
  ajouter("T_MCO25B : valeurs de SEJ_NP", "SEJ_NP", function(pre)
    sprintf("SELECT NVL(TO_CHAR(B.SEJ_NP), 'NULL') AS PERIODE, COUNT(*) AS N FROM %sT_MCO25B B WHERE B.ETA_NUM = '%s' GROUP BY B.SEJ_NP", pre, finess))
  ajouter("T_MCO25B : valeurs de STC_URG", "STC_URG", function(pre)
    sprintf("SELECT NVL(TO_CHAR(B.STC_URG), 'NULL') AS PERIODE, COUNT(*) AS N FROM %sT_MCO25B B WHERE B.ETA_NUM = '%s' GROUP BY B.STC_URG", pre, finess))
  ajouter("T_MCO25B : valeurs de ENT_MOD", "ENT_MOD", function(pre)
    sprintf("SELECT NVL(TO_CHAR(B.ENT_MOD), 'NULL') AS PERIODE, COUNT(*) AS N FROM %sT_MCO25B B WHERE B.ETA_NUM = '%s' GROUP BY B.ENT_MOD", pre, finess))
  ajouter("T_MCO25B : valeurs de SOR_MOD", "SOR_MOD", function(pre)
    sprintf("SELECT NVL(TO_CHAR(B.SOR_MOD), 'NULL') AS PERIODE, COUNT(*) AS N FROM %sT_MCO25B B WHERE B.ETA_NUM = '%s' GROUP BY B.SOR_MOD", pre, finess))
  ajouter("T_MCO25B : valeurs de SEJ_TYP", "SEJ_TYP", function(pre)
    sprintf("SELECT NVL(TO_CHAR(B.SEJ_TYP), 'NULL') AS PERIODE, COUNT(*) AS N FROM %sT_MCO25B B WHERE B.ETA_NUM = '%s' GROUP BY B.SEJ_TYP", pre, finess))
  ajouter("IR_BEN_R : NIR_ANO_17 du CHU retrouves (5000 au plus)", "nir_ano_17_dans_ir_ben_r", function(pre)
    sprintf("WITH s AS (SELECT NIR_ANO_17 FROM (SELECT DISTINCT C.NIR_ANO_17 FROM %sT_MCO25C C WHERE C.ETA_NUM = '%s' AND C.NIR_RET = '0' ORDER BY C.NIR_ANO_17) WHERE ROWNUM <= 5000) SELECT CASE WHEN r.BEN_NIR_PSA IS NULL THEN 'non' ELSE 'oui' END AS PERIODE, COUNT(*) AS N FROM s LEFT JOIN (SELECT DISTINCT R.BEN_NIR_PSA FROM %sIR_BEN_R R WHERE R.BEN_NIR_PSA IN (SELECT NIR_ANO_17 FROM s)) r ON r.BEN_NIR_PSA = s.NIR_ANO_17 GROUP BY CASE WHEN r.BEN_NIR_PSA IS NULL THEN 'non' ELSE 'oui' END", pre, finess, pre))

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
valeurs()
