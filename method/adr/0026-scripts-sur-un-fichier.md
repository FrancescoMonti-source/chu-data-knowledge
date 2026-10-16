# 0026 — Un script R pour un fichier gardé à l'hôpital

Statut : accepté, 2026-10-15 (Francesco, enquête revalorisation-chir-m8, issue #50).

## Contexte

Certaines questions demandent l'état des séjours à un moment passé, celui d'un envoi par exemple. Cet état n'existe parfois que dans un fichier gardé à l'hôpital, comme le fichier groupé de l'envoi. Ce fichier contient des données de patients : il ne sort pas de l'hôpital. Les personnes qui y exécutent les requêtes travaillent en R.

La confidentialité repose sur des requêtes qui agrègent et masquent elles-mêmes, et sur le contrôle, qui y cherche les marques de ce masquage (queries.md). Une requête SQL ne renvoie que le résultat de son SELECT. Un script peut imprimer à n'importe quelle ligne : le contrôle y cherche les mêmes marques, sans pouvoir s'assurer que le tableau masqué est la seule chose imprimée.

## Décision

Une requête peut être un script R qui lit un fichier gardé à l'hôpital, et au besoin la base de son système, et qui n'imprime qu'un tableau d'agrégats masqués. Son résultat est une preuve d'exécution comme une autre. Les règles : method/queries.md, « Un script sur un fichier ».

## Alternatives écartées

- **Garder le script hors du dépôt, son résultat dans l'issue :** aucun claim ne pourrait citer ce résultat.
- **Reconstituer l'état passé depuis l'historique de la base :** l'historique ne garde pas tout ce que le fichier garde.
- **Charger le fichier dans une base, pour l'interroger en SQL :** il faut d'abord copier les données de patients dans cette base, et la copie reste à protéger puis à effacer.
- **Des paquets R au choix :** chaque paquet est du code de plus à installer à l'hôpital et à faire confiance. R de base suffit pour lire un fichier ; DBI suffit pour lire la base, sur la connexion que la personne ouvre déjà.

## Conséquences

- Pour un script, que seul le tableau masqué sorte est une règle de confiance : le contrôle ne le vérifie pas (queries.md, « Un script sur un fichier »).
- Exécuter une requête peut demander R à l'hôpital, et DBI quand le script lit la base.
