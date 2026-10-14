---
review: unreviewed
id: fin-intervention-inclut-bionettoyage
kind: empirical
author: Pierre
statement: "Dans OpRoom, la fin réelle d'une intervention (I_ACTUAL_END) est la fin du bionettoyage : le début du bionettoyage tombe entre le début et la fin pour 99,9 % des interventions réalisées. La durée début → fin (environ 117 minutes en moyenne) compte donc une douzaine de minutes de bionettoyage de plus que le TROS, qui s'arrête au début du bionettoyage (environ 105 minutes)."
scope: "OpRoom de production (QBLOCP), interventions terminées ou clôturées commencées de janvier 2023 au 2026-10-09, par l'extraction de requete_oproom.py"
refuted_if: "pour une année, le début du bionettoyage tombe hors de l'intervalle début → fin pour plus de 1 % des interventions qui ont une phase BIONET"
maturity: observed
lifecycle: active
terms: [oproom:intervention]
tables: [oproom:OR_INTERVENTIONS, oproom:OR_INTERVENTION_PHASES, oproom:OR_PHASE_TYPES]
supported_by: [20261014-oproom-durees-resultat]
depends_on: [developper-sur-qbloct]
---
## Pour s'en servir

Choisir la durée selon la question, et la nommer :

- **TROS (temps de réalisation opératoire, convention ANAP) :** de `I_ACTUAL_START` (entrée en salle) au début de la phase `BIONET`, ou `I_ACTUAL_END` s'il n'y a pas de bionettoyage.
- **Occupation de la salle :** `I_ACTUAL_END − I_ACTUAL_START`, bionettoyage compris.
- **Temps chirurgical :** la phase `OPERAT`, de l'incision au pansement.

Ne jamais présenter `I_ACTUAL_END − I_ACTUAL_START` comme un TROS : il le dépasse d'environ 12 minutes par intervention. Exclure les durées négatives ou de plus de 24 heures, et dire combien (moins de 10 par an).

## Ce qui l'appuie

Interventions par année de début (20261014-oproom-durees-resultat) : début du bionettoyage entre DEBUT et FIN pour 28 085 interventions en 2023, 32 471 en 2024, 34 595 en 2025 et 26 771 en 2026, sur 28 115, environ 32 500, 34 628 et environ 26 790 ; moins de 10 par an sans phase BIONET, sans fin ou sans incision. Moyennes, en minutes, de 2023 à 2026 : occupation 120, 117, 116, 117 ; TROS 108, 105, 104, 105 ; incision (phase OPERAT) 63, 60, 60, 60 ; bionettoyage (début du BIONET → FIN) 12, 11, 12, 12. De 5 à 9 phases pour 96,6 à 99,7 % des interventions selon l'année.
