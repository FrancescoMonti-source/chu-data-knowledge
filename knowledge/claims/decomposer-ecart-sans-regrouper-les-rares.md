---
review: unreviewed
id: decomposer-ecart-sans-regrouper-les-rares
kind: decision
author: Pierre
statement: "Au DIM, pour décomposer l'écart de TMI entre deux années en effet de structure et effet de durée par acte, chaque acte reste une strate dans le calcul, y compris les actes rares, nouveaux et disparus ; un seuil d'effectif ne sert qu'à l'affichage."
scope: "décomposition d'un écart de moyenne entre deux périodes, TMI par acte principal, QBLOCP 2025-2026"
responsible: Pierre
reconsider_when: "une méthode d'estimation qui tient compte du bruit des petites strates est adoptée, ou la décomposition porte sur une mesure dont les strates rares n'ont pas de sens"
maturity: documented
lifecycle: active
terms: [oproom:tmi]
tables: []
supported_by: [20261015-decision-resolution-fine]
depends_on: []
---
## Pour s'en servir

Décomposer l'écart de moyenne entre l'année A et l'année B avec une strate par acte (acte-principal-icr), sans seuil dans le calcul :

- structure d'une strate = (poids B moins poids A) × (moyenne de la strate moins moyenne globale), la moyenne de la strate étant celle des deux années ; durée = (moyenne B moins moyenne A) × (poids moyen) ; les deux s'additionnent exactement à l'écart observé ;
- un acte présent une seule année garde sa strate : son effet est de la structure pure ;
- ne pas regrouper les actes rares dans un bloc « Autres » avant de calculer : un bloc traité comme une seule strate compte en « durée » tout changement de sa composition (actes qui entrent, qui sortent, actes rares plus longs) ;
- un seuil d'effectif (par exemple 10 interventions chaque année) sert à choisir les actes listés ; les autres se regroupent après le calcul, en lignes séparées (rares, disparus, nouveaux), sans changer un total.

L'implémentation est decomposition_tmi.decomposition_fine, dans l'étude casemix de dim-code.

## Ce qui l'appuie

Décision de Pierre le 15/10/2026, après avoir vu que le résultat changeait beaucoup entre la version groupée et la version fine. Relevé de l'étude (QBLOCP, janvier à septembre 2025 et 2026, hors bloc d'urgence), non rejoué par relay : avec les actes de moins de 10 interventions regroupés dans un bloc, l'effet de durée du bloc vaut environ +2,6 minutes ; une fois le bloc ouvert, environ +0,4 ; l'effet de durée total varie de +3,3 à +4,6 minutes selon le seuil (100 ou 10), alors que la version fine n'en dépend pas.

Points ouverts : les intervalles de confiance (bootstrap) fixent les strates sur l'échantillon observé : l'incertitude sur les actes rares qui apparaissent ou disparaissent est sous-estimée ; une partie du roulement des actes rares est du hasard d'échantillonnage.
