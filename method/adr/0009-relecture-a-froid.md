# 0009 — Corrections après la relecture à froid

Statut : accepté, 2026-10-11 (Francesco, choix « Clear fixes » après la relecture à froid des skills et de docs/agents). Modifié par 0018 : la branche d'une enquête s'appelle investigation/<id>. Modifié par 0033 : plus d'exception WHERE 1=0, les colonnes se cherchent dans le catalogue.

## Contexte

Un agent sans contexte a relu AGENTS.md, les skills et docs/agents en suivant une enquête de bout en bout. Il a trouvé des étapes qui ne disent pas sur quelle branche travailler, deux règles de sécurité que le contrôle suppose sans qu'aucune convention les demande, et des étapes qu'un agent ne peut pas finir seul.

## Décision

- Une enquête se fait sur sa branche `enquete/<id>` ; chaque commit est poussé ; frame retrouve une enquête par ses branches (investigations/README.md, « La branche »).
- Une colonne d'effectif s'appelle N_… ou NB_… ; le résultat d'une exécution est un tableau Markdown. Pour un résultat masqué, le contrôle refuse tout ce qui est hors du tableau, sauf un bloc sql.
- Le contrôle lit une requête sans ses commentaires, en gardant le texte entre guillemets ; WHERE 1=0 n'exempte qu'une requête à un seul SELECT.
- Une personne s'écrit toujours de la même façon : son prénom, plus l'initiale du nom si deux personnes ont le même prénom. read_by suit la même règle qu'author.
- Une donnée de personne arrivée dans la conversation suit la procédure d'incident, comme dans un fichier.
- sediment écrit les Conclusions avant le merge, demande l'accord de la personne avant d'écrire une relecture à son nom, et dit comment fermer ou suspendre l'issue.
- L'agent propose la retro quand la personne s'arrête (AGENTS.md), à la place des rappels dans relay et sediment.

## Conséquences

- Une requête des colonnes faite avec un WITH (deux SELECT) n'est plus exemptée : on l'écrit en un seul SELECT.
- Les effectifs ne sont toujours cherchés que dans les colonnes N_ et NB_ : c'est une limite déclarée (docs/agents/checks.md).
