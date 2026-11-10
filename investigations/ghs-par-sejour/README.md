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

## Conclusions
