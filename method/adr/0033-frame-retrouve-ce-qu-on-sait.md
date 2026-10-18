# 0033 — frame retrouve ce que le dépôt sait ; research et relay servent les étapes du plan

Statut : proposé, 2026-10-18 (Francesco, révision des skills). Modifie 0006 (une skill par activité, pour frame et research) et 0024 (la recherche dans le dépôt est celle de frame).

## Contexte

Dans la v0.4, frame cherchait aussi ce que le dépôt savait, et research ne lisait que des documents : frame paraissait complète, les autres floues. 0006 a donc donné une activité à chaque skill, frame pour parler, research pour lire les claims puis les documents.

Mais pour recommander une réponse à chaque question du cadrage, frame a besoin des claims : dans les tests de frame (2026-10-18), l'agent lisait déjà separer-ambulatoire-par-ghm pour proposer « GHM C…J ». research refaisait ensuite la même recherche. Et ce qu'on sait suffit ou non se voit déjà pendant le cadrage : research ne servait plus qu'à répondre ou à ouvrir l'enquête, avant ses documents. Enfin, research et relay ne se suivent pas : chacune sert une étape du plan, dans l'ordre que le plan demande.

## Décision

Le parcours a trois temps : frame, l'enquête si quelque chose manque, sediment.

- frame regarde d'abord si quelqu'un a déjà posé la question, puis cadre en cherchant ce que le dépôt sait. Ensuite, elle répond, prépare une routine, ou ouvre l'enquête. Ce qui manque : un fait qu'aucun claim n'établit, ou des données de l'hôpital, même un seul chiffre.
- Dans l'enquête, chaque étape du plan prend research pour un document, relay pour des données de l'hôpital.
- Les règles de 0024 valent pour la recherche de frame : lire les claims et leurs prémisses, pas leurs preuves ; les résultats des requêtes s'ouvrent dans relay. Le comment : method/layout.md, « Retrouver ce qu'on sait ».

## Raisons

On revient au partage de la v0.4, sans sa faiblesse : research et relay ont maintenant chacune une activité nette, un document ou des données. frame fait plus, mais ses deux étapes ont chacune leur critère de fin, et pendant le cadrage rien ne s'écrit.

## Alternatives écartées

- Garder la recherche complète dans research, frame ne lisant que les claims utiles au cadrage : les deux skills cherchent dans les mêmes fichiers, sans frontière nette.
- Fusionner research et relay : chaque skill ne charge que ses étapes, et celles de relay, qui protègent les données, restent à part (raison de 0006).
- Un chemin relay sans enquête pour un seul chiffre : la preuve n'aurait pas de branche où vivre.

## Conséquences

- Un comptage rapide dont la méthode est connue ouvre une enquête d'une seule étape relay.
- frame n'est plus seulement une conversation : après le cadrage, elle écrit la réponse, la routine ou l'ouverture de l'enquête.
