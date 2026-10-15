---
review: unreviewed
id: duree-intervention-avec-bionettoyage
kind: empirical
author: Pierre
statement: "Dans OpRoom, la fin réelle d'une intervention (I_ACTUAL_END) est la fin du bionettoyage : le début du bionettoyage tombe entre le début et la fin pour 99,9 % des interventions réalisées. I_ACTUAL_END − I_ACTUAL_START est donc la durée d'une intervention au sens du TROS, de l'entrée en salle à la fin de la remise en état, avec un bionettoyage mesuré (environ 12 minutes en moyenne) et non forfaitaire."
scope: "OpRoom de production (QBLOCP), interventions terminées ou clôturées commencées de janvier 2023 au 2026-10-09, par l'extraction de requete_oproom.py"
refuted_if: "pour une année, le début du bionettoyage tombe hors de l'intervalle début → fin pour plus de 1 % des interventions qui ont une phase BIONET"
maturity: observed
lifecycle: active
terms: [oproom:intervention]
tables: [oproom:OR_INTERVENTIONS, oproom:OR_INTERVENTION_PHASES, oproom:OR_PHASE_TYPES]
supported_by: [20261014-oproom-durees-resultat, 20261015-ars-definition-tros, 20261015-precision-tmi-tros]
depends_on: [developper-sur-qbloct]
---
## Pour s'en servir

La durée d'une intervention est `I_ACTUAL_END − I_ACTUAL_START`, bionettoyage compris. Les indicateurs en découlent :

- **TMI (temps moyen d'intervention) :** la moyenne de ces durées, nettoyage compris (environ 117 minutes depuis 2024).
- **TROS (temps réel d'occupation des salles) :** la somme de ces durées sur une journée et une salle. Le benchmark ANAP la restreint aux interventions des vacations au programmé, et la rapporte au TVO.
- **Temps chirurgical :** la phase `OPERAT`, de l'incision au pansement (environ 60 minutes).

Le benchmark compte la remise en état au forfait : 5 minutes pour un acte de 30 minutes ou moins, 15 minutes au-delà. OpRoom la mesure, par la phase `BIONET`. Dire laquelle des deux on utilise quand on compare à un benchmark. Exclure les durées négatives ou de plus de 24 heures (moins de 10 par an), et dire combien.

## Ce qui l'appuie

Interventions par année de début (20261014-oproom-durees-resultat) : le début du bionettoyage tombe entre DEBUT et FIN pour 28 085 interventions sur 28 115 en 2023, 32 471 sur environ 32 500 en 2024, 34 595 sur 34 628 en 2025 et 26 771 sur environ 26 790 en 2026. Moins de 10 par an n'ont pas de phase BIONET, pas de fin ou pas d'incision. De 5 à 9 phases pour 96,6 à 99,7 % des interventions selon l'année.

Moyennes en minutes, de 2023 à 2026 :

- **Début → fin :** 120, 117, 116 et 117.
- **Début → début du bionettoyage :** 108, 105, 104 et 105.
- **Incision (phase OPERAT) :** 63, 60, 60 et 60.
- **Bionettoyage (début du BIONET → fin) :** 12, 11, 12 et 12.

Définitions : le benchmark de l'ARS Rhône-Alpes, qui suit la méthode de l'ANAP et de la MeaH, compte une intervention de l'entrée en salle à la fin de la remise en état, et fait du TROS la somme de ces durées (20261015-ars-definition-tros). Pour Pierre, le TMI est la moyenne de ces durées, nettoyage compris, et le TROS leur somme sur une journée (20261015-precision-tmi-tros).

La kb de DIM-code proposait d'arrêter le TROS au début du bionettoyage (note:oproom.definition.tros, « définition proposée »). Cette proposition n'est pas reprise.
