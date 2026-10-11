---
name: retro
description: Rétrospective en fin de session : relever les accrocs avec la personne, comprendre leur cause, puis ouvrir ou compléter une issue friction sur GitHub. Quand la personne la demande.
disable-model-invocation: true
---

# retro

La retro se fait en parlant : la personne sait ce qui l'a gênée, l'agent sait ce qu'il a fait. Elle note et propose ; le mainteneur corrige.

Chaque problème est une issue GitHub avec l'étiquette friction ; chaque fois qu'il revient, un commentaire.

1. **Relever** les accrocs de la session : corrections de la personne, contrôles qui ont échoué, étapes refaites, outils refusés, règles cherchées ou mal comprises. Les présenter en une ligne chacun, et demander à la personne ce qui manque.
   Fini quand : la personne a confirmé la liste. Une liste vide est un bon résultat : la retro s'arrête là.
2. **Comprendre** chaque accroc avec la personne : ce qui s'est passé, et pourquoi. Prendre la première cause qui convient, dans cet ordre :
   - **check :** un contrôle aurait attrapé l'erreur. Une règle qu'on peut contrôler devient un contrôle, avec son test.
   - **pointer :** la règle existe, mais l'agent ne l'a pas trouvée : il manque un pointeur dans AGENTS.md, une skill ou docs/agents/.
   - **drift :** deux règles se contredisent, ou une règle cite un chemin, un champ ou une commande qui n'existe plus.
   - **unclear-step :** une étape de skill dit mal quoi faire, ou son critère de fin est trop vague.
   - **dead-weight :** une règle ne change rien, ou elle est écrite deux fois : la retirer.

   Écarter un accroc ponctuel que rien dans les règles n'aurait évité. Pour chacun des autres, proposer une correction : corriger la règle existante plutôt qu'en ajouter une.
   Fini quand : chaque accroc a une cause et une correction que la personne accepte, ou il est écarté avec sa raison.
3. **Chercher** parmi les issues friction, ouvertes et fermées, celle qui décrit le même accroc : `gh issue list --label friction --state all`, puis `gh issue view <n>`. Sans `gh`, demander la liste à la personne.
   Fini quand : chaque accroc gardé est relié à une issue, ou il est nouveau.
4. **Écrire.** Accroc déjà connu : un commentaire « Occurrence : <date>, <skill>, <enquête> : <ce qui s'est passé> », et `gh issue reopen` si l'issue était fermée. Accroc nouveau : une issue au format de .github/ISSUE_TEMPLATE/friction.md, avec l'étiquette friction. Sans `gh`, donner le texte à la personne, qui le colle. Décrire l'accroc, jamais les données : aucun extrait de résultat (docs/agents/privacy.md).
   Fini quand : chaque accroc gardé a son issue ou son commentaire, et la personne sait quelles issues ont deux occurrences ou plus.
