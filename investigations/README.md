# Enquêtes

Une enquête répond à une question précise. Un dossier par enquête, nommé par son sujet : `investigations/uf-vs-rum/`.

```text
investigations/uf-vs-rum/
  README.md   la question, le cadrage, les choix, les conclusions
  claims/     les claims d'enquête
```

Les preuves ne vont pas ici : elles vont dans systems/ ou domains/, où d'autres enquêtes les retrouveront.

## La branche

Une enquête se fait sur sa branche, `enquete/<id>`, où l'id est le nom de son dossier. La branche principale est la branche par défaut du dépôt sur GitHub (claude/v2 pour l'instant) : le README d'une enquête n'y arrive qu'avec sediment.

- **Ouvrir :** créer la branche depuis la branche principale à jour.
- **Retrouver :** `git fetch`, puis `git branch -r --list "origin/enquete/*"`. Une enquête est ouverte tant que son issue l'est.
- **Reprendre :** se placer sur sa branche avant tout travail.
- **Enregistrer :** chaque commit de l'enquête va sur sa branche, et il est poussé (`git push -u origin enquete/<id>`) : la session suivante le retrouve, même sur un autre ordinateur.

## Le README.md d'une enquête

```markdown
# <la question, en une phrase>

Personne : <qui mène l'enquête>
Issue : #<N>

## Cadrage
But, population, période, unité d'analyse, mesure, comparaison.

## Choix
Les décisions de méthode.

## Conclusions
Les claims de l'enquête, avec leur état de relecture.
```

## Le plan

Le plan est un échafaudage : il vit dans l'issue de l'enquête (modèle : .github/ISSUE_TEMPLATE/enquete.md).

- Un plan revu est un nouveau commentaire « Plan revu », avec sa raison. Le plan valable est le dernier.
- Chaque preuve enregistrée est citée dans un commentaire de l'issue : son id et l'étape qu'elle couvre.
- Sans `gh`, la personne fait le lien : elle colle l'issue dans la conversation pour que l'agent la lise, et colle dans l'issue le texte que l'agent lui donne.
