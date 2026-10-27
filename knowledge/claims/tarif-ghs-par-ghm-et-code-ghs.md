---
review: unreviewed
id: tarif-ghs-par-ghm-et-code-ghs
kind: empirical
author: Francesco
statement: "Dans CORA, PMSI_LIB_GHS_TARIF porte presque toujours plusieurs lignes valides pour un même GHM, dont un GHS 5xxx moins cher, dans lequel le CHU groupe aussi des RSS : pour le tarif d'un RSS, joindre à la fois le GHM complet (TRIM(GHS)) et le CODE_GHS du RSS, sans écarter les GHS 5xxx ; par le GHM seul, chaque RSS trouve deux lignes ou plus, et le plus petit PRIX sous-estime le tarif de la plupart des RSS."
scope: "CORA de production (CWPROD, schéma CORA_REC), lignes de PMSI_LIB_GHS_TARIF valides au 2026-06-30 ; RSS de TB_SYNTH_RSS finis de janvier 2022 à août 2026, hors GHS 9999 et CMD 90, tarif lu à la date de fin du RSS ; lus le 2026-10-23 et le 2026-10-27"
refuted_if: "au 2026-06-30, moins de la moitié des GHM ont deux lignes valides ou plus dans PMSI_LIB_GHS_TARIF, ou, pour une année de 2022 à 2026, moins de 95 % des RSS de MONTANT_GHS positif, joints par le GHM et le CODE_GHS à leur date de fin, ont un PRIX égal à MONTANT_GHS à 0,50 € près"
maturity: observed
lifecycle: active
terms: [cora:rss, pmsi:ghm]
tables: [cora:PMSI_LIB_GHS_TARIF, cora:TB_SYNTH_RSS]
supported_by: [20261023-tarif-ghs-lignes-et-ratio-resultat, 20261026-tarif-ghs-5xxx-et-ecarts-resultat, 20261027-tarif-ghs-5xxx-nuits-et-type-resultat, 20261027-tarif-ghs-5xxx-uhcd-resultat, 20261027-tarif-ghs-5xxx-seul-ou-second-resultat]
depends_on: []
challenges: [tarif-ghs-jointure-couverture]
---
## Pour s'en servir

Pour le tarif des RSS `s` à une date fixe `d`, joindre par les deux clés une ligne par couple :

```sql
LEFT JOIN (
  SELECT TRIM(GHS) AS GHM6, TRIM(CODE_GHS) AS CODE_GHS, MIN(PRIX) AS PRIX
  FROM CORA_REC.PMSI_LIB_GHS_TARIF
  WHERE DATE_DEBUT <= d AND DATE_FIN >= d
  GROUP BY TRIM(GHS), TRIM(CODE_GHS)
) t
  ON t.GHM6 = TRIM(s.CODE_CMD) || TRIM(s.CODE_GHM)
 AND t.CODE_GHS = TRIM(s.CODE_GHS)
```

- La colonne GHS porte le GHM sur 6 caractères ; CODE_GHS porte le numéro du GHS sur 4 caractères, comme TB_SYNTH_RSS.CODE_GHS.
- Ne pas prendre, pour un GHM, le plus petit PRIX ni une ligne quelconque, ni écarter les GHS 5xxx : la ligne 5xxx, le plus souvent la moins chère du GHM, est le tarif des seuls RSS groupés dans ce GHS. En CMD 14 et 15, et pour une partie de la CMD 13, toutes les lignes du GHM sont en 5xxx : son GHS ordinaire y est numéroté 5xxx.
- Un couple peut avoir deux lignes valides à la même date : sans le GROUP BY, ses RSS sont comptés deux fois. À la date de chaque RSS, joindre la table puis grouper par RSS (MIN(PRIX)), comme la requête 20261026-tarif-ghs-5xxx-et-ecarts.
- À tarif constant (des RSS de plusieurs années au tarif d'une même date), garder le GHM et le CODE_GHS de chaque RSS et prendre la ligne valide à cette date. Compter à part les RSS dont le couple n'a pas de ligne à cette date (PRIX vide), et les RSS de GHS 9999.

## Ce qui l'appuie

Lignes valides au 2026-06-30 (20261023-tarif-ghs-lignes-et-ratio-resultat) : 2 205 GHM ont deux lignes, 426 trois ou plus, 25 une seule. Les GHS 5xxx portent 2 876 lignes sur 5 735, pour 2 609 GHM, et 2 755 d'entre elles ont la borne haute 999. Ce sont 918 GHS distincts, soit près de trois GHM par GHS 5xxx en moyenne. Leur LIBELLE_GHS reprend celui du GHM (04C021, 05C021 et les cinq libellés 5xxx les plus fréquents) : il ne dit pas ce qu'est un GHS 5xxx. 5 727 couples GHM et CODE_GHS ont une ligne, 4 en ont deux ou plus, au même PRIX (20261026-tarif-ghs-5xxx-et-ecarts-resultat).

Dans les sept racines lues (04C02, 05C02, 05C03, 05C10, 06C03, 06C04, 07C09), chaque GHM a la ligne de son GHS, et une ligne d'un GHS 5xxx commun à toute la racine, de borne basse 0 et de borne haute 999, 1,9 à 5,3 fois moins chère. Par exemple, 04C021 a le GHS 1005 à 8 038,05 € et le GHS 5181 à 4 327,69 €. Les GHM de 05C02 et 05C03 ont en plus deux GHS propres : 05C021 a les GHS 1430 à 17 719,34 € et 1524 à 20 945,39 €. Écarter le GHS 5xxx ne suffit donc pas à trouver la ligne d'un RSS.

RSS de MONTANT_GHS positif finis de 2022 à août 2026, hors CMD 90 et GHS 9999, joints par le GHM et le CODE_GHS à leur date de fin (20261026-tarif-ghs-5xxx-et-ecarts-resultat) : chaque année, tous sauf 26 à 56 trouvent leur ligne, moins de 10 en trouvent plusieurs, et le PRIX égale MONTANT_GHS à 0,50 € près pour plus de 99 % des RSS joints (tous en 2022, 2025 et 2026). Le rapport entre MONTANT_GHS et PRIX vaut 1 du 5e au 95e centile, chaque année. Sur les RSS d'au moins une nuit finis d'octobre 2025 à août 2026, hors CMD 28, ce rapport vaut 1 en médiane, et 3,494 avec le plus petit PRIX du GHM (20261023-tarif-ghs-lignes-et-ratio-resultat).

Le CHU groupe des RSS dans les GHS 5xxx : de 27 198 à 30 371 par an de 2022 à 2025, 20 389 de janvier à août 2026. Tous trouvent leur ligne par les deux clés, avec un rapport médian de 1 : la ligne 5xxx est leur tarif (20261026-tarif-ghs-5xxx-et-ecarts-resultat). En 2025, 26 218 de ces 30 371 RSS n'ont qu'un RUM, dont 19 532 dans les quatre UM d'urgences et d'UHCD (5701, 5720, 5015, 5010) ; dans chacune de ces UM, moins de 10 RSS d'un seul RUM sont dans un autre GHS (20261027-tarif-ghs-5xxx-uhcd-resultat). Cela concorde avec le GHS « monorum UHCD » que décrivent des sources secondaires depuis la campagne MCO 2021 : un GHS par racine, pour un séjour dont l'unique RUM est en UHCD, au même prix quelle que soit sa durée ; d'où la ligne 5xxx commune à la racine et sans borne, et les 16 082 RSS en 5xxx d'au moins une nuitée (20261027-tarif-ghs-5xxx-nuits-et-type-resultat). Les autres RSS d'un seul RUM en 5xxx sont surtout dans des UM d'obstétrique, de gynécologie et de fertilité (4 654) et d'hôpital de jour (1 426, une minorité des RSS d'un seul RUM de ces UM). Ceux d'obstétrique, de gynécologie et de fertilité, et ceux des hôpitaux de jour de gynécologie-obstétrique (6168) et pour la plupart d'endocrinologie (5135), sont dans des GHM dont toutes les lignes sont en 5xxx (20261027-tarif-ghs-5xxx-seul-ou-second-resultat). Au 2025-06-30, c'est le cas de tous les GHM des CMD 14 et 15 sauf un par CMD, de 40 des 115 GHM de la CMD 13, et d'aucun GHM des autres CMD : les GHS ordinaires sont numérotés dans l'ordre des CMD (ceux hors 5xxx de la CMD 13 vont jusqu'à 4999, ceux de la CMD 16 commencent à 6104), et ceux de ces CMD tombent en 5xxx. Par exemple, 14Z15Z a les GHS 5500 (borne haute 3) et 5503 à 1 022,72 €, et 5713 à 550,63 € sans borne. Les RSS en 5xxx des autres hôpitaux de jour (6850, 5420, 5405, 5533) sont presque tous, comme ceux des urgences, dans une ligne 5xxx à côté d'un GHS ordinaire. Un GHS 5xxx ne repère donc à lui seul ni un séjour d'UHCD ni un hôpital de jour.

Ce claim conteste tarif-ghs-jointure-couverture (unreviewed). Sa clé, le GHM complet « pas CODE_GHS », prend la bonne colonne pour le GHM, mais un agent qui la suit obtient deux lignes ou plus par RSS. Sa mesure de couverture, qui dit seulement si un RSS trouve au moins une ligne, n'en dépend pas.

Points ouverts : le texte officiel du GHS monorum UHCD (arrêté du 19 février 2015 dit « forfaits », notice technique de financement de l'ATIH) n'est pas lu ; les RSS en 5xxx des hôpitaux de jour qui sont dans une ligne 5xxx à côté d'un GHS ordinaire ne sont pas expliqués (GHS « intermédiaire » de la gradation des prises en charge ambulatoires : hypothèse), ni les 1 440 RSS de plusieurs RUM dans ce cas en 2025 ; dans un GHM dont toutes les lignes sont en 5xxx, on ne sait pas laquelle est le GHS ordinaire, ni ce qu'est une seconde ligne au même prix (5503 pour 14Z15Z) ; en 2023, 911 RSS joints ont un PRIX qui diffère de MONTANT_GHS, 26 en 2024, pour une raison non étudiée ; le sens de GET_LIBELLE n'est pas établi ; les lignes par GHM ne sont comptées qu'au 2026-06-30.
