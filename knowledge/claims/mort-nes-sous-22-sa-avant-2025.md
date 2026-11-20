---
review: unreviewed
id: mort-nes-sous-22-sa-avant-2025
kind: empirical
author: Francesco
statement: "Dans CORA, de 2019 à 2024, des séjours d'enfant mort-né (P95+0, P95+1) existent sous 22 SA et sous 500 g, où l'instruction de 2021 ne prévoit pas de RUM ; il n'y en a plus en 2025 : pour compter les mort-nés, ne garder que les séjours d'enfant à 22 SA ou plus, ou de 500 g ou plus."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours d'enfant avec P95+0 ou P95+1 en DP, de 2019 à 2025, lus le 2026-11-03"
refuted_if: "pour une année de 2019 à 2024, aucun séjour d'enfant avec P95+0 ou P95+1 en DP n'a une plus grande SEM_AMENORHEE de 1 à 21 et un plus grand POIDS_RUM sous 500 g"
maturity: observed
lifecycle: active
terms: [pmsi:mort-ne, cora:mouvement, cora:diagnostic]
tables: [cora:TB_MVT, cora:TB_DIAG, cora:TB_SEJOUR]
supported_by: [20261103-mfs-enfant-mere-22sa-resultat, 20261102-guide-rum-mort-ne, 20261103-mortnes-pas-de-rum-moins-22sa, 20261103-mortnes-moins-22sa-500g, 20261103-mortnes-mere-avortement-moins-22sa]
depends_on: []
---
## Pour s'en servir

Pour un séjour d'enfant mort-né, prendre la plus grande SEM_AMENORHEE et le plus grand POIDS_RUM (grammes) de ses mouvements, et le garder si `SA_MAX >= 22 OR POIDS_MAX >= 500`. Le filtre ne retire rien en 2025 ; il ne coûte rien de le garder.

Les cas écartés ont, côté mère, un séjour d'avortement (O03 ou O04) et pas de code Z37 : un rapprochement enfant-mère sur Z37 ne les trouve pas. Sans ce filtre, une comparaison des P95 de l'enfant avec les Z37 de la mère montre un écart dont ils sont la plus grande part ; pour les MFS, un écart reste après le filtre certaines années (« Points ouverts »).

## Ce qui l'appuie

Aucun RUM n'est produit pour une naissance avant 22 SA d'un fœtus de moins de 500 g (20261103-mortnes-pas-de-rum-moins-22sa) ; le RUM s'impose à partir de 22 SA ou de 500 g (20261102-guide-rum-mort-ne). Sous 22 SA, la mère a un séjour d'avortement, O03 ou O04 (20261103-mortnes-mere-avortement-moins-22sa), sans Z37 ; un enfant de 500 g ou plus a quand même son RUM (20261103-mortnes-moins-22sa-500g).

Séjours d'enfant P95+1 en DP sous 22 SA, par année (20261103-mfs-enfant-mere-22sa-resultat) : 12 en 2019, 25 en 2020, 17 en 2021, 15 en 2022, 32 en 2023, 20 en 2024, aucun en 2025. De 2019 à 2022, tous pèsent aussi moins de 500 g (N_HORS_REGLE égal à N_SA_MOINS_22) ; en 2023 et 2024 la case est masquée. P95+0 : 12 en 2020, 10 en 2021, 11 en 2023, 11 en 2024, aucun en 2025. Aucun séjour d'enfant P95 n'a une SEM_AMENORHEE vide. Côté mère, O03 ou O04 sur le séjour lié à un enfant P95+1 : 13 en 2020, 15 en 2023 (autres années masquées).

Une fois le filtre posé, les IMG concordent : P95+0 à 22 SA ou plus contre Z3711 côté mère, 12 contre 11 en 2020, 20 contre 19 en 2021, 14 contre 13 en 2023, 19 contre 19 en 2024, 28 contre 28 en 2025.

Points ouverts : la cause du changement de 2025 n'est pas connue (changement de pratique déduit des données, non confirmé par l'équipe de codage). Pour les MFS, P95+1 à 22 SA ou plus dépasse encore Z3710 certaines années (2021 : 29 contre 19 ; 2023 : 34 contre 24 ; 2024 : 33 contre 24), alors que presque tous ces enfants ont une mère qui porte un code Z37 (29, 33 et 32) : la mère porte sans doute un autre code Z37, non mesuré. P95+2 et P95+8 ne sont pas mesurés.
