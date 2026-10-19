# 0032 — La réponse d'une enquête passe le test des autres conclusions

Statut : accepté, 2026-10-16 (Francesco, carte de l'enquête revalorisation-chir-m8). Applique 0022 à la réponse d'une enquête. Modifie 0018 (point 2).

## Contexte

0022 a ajouté le test « Ce qui mérite un claim » : une mesure qui n'oriente aucun usage n'est pas un claim. Cinq phrases venues de la v0.4 faisaient pourtant toujours de la réponse à la question un claim d'enquête : l'étape 1 de sediment, deux passages de claims.md, layout.md et le glossaire. Sur une question de comptage, les règles se contredisaient.

Dans l'enquête revalorisation-chir-m8, la réponse était un compte : les RSS de chirurgie dont le niveau a monté depuis l'envoi M8. L'agent en a fait un claim, comme le demandait sediment. Francesco l'a jugé inutile : ce compte ne change aucune requête. De cette enquête, ce qui mérite de rester est la méthode, ce qu'on a fait et pourquoi : les claims sur les données, la section Choix et la routine.

## Décision

La réponse à la question d'une enquête passe le même test que les autres conclusions (claims.md, « Ce qui mérite un claim »). Quand elle ne change rien à la façon d'interroger, elle va dans le commentaire qui ferme l'issue (sediment, étape 6).

## Alternatives écartées

- **Garder la réponse en claim d'enquête :** ses prémisses la reliaient aux claims atomiques, et l'on savait quelle réponse revoir si l'un d'eux tombait. Mais une réponse déjà remise à la personne n'est plus revue, et ce claim s'ajoute à ce que l'agent suivant doit lire sans rien lui apprendre.

## Conséquences

- Une enquête peut finir sans claim : Conclusions liste alors les claims atomiques, ou rien.
- Ce qu'on perd : depuis un claim atomique, depends_on ne mène plus aux réponses qu'il appuyait ; seule l'issue fermée garde la réponse.
- Le contrôle ne change pas : il ne distingue pas une réponse des autres claims.
