# 0016 — Les skills supermatt : leur méthode, les formats du dépôt

Statut : accepté, 2026-10-12 (Francesco, PR #13 fusionnée ; la ligne « À éviter » attendra une enquête qui en a besoin). Modifié par 0018 : les ADR sont dans method/adr/, et les glossaires dans knowledge/glossaries/. Modifié par 0021 : la ligne « Alias » remplace la ligne _Avoid_. Modifié par 0028 : seule une décision qui compte et qui tranche reçoit un ADR. Modifié par 0034 : après le cadrage, frame écrit la réponse, la routine ou l'ouverture de l'enquête.

## Contexte

Le dépôt attend deux skills de supermatt, installées par chacun (0000) : writing-for-agents et domain-modeling.

writing-for-agents ne fixe aucun format : elle dit comment écrire un document qu'un agent lit. Elle convient telle quelle.

domain-modeling apporte une méthode qui convient au dépôt : questionner un terme flou, inventer des cas limites, comparer ce que dit la personne à ce qui est écrit. Mais elle apporte aussi ses formats, et cinq d'entre eux contredisent le dépôt :

- un terme s'y écrit `**Mouvement**:` sous une section « Language », avec une ligne `_Avoid_` ; le contrôle ne lit que les titres `## cora:mouvement`, et un claim qui cite le terme reçoit un ROUGE (vérifié sur le jeu de test de checks/test_check.py le 2026-10-12) ;
- les liens entre contextes vont dans une section « Relationships » de GLOSSARY-MAP.md ; ici, un pont est un claim, avec ses preuves ;
- le glossaire s'écrit dès qu'un terme est tranché, pendant la conversation ; ici, frame n'écrit rien ;
- chaque contexte peut avoir son propre docs/adr/ ; ici, un seul dossier, pour les règles seulement ;
- un ADR ne s'écrit que s'il est difficile à défaire, surprenant et issu d'un vrai choix ; ici, toute décision du mainteneur sur une règle en reçoit un (règle 7).

## Décision

- On garde les deux skills telles quelles, sans copie ni version modifiée dans le dépôt (0000 reste en vigueur).
- AGENTS.md dit à quoi sert domain-modeling ici, et que ce qu'elle fait écrire suit les formats du dépôt.
- Les formats manquants sont écrits : un terme entre dans son glossaire avec le premier claim qui le cite (layout.md), et docs/adr/README.md décrit un ADR.

## Conséquences

- Une mise à jour de supermatt ne demande rien au dépôt : il ne s'appuie que sur la méthode de domain-modeling.
- La ligne `_Avoid_` de domain-modeling (les mots à éviter pour un terme) n'est pas reprise. Elle passerait le contrôle ; on l'ajoutera quand une enquête rencontrera deux mots pour une même chose.
