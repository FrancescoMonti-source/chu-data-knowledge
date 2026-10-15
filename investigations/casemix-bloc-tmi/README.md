# L'allongement du TMI des blocs entre 2025 et 2026 vient-il de la structure de l'activité ou de la durée des actes ?

Personne : Pierre
Issue : à ouvrir (le numéro s'ajoute ici avec la PR)

## Cadrage
But : savoir si l'allongement du temps moyen d'intervention (TMI) entre 2025 et 2026 vient d'un changement de structure de l'activité (moins d'actes rapides, plus d'actes longs) ou d'actes plus longs à structure égale, et dans quelles phases (avant l'incision, temps chirurgical, après l'incision).
Population : interventions OpRoom de la base de production, hors bloc d'urgence, avec au moins un acte CCAM rattaché ; salles interventionnelles écartées.
Période : janvier à septembre 2025 contre janvier à septembre 2026 (mêmes mois).
Unité d'analyse : l'intervention.
Mesure : le TMI, bionettoyage compris ; décomposition exacte de l'écart de moyenne (type Kitagawa) par acte CCAM principal.
Comparaison : 2026 contre 2025 ; intervalles de confiance par bootstrap, non corrigés des comparaisons multiples.

Le travail s'est fait dans le dépôt dim-code (analysis/2026-10_casemix_bloc), avec la restitution du GIC du 15/10/2026 ; ce dépôt n'en garde que les conventions.

## Choix
- Strate = acte CCAM principal, pas la procédure OpRoom : le catalogue des procédures change d'une année à l'autre et crée de faux effets de structure.
- Acte principal choisi par l'ICR (acte-principal-icr), pas par le tarif : l'ICR est stable d'une année à l'autre.
- Résolution fine, aucun seuil dans le calcul (decomposer-ecart-sans-regrouper-les-rares) : le regroupement des actes rares dans un bloc déplaçait de la structure vers la durée.
- Bloc d'urgence = tout le non programmé, écarté du TMI seulement (tmi-hors-bloc-urgence).
- Correction des comparaisons multiples de TMI par Benjamini-Hochberg (taux de fausses découvertes), pas par Holm : moins stricte, plus habituelle pour une comparaison exploratoire de nombreux groupes (Pierre).
- Valorisation : somme des tarifs CCAM, ICR, montant du RSS ou du GHS (valorisation-intervention).
- La comparaison à niveau de chaînage constant n'est pas faisable : le chaînage direct est très rare en 2025 et sur une sous-partie non représentative du CHU (chainage-actes-oproom-progressif).
- Le résultat chiffré n'est pas un claim : il n'a pas été obtenu par relay (colonnes calculées dans dim-code à partir d'extractions locales), donc il n'a pas de preuve d'exécution ici. Il reste dans les notebooks de dim-code.

## Conclusions
- tmi-bionettoyage-compris (unreviewed)
- programmation-priorite-demande (unreviewed)
- tmi-hors-bloc-urgence (unreviewed)
- salles-hors-perimetre-bloc (unreviewed)
- periode-analyse-oproom-2023 (unreviewed)
- acte-principal-icr (unreviewed)
- decomposer-ecart-sans-regrouper-les-rares (unreviewed)
- valorisation-intervention (unreviewed)
- chainage-actes-oproom-progressif (unreviewed)

Résultat de l'étude, pour mémoire (non sédimenté, voir dim-code, decomposition_tmi_2025_2026.ipynb) : le TMI hors bloc d'urgence augmente d'environ 2,7 minutes (+2 %). À résolution fine, la structure explique peu (environ +0,3 minute) et la durée à acte égal environ +2,4 minutes, répartie sur beaucoup d'actes et sur les trois phases. Cet effet de durée n'est pas séparable d'une hausse des interventions à plusieurs actes, dont la part est liée au changement de chaînage.
