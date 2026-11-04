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
- La requête du catalogue complet (20261104-snds-objets-visibles) a été abandonnée après plus de 20 minutes ; elle est remplacée par 20261104-snds-familles-tables, filtrée sur les préfixes des tables du schéma du HDH et regroupée par famille. Une requête de catalogue sur ce portail cherche des noms exacts ou des préfixes, jamais tout le catalogue.
- Dans la preuve 20261104-snds-familles-tables-resultat, le propriétaire des synonymes privés, qui est l'identifiant de connexion de Pierre, est remplacé par UTILISATEUR : un identifiant de personne n'entre pas dans le dépôt public (method/privacy.md).
- Les algorithmes de la BOAS (gitlab.com/healthdatahub/boas) ont une fiche quand une étude en lit un, pas avant.
- La profondeur des tables utilisées (étape 4) se mène dans l'étude DIM-code 2026-11_mortalite_chir_onco_digestive, première étude SNDS de l'utilisateur : deux requêtes, 20261104-snds-profondeur-mco-deces-v2 (sorties du CHU par mois de 2020 à 2025, décès du référentiel par mois, tables de 2026) et 20261104-snds-valeurs-codes-mco-chu-v2 (valeurs de SEJ_NP, STC_URG, ENT_MOD, SOR_MOD, SEJ_TYP, clé de jointure PMSI-référentiel, BEN_DCD_DTE reste traité en R : 1600-01-01 = pas de décès). Leur résultat décide la fin du suivi de cette étude.

## Conclusions
- roracle-fonctionne-portail-snds (unreviewed)
- tables-snds-vues-profil-108 (unreviewed)
- referentiels-hdh-absents-profil-108 (unreviewed)
- lots-annee-en-cours-snds-cumulatifs (unreviewed)
- sej-np-stc-urg-codes-non-binaires (unreviewed)
- joindre-pmsi-mco-referentiel-par-nir (unreviewed)
