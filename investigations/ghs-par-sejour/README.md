# Pour donner à l'entrepôt le GHS et le montant de chaque séjour, quels RSS de CORA faut-il écarter ou signaler, le NO_SEJOUR de CORA est-il unique, et l'EVTID de l'entrepôt lui correspond-il un pour un ?

Personne : Francesco
Issue : #133

## Cadrage
- **But :** Mikael, de l'entrepôt (EDSaN), veut une fonction Python qui rende le GHS et le montant de chaque séjour, à joindre à son identifiant de séjour, EVTID. La requête qu'il a reçue (hors du dépôt, ligne à ligne) lit TB_SYNTH_RSS ; l'enquête dit ce qu'elle doit écarter et sur quelle clé joindre.
- **Source :** CORA de production (CWPROD, schéma CORA_REC), requêtes exécutées par Francesco ; le guide méthodologique MCO 2026 pour les règles ; l'entrepôt pour EVTID, dont les tables ne sont pas encore connues du dépôt.
- **Unité :** le RSS, puis le séjour de CORA (ID_SEJOUR, NO_SEJOUR).
- **Période :** RSS finis de 2022 à 2025 ; les mois récents ne sont pas encore codés (rss-mois-recents-non-codes, unreviewed).
- **Montant :** MONTANT_GHS pour le GHS, MNT_TOTAL pour le séjour avec ses suppléments (montant-ghs-rss, unreviewed) : la valorisation calculée par CORA, pas une facture.
- **PIE :** le CHU prestataire produit un RSS aux modes d'entrée et de sortie « 0 », non facturé à l'assurance maladie, sauf les séances, dont il facture le GHS (20261110-guide-pie-prestataire, 20261110-guide-pie-seances). Le CHU demandeur garde un seul RSS, avec Z75.80 (20261110-guide-pie-demandeur). Ce que CORA en fait est mesuré, pas supposé.
- **PIA :** facturées directement par le prestataire, avec un RSS ordinaire (guide MCO 2026, chapitre I, § 4) : pas de traitement à part pour le montant ; elles comptent seulement si un EVTID couvre à la fois un séjour SMR et un séjour MCO, à voir à l'étape 4.
- **Plusieurs RSS par séjour :** 1 à 3 % des séjours qui ont un RSS (joindre-rss-par-id-sejour, unreviewed) ; l'étape 2 dit si les PIE les expliquent.
- **Masquage :** effectifs < 10 masqués dans les requêtes du dépôt ; la requête ligne à ligne de Mikael reste à l'hôpital.
- **Branche :** claude/project-thread-pp06dr, imposée par la session, au lieu de investigation/ghs-par-sejour.

## Choix
- **Une cellule de plus masquée dans 20261110-pie-rss-sejour-resultat :** N_PB_GHS_POS en 2025, dont l'écart à N_ME0_ET_MS0 valait de 1 à 9 ; la requête ne comparait N_PB_GHS_POS qu'à N_PB, lui-même masqué (suppression secondaire, queries.md règle 4).
- **Une cellule de plus masquée dans 20261110-iep-evtid-correspondance-resultat :** N_EVTID_RETOUR_MEME_IEP, dont l'écart à N_IEP_MATCHED, d'une autre ligne, borne N_EVTID_RETOUR_AUTRE (suppression secondaire entre lignes, queries.md règle 4).
- **Cellules de plus masquées dans 20261110-sejour-plusieurs-rss-ecarts-resultat :** N_ECART_0 de 2022 à 2024 et N_PAIRES de 2025. Le nombre de paires d'une année se retrouve par N_RSS − N_SEJ de 20261110-sejour-plusieurs-rss-type-resultat ; avec N_ECART_0, il rendait la somme des autres classes d'écart (de 1 à 9), et en 2025 il rendait N_SEJ, masqué dans l'autre résultat (suppression secondaire entre résultats).
- **N_ETAB_DIFFERENT de 2025 masqué dans 20261110-sejour-plusieurs-rss-etab-resultat :** ID_ETABLIS est vide pour tous ces RSS (ETABLIS_DISTINCTS = 0), donc la colonne compte toutes les paires ; elle rendait le nombre de paires de 2025, masqué dans 20261110-sejour-plusieurs-rss-ecarts-resultat.
- **20261110-sejour-plusieurs-rss-eg limitée à 2022-2024 :** en 2025, la somme de ses cellules redonnait le nombre de paires, masqué dans 20261110-sejour-plusieurs-rss-ecarts-resultat.
- **20261110-rss-plusieurs-eg exécutée deux fois :** à la première exécution, trois colonnes de thésaurus (nombre d'EG, d'UF à plusieurs EG, d'UF sans EG) commençaient par N_ et le contrôle les lisait comme des effectifs de personnes ; renommées sans N_, la requête a été relancée, avec les mêmes chiffres. Seule la seconde exécution est conservée.
- **Deux plus petites classes toujours cachées dans 20261110-rss-plusieurs-eg-um :** leur somme redonnait N_RSS_PLUSIEURS_EG, masqué dans 20261110-rss-plusieurs-eg-resultat. Une seule classe est sortie chaque année, donc masquée ; son absence de concurrente suffit à la conclusion.
- **Site d'un RUM par l'UF d'hébergement, site d'une UM par ses UF :** TB_SYNTH_RSS.ID_ETABLIS est vide, TB_UNITE_MEDICALE n'a pas de site ; TB_EG_UNITE et TB_UNITE_M_UNITE sont lus sans dates.

## Conclusions

Réponse : la requête de Mikael lit TB_SYNTH_RSS, une ligne par RSS. Elle signale les RSS de PIE où le CHU est prestataire (modes 0 et 0), valorisés par CORA mais non facturés à l'assurance maladie hors séances. Le NO_SEJOUR de CORA est l'IEP, unique par séjour, et redsan::edsan_ct le relie un pour un à l'EVTID. Un séjour a plusieurs RSS pour une série de séances ou un changement de site du CHU ; le montant d'un EVTID est la somme de ses RSS, ses GHS ne s'additionnent pas.

Claims :
- iep-evtid-par-edsan-ct (unreviewed)
- pie-prestataire-valorisees-cora (unreviewed)
- eg-du-rum-par-uf-hebergement (unreviewed)
- sejour-plusieurs-rss-changement-eg (unreviewed)

Termes ajoutés : edsan:evtid, cora:eg, pmsi:pie. Terme corrigé : pmsi:mode-entree-sortie (le guide distingue mutation et transfert par l'entité géographique, pas par l'entité juridique).

Points ouverts, laissés dans l'issue : les 105 paires de RSS sur le même site (Charles Nicolle) en 2024 ; la cause des changements de site codés en mutation dans un seul RSS ; la hausse des RSS de PIE prestataire en 2025.
