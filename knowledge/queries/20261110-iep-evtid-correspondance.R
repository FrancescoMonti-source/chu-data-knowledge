# id: 20261110-iep-evtid-correspondance
# system: edsan
# person_data: masked
# purpose: étape 4 du plan (#133, enquête ghs-par-sejour) : dire si la correspondance entre l'IEP (TB_SEJOUR.NO_SEJOUR de CORA) et l'EVTID de l'EDSaN, rendue par le service EDSaN CT (redsan::edsan_ct), est un pour un, pour les séjours qui ont un RSS groupé fini en 2025
#
# Les IEP viennent de CORA de production (CWPROD, schéma CORA_REC) : TRIM(TB_SEJOUR.NO_SEJOUR) des séjours qui ont un RSS de DATE_FIN 2025, groupé (CODE_GHM renseigné, CODE_CMD différent de '90'), joint par ID_SEJOUR (joindre-rss-par-id-sejour). Ils restent en mémoire.
# Aller : redsan::edsan_ct(ids, from = "IEP") interroge getHISToEDSaNCorrespondences (type CPAGE) par lots de 3 500 et rend une ligne par couple IEP-EVTID, avec status : matched (un EVTID), not_found (aucun), multiple_matches (plusieurs ; une ligne par EVTID).
# Retour : les EVTID trouvés repassent par redsan::edsan_ct(ids, from = "EVTID") (getEDSaNToHISCorrespondences) : rend-on le même IEP ?
# Mesures (une ligne chacune, N = effectif) :
#   N_IEP : IEP distincts lus dans CORA ; N_IEP_NON_NUMERIQUE : IEP qui ne sont pas une suite de chiffres ; N_IEP_COMMENCE_00 : IEP qui commencent par 00 (forme d'un IPP pour redsan) ;
#   N_IEP_MATCHED, N_IEP_NOT_FOUND, N_IEP_MULTIPLE : IEP par status de l'aller ;
#   N_EVTID : EVTID distincts trouvés ; N_EVTID_PLUSIEURS_IEP : EVTID rendus pour deux IEP ou plus ;
#   N_EVTID_RETOUR_MEME_IEP : au retour, l'EVTID rend exactement le ou les IEP qui l'ont donné ; N_EVTID_RETOUR_AUTRE : il rend un autre IEP, plusieurs, ou aucun.
# Masquage : tout effectif < 10 sort en <10. Suppression secondaire (règle 4) : les trois status font N_IEP ; si l'un vaut de 1 à 9, N_IEP sort en « masqué ». De même, les deux mesures du retour font N_EVTID : si l'une vaut de 1 à 9, N_EVTID sort en « masqué ».
# Chemins et connexion : les seules lignes à adapter sont les deux suivantes.
con <- redsan:::.cora_connect()
ks_path <- NULL

sql <- "SELECT DISTINCT TRIM(t.NO_SEJOUR) AS IEP
FROM CORA_REC.TB_SYNTH_RSS s
JOIN CORA_REC.TB_SEJOUR t ON t.ID_SEJOUR = s.ID_SEJOUR
WHERE s.DATE_FIN >= DATE '2025-01-01' AND s.DATE_FIN < DATE '2026-01-01'
  AND TRIM(s.CODE_GHM) IS NOT NULL AND TRIM(s.CODE_CMD) <> '90'
  AND TRIM(t.NO_SEJOUR) IS NOT NULL"
iep <- unique(as.character(DBI::dbGetQuery(con, sql)$IEP))
DBI::dbDisconnect(con)
iep <- iep[!is.na(iep) & nzchar(iep)]

aller <- redsan::edsan_ct(iep, from = "IEP", ks_path = ks_path)
statut <- tapply(aller$status, aller$IEP, function(x) x[1])
n_par_statut <- function(s) sum(statut == s)

trouves <- aller[!is.na(aller$EVTID) & nzchar(aller$EVTID), c("IEP", "EVTID")]
iep_par_evtid <- split(trouves$IEP, trouves$EVTID)
evtid <- names(iep_par_evtid)

retour <- if (length(evtid)) redsan::edsan_ct(evtid, from = "EVTID", ks_path = ks_path) else NULL
ok <- !is.null(retour) & !is.na(retour$IEP) & nzchar(retour$IEP)
iep_retour <- split(retour$IEP[ok], retour$EVTID[ok])
meme <- vapply(evtid, function(e) {
  r <- unique(iep_retour[[e]])
  length(r) > 0 && setequal(r, unique(iep_par_evtid[[e]]))
}, logical(1))

n <- c(
  N_IEP = length(iep),
  N_IEP_NON_NUMERIQUE = sum(!grepl("^[0-9]+$", iep)),
  N_IEP_COMMENCE_00 = sum(startsWith(iep, "00")),
  N_IEP_MATCHED = n_par_statut("matched"),
  N_IEP_NOT_FOUND = n_par_statut("not_found"),
  N_IEP_MULTIPLE = n_par_statut("multiple_matches"),
  N_EVTID = length(evtid),
  N_EVTID_PLUSIEURS_IEP = sum(lengths(lapply(iep_par_evtid, unique)) >= 2),
  N_EVTID_RETOUR_MEME_IEP = sum(meme),
  N_EVTID_RETOUR_AUTRE = sum(!meme)
)

affiche <- ifelse(n < 10, "<10", as.character(n))
s3 <- n[c("N_IEP_MATCHED", "N_IEP_NOT_FOUND", "N_IEP_MULTIPLE")]
if (any(s3 >= 1 & s3 <= 9)) affiche["N_IEP"] <- "masqué"
s2 <- n[c("N_EVTID_RETOUR_MEME_IEP", "N_EVTID_RETOUR_AUTRE")]
if (any(s2 >= 1 & s2 <= 9)) affiche["N_EVTID"] <- "masqué"

print(data.frame(QUERY_ID = "20261110-iep-evtid-correspondance",
                 DATABASE_NAME = "CWPROD + EDSaN CT",
                 RUN_AT = format(Sys.time(), "%Y-%m-%d %H:%M"),
                 MESURE = names(n), N = unname(affiche)), row.names = FALSE)
