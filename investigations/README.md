# Enquêtes

Une enquête répond à une question précise. Un dossier par enquête, nommé par son sujet, avec son seul README.md : `investigations/uf-vs-rum/README.md`. Il garde la question, le cadrage, les choix et les conclusions.

Les claims, les preuves et les requêtes de l'enquête vont dans knowledge/ (method/layout.md), où d'autres enquêtes les retrouveront. Le README les cite par leur id.

## La branche

Une enquête se fait sur sa branche, `investigation/<id>`, où l'id est le nom de son dossier. La branche principale est main, la branche par défaut du dépôt sur GitHub : le README d'une enquête n'y arrive qu'avec sediment.

- **Ouvrir :** créer la branche depuis la branche principale à jour.
- **Retrouver :** `git fetch --prune`, puis `git branch -r --list "origin/investigation/*"` : une branche par enquête ouverte ou suspendue, car fermer une enquête supprime sa branche (sediment, étape 6).
- **Reprendre :** avant tout travail, se placer sur sa branche, puis y faire entrer la branche principale à jour (`git fetch`, puis `git merge origin/main`). Sinon l'enquête ne voit pas les claims entrés depuis son ouverture.
- **Conflits :** un conflit add/add sur un claim de knowledge/claims/ veut dire que deux enquêtes ont choisi le même id. Garder tel quel le fichier de main, et donner au sien un nouvel id : nom du fichier, champ id, et partout où il est cité. Dans un glossaire, garder les termes des deux côtés ; un terme défini deux fois se tranche avec la personne.
- **Enregistrer :** `python checks/check.py` sans ROUGE ; commit sur la branche de l'enquête ; push (`git push -u origin investigation/<id>`) ; puis, pour chaque nouvelle preuve, un commentaire dans l'issue avec son id et l'étape du plan qu'elle couvre. La session suivante retrouve tout, même sur un autre ordinateur.

## Le README.md d'une enquête

```markdown
# <la question, en une phrase>

Personne : <qui mène l'enquête>
Issue : #<N>

## Cadrage
But, population, période, unité d'analyse, mesure, comparaison.

## Choix
Les décisions de méthode, une ligne chacune avec sa raison.

## Conclusions
Les claims de l'enquête, avec leur état de relecture.
```

## Choix

Une décision de méthode prise avec la personne s'écrit dans Choix au moment où elle est prise, en une ligne avec sa raison : « on compte les séjours, pas les patients : la question porte sur l'activité ». Elle n'est pas un claim : une preuve ne peut ni la confirmer ni la contredire.

## Le plan

Le plan est un échafaudage : il vit dans l'issue de l'enquête (modèle : .github/ISSUE_TEMPLATE/investigation.md).

- Un plan revu est un nouveau commentaire « Plan revu », avec sa raison. Le plan valable est le dernier. La raison va aussi dans Choix : l'issue finit fermée, le README reste.
- Sans `gh`, la personne fait le lien : elle colle l'issue dans la conversation pour que l'agent la lise, et colle dans l'issue le texte que l'agent lui donne.

## L'issue ou le dépôt

L'issue d'une enquête garde le travail à faire. Le dépôt garde ce qu'on a observé.

Avant d'écrire une chose, la classer :

- **Une requête, une preuve ou un claim :** l'écrire dans le dépôt, sur la branche de l'enquête. Dans l'issue, écrire seulement l'id de la preuve, sans le résultat.
- **Un plan, une hypothèse ou un test à faire :** l'écrire dans l'issue.

Une preuve qu'aucun claim ne cite, avant que l'enquête entre dans la branche principale :

- **une lecture :** la supprimer. Relire le document coûte peu.
- **le résultat d'une requête :** le garder dans le dépôt, avec sa requête. Une nouvelle exécution demande une personne à l'hôpital.

Une affirmation non éprouvée est une hypothèse, même quand un document la dit. La lecture du document est une preuve ; l'affirmation reste dans l'issue jusqu'à son test.

Exemple : le résultat d'une requête sur les séjours sans RSS est une preuve, dans knowledge/evidence/. « La plupart des séjours sans RSS sont des consultations externes » est une hypothèse, dans l'issue.

Raison : le contrôle et research lisent seulement le dépôt, et l'issue finit fermée.
