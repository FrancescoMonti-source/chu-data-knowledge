---
review: unreviewed
id: p964-encore-sur-mort-nes
kind: empirical
author: Francesco
statement: "Dans CORA, P96.4 reste codé sur des séjours d'enfant mort-né (P95) après 2021, alors que depuis l'instruction de 2021 il ne marque plus l'IMG d'un mort-né : à partir de 2019, pour repérer une IMG de mort-né, prendre l'extension P95+0, pas P96.4."
scope: "CORA de production (CWPROD, schéma CORA_REC), diagnostics de 2018 à 2025, lus le 2026-11-02"
refuted_if: "de 2022 à 2025, aucun patient qui porte P95 n'a P964 sur son séjour"
maturity: observed
lifecycle: active
terms: [pmsi:mort-ne, cora:diagnostic]
tables: [cora:TB_DIAG, cora:TB_MVT]
supported_by: [20261102-morts-foetales-codes-resultat, 20261102-codes-mortinatalite-detail-resultat, 20261102-mortnes-p964, 20261103-mortnes-p964-ne-vivant]
depends_on: []
---
## Pour s'en servir

À partir de 2019 : IMG d'un enfant mort-né, DP `P95+0` ; MFS, `P95+1`, `P95+2` ou `P95+8`. Ne pas compter P964 comme une IMG de mort-né : sur ces séjours il double ou contredit l'extension de P95. Une IMG d'enfant né vivant se cherche par P964 sur un séjour sans P95.

Avant 2019, P95 n'a pas d'extension : ce claim ne dit pas comment séparer IMG et MFS sur ces années (P964 était alors le marqueur, à vérifier).

## Ce qui l'appuie

Depuis 2021, P96.4 ne marque plus l'IMG d'un mort-né, que porte l'extension de P95 ; il reste le marqueur de l'IMG d'un enfant né vivant (20261102-mortnes-p964), seul moyen de la repérer, car les extensions ne concernent que P95 (20261103-mortnes-p964-ne-vivant). Le libellé CIM-10 de P96.4, « Interruption de la grossesse affectant le fœtus et le nouveau-né », ne dit pas cette restriction : lu seul, il pousse à le prendre pour toute IMG.

Patients qui portent P95 et dont le séjour porte aussi P964 (20261102-morts-foetales-codes-resultat) : 70 en 2018-2021, 78 en 2022-2025, donc sans baisse après l'instruction. Séjours avec P964 en DAS (20261102-codes-mortinatalite-detail-resultat) : 21 en 2022, 26 en 2023.

Points ouverts : la mesure ne dit pas si P964 accompagne P95+0 (doublon sans conséquence) ou P95+1 (contradiction). Les IMG d'enfants nés vivants ne sont pas mesurées.
