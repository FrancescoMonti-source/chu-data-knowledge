---
review: unreviewed
id: rhs-htp-une-venue
kind: empirical
author: Pierre
statement: "En HTP SMR, CORA enregistre un RHS par venue, non un par semaine : une personne vue trois jours dans la semaine a trois RHS d'une journée de présence chacun."
scope: "CORA de production (CWPROD, schéma CORA_REC), RHS de HTP (TYPE_HOSPIT_SSR = 2) de TB_MVT_SSR_SEM dont la semaine débute en 2025, lus le 2026-10-20"
refuted_if: "en 2025, au moins 10 personnes-semaines de HTP portent un seul RHS de plus d'une journée de présence (NBJ_PRES > 1)"
maturity: observed
lifecycle: active
terms: [cora:rhs, pmsi:htp]
tables: [cora:TB_MVT_SSR_SEM]
supported_by: [20261020-rhs-par-personne-semaine-2025-2-resultat, 20261020-rhs-htp-gn-gr-montants-2025-resultat]
depends_on: [htp-smr-type-hospit-ssr]
---
## Pour s'en servir

Pour compter des semaines, des personnes-semaines ou des journées de HTP, regrouper par `ID_PATIENT` et `DATE_DEBUT_SEM` : compter les lignes de TB_MVT_SSR_SEM compte des venues. Le manuel de l'ATIH décrit un RHS par semaine, donc ne pas reprendre ses règles de score ou de groupe comme si chaque ligne était la semaine entière : le groupe d'une ligne est celui d'une seule venue. Pour ce que donnerait un RHS par semaine, il faut regrouper les lignes d'une même personne-semaine et recalculer.

## Ce qui l'appuie

Sur les personnes-semaines de HTP de 2025, la somme des journées de présence égale le nombre de RHS : 1 884 avec un RHS et un jour, 81 avec deux RHS et deux jours, 129 avec trois et trois, 77 avec quatre et quatre (20261020-rhs-par-personne-semaine-2025-2-resultat). Par GN et groupe de réadaptation, le nombre de RHS égale le nombre de journées de présence dans chaque cellule visible (20261020-rhs-htp-gn-gr-montants-2025-resultat).

Points ouverts : une cellule à quatre RHS et trois jours (moins de 10 personnes-semaines) montre qu'un RHS peut compter zéro jour de présence ; NBJ_PRES est vide pour un RHS de HTP sur 2 750 (20261020-rhs-htp-colonnes-2025-resultat). Les autres années ne sont pas lues.
