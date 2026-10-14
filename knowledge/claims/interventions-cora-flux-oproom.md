---
review: unreviewed
id: interventions-cora-flux-oproom
kind: empirical
author: Pierre
statement: "Dans CORA, TB_INTERVENTION ne contient des interventions que depuis novembre 2023, venues presque toutes du flux OpRoom (application 16) : environ 100 par mois jusqu'en avril 2025, puis de 1 300 à 3 200 par mois, et le flux est presque complet depuis 2026 (Pierre) ; le type d'intervention n'y est jamais renseigné, et 30 à 70 % des interventions n'ont aucun acte relié par TB_ACTE.NO_INTERVENTION."
scope: "CORA de production (CWPROD, schéma CORA_REC), table TB_INTERVENTION, interventions de 2014 au 2026-10-14, lues le 2026-10-14"
refuted_if: "TB_INTERVENTION compte plus de 10 interventions par mois avant novembre 2023, ou plus de 10 % des interventions d'un mois ont ID_TYPE_INTERVENTION renseigné"
maturity: observed
lifecycle: active
terms: [cora:intervention, cora:acte]
tables: [cora:TB_INTERVENTION, cora:TB_ACTE]
supported_by: [20261014-interventions-cora-resultat, 20261014-revue-pr38]
depends_on: []
---
## Pour s'en servir

Pour compter des interventions de bloc, ne partir de TB_INTERVENTION qu'à partir de 2026, quand le flux est presque complet. Avant novembre 2023 elle est vide, jusqu'en avril 2025 elle ne reçoit que quelques blocs, et en 2025 elle monte en charge. Partir d'OpRoom, ou des actes groupés par NO_INTERVENTION_CCAM (grouper-actes-par-no-intervention-ccam).

Le type d'intervention (ID_TYPE_INTERVENTION) est vide : il ne permet pas de séparer chirurgie, endoscopie ou imagerie. NO_INTERVENTION_EXT et l'entrée en salle sont toujours renseignés : la première sert de clé vers OpRoom.

## Ce qui l'appuie

Interventions par mois et par application (20261014-interventions-cora-resultat) : la première ligne est en novembre 2023 (moins de 10) ; de décembre 2023 à mars 2025, 89 à 121 interventions par mois de l'application 16 ; 329 en avril 2025, 1 311 en mai, puis de 1 581 à 3 187 par mois jusqu'en septembre 2026. Les interventions sans application sont moins de 25 par mois. Pour l'application 16, NO_INTERVENTION_EXT et ENTREE_EN_SALLE sont renseignés pour toutes, ID_TYPE_INTERVENTION pour moins de 10 par mois ; la part avec au moins un acte relié par TB_ACTE.NO_INTERVENTION va de 28 sur 93 (décembre 2024) à 2 218 sur 3 187 (mars 2026).

Que le flux soit presque complet depuis 2026 vient de Pierre, qui connaît les blocs passés sur OpRoom (20261014-revue-pr38) ; les volumes de 2026, de 2 216 à 3 187 interventions par mois complets, vont dans ce sens.
