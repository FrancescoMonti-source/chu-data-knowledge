---
review: unreviewed
id: programmation-priorite-demande
kind: decision
author: Pierre
statement: "Au DIM, une intervention est programmée, non programmée ou urgente selon la priorité posée à sa demande d'intervention (W_PRIORITY), à défaut celle de l'intervention ; les urgences sont rangées avec le non programmé, sans contrôle par le mode d'entrée du séjour."
scope: "OpRoom, études de casemix et de temps de bloc du DIM"
responsible: Pierre
reconsider_when: "la priorité à la demande se révèle peu fiable, ou le mode d'entrée du séjour (CORA) est retenu pour repérer les urgences"
maturity: documented
lifecycle: active
terms: [oproom:programmation, oproom:intervention]
tables: [oproom:OR_WAITINGLIST, oproom:OR_INTERVENTIONS]
supported_by: [20261015-kb-priorite-demande]
depends_on: []
---
## Pour s'en servir

Lire la priorité sur la demande d'intervention (W_PRIORITY de OR_WAITINGLIST), puis sur l'intervention seulement si la demande n'en porte pas. Regrouper les codes en trois classes : urgence, non programmé, programmé. La table de regroupement est celle de l'étude casemix de dim-code (config_casemix.PRIORITE) : les codes d'urgence vitale ou relative, les codes semi-programmés et non programmés de moins d'une semaine, et les codes programmés. Ne pas passer par le mode d'entrée du séjour pour dire qu'une intervention est une urgence.

## Ce qui l'appuie

Décision de Pierre (08/10/2026), consignée dans la base de connaissances de dim-code. Alternatives écartées : la priorité de l'intervention seule (posée après coup) et le mode d'entrée du séjour.

Points ouverts : la table de regroupement des codes n'est pas recopiée ici ; elle vit dans le code de l'étude.
