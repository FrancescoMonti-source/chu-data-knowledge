# id: revalorisation-entre-deux-etats
# system: cora
# purpose: comparer deux états du codage MCO (avant : le fichier groupé d'un envoi ; après : un second fichier groupé, ou CORA aujourd'hui) et compter, par thème de diagnostics, les RSS qui ont gagné ou perdu un code du thème, répartis en classes A, B, C, avec le gain en euros de la classe B
# La méthode, les paramètres, les positions et les limites : README.md, à côté de ce fichier.
# R de base ; DBI seulement quand l'état après est CORA. Le résultat reste à l'hôpital (method/queries.md, « Une routine »).

revalorisation_entre_deux_etats <- function(avant_grp, avant_valo = NULL, apres = "cora", apres_valo = NULL,
                                            connexion = NULL, themes, periode = NULL, types_diag = "DAS",
                                            garder = NULL, par = NULL, masquer = TRUE) {
  ancien <- options(width = 400)
  on.exit(options(ancien))
  classes <- c("A_CMD90_AVANT", "A_ABSENT_AVANT", "B_NIVEAU_MONTE", "C_MEME_NIVEAU", "NIVEAU_BAISSE", "C_SANS_NIVEAU", "TYPE_CHANGE")
  niveaux_ghm <- c("cmd", "type", "racine", "ghm")
  stopifnot(all(types_diag %in% c("DAS", "DP", "DR")), all(names(garder) %in% niveaux_ghm), all(par %in% niveaux_ghm),
            is.null(periode) || length(periode) == 2, apres != "cora" || is.function(connexion))
  # cmd 06, type C, racine 06C04, ghm 06C042 : lus sur l'état après
  decoupe <- function(rss) list(cmd = rss$cmd, type = substr(rss$ghm, 1, 1),
                                racine = paste0(rss$cmd, substr(rss$ghm, 1, 3)), ghm = paste0(rss$cmd, rss$ghm))

  theme_de <- function(code) {
    out <- rep(NA_character_, length(code))
    for (t in names(themes)) for (p in themes[[t]]) out[is.na(out) & startsWith(code, p)] <- t
    out
  }

  masque <- function(x, parent = NULL) {
    if (!masquer) return(as.character(x))
    out <- ifelse(x < 10, "<10", as.character(x))
    if (!is.null(parent)) out[x >= 10 & (parent - x) >= 1 & (parent - x) <= 9] <- "masqué"
    out
  }

  # Un état : rss (no_rss, cmd, ghm, sortie, mnt) et diag (no_rss, theme)
  lire_grp <- function(chemin) {
    l <- readLines(chemin, encoding = "latin1", warn = FALSE)
    l <- sub("\r$", "", l)
    l <- l[nchar(l) > 0]
    if (any(substr(l, 10, 12) != "123")) stop("Format du fichier groupé autre que 123 : ", basename(chemin))
    rss <- trimws(substr(l, 28, 47))
    premier <- !duplicated(rss)
    sortie <- tapply(as.numeric(as.Date(substr(l, 103, 110), format = "%d%m%Y")), rss,
                     function(x) suppressWarnings(max(x, na.rm = TRUE)))
    r <- data.frame(no_rss = rss[premier], cmd = substr(l[premier], 3, 4), ghm = substr(l[premier], 5, 8),
                    stringsAsFactors = FALSE)
    r$sortie <- as.Date(ifelse(is.finite(sortie[r$no_rss]), sortie[r$no_rss], NA), origin = "1970-01-01")
    d <- data.frame(no_rss = character(0), code = character(0), stringsAsFactors = FALSE)
    if ("DP" %in% types_diag) d <- rbind(d, data.frame(no_rss = rss, code = substr(l, 141, 148), stringsAsFactors = FALSE))
    if ("DR" %in% types_diag) d <- rbind(d, data.frame(no_rss = rss, code = substr(l, 149, 156), stringsAsFactors = FALSE))
    if ("DAS" %in% types_diag) {
      nda <- suppressWarnings(as.integer(substr(l, 134, 135)))
      nda[is.na(nda)] <- 0L
      idx <- rep(seq_along(l), nda)
      k <- sequence(nda)
      d <- rbind(d, data.frame(no_rss = rss[idx], code = substr(l[idx], 206 + 8 * (k - 1), 205 + 8 * k),
                               stringsAsFactors = FALSE))
    }
    d$code <- gsub("[ .]", "", d$code)
    list(rss = r, diag = unique(data.frame(no_rss = d$no_rss, theme = theme_de(d$code), stringsAsFactors = FALSE)))
  }

  lire_valo <- function(chemin) {
    if (is.null(chemin)) return(NULL)
    entete <- readLines(chemin, n = 1, encoding = "latin1", warn = FALSE)
    seps <- c(";", ",", "\t")
    sep <- seps[which.max(sapply(seps, function(s) length(strsplit(entete, s, fixed = TRUE)[[1]])))]
    v <- read.table(chemin, sep = sep, header = TRUE, quote = "\"", colClasses = "character", fill = TRUE,
                    fileEncoding = "latin1", check.names = FALSE, comment.char = "")
    noms <- toupper(trimws(names(v)))
    if (!all(c("NO_RSS", "MNT_GHS") %in% noms)) stop("NO_RSS ou MNT_GHS absent de ", basename(chemin))
    no <- trimws(v[[match("NO_RSS", noms)]])
    mnt <- suppressWarnings(as.numeric(gsub(",", ".", gsub("[[:space:]]", "", v[[match("MNT_GHS", noms)]]))))
    setNames(mnt[!duplicated(no)], no[!duplicated(no)])
  }

  lire_cora <- function() {
    con <- connexion()
    on.exit(DBI::dbDisconnect(con))
    periode_sql <- paste0("s.DATE_FIN >= DATE '", periode[1], "' AND s.DATE_FIN < DATE '", periode[2] + 1, "'")
    r <- DBI::dbGetQuery(con, paste(
      "SELECT TRIM(s.NO_RSS) AS NO_RSS, TRIM(s.CODE_CMD) AS CMD, TRIM(s.CODE_GHM) AS GHM,",
      "TO_CHAR(s.DATE_FIN, 'YYYY-MM-DD') AS SORTIE, s.MONTANT_GHS AS MNT FROM CORA_REC.TB_SYNTH_RSS s WHERE", periode_sql))
    motifs <- paste0("d.CODE_DIAG LIKE '", unique(substr(unlist(themes), 1, 3)), "%'", collapse = " OR ")
    d <- DBI::dbGetQuery(con, paste(
      "SELECT DISTINCT TRIM(s.NO_RSS) AS NO_RSS, REPLACE(REPLACE(TRIM(d.CODE_DIAG), '.', ''), ' ', '') AS CODE",
      "FROM CORA_REC.TB_SYNTH_RSS s",
      "JOIN CORA_REC.TB_MVT_RUM mr ON mr.ID_RSS = s.ID_RSS",
      "JOIN CORA_REC.TB_DIAG d ON d.ID_MVT = mr.ID_MVT",
      "WHERE", periode_sql, "AND TRIM(d.TYPE_DIAG) IN (", paste0("'", c(DAS = "S", DP = "P", DR = "R")[types_diag], "'", collapse = ", "),
      ") AND (", motifs, ")"))
    base <- DBI::dbGetQuery(con, "SELECT SYS_CONTEXT('USERENV', 'DB_NAME') AS DB FROM DUAL")[[1]]
    names(r) <- tolower(names(r))
    names(d) <- tolower(names(d))
    r$no_rss <- as.character(r$no_rss)
    r$sortie <- as.Date(r$sortie)
    mnt <- setNames(as.numeric(r$mnt), r$no_rss)
    r$mnt <- NULL
    list(rss = r, diag = unique(data.frame(no_rss = as.character(d$no_rss), theme = theme_de(d$code),
                                           stringsAsFactors = FALSE)),
         mnt = mnt, nom = base)
  }

  # 1. Les deux états
  av <- lire_grp(avant_grp)
  if (is.null(periode)) {
    # Du 1er janvier à la fin du dernier mois de sortie de l'état avant
    fin <- max(av$rss$sortie, na.rm = TRUE)
    if (!is.finite(fin)) stop("Aucune date de sortie lisible dans ", basename(avant_grp))
    periode <- c(as.Date(format(fin, "%Y-01-01")), seq(as.Date(format(fin, "%Y-%m-01")), by = "month", length.out = 2)[2] - 1)
  }
  periode <- as.Date(periode)
  mnt_av <- lire_valo(avant_valo)
  if (apres == "cora") {
    ap <- lire_cora()
    mnt_ap <- ap$mnt
  } else {
    ap <- lire_grp(apres)
    ap$nom <- basename(apres)
    mnt_ap <- lire_valo(apres_valo)
  }
  pop <- ap$rss[!is.na(ap$rss$sortie) & ap$rss$sortie >= periode[1] & ap$rss$sortie <= periode[2] & ap$rss$cmd != "90", ]
  n_double <- sum(duplicated(pop$no_rss))
  pop <- pop[!duplicated(pop$no_rss), ]
  for (n in names(garder)) pop <- pop[decoupe(pop)[[n]] %in% garder[[n]], ]
  if (nrow(pop) == 0) stop("Aucun RSS de l'état après dans la période et dans garder")

  # 2. Classe de chaque RSS
  i <- match(pop$no_rss, av$rss$no_rss)
  cmd_av <- av$rss$cmd[i]
  ghm_av <- av$rss$ghm[i]
  niv_ap <- suppressWarnings(as.integer(substr(pop$ghm, 4, 4)))
  niv_av <- suppressWarnings(as.integer(substr(ghm_av, 4, 4)))
  niveaux <- niv_ap %in% 1:4 & niv_av %in% 1:4
  classe <- ifelse(is.na(i), "A_ABSENT_AVANT",
            ifelse(cmd_av == "90", "A_CMD90_AVANT",
            ifelse(substr(ghm_av, 1, 1) != substr(pop$ghm, 1, 1), "TYPE_CHANGE",
            ifelse(!niveaux, "C_SANS_NIVEAU",
            ifelse(niv_ap > niv_av, "B_NIVEAU_MONTE",
            ifelse(niv_ap == niv_av, "C_MEME_NIVEAU", "NIVEAU_BAISSE"))))))
  groupe <- if (is.null(par)) rep("ensemble", nrow(pop)) else do.call(paste, unname(decoupe(pop)[par]))
  ecart <- if (is.null(mnt_av) || is.null(mnt_ap)) rep(NA_real_, nrow(pop)) else
    unname(mnt_ap[pop$no_rss]) - unname(mnt_av[pop$no_rss])

  # matrix() garde une ligne par RSS, même quand la population n'en a qu'un
  presence <- function(etat) matrix(sapply(names(themes), function(t)
    pop$no_rss %in% etat$diag$no_rss[!is.na(etat$diag$theme) & etat$diag$theme == t]),
    nrow = nrow(pop), dimnames = list(NULL, names(themes)))
  a_ap <- presence(ap)
  a_av <- presence(av)
  sens_m <- list(gain = a_ap & !a_av, perte = a_av & !a_ap)

  # 3. Tableau
  lignes <- list()
  for (g in sort(unique(groupe))) {
    for (s in names(sens_m)) {
      m <- cbind(sens_m[[s]], tous = rowSums(sens_m[[s]]) > 0)
      for (t in colnames(m)) {
        sel <- groupe == g & m[, t]
        n <- sapply(classes, function(cl) sum(sel & classe == cl))
        b <- sel & classe == "B_NIVEAU_MONTE"
        b_mnt <- b & !is.na(ecart)
        euros <- if (is.null(mnt_av) || is.null(mnt_ap)) "sans_valo" else if (masquer && sum(b_mnt) < 10) "<10" else
          as.character(round(sum(ecart[b_mnt])))
        lignes[[length(lignes) + 1]] <- data.frame(
          GROUPE = g, SENS = s, THEME = t, as.list(setNames(masque(n), paste0("N_RSS_", classes))),
          N_RSS_B_SANS_MNT = masque(sum(b & is.na(ecart)), parent = sum(b)), EUROS_B = euros, N_CONTROLE = "",
          stringsAsFactors = FALSE, check.names = FALSE)
      }
    }
  }
  n_pop <- nrow(pop)
  controle <- c(rss_apres = masque(n_pop),
                rss_apres_dans_avant = masque(sum(!is.na(i)), parent = n_pop),
                rss_apres_avec_mnt_avant = if (is.null(mnt_av)) "sans_valo" else
                  masque(sum(pop$no_rss %in% names(mnt_av)), parent = n_pop),
                no_rss_double_apres = masque(n_double),
                rss_avant = masque(nrow(av$rss)),
                rss_avant_hors_periode = masque(sum(is.na(av$rss$sortie) | av$rss$sortie < periode[1] |
                                                    av$rss$sortie > periode[2]), parent = nrow(av$rss)))
  vide <- lignes[[1]][1, ]
  vide[] <- ""
  for (t in names(controle)) {
    ligne <- vide
    ligne$GROUPE <- "tous"
    ligne$SENS <- "controle"
    ligne$THEME <- t
    ligne$N_CONTROLE <- controle[[t]]
    lignes[[length(lignes) + 1]] <- ligne
  }
  res <- do.call(rbind, lignes)
  res <- data.frame(DATABASE_NAME = paste(basename(avant_grp), "->", ap$nom),
                    RUN_AT = format(Sys.time(), "%Y-%m-%d %H:%M"), PERIODE = paste(periode, collapse = " / "),
                    MASQUE = if (masquer) "oui" else "non", res, stringsAsFactors = FALSE, check.names = FALSE)
  print(res, right = FALSE, row.names = FALSE)
  invisible(res)
}
