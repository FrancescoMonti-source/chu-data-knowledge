---
review: unreviewed
id: tmi-bionettoyage-compris
kind: decision
author: Pierre
statement: "Au DIM, pour les études de bloc, la durée d'une intervention va de l'entrée en salle à la fin réelle (I_ACTUAL_START à I_ACTUAL_END), bionettoyage compris, et le TMI en est la moyenne ; cette définition diffère de celle de l'ANAP."
scope: "OpRoom, études de casemix et de temps de bloc du DIM ; le tableau de bord ANAP garde sa définition"
responsible: Pierre
reconsider_when: "le conflit avec la définition ANAP du TROS est tranché (kb de dim-code : oproom.open-question.tmi-meaning)"
maturity: documented
lifecycle: active
terms: [oproom:tmi, oproom:intervention]
tables: [oproom:OR_INTERVENTIONS]
supported_by: [20261015-kb-tmi-bionettoyage]
depends_on: []
---
## Pour s'en servir

Calculer la durée d'une intervention par I_ACTUAL_END moins I_ACTUAL_START : elle inclut le bionettoyage. Écrire « TMI, bionettoyage compris » à côté du chiffre. Ne pas comparer ce TMI aux chiffres du tableau de bord ANAP, dont le temps s'arrête au début du bionettoyage.

## Ce qui l'appuie

La décision est consignée dans la base de connaissances de dim-code (note validée par Pierre le 08/10/2026). I_ACTUAL_END est la fin du bionettoyage, pas la sortie de salle : la même note de dim-code le rappelle (pitfall.actual-start-end-meaning).

Points ouverts : la définition de l'ANAP et celle du DIM coexistent ; le choix n'est pas arbitré entre elles.
