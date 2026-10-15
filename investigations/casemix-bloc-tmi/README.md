# L'allongement du TMI des blocs entre 2025 et 2026 vient-il de la structure de l'activité ou de la durée des actes ?

Personne : Pierre
Issue : à ouvrir (le numéro s'ajoute ici avec la PR)

## Cadrage
But : savoir si l'allongement du temps moyen d'intervention (TMI) entre 2025 et 2026 vient d'un changement de structure de l'activité (moins d'actes rapides, plus d'actes longs) ou d'actes plus longs à structure égale, et dans quelles phases (avant l'incision, temps chirurgical, après l'incision).
Population : interventions OpRoom de la base de production, hors bloc d'urgence (non programmé), avec au moins un acte CCAM rattaché.
Période : janvier à septembre 2025 contre janvier à septembre 2026 (mêmes mois).
Unité d'analyse : l'intervention.
Mesure : le TMI (duree-intervention-avec-bionettoyage) ; décomposition exacte de l'écart de moyenne (type Kitagawa) par acte CCAM principal.
Comparaison : 2026 contre 2025 ; intervalles de confiance par bootstrap, non corrigés des comparaisons multiples.

Le travail s'est fait dans le dépôt dim-code (analysis/2026-10_casemix_bloc) et sert la restitution du GIC du 15/10/2026. Les conventions propres à cette étude (périmètre, bloc d'urgence, valorisation, correction de Benjamini-Hochberg, type de séjour) restent dans le README de l'étude, section « Conventions du projet » : elles ne valent pas règle générale. Ce dépôt n'en garde que deux méthodes, proposées pour toute étude.

## Choix
- Strate = acte CCAM principal, pas la procédure OpRoom : le catalogue des procédures change d'une année à l'autre et crée de faux effets de structure.
- Acte principal choisi par l'ICR, pas par le tarif (acte-principal-icr) : l'ICR est stable d'une année à l'autre.
- Résolution fine, aucun seuil dans le calcul (decomposer-ecart-sans-regrouper-les-rares) : le regroupement des actes rares dans un bloc déplaçait de la structure vers la durée.
- Le résultat chiffré n'est pas un claim : il n'a pas été obtenu par relay (colonnes calculées dans dim-code à partir d'extractions locales), donc il n'a pas de preuve d'exécution ici. Il reste dans le notebook de dim-code.
- Le lien entre la hausse de la part des interventions à plusieurs actes et le changement de niveau de chaînage reste une hypothèse (issue), pas un claim : voir plus bas.

## Conclusions
- acte-principal-icr (unreviewed)
- decomposer-ecart-sans-regrouper-les-rares (unreviewed)

Résultat de l'étude, pour mémoire (non sédimenté, voir dim-code, decomposition_tmi_2025_2026.ipynb) : le TMI hors bloc d'urgence augmente d'environ 2,7 minutes (+2 %). À résolution fine, la structure explique peu et la durée à acte égal environ 2,4 minutes, répartie sur beaucoup d'actes et sur les trois phases. Cet effet de durée n'est pas séparable d'une hausse des interventions à plusieurs actes, dont la part est liée au changement de chaînage (le niveau « chaîné » passe d'environ un cinquième des interventions avec acte en 2025 à plus des trois quarts en 2026 ; relevé du notebook).

Hypothèse à éprouver (pour l'issue) : le nombre d'actes par intervention et l'acte principal ne sont pas comparables entre 2025 et 2026 sans contrôler le niveau de chaînage ; une requête relay qui compte les interventions par niveau de chaînage et par année en donnerait la preuve (rattacher-actes-bloc-sans-cle, chainer-oproom-cora).
