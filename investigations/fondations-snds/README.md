# Que faut-il savoir du portail SNDS de la Cnam (profil 108) avant d'en interroger les tables depuis R ?

Personne : Pierre
Issue : #127

## Cadrage
But : que l'agent d'une étude SNDS écrive du R qui tourne du premier coup sur le portail, et sache ce que les sources ne disent pas sur notre accès.
Source : le portail SNDS de la Cnam, via Citrix et RStudio Server, profil 108 (accès permanent d'un établissement de santé, ici le DIM du CHU de Rouen) ; la documentation collaborative du HDH et les documents de la Cnam qu'elle publie.
Population : sans objet (fondations : accès, tables, profondeur historique).
Période : à trancher par table, à l'étape 4.
Unité d'analyse : la table ou la vue Oracle visible depuis le profil.
Mesure : une par claim (connexion, tables visibles, années disponibles).
Comparaison : ce que disent les sources contre ce qu'on observe sur le portail.

## Choix
- La documentation n'est pas recopiée : elle reste chez son éditeur, et chaque document lu a sa fiche dans sources/, avec un lien figé sur un commit du dépôt GitLab du HDH (le site documentation-snds.health-data-hub.fr est inaccessible depuis l'environnement de l'agent, ses sources GitLab le sont).
- Le circuit de travail (scripts envoyés par presse-papiers, sortie des agrégats par `sortir()` puis `snds_retour.py`) est un outil de DIM-code, pas un fait des données : il vit dans DIM-code (`.agents/habitudes/circuit.md`, PR #44 de DIM-code), pas ici.
- Seuil de masquage : 10 pour tout ce qui sort du portail, comme dans le reste du dépôt, alors que la charte du portail exige 5 (Pierre, 2026-11-04).
- Les algorithmes de la BOAS (gitlab.com/healthdatahub/boas) ont une fiche quand une étude en lit un, pas avant.

## Conclusions
