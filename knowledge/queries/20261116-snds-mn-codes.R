# id: 20261116-snds-mn-codes
# system: snds
# person_data: masked
# purpose: compter les actes de médecine nucléaire (CCAM en __QL et liste de RIV de la SAE) par établissement et par code, en séjour et en consultation externe, en 2024 : quels codes sortent du motif, et le CHU en code-t-il ? (étape 1 du plan, enquête reperage-medecine-nucleaire-snds, #143)
# Lignes : une par établissement (CHU, Becquerel), source et code ; N_ACTES compte des actes (lignes de T_MCO24A ou de T_MCO24FMSTC), masqué sous 10.
# Exécutée depuis l'étude DIM-code 2026-11_radiotherapie_becquerel (chercher_mn(), commit a7deba5), qui fait le même calcul : voir la preuve.
conn <- DBI::dbConnect(ROracle::Oracle(), dbname = "IPIAMPR2.WORLD")
eta <- c(CHU = "760780239", Becquerel = "760000166")
cond <- function(col) sprintf("(%s LIKE '__QL%%' OR %s IN ('KCNL003','KCNL004','ZZNL016','PANL001','PBLL001','FENL001'))", col, col)
in_eta <- function(col) sprintf("%s IN (%s)", col, paste0("'", eta, "'", collapse = ","))
s <- DBI::dbGetQuery(conn, sprintf("SELECT A.ETA_NUM, A.CDC_ACT AS CODE, COUNT(*) AS N FROM PROFIL_108.T_MCO24A A WHERE %s AND %s GROUP BY A.ETA_NUM, A.CDC_ACT", in_eta("A.ETA_NUM"), cond("A.CDC_ACT")))
a <- DBI::dbGetQuery(conn, sprintf("SELECT M.ETA_NUM, M.CCAM_COD AS CODE, COUNT(*) AS N FROM PROFIL_108.T_MCO24FMSTC M WHERE %s AND %s GROUP BY M.ETA_NUM, M.CCAM_COD", in_eta("M.ETA_NUM"), cond("M.CCAM_COD")))
DBI::dbDisconnect(conn)
r <- rbind(cbind(SOURCE = rep("séjour", nrow(s)), s), cbind(SOURCE = rep("consultation externe", nrow(a)), a))
r <- r[order(r$ETA_NUM, r$SOURCE, -r$N), ]
print(data.frame(QUERY_ID = "20261116-snds-mn-codes", DATABASE_NAME = "IPIAMPR2.WORLD", RUN_AT = format(Sys.time(), "%Y-%m-%d %H:%M"),
                 LIEU = names(eta)[match(r$ETA_NUM, eta)], SOURCE = r$SOURCE, CODE = r$CODE,
                 N_ACTES = ifelse(r$N < 10, "<10", as.character(r$N))), row.names = FALSE)
