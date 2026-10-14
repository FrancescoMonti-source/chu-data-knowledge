---
review: unreviewed
id: oproom-blocs-entres-par-etapes
kind: empirical
author: Pierre
statement: "Dans OpRoom, les blocs ne sont pas tous suivis depuis 2023 : le bloc de pédiatrie entre en mai 2023 et atteint son volume au printemps 2024, l'endoscopie et Robec M4 en août-septembre 2023, DEVE en février 2024 ; une série qui couvre plusieurs blocs doit partir de mars 2024, ou se faire bloc par bloc."
scope: "OpRoom de production (QBLOCP), interventions terminées ou clôturées commencées de janvier 2023 au 2026-10-09, par l'extraction de requete_oproom.py"
refuted_if: "un de ces blocs compte plus de 50 interventions par mois avant la date d'entrée donnée ici"
maturity: observed
lifecycle: active
terms: [oproom:intervention]
tables: [oproom:OR_INTERVENTIONS, oproom:OR_ROOMS, oproom:OR_SITES]
supported_by: [20261014-oproom-blocs-mois-resultat, 20261014-oproom-specialites-salles-resultat]
depends_on: [developper-sur-qbloct]
---
## Pour s'en servir

Avant de comparer des volumes d'interventions dans le temps, regarder à quelle date chaque bloc (le site physique de la salle) entre dans OpRoom :

- **Pédiatrie :** depuis mai 2023, en montée de charge jusqu'au printemps 2024 ;
- **Endoscopie, Robec M4 :** depuis août 2023, pleins en septembre 2023 ;
- **DEVE :** depuis février 2024.

Une hausse du total entre 2023 et 2024 vient surtout de ces entrées, pas de l'activité. Une série tous blocs confondus part de mars 2024 ; avant, la faire bloc par bloc, ou exclure les blocs entrés en cours de route et le dire. Robec N1 et Robec N3 changent de volume en 2023-2024 : une série de l'un ou l'autre n'est pas comparable d'une année à l'autre. Des salles ont sans doute changé de bloc ; c'est à vérifier dans OR_ROOM_SITES. La spécialité PED suit le bloc de pédiatrie : 1 532 interventions en 2023, 3 809 en 2024, 4 459 en 2025.

## Ce qui l'appuie

Interventions par mois et par bloc (20261014-oproom-blocs-mois-resultat) : Pédiatrie, aucune ligne avant mai 2023, 85 en mai 2023, de 143 à 275 par mois jusqu'en avril 2024, puis de 278 à 433 par mois de mai 2024 à septembre 2026 ; Endoscopie, 30 en août 2023, puis 106 à 274 par mois ; Robec M4, 22 en août 2023, puis 207 à 354 ; DEVE, 15 en février 2024, puis 35 à 112. Gynéco-obstétrique et Robec N1 à N3 sont présents dès janvier 2023 ; Robec N1 passe d'environ 800 interventions par mois à environ 400 en février 2024 ; Robec N3 descend d'environ 900 en janvier 2023 à 340 en décembre 2023, puis compte environ 1 000 par mois depuis novembre 2024 (masqué de février à octobre 2024). Bloc non renseigné : de moins de 10 à 17 par mois en 2023, aucune ligne depuis novembre 2024.

Spécialité PED par année (20261014-oproom-specialites-salles-resultat).

Les cases de moins de 10 sont masquées ; quand elles totalisent moins de 10 dans un mois, le plus gros bloc du mois l'est aussi (souvent Robec N3).
