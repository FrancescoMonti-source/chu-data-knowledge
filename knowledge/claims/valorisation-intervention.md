---
review: unreviewed
id: valorisation-intervention
kind: decision
author: Pierre
statement: "Au DIM, on valorise une intervention de bloc par la somme des tarifs CCAM de ses actes (ni le montant CORA ni le tarif facturable), par son ICR, ou par le montant de son séjour (RSS ou GHS), partagé à parts égales entre les interventions du séjour."
scope: "CORA et OpRoom, restitution du GIC du 15/10/2026 et analyses de valorisation du DIM"
responsible: Pierre
reconsider_when: "une valorisation à la recette de l'intervention est possible, ou la méthode de répartition du séjour entre ses interventions change"
maturity: documented
lifecycle: active
terms: [oproom:intervention, pmsi:ccam, pmsi:icr, cora:rss, cora:acte]
tables: [cora:TB_ACTE, cora:TB_SYNTH_RSS]
supported_by: [20261015-decision-valorisation]
depends_on: []
---
## Pour s'en servir

Trois valorisations, aux sens différents ; nommer celle qu'on emploie :

- **par les actes :** somme des tarifs CCAM secteur 1, à 100 % de chaque acte, des actes chirurgicaux (activité 1) rattachés à l'intervention ; pas le montant calculé par CORA, pas le tarif « facturable » pondéré par le code d'association ;
- **par l'ICR :** somme des ICR des actes chirurgicaux, référentiel de l'ATIH (acte-principal-icr) ; un indice de poids, pas un montant ;
- **par le séjour :** montant du RSS (MNT_TOTAL : GHS, bornes haute et basse, suppléments) ou montant du GHS seul (calculé par CORA, à défaut tarif du référentiel), réparti à parts égales entre les interventions du même séjour.

Les interventions sans acte rattaché ne sont pas valorisées par les actes : le total sous-estime l'activité quand le chaînage est incomplet (chainage-actes-oproom-progressif).

## Ce qui l'appuie

Choix de Pierre pour la restitution du 15/10/2026, après avoir comparé le montant CORA, le tarif facturable et la somme des tarifs CCAM. La restitution présente aussi les euros par heure de TMI comme indicateur à discuter, pas comme une mesure établie.

Points ouverts : un acte réalisé pendant une hospitalisation est inclus dans le GHS du séjour (piège de la base de connaissances de dim-code, cora.pitfall.or-act-included-in-ghs) : la valorisation par les actes mesure un contenu en actes codés, pas une recette. Les derniers mois d'une extraction ont un codage de séjour incomplet (cora.pitfall.rss-before-validation) : à exclure ou signaler pour le RSS et le GHS.
