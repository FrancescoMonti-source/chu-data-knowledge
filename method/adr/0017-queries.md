# 0017 — Les requêtes s'appellent queries

Statut : accepté, 2026-10-12 (Francesco, qui a demandé le nouveau nom). Modifié par 0018 : les requêtes vont dans knowledge/queries/, et leur convention est method/queries.md.

## Contexte

Les clés et les noms de fichiers sont en anglais (AGENTS.md, règle 6). Le dossier des requêtes SQL s'appelait requests/, traduction mot à mot de « requêtes ». En anglais, une requête SQL est une query ; une request est une demande. Le mot trompait un lecteur anglophone, et le dépôt range déjà des « queries » ailleurs : les requêtes par défaut de CORA, dans sources/.

Aucune requête n'avait encore été écrite : les quatre dossiers étaient vides.

## Décision

Partout où le dépôt nomme une requête SQL, request devient query :

- les dossiers `systems/<système>/queries/` ;
- docs/agents/queries.md ;
- le champ `query` d'une preuve d'exécution, et la colonne `query_id` en tête du résultat ;
- le contrôle (checks/check.py) et ses tests.

Le texte libre garde « requête ».

## Conséquences

- Les ADR plus anciens (0003, 0011) gardent leur texte : requests.md et request_commit y désignent ce qui s'appelle maintenant queries.md et query.
- Une preuve qui écrirait encore `request:` reçoit un ROUGE : le champ query manque.
