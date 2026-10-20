---
review: unreviewed
id: actes-derniers-mois-incomplets
kind: empirical
author: Pierre
statement: "Dans CORA, depuis octobre 2020, exclure ou signaler les deux à trois derniers mois dans toute analyse des actes (nombre d'actes, valorisation, ICR, actes par intervention OpRoom) : une partie des actes n'y est pas encore créée, et la baisse finale n'est pas une baisse d'activité."
scope: "CORA de production (CWPROD, schéma CORA_REC), TB_ACTE, actes réalisés d'octobre 2020 au 2026-10-19, lu le 2026-10-19"
refuted_if: "plus de 5 % des actes d'une année complète de 2021 à 2025 sont créés plus de 90 jours après leur réalisation"
maturity: observed
lifecycle: active
terms: [cora:acte, cora:intervention]
tables: [cora:TB_ACTE, cora:TB_INTERVENTION]
supported_by: [20261019-delai-saisie-actes-mois-resultat, 20261019-actes-par-intervention-rattachement-resultat]
depends_on: [dates-creation-actes-avant-2020-sont-des-reprises]
---
## Pour s'en servir

- **Série mensuelle d'actes :** la borner à la date d'extraction moins trois mois et dire le dernier mois retenu. Au 19 octobre 2026, le dernier mois retenu est juin 2026 ; juillet manque encore quelques pour cent d'actes, août à octobre bien plus.
- **Même règle** pour un total de tarifs CCAM ou d'ICR, et pour un nombre d'actes par intervention OpRoom jointe aux actes (le dernier mois et le mois en cours sont nettement incomplets, voir plus bas).
- **Ne pas lire** la chute des derniers mois comme une baisse d'activité.
- **Avant octobre 2020 :** ne pas appliquer cette règle, DATE_CREAT n'y donne pas de délai (dates-creation-actes-avant-2020-sont-des-reprises). Même logique que rss-mois-recents-non-codes pour les RSS.

## Ce qui l'appuie

Délai entre DATE_ACTE et DATE_CREAT par mois de réalisation (20261019-delai-saisie-actes-mois-resultat), parts calculées sur les cases visibles, à quelques actes près.

| Actes réalisés en | créés en 0 à 1 jour | en 30 jours au plus | en 90 jours au plus | après plus de 90 jours |
|---|---|---|---|---|
| 2021 | 82,2 % | 91,4 % | 98,8 % | 1,2 % |
| 2022 | 79,6 % | 88,4 % | 98,8 % | 1,2 % |
| 2023 | 74,8 % | 85,9 % | 96,6 % | 3,4 % |
| 2024 | 77,7 % | 87,6 % | 97,9 % | 2,1 % |
| 2025 | 79,5 % | 87,8 % | 98,6 % | 1,4 % |

De 2021 à 2025, 78,7 % des actes sont créés le jour ou le lendemain (3 191 395 sur 4 053 456), 88,2 % en 30 jours, 98,1 % en 90 jours (le nombre d'actes des lignes masquées est lu comme la somme de leurs classes de délai). Un mois fini depuis un mois manque donc environ 12 % de ses actes, un mois fini depuis trois mois de 1,2 à 3,4 % selon l'année : d'où le seuil de trois mois. Le seuil de 5 % du refuted_if n'est atteint par aucune année.

**Le délai dépend de l'origine.** Pour les actes sans ECRAN (flux importé) : 82 % créés en 0 à 1 jour et 1,4 % après 90 jours de 2021 à 2023, 83 % et 0,8 % en 2024, 87 % et 0,5 % en 2025. Pour les actes saisis dans CORA (ECRAN renseigné), le délai est long : 2 % en 0 à 1 jour et 14 % après 90 jours de 2021 à 2023, 35 % et 12 % en 2024, 53 % et 4,8 % en 2025. Quand une série est surtout faite d'actes saisis dans CORA, elle se complète plus lentement.

**Les derniers mois au 19 octobre 2026.** Sur les 91 à 365 jours après la réalisation, juin 2026 compte 457 actes à ECRAN renseigné et 245 sans ECRAN, juillet 121 et 94, août à octobre moins de 10, faute de recul ; en 2025 la part après 90 jours était de 4,8 % pour la saisie CORA. Côté interventions (20261019-actes-par-intervention-rattachement-resultat, interventions seules dans leur séjour et leur jour), la part sans aucun acte de site de bloc le même jour est de 14 à 17 % de janvier à juin 2026 et en août, 20 % en juillet (534 sur 2 668), 28,6 % en septembre (824 sur 2 886) et 46 % en octobre (797 sur 1 733, jusqu'au 19) : pour cette jointure, seuls le mois en cours et le précédent sont nettement incomplets.

Points ouverts : de janvier à juin 2026, il y a 14 % d'actes de moins qu'en janvier à juin 2025 (environ 366 000 contre 425 000) alors que ces mois ont plus de trois mois de recul et que 1,5 % au moins de leurs actes arrivent après 90 jours (1,6 % en janvier à juin 2025) : le recul de 2026 n'est donc pas un effet de délai ; les actes sans ECRAN baissent de 25 % (342 000 à 257 000) et ceux à ECRAN renseigné montent de 31 % (84 000 à 110 000), sans explication établie. Un chiffrage antérieur d'interventions sans acte sur QBLOCT (test) n'a pas été retrouvé dans CWPROD, où la définition (acte de site de bloc le même jour) donne les parts ci-dessus. La part d'actes de bloc créés après 90 jours n'est pas mesurée à part.
