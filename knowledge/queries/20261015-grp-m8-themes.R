# id: 20261015-grp-m8-themes
# system: cora
# person_data: masked
# purpose: compter, par mois de sortie, les RSS du fichier groupé M8 (20261002_074740_RSS_Final_….grp), ceux en CMD 90, ceux en GHM chirurgical, ceux qui portent un DAS de chacun des six thèmes, et le nombre de DAS ; pour comparer ces comptages aux deux reconstitutions de CORA (20261015-m8-cora-par-mois) et savoir laquelle colle au fichier envoyé (étape 2 du plan)
# R de base, sans paquet (method/queries.md, « Un script sur un fichier »). Le script lit le fichier à l'hôpital et n'imprime qu'un tableau d'agrégats masqués : aucune ligne du fichier n'est affichée ni écrite. Le fichier est produit par CORA.
# Mise en page : feuille « RSS groupé format 123 » (atih-formats-mco-2026), une ligne par RUM ; longueur = 205 + 8 nDA + 8 nDAD + 32 nZA (20261015-forme-lignes-grp-resultat).
# Positions : CMD 3-4, GHM 5-8, n° de RSS 28-47, date de sortie de l'UM 103-110 (JJMMAAAA), nDA 134-135, nDAD 136-137, nZA 138-140, DA n° k de 206 + 8 (k - 1).
# Mois de sortie d'un RSS : la plus grande date de sortie de ses RUM. GHM chirurgical : CMD autre que 90 et 1er caractère du GHM = C.
# INDICATEUR : rss (tous les RSS du mois), cmd90, chirurgie, un thème (RSS qui en portent au moins un DAS), das (couples RSS-code de DAS distincts) ; avec MOIS_SORTIE = tous, lignes_longueur_ok et lignes_longueur_ko (lignes dont la longueur suit ou non la mise en page).
# Règle 3 : chaque effectif sous 10 sort <10. Règle 4 : une ligne qui compte une partie des RSS du mois sort « masqué » quand la ligne rss moins elle vaut de 1 à 9.
# Usage : remplacer le chemin ci-dessous, puis source() ou Rscript.

fichier <- "CHEMIN/VERS/20261002_074740_RSS_Final.grp"

l <- readLines(fichier, encoding = "latin1", warn = FALSE)
l <- sub("\r$", "", l)
l <- l[nchar(l) > 0]

rss <- trimws(substr(l, 28, 47))
cmd <- substr(l, 3, 4)
ghm <- substr(l, 5, 8)
sortie <- as.Date(substr(l, 103, 110), format = "%d%m%Y")
nda <- suppressWarnings(as.integer(substr(l, 134, 135)))
ndad <- suppressWarnings(as.integer(substr(l, 136, 137)))
nza <- suppressWarnings(as.integer(substr(l, 138, 140)))
longueur_ok <- !is.na(nda) & !is.na(ndad) & !is.na(nza) & nchar(l) == 205 + 8 * nda + 8 * ndad + 32 * nza

masque <- function(x, parent = NULL) {
  out <- ifelse(x < 10, "<10", as.character(x))
  if (!is.null(parent)) out[x >= 10 & (parent - x) >= 1 & (parent - x) <= 9] <- "masqué"
  out
}

# DAS : un vecteur de codes par ligne, puis un tableau long (ligne, code)
idx <- rep(seq_along(l), ifelse(is.na(nda), 0L, nda))
k <- sequence(ifelse(is.na(nda), 0L, nda))
code <- gsub("[ .]", "", substr(l[idx], 206 + 8 * (k - 1), 205 + 8 * k))
das <- unique(data.frame(rss = rss[idx], code = code, stringsAsFactors = FALSE))
das <- das[nchar(das$code) > 0, ]

theme_de <- function(x) {
  p3 <- substr(x, 1, 3)
  ifelse(p3 %in% c("E40", "E41", "E42", "E43", "E44", "E45", "E46"), "denutrition",
  ifelse(startsWith(x, "L89"), "escarres",
  ifelse(startsWith(x, "R33"), "retention_urine",
  ifelse(startsWith(x, "R521") | startsWith(x, "R522"), "douleur_chronique",
  ifelse(p3 %in% c("U82", "U83", "U84", "U85"), "resistance_atb",
  ifelse(startsWith(x, "Z290"), "isolement_prophylactique", NA))))))
}
das$theme <- theme_de(das$code)

# Un RSS : son mois de sortie, sa CMD, son GHM
r <- data.frame(rss = rss, cmd = cmd, ghm = ghm, sortie = as.numeric(sortie), stringsAsFactors = FALSE)
fin <- tapply(r$sortie, r$rss, function(x) suppressWarnings(max(x, na.rm = TRUE)))
r1 <- r[!duplicated(r$rss), c("rss", "cmd", "ghm")]
r1$mois <- format(as.Date(ifelse(is.finite(fin[r1$rss]), fin[r1$rss], NA), origin = "1970-01-01"), "%Y-%m")
r1$chir <- r1$cmd != "90" & substr(r1$ghm, 1, 1) == "C"

mois <- sort(unique(r1$mois))
lignes <- list(data.frame(
  MOIS_SORTIE = "tous",
  INDICATEUR = c("lignes_longueur_ok", "lignes_longueur_ko"),
  N_COMPTE = c(masque(sum(longueur_ok)), masque(sum(!longueur_ok))),
  stringsAsFactors = FALSE))
for (m in mois) {
  rmo <- r1[!is.na(r1$mois) & r1$mois == m, ]
  n_rss <- nrow(rmo)
  dm <- das[das$rss %in% rmo$rss, ]
  vals <- c(rss = n_rss,
            cmd90 = sum(rmo$cmd == "90"),
            chirurgie = sum(rmo$chir),
            sapply(c("denutrition", "douleur_chronique", "escarres", "isolement_prophylactique",
                     "resistance_atb", "retention_urine"),
                   function(t) length(unique(dm$rss[!is.na(dm$theme) & dm$theme == t]))))
  n_das <- nrow(dm)
  lignes[[m]] <- data.frame(
    MOIS_SORTIE = m,
    INDICATEUR = c(names(vals), "das"),
    N_COMPTE = c(masque(vals[1]), masque(vals[-1], parent = n_rss), masque(n_das)),
    stringsAsFactors = FALSE)
}
res <- do.call(rbind, lignes)
res <- data.frame(QUERY_ID = "20261015-grp-m8-themes", DATABASE_NAME = basename(fichier),
                  RUN_AT = format(Sys.time(), "%Y-%m-%d %H:%M"), res, stringsAsFactors = FALSE)
print(res, right = FALSE, row.names = FALSE)
