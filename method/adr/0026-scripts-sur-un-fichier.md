# 0026 — Un script R pour un fichier gardé à l'hôpital

Statut : accepté, 2026-10-15 (Francesco, enquête revalorisation-chir-m8, issue #50).

## Contexte

Certaines questions comparent les séjours à deux moments. Par exemple : quelle revalorisation a eu lieu entre un envoi et aujourd'hui, pour certains codes CIM-10 et un certain périmètre ? L'état ancien n'existe parfois plus que dans un fichier gardé à l'hôpital, comme le fichier groupé d'un envoi. La base a changé depuis, et son historique ne garde pas tout ce que le fichier garde. Ce fichier contient des données de patients : il reste à l'hôpital. Une requête était jusqu'ici un fichier SQL sur une base : le dépôt n'avait aucun moyen de lire un tel fichier, ni de le comparer séjour par séjour à l'état actuel de la base.

## Décision

Une requête peut être un script R qui lit un fichier gardé à l'hôpital, et au besoin le système de son en-tête, puis n'imprime qu'un tableau d'agrégats masqués. Son résultat est une preuve d'exécution comme une autre. Les règles : method/queries.md, « Un script sur un fichier ».

## Alternatives écartées

- **Garder le script hors du dépôt, son résultat dans l'issue :** aucun claim ne pourrait citer ce résultat.
- **Charger le fichier dans une table de la base, pour joindre en SQL :** cela copie des données de patients dans une base de production.
- **Reconstituer l'état ancien depuis l'historique de la base :** l'historique ne garde pas tout. Pour l'envoi M8, le GHM de l'envoi y manquait.
- **Python plutôt que R :** les personnes qui exécutent à l'hôpital travaillent en R.
- **Des paquets R au choix :** chaque paquet est du code de plus à installer à l'hôpital et à faire confiance. R de base suffit pour lire un fichier ; DBI suffit pour lire la base, sur la connexion que la personne ouvre déjà.

## Conséquences

- Le contrôle ne vérifie pas qu'un script n'imprime rien d'autre que son tableau : c'est une règle de confiance, comme le masquage juste d'une requête SQL (checks.md).
