# 0034 — frame retrouve ce que le dépôt sait ; research et relay servent les étapes du plan

Statut : proposé, 2026-10-18 (Francesco, révision des skills). Modifie 0006 (une skill par activité, pour frame et research), 0016 (frame écrit après le cadrage), 0021, 0023 et 0024 (la recherche dans le dépôt est celle de frame).

## Contexte

Dans la v0.4, frame cherchait aussi ce que le dépôt savait, et research ne lisait que des documents : frame paraissait complète, les autres floues. 0006 a donc donné une activité à chaque skill, frame pour parler, research pour lire les claims puis les documents.

Mais pour recommander une réponse à chaque question du cadrage, frame a besoin des claims : dans les tests de frame (2026-10-18, simulés, non conservés), l'agent lisait déjà separer-ambulatoire-par-ghm pour proposer « GHM C…J ». research refaisait ensuite la même recherche. Et ce qu'on sait suffit ou non se voit déjà pendant le cadrage : research ne servait plus qu'à répondre ou à ouvrir l'enquête, avant ses documents. Enfin, research et relay ne se suivent pas : chacune sert une étape du plan, dans l'ordre que le plan demande.

## Décision

Le parcours a trois temps : frame, l'enquête si quelque chose manque, sediment. Un chiffre de l'hôpital, même seul, passe par une enquête ; sans claim, elle se ferme sans pull request. Une question qui ne demande que ce que dit un document hors du dépôt se répond dans frame, sans enquête ni écriture. Les règles : .agents/skills/frame/SKILL.md (ce qui manque), method/layout.md (« Retrouver ce qu'on sait »), .agents/skills/sediment/SKILL.md (étapes 5 et 6).

## Raisons

- La recherche nourrit le grill : la faire dans frame évite de la refaire dans research. research et relay gardent chacune une activité nette, un document ou des données, au service d'une étape du plan ; research garde son nom, lire un document reste une recherche.
- Un chiffre passe par une enquête parce que son issue rend la question visible à l'étape 1 de frame pour les autres, que la CI contrôle sa requête (privacy.md), et que le commentaire de fermeture garde la question, le cadrage et la réponse. Sans claim, une pull request ne ferait entrer qu'un README.
- Ce qu'une source dit déjà n'est pas recopié en claim (method/claims.md, « Ce qui mérite un claim »), et sa lecture serait supprimée avant le merge (investigations/README.md, « L'issue ou le dépôt ») : une enquête n'en garderait que l'issue.
- 0024 évitait d'ouvrir les preuves d'un claim pour s'en servir. Le résultat d'une requête dont le purpose répond à la question est la réponse elle-même : frame l'ouvre, avec sa date.

## Alternatives écartées

- Garder la recherche complète dans research, frame ne lisant que les claims utiles au cadrage : les deux skills cherchent dans les mêmes fichiers, sans frontière nette.
- Fusionner research et relay : chaque skill ne charge que ses étapes, et celles de relay, qui protègent les données, restent à part (raison de 0006).
- Un relay sans enquête pour un seul chiffre, la requête contrôlée sur le poste et le chiffre donné dans la conversation : plus rapide, mais rien ne garde la question pour les autres, ni la trace d'un chiffre faux.
- Une enquête de chiffre fermée par une pull request : elle fait entrer un README sans claim, et chaque chiffre attend un mainteneur.

## Conséquences

- Un chiffre coûte une issue, une branche, une requête et sa preuve, puis la fermeture ; une routine, une pull request.
- Une enquête fermée sans claim perd son README, ses choix, ses requêtes et ses preuves : seule son issue reste, et l'étape 1 de frame cherche aussi les issues fermées.
- frame n'est plus seulement une conversation (0016 : « frame n'écrit rien ») : après le cadrage, elle écrit la réponse, la routine ou l'ouverture de l'enquête, avec le critère de fin de son étape 3.
- frame se charge en entier pour toute question nouvelle.
