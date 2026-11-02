---
review: unreviewed
id: grouper-actes-par-no-intervention-ccam
kind: empirical
author: Pierre
statement: "Dans CORA, TB_ACTE.NO_INTERVENTION_CCAM est renseigné pour presque tous les actes, à toutes les époques, et un groupe d'actes de même NO_INTERVENTION_CCAM reste sur un seul séjour, un seul jour et, sauf quelques centaines de groupes par an, un seul mouvement ; TB_ACTE.NO_INTERVENTION est presque toujours vide jusqu'en 2024 et ne couvre qu'une partie des actes ensuite, presque tous saisis dans CORA."
scope: "CORA de production (CWPROD, schéma CORA_REC), table TB_ACTE, actes datés de 2014 à 2025, lus le 2026-10-14"
refuted_if: "plus de 1 % des groupes d'une année couvrent plusieurs séjours ou plusieurs jours, ou plus de 1 % des actes d'une année n'ont pas de NO_INTERVENTION_CCAM"
maturity: observed
lifecycle: active
terms: [cora:acte, cora:intervention]
tables: [cora:TB_ACTE]
supported_by: [20261014-groupes-ccam-resultat, 20261014-epoques-actes-resultat, 20261019-actes-ecran-annee-resultat]
depends_on: []
---
## Pour s'en servir

Pour regrouper les actes d'une même intervention (un même temps médical), grouper par `TB_ACTE.NO_INTERVENTION_CCAM`. Le groupe reste dans un séjour et un jour : on peut le rattacher à son séjour sans dupliquer.

Ne pas se servir de `TB_ACTE.NO_INTERVENTION` pour rattacher les actes à une intervention : il n'existe presque que pour les actes saisis dans CORA (surtout l'écran Bloc, un peu RSS, RUM et AUT), presque vide avant 2025 (1 414 actes en 2024, 15 088 en 2025).

## Ce qui l'appuie

Groupes de NO_INTERVENTION_CCAM par année du premier acte (20261014-groupes-ccam-resultat) : de 264 445 groupes en 2014 à 576 285 en 2025 ; dans chaque année, moins de 10 couvrent plusieurs séjours ; moins de 10 couvrent plusieurs jours, sauf 10 en 2024 et 12 en 2025 ; moins de 10 couvrent plusieurs mouvements, sauf 281 en 2021, 177 en 2022, 59 en 2023 et 25 en 2024. De 70 à 97 % des groupes n'ont qu'un acte.

Actes par mois (20261014-epoques-actes-resultat) : NO_INTERVENTION_CCAM est renseigné pour tous les actes de 2021 à 2025 et pour presque tous avant (moins de 10 manquants par mois et par application) ; NO_INTERVENTION l'est pour environ 120 actes en 2023, 1 400 en 2024 et 15 100 en 2025, moins de 10 par mois avant. Par écran de saisie (20261019-actes-ecran-annee-resultat) : en 2025, 12 482 actes d'écran BLO, 1 233 RSS, 946 AUT, 169 RUM et 258 sans écran ; en 2026, 22 754 BLO, 5 166 RSS, 949 RUM et 906 AUT.
