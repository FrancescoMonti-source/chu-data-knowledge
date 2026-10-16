# 0027 — Des routines pour les calculs qu'on refait

Statut : accepté, 2026-10-16 (Francesco, enquête revalorisation-chir-m8, issue #50).

## Contexte

Un même calcul revient d'une question à l'autre, avec d'autres réglages : d'autres codes, une autre période, un autre périmètre. Une requête exécutée ne change plus (queries.md, règle 6) : refaire le calcul voudrait dire recopier tout le script sous un nouvel id. Sa méthode (positions du fichier, définitions, limites) n'aurait pas d'endroit à elle : elle resterait dans les commentaires de chaque copie, et une correction ne toucherait qu'une copie.

## Décision

Un calcul qu'on refait est une routine : un dossier knowledge/routines/<id>/ avec son code et sa méthode, dans un README.md. Elle porte une version, augmentée à chaque changement du code. Une exécution n'entre dans le dépôt que si son résultat sert de preuve à un claim : c'est alors une requête datée qui appelle la routine avec ses réglages. Les règles : method/queries.md, « Une routine ».

## Raisons

- La méthode a un seul endroit, le README de la routine.
- La requête garde ses règles : un fichier daté qui ne change plus et dit exactement les réglages utilisés.
- Le dépôt garde ce qu'on apprend, pas les chiffres qu'une routine produit à chaque exécution.
- La version imprimée dans le résultat dit quel code a produit une preuve. Un claim relu s'appuie sur ce code : quand il change, la relecture doit être refaite, donc l'empreinte du claim couvre la routine.

## Alternatives écartées

- **Un dossier scripts/ hors de knowledge/ :** une routine compte des données du CHU et dépend de claims (les positions d'un fichier, le sens d'un code de la base) : elle va avec ce qu'on apprend, et le contrôle doit la lire.

## Conséquences

- Seulement en R pour l'instant. Une routine SQL attendra une vraie enquête qui la demande.
- Le contrôle ne vérifie pas qu'une version a augmenté quand le code a changé : c'est une règle de confiance (checks.md).
