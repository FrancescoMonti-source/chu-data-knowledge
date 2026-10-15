---
review: unreviewed
id: tmi-hors-bloc-urgence
kind: decision
author: Pierre
statement: "Au DIM, le « bloc d'urgence » est toute intervention non programmée, quelle que soit la salle ; une analyse de TMI l'écarte et le dit (« hors bloc d'urgence »), les autres indicateurs (volumes, valorisation, casemix) la gardent."
scope: "OpRoom, restitution du GIC du 15/10/2026 et analyses de TMI du DIM"
responsible: Pierre
reconsider_when: "la restitution distingue les urgences vitales du non programmé, ou le TMI des interventions non programmées devient lui-même un objet d'étude"
maturity: documented
lifecycle: active
terms: [oproom:programmation, oproom:tmi]
tables: []
supported_by: [20261015-decision-bloc-urgence]
depends_on: [programmation-priorite-demande, tmi-bionettoyage-compris]
---
## Pour s'en servir

Pour un TMI ou une comparaison de TMI, écarter toutes les interventions dont la programmation est « non programmé » : urgences vitales ou relatives, semi-programmé et non programmé de moins d'une semaine (programmation-priorite-demande). Garder les interventions dont la priorité n'est pas renseignée. Écrire « hors bloc d'urgence » sur le chiffre ou la figure.

Pour tout le reste (volumes, valorisation, casemix, qualité du chaînage), garder les urgences.

Ne pas confondre avec une salle d'urgence (la salle Tokyo de gynécologie n'est pas écartée en bloc) ni avec la seule classe « urgence » : le non programmé et le semi-programmé sortent aussi.

## Ce qui l'appuie

Décision de Pierre le 15/10/2026, après une première restitution qui n'écartait que les urgences au sens strict : « ce que j'appelle les blocs d'urgence, c'est tout ce qui n'est pas programmé ». Elle est consignée dans la configuration de l'étude casemix.

Points ouverts : la part d'interventions écartées n'est pas mesurée dans ce claim.
