# id: 20261116-snds-referentiels-libelles
# system: snds
# person_data: no-person-data
# purpose: savoir où lire les libellés des GHM, des établissements (FINESS) et des diagnostics (CIM-10) sur le portail, et les colonnes de T_MCO23UM (enquête fondations-snds, #127)
# Lignes : une par constat (fichier présent, colonnes, nombre de lignes d'un référentiel, colonnes d'une table Oracle) ; aucune donnée de personne, aucun libellé ni code lu.
# Masquage : sans objet (référentiels et noms de colonnes).
source(file.path(Sys.getenv("DIM_SNDS_COMMUN", "~/rdata/dim/commun"), "sortie.R"))   # sortir()

referentiels <- function() {
  id <- "20261116-snds-referentiels-libelles"
  dossier <- path.expand("~/rfcommun")
  res <- list()
  ajouter <- function(source, element, valeur) res[[length(res) + 1]] <<- data.frame(SOURCE = source, ELEMENT = element, VALEUR = as.character(valeur))
  # 1. Dossier RFCOMMUN (fichiers sas7bdat) : noms des fichiers cherchés
  f <- list.files(dossier, pattern = "^(ghm|datasante_t_finess)\\.sas7bdat$", ignore.case = TRUE)
  ajouter("rfcommun", "fichiers ghm / datasante_t_finess présents", if (length(f)) paste(sort(f), collapse = ", ") else "aucun")
  for (p in c("haven", "sas7bdat")) ajouter("R", paste("paquet", p, "installé"), requireNamespace(p, quietly = TRUE))
  # 2. Colonnes et taille de chaque fichier (aucune ligne affichée)
  for (nom in c("ghm", "datasante_t_finess")) {
    fic <- file.path(dossier, paste0(nom, ".sas7bdat"))
    d <- tryCatch(if (requireNamespace("haven", quietly = TRUE)) haven::read_sas(fic) else sas7bdat::read.sas7bdat(fic),
                  error = function(e) conditionMessage(e))
    if (is.data.frame(d)) {
      ajouter(nom, "colonnes", paste(names(d), collapse = ", "))
      ajouter(nom, "nombre de lignes", nrow(d))
    } else ajouter(nom, "erreur de lecture", substr(gsub("[\r\n]+", " ", d), 1, 150))
  }
  # 3. Colonnes des tables Oracle (catalogue filtré par noms exacts)
  conn <- DBI::dbConnect(ROracle::Oracle(), dbname = "IPIAMPR2.WORLD")
  on.exit(DBI::dbDisconnect(conn), add = TRUE)
  q <- "SELECT OWNER, TABLE_NAME, COLUMN_NAME FROM ALL_TAB_COLUMNS WHERE TABLE_NAME IN ('IR_CIM_V', 'IR_GHS_V', 'BE_IDE_R', 'T_MCO23UM') ORDER BY OWNER, TABLE_NAME, COLUMN_ID"
  o <- tryCatch(DBI::dbGetQuery(conn, q), error = function(e) conditionMessage(e))
  if (is.data.frame(o)) {
    names(o) <- toupper(names(o))
    for (k in unique(paste(o$OWNER, o$TABLE_NAME, sep = "."))) {
      sel <- paste(o$OWNER, o$TABLE_NAME, sep = ".") == k
      ajouter(k, "colonnes", paste(o$COLUMN_NAME[sel], collapse = ", "))
    }
    if (!nrow(o)) ajouter("oracle", "colonnes", "aucune table trouvée")
  } else ajouter("oracle", "erreur de lecture", substr(gsub("[\r\n]+", " ", o), 1, 150))
  tableau <- data.frame(QUERY_ID = id, DATABASE_NAME = "IPIAMPR2.WORLD + ~/rfcommun", RUN_AT = format(Sys.time(), "%Y-%m-%d %H:%M"),
                        do.call(rbind, res), row.names = NULL)
  sortir(tableau, id, person_data = "no-person-data", entete = FALSE)
}
referentiels()
