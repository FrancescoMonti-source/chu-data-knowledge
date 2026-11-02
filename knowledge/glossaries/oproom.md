# Glossaire OpRoom

Les termes du contexte oproom. Un titre par terme (## oproom:terme), puis la définition en français. Règles : method/layout.md, « Termes et glossaires ».

## oproom:base

Alias : QBLOCT, QBLOCP, QBLC-T, base de test, base de production, OpRoom Oracle, schéma C3

Les deux bases Oracle d'OpRoom, au schéma applicatif C3 : QBLOCT, la base de test, où se mettent au point les requêtes ; QBLOCP, la base de production, d'où viennent les mesures.

## oproom:intervention

Alias : OR_INTERVENTIONS, intervention, interventions, intervention réalisée, I_KEY, I_STATE

Une ligne de OR_INTERVENTIONS : une intervention au bloc, planifiée puis réalisée, dans une salle, pour une procédure. I_STATE dit son état (2 terminée, 4 clôturée pour les interventions réalisées).

## oproom:duree-intervention

Alias : durée d'intervention, temps d'intervention, durée d'occupation, I_ACTUAL_START, I_ACTUAL_END, entrée en salle, remise en état

Le temps d'une intervention, de l'entrée du patient en salle (I_ACTUAL_START) à la fin de la remise en état de la salle, bionettoyage compris (I_ACTUAL_END). Le benchmark ANAP compte la remise en état au forfait ; OpRoom la mesure par la phase BIONET (duree-intervention-avec-bionettoyage).

## oproom:tmi

Alias : TMI, temps moyen d'intervention, durée moyenne d'intervention

La moyenne des durées d'intervention (oproom:duree-intervention), nettoyage compris.

## oproom:tros

Alias : TROS, temps réel d'occupation des salles, temps d'occupation, occupation des salles

La somme des durées d'intervention (oproom:duree-intervention) d'une salle sur une journée ; le benchmark ANAP n'y compte que les interventions réalisées dans des vacations au programmé.

## oproom:tvo

Alias : TVO, temps de vacation offert, temps d'ouverture, taux d'occupation, TROS/TVO

La somme des temps de vacation offerts au programmé pour accueillir de l'activité (oproom:vacation). Le taux d'occupation des salles est TROS / TVO.

## oproom:vacation

Alias : vacation, vacations, plage, plage de salle, vacation de spécialité, OR_ROOM_AVAIL_PER_DAY, OR_SPECIALISM_AVAIL_PER_DAY, OR_SPEC_AVAIL_PER_DAY_ROOM

Une plage horaire offerte à l'activité opératoire : l'ouverture d'une salle sur une journée (OR_ROOM_AVAIL_PER_DAY), ou la plage d'une spécialité posée sur une ou plusieurs salles (OR_SPECIALISM_AVAIL_PER_DAY, OR_SPEC_AVAIL_PER_DAY_ROOM).

## oproom:bloc

Alias : bloc, bloc opératoire, site, site physique, OR_SITES, OR_ROOM_SITES, Robec, DEVE, Pédiatrie, Endoscopie

Le site physique d'une salle d'OpRoom (OR_SITES avec SI_PHYSICAL = 1, relié à la salle par OR_ROOM_SITES) : Robec N1 à N3 et M4, Gynéco-obstétrique, Pédiatrie, Endoscopie, DEVE.

## oproom:phase

Alias : phase, phases, OR_INTERVENTION_PHASES, OR_PHASE_TYPES, ENTSAL, OPERAT, PANSMT, SORTI, BIONET, bionettoyage, incision

Une étape horodatée d'une intervention (OR_INTERVENTION_PHASES, type dans OR_PHASE_TYPES), de l'entrée en salle (ENTSAL) au bionettoyage (BIONET) ; la phase OPERAT va de l'incision au pansement.
