# Glossaire OpRoom

Les termes du contexte oproom. Un titre par terme (## oproom:terme), puis la définition en français. Règles : method/layout.md, « Termes et glossaires ».

## oproom:intervention

Alias : OR_INTERVENTIONS, intervention OpRoom

Un enregistrement de OR_INTERVENTIONS : une intervention réalisée en salle, avec ses horaires réels de début et de fin (I_ACTUAL_START, I_ACTUAL_END). Elle correspond à une demande d'intervention de OR_WAITINGLIST.

## oproom:tmi

Alias : TMI, temps moyen d'intervention, durée d'intervention

La moyenne, sur un ensemble d'interventions, de la durée d'une intervention, de l'entrée en salle à la fin réelle. Ce que la durée inclut (le bionettoyage ou non) est une décision : tmi-bionettoyage-compris.

## oproom:programmation

Alias : priorité, programmé, non programmé, urgence, bloc d'urgence

Le caractère programmé d'une intervention : programmé, non programmé ou urgence, selon la priorité de sa demande d'intervention (W_PRIORITY de OR_WAITINGLIST).
