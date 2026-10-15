# 0026 — Un script R pour un fichier gardé à l'hôpital

Statut : accepté, 2026-10-15 (Francesco, enquête revalorisation-chir-m8, issue #50).

## Contexte

L'enquête revalorisation-chir-m8 doit savoir ce que contenait le fichier groupé de l'envoi M8. Ce fichier reste à l'hôpital : il contient des données de patients. CORA ne dit pas si le fichier a été fait depuis les lignes groupées stockées ou par un nouveau groupage, et seul le fichier tranche. Le fichier s'est révélé être un nouveau groupage (20261015-m8-cora-par-mois-resultat) : pour classer chaque RSS, il faut le joindre, RSS par RSS, à son état actuel dans CORA. Le dépôt ne connaissait que des requêtes SQL : check.py ne lisait que les .sql de knowledge/queries/, et un autre fichier y recevait un ROUGE.

## Décision

Une requête sur un fichier gardé à l'hôpital est un script R de base, sans paquet, dans knowledge/queries/, avec le même en-tête commenté par `#`. Il suit les règles de method/queries.md, sauf la règle 2 : les positions du fichier viennent de la fiche de son format. Son résultat est une preuve d'exécution comme une autre.

Quand le résultat demande de joindre le fichier à CORA, le script lit aussi CORA : une requête SQL passée à `DBI::dbGetQuery`, sur la connexion que la personne a déjà ouverte. DBI est le seul paquet admis. Les lignes lues restent en mémoire, comme dans la base pour une requête SQL : seul le tableau d'agrégats masqués sort. Cette requête nomme ses colonnes, mais n'a pas à agréger (Francesco, 15/10).

check.py lit ces scripts : en-tête obligatoire, system connu ; pour masked, l'id entre guillemets, un comptage et le seuil < 10. Une preuve d'un script modifié garde la version exécutée dans un bloc ```r.

## Alternatives

- **Garder le script hors du dépôt**, son résultat dans l'issue : écarté, car un claim n'aurait pas pu citer ce résultat, qui décide de la réponse de l'enquête.
- **Python plutôt que R :** Francesco travaille en R à l'hôpital.
- **Charger le fichier dans une table de CORA** pour joindre en SQL : écarté, car cela copie des données de patients dans une base de production.
- **Rester dans CORA**, avec les DAS reconstitués par DATE_CREAT : écarté, car le GHM à M8 resterait inconnu, et la montée de niveau avec lui.

## Conséquences

- Le contrôle ne vérifie pas qu'un script n'imprime rien d'autre que son tableau : c'est une règle de confiance, comme le masquage juste d'une requête SQL.
