# id: 20261015-classes-m8-fichier
# system: cora
# person_data: masked
# purpose: pour les RSS MCO finis de janvier à août 2026 et groupés hors CMD 90 aujourd'hui, en GHM chirurgical ou non, compter par thème ceux qui ont gagné ou perdu un DAS du thème entre le fichier groupé M8 et CORA aujourd'hui, répartis en classes A, B, C, et chiffrer la classe B (étapes 3, 4 et 5 du plan). Remplace 20261015-classes-m8-regroupes, dont l'état M8 (LIGNES_GRP) n'est pas celui du fichier (20261015-m8-cora-par-mois-resultat).
# R de base, plus DBI pour lire CORA sur une connexion à CWPROD (method/queries.md, « Un script sur un fichier », method/adr/0026). Les lignes du fichier et de CORA restent en mémoire : le script n'imprime qu'un tableau d'agrégats masqués.
# État M8 : le fichier 20261002_074740_RSS_Final_….grp (feuille « RSS groupé format 123 », atih-formats-mco-2026). Un RSS = ses RUM, réunis par n° de RSS (28-47). CMD 3-4 et GHM 5-8 de son 1er RUM ; DAS de tous ses RUM (nDA 134-135, DA n° k de 206 + 8 (k - 1)).
# Montant M8 : MNT_GHS de VisualValoSejours.csv, valorisation du même envoi, par NO_RSS (1re ligne d'un NO_RSS ; séparateur ; , ou tabulation, lu dans l'en-tête).
# État aujourd'hui : TB_SYNTH_RSS (CODE_CMD, CODE_GHM, MONTANT_GHS) et les DAS de TB_DIAG (TYPE_DIAG = 'S', chemin TB_MVT_RUM). Un DAS saisi mais pas encore regroupé compte comme présent : 22 DAS seulement dans ce cas (20261015-das-m8-lignes-grp-vs-tb-diag-resultat).
# Jointure : NO_RSS de CORA = n° de RSS du fichier (20261015-forme-lignes-grp-resultat). GHM = type, deux chiffres, niveau (20261015-type-niveau-ghm-resultat).
# GROUPE : chirurgie si le type du GHM d'aujourd'hui vaut C, sinon hors_chirurgie. Pas de ligne qui somme les deux groupes.
# Colonnes de classe (chaque RSS dans une seule) :
#   N_RSS_A_CMD90_M8 : en CMD 90 dans le fichier. N_RSS_A_ABSENT_FICHIER : absent du fichier.
#   N_RSS_B_NIVEAU_MONTE, N_RSS_C_MEME_NIVEAU, N_RSS_NIVEAU_BAISSE : même type de GHM, niveau 1-4 aux deux dates.
#   N_RSS_C_SANS_NIVEAU : même type, mais un niveau hors 1-4 (J, T, lettre) à une des deux dates.
#   N_RSS_TYPE_CHANGE : type de GHM différent dans le fichier ; hors des classes.
# EUROS_B : somme de MONTANT_GHS aujourd'hui moins MNT_GHS à M8, sur la classe B ; N_RSS_B_SANS_MNT_M8 : RSS de la classe B absents de la valorisation, hors de cette somme.
# THEME = tous : RSS qui ont gagné (ou perdu) au moins un thème, comptés une fois.
# Lignes SENS = controle (colonne N_CONTROLE) : rss_cora, rss_cora_dans_fichier, rss_cora_dans_valo, no_rss_double_cora, rss_fichier.
# Règle 3 : chaque effectif sous 10 sort <10 ; EUROS_B sort <10 quand la classe B a moins de 10 RSS. Règle 4 : rss_cora_dans_fichier et rss_cora_dans_valo sortent « masqué » quand rss_cora moins elles vaut de 1 à 9.
# Usage : remplacer les deux chemins, et la connexion DBI à CWPROD si elle s'ouvre autrement (ici par redsan, le paquet de l'hôpital), puis source() ou Rscript. Le script ferme la connexion après ses deux lectures.
# masquer : TRUE par défaut. FALSE donne les vrais effectifs pour la personne seule, à l'hôpital ; la colonne MASQUE dit alors « non », et ce résultat ne se partage pas (method/privacy.md). Seul un résultat à MASQUE « oui » devient une preuve.

fichier_grp <- "CHEMIN/VERS/20261002_074740_RSS_Final.grp"
fichier_valo <- "CHEMIN/VERS/VisualValoSejours.csv"
connexion <- redsan:::.cora_connect()
masquer <- TRUE

options(width = 400)
themes <- c("denutrition", "douleur_chronique", "escarres", "isolement_prophylactique", "resistance_atb", "retention_urine")
classes <- c("A_CMD90_M8", "A_ABSENT_FICHIER", "B_NIVEAU_MONTE", "C_MEME_NIVEAU", "NIVEAU_BAISSE", "C_SANS_NIVEAU", "TYPE_CHANGE")

theme_de <- function(x) {
  p3 <- substr(x, 1, 3)
  ifelse(p3 %in% c("E40", "E41", "E42", "E43", "E44", "E45", "E46"), "denutrition",
  ifelse(startsWith(x, "L89"), "escarres",
  ifelse(startsWith(x, "R33"), "retention_urine",
  ifelse(startsWith(x, "R521") | startsWith(x, "R522"), "douleur_chronique",
  ifelse(p3 %in% c("U82", "U83", "U84", "U85"), "resistance_atb",
  ifelse(startsWith(x, "Z290"), "isolement_prophylactique", NA))))))
}

masque <- function(x, parent = NULL) {
  if (!masquer) return(as.character(x))
  out <- ifelse(x < 10, "<10", as.character(x))
  if (!is.null(parent)) out[x >= 10 & (parent - x) >= 1 & (parent - x) <= 9] <- "masqué"
  out
}

# 1. État M8 : le fichier groupé
l <- readLines(fichier_grp, encoding = "latin1", warn = FALSE)
l <- sub("\r$", "", l)
l <- l[nchar(l) > 0]
rss <- trimws(substr(l, 28, 47))
nda <- suppressWarnings(as.integer(substr(l, 134, 135)))
nda[is.na(nda)] <- 0L
premier <- !duplicated(rss)
m8 <- data.frame(no_rss = rss[premier], cmd = substr(l[premier], 3, 4), ghm = substr(l[premier], 5, 8),
                 stringsAsFactors = FALSE)
idx <- rep(seq_along(l), nda)
k <- sequence(nda)
code <- gsub("[ .]", "", substr(l[idx], 206 + 8 * (k - 1), 205 + 8 * k))
th_m8 <- unique(data.frame(no_rss = rss[idx], theme = theme_de(code), stringsAsFactors = FALSE))
th_m8 <- th_m8[!is.na(th_m8$theme), ]

# 2. Montant M8 : la valorisation du même envoi
entete <- readLines(fichier_valo, n = 1, encoding = "latin1", warn = FALSE)
seps <- c(";", ",", "\t")
sep <- seps[which.max(sapply(seps, function(s) length(strsplit(entete, s, fixed = TRUE)[[1]])))]
valo <- read.table(fichier_valo, sep = sep, header = TRUE, quote = "\"", colClasses = "character", fill = TRUE,
                   fileEncoding = "latin1", check.names = FALSE, comment.char = "")
noms <- toupper(trimws(names(valo)))
col_rss <- match("NO_RSS", noms)
col_mnt <- match("MNT_GHS", noms)
mnt_m8 <- NULL
if (!is.na(col_rss) && !is.na(col_mnt)) {
  v <- valo[!duplicated(trimws(valo[[col_rss]])), ]
  mnt_m8 <- setNames(suppressWarnings(as.numeric(gsub(",", ".", gsub("[[:space:]]", "", v[[col_mnt]])))),
                     trimws(v[[col_rss]]))
}
rm(valo)

# 3. État aujourd'hui : CORA
periode <- "s.DATE_FIN >= DATE '2026-01-01' AND s.DATE_FIN < DATE '2026-09-01' AND TRIM(s.CODE_CMD) <> '90'"
base <- DBI::dbGetQuery(connexion, "SELECT SYS_CONTEXT('USERENV', 'DB_NAME') AS DB FROM DUAL")[[1]]
auj <- DBI::dbGetQuery(connexion, paste(
  "SELECT TRIM(s.NO_RSS) AS NO_RSS, TRIM(s.CODE_CMD) AS CMD, TRIM(s.CODE_GHM) AS GHM, s.MONTANT_GHS AS MNT",
  "FROM CORA_REC.TB_SYNTH_RSS s WHERE", periode))
das_auj <- DBI::dbGetQuery(connexion, paste(
  "SELECT DISTINCT TRIM(s.NO_RSS) AS NO_RSS, REPLACE(REPLACE(TRIM(d.CODE_DIAG), '.', ''), ' ', '') AS CODE",
  "FROM CORA_REC.TB_SYNTH_RSS s",
  "JOIN CORA_REC.TB_MVT_RUM mr ON mr.ID_RSS = s.ID_RSS",
  "JOIN CORA_REC.TB_DIAG d ON d.ID_MVT = mr.ID_MVT",
  "WHERE", periode, "AND TRIM(d.TYPE_DIAG) = 'S'",
  "AND (d.CODE_DIAG LIKE 'E4%' OR d.CODE_DIAG LIKE 'L89%' OR d.CODE_DIAG LIKE 'R33%'",
  "OR d.CODE_DIAG LIKE 'R52%' OR d.CODE_DIAG LIKE 'U8%' OR d.CODE_DIAG LIKE 'Z29%')"))
names(auj) <- tolower(names(auj))
names(das_auj) <- tolower(names(das_auj))
auj$no_rss <- as.character(auj$no_rss)
n_double <- sum(duplicated(auj$no_rss))
auj <- auj[!duplicated(auj$no_rss), ]
th_auj <- unique(data.frame(no_rss = as.character(das_auj$no_rss), theme = theme_de(das_auj$code),
                            stringsAsFactors = FALSE))
th_auj <- th_auj[!is.na(th_auj$theme), ]
rm(das_auj)
DBI::dbDisconnect(connexion)

# 4. Classe de chaque RSS
i <- match(auj$no_rss, m8$no_rss)
cmd_m8 <- m8$cmd[i]
ghm_m8 <- m8$ghm[i]
niv_auj <- suppressWarnings(as.integer(substr(auj$ghm, 4, 4)))
niv_m8 <- suppressWarnings(as.integer(substr(ghm_m8, 4, 4)))
niveaux <- niv_auj %in% 1:4 & niv_m8 %in% 1:4
classe <- ifelse(is.na(i), "A_ABSENT_FICHIER",
          ifelse(cmd_m8 == "90", "A_CMD90_M8",
          ifelse(substr(ghm_m8, 1, 1) != substr(auj$ghm, 1, 1), "TYPE_CHANGE",
          ifelse(!niveaux, "C_SANS_NIVEAU",
          ifelse(niv_auj > niv_m8, "B_NIVEAU_MONTE",
          ifelse(niv_auj == niv_m8, "C_MEME_NIVEAU", "NIVEAU_BAISSE"))))))
groupe <- ifelse(substr(auj$ghm, 1, 1) == "C", "chirurgie", "hors_chirurgie")
ecart <- if (is.null(mnt_m8)) rep(NA_real_, nrow(auj)) else as.numeric(auj$mnt) - unname(mnt_m8[auj$no_rss])

a_auj <- sapply(themes, function(t) auj$no_rss %in% th_auj$no_rss[th_auj$theme == t])
a_m8 <- sapply(themes, function(t) auj$no_rss %in% th_m8$no_rss[th_m8$theme == t])
sens_m <- list(gain = a_auj & !a_m8, perte = a_m8 & !a_auj)

# 5. Tableau
lignes <- list()
for (g in c("chirurgie", "hors_chirurgie")) {
  for (s in names(sens_m)) {
    m <- cbind(sens_m[[s]], tous = rowSums(sens_m[[s]]) > 0)
    for (t in colnames(m)) {
      sel <- groupe == g & m[, t]
      n <- sapply(classes, function(cl) sum(sel & classe == cl))
      b <- sel & classe == "B_NIVEAU_MONTE"
      euros <- if (masquer && sum(b) < 10) "<10" else if (is.null(mnt_m8)) "valo_illisible" else
        as.character(round(sum(ecart[b], na.rm = TRUE)))
      lignes[[length(lignes) + 1]] <- data.frame(
        GROUPE = g, SENS = s, THEME = t, as.list(setNames(masque(n), paste0("N_RSS_", classes))),
        N_RSS_B_SANS_MNT_M8 = masque(sum(b & is.na(ecart))), EUROS_B = euros, N_CONTROLE = "",
        stringsAsFactors = FALSE, check.names = FALSE)
    }
  }
}
n_rss <- nrow(auj)
controle <- c(rss_cora = masque(n_rss),
              rss_cora_dans_fichier = masque(sum(!is.na(i)), parent = n_rss),
              rss_cora_dans_valo = if (is.null(mnt_m8)) "valo_illisible" else
                masque(sum(auj$no_rss %in% names(mnt_m8)), parent = n_rss),
              no_rss_double_cora = masque(n_double),
              rss_fichier = masque(nrow(m8)))
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
res <- data.frame(QUERY_ID = "20261015-classes-m8-fichier", DATABASE_NAME = paste(basename(fichier_grp), "+", base),
                  RUN_AT = format(Sys.time(), "%Y-%m-%d %H:%M"),
                  MASQUE = if (masquer) "oui" else "non", res, stringsAsFactors = FALSE, check.names = FALSE)
print(res, right = FALSE, row.names = FALSE)
