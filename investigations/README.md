# Enquêtes

Une enquête répond à une question précise. Un dossier par enquête, nommé par son sujet, avec son seul README.md : `investigations/uf-vs-rum/README.md`. Il garde la question, le cadrage, les choix et les conclusions.

Les claims, les preuves et les requêtes de l'enquête vont dans knowledge/ (method/layout.md), où d'autres enquêtes les retrouveront. Le README les cite par leur id.

## La branche

Une enquête se fait sur sa branche, `investigation/<id>`, où l'id est le nom de son dossier. La branche principale est main, la branche par défaut du dépôt sur GitHub : le README d'une enquête n'y arrive qu'avec sediment.

- **Ouvrir :** ouvrir l'issue, avec la question et le plan (« Le plan »), ou compléter celle qui pose déjà la question ; créer la branche depuis la branche principale à jour ; y écrire `investigations/<id>/README.md`, avec la question, le cadrage de frame et le numéro de l'issue ; enregistrer.
- **Retrouver :** une question peut vivre dans une issue avant d'avoir sa branche, et une enquête fermée ne garde que son issue, car fermer supprime la branche (sediment, étape 6). Chercher donc les mots du sujet dans les issues, ouvertes et fermées (`gh issue list --state all --search "<mots>"`), et dans les pull requests ouvertes (`gh pr list --search "<mots>"`) ; sans `gh`, demander à la personne. Puis lister les branches : `git fetch --prune`, `git branch -r --list "origin/investigation/*"`. Le README d'une branche se lit sans la reprendre : `git show origin/investigation/<id>:investigations/<id>/README.md`.
- **Reprendre :** avant tout travail, se placer sur sa branche, puis y faire entrer la branche principale à jour (`git fetch`, puis `git merge origin/main`). Sinon l'enquête ne voit pas les claims entrés depuis son ouverture. Lire ensuite son README, le dernier plan de son issue (« Le plan ») et les commentaires qui le suivent : les preuves déjà enregistrées, et l'étape que couvre chacune.
- **Rejoindre** ce que frame a trouvé, avec la personne qui le mène : une enquête, la reprendre ; son cadrage tient lieu de celui de frame s'il couvre la question, sinon proposer un plan revu. Une issue sans branche : ouvrir l'enquête depuis elle. Une pull request : la personne choisit d'attendre sa fusion ou de partir de sa branche.
- **Conflits :** un conflit add/add sur un claim de knowledge/claims/ veut dire que deux enquêtes ont choisi le même id. Garder tel quel le fichier de main, et donner au sien un nouvel id : nom du fichier, champ id, et partout où il est cité. Dans un glossaire, garder les termes des deux côtés ; un terme défini deux fois se tranche avec la personne.
- **Enregistrer :** `python checks/check.py` sans ROUGE ; commit sur la branche de l'enquête ; push (`git push -u origin investigation/<id>`) ; puis, pour chaque nouvelle preuve, un commentaire dans l'issue avec son id et l'étape du plan qu'elle couvre. La session suivante retrouve tout, même sur un autre ordinateur.

## Le README.md d'une enquête

```markdown
# <la question, en une phrase>

Personne : <qui mène l'enquête>
Issue : #<N>

## Cadrage
Le cadrage de frame, chaque point tranché avec sa raison en quelques mots.

## Choix
Les décisions de méthode, une ligne chacune avec sa raison.

## Conclusions
Les claims de l'enquête, avec leur état de relecture.
```

## Choix

Ce que frame a tranché reste dans Cadrage. Une décision de méthode prise ensuite avec la personne, ou qui change le cadrage, s'écrit dans Choix au moment où elle est prise, en une ligne avec sa raison : « on écarte les séjours sans RSS : la requête montre qu'ils ne sont pas classés ». Elle n'est pas un claim : une preuve ne peut ni la confirmer ni la contredire.

## Le plan

Le plan est un échafaudage : il vit dans l'issue de l'enquête (modèle : .github/ISSUE_TEMPLATE/investigation.md). C'est ce qui manque, en quelques étapes dans l'ordre, chacune avec ce à quoi elle sert : un document à lire (research), une requête à l'hôpital (relay), ou une définition à trancher avec la personne une fois ses preuves réunies, qui s'écrit alors dans Choix. Une routine qui fait le calcul d'une étape y est nommée avec ses réglages, et l'écart entre ce qu'elle compte et la question, s'il y en a un.

- Un plan revu est un nouveau commentaire « Plan revu », avec sa raison. Le plan valable est le dernier. La raison va aussi dans Choix : l'issue finit fermée, le README reste.
- Sans `gh`, la personne fait le lien : elle colle l'issue dans la conversation pour que l'agent la lise, et colle dans l'issue le texte que l'agent lui donne.

## L'issue ou le dépôt

L'issue d'une enquête garde le travail à faire. Le dépôt garde ce qu'on a observé.

Avant d'écrire une chose, la classer :

- **Une requête, une preuve ou un claim :** l'écrire dans le dépôt, sur la branche de l'enquête. Dans l'issue, écrire seulement l'id de la preuve, sans le résultat. Seule exception : le commentaire qui ferme l'issue donne la réponse, masquée comme une preuve (sediment, étape 6).
- **Un plan, une hypothèse ou un test à faire :** l'écrire dans l'issue.

Une preuve qu'aucun claim ne cite :

- **le résultat d'une requête :** il reste dans le dépôt tant que l'issue ouverte d'une enquête le cite. Si l'enquête se ferme sans claim qui le cite, la preuve et sa requête sont supprimées (sediment, étape 5).
- **une lecture :** la supprimer avant le merge. Relire le document coûte peu.

Un claim jugé inutile avant le merge part avec ce qui ne servait qu'à lui : preuves, requêtes, termes. Après le merge, il passe en withdrawn (method/claims.md).

Une affirmation non éprouvée est une hypothèse, même quand un document la dit. La lecture du document est une preuve ; l'affirmation reste dans l'issue jusqu'à son test.

Exemple : le résultat d'une requête sur les séjours sans RSS est une preuve, dans knowledge/evidence/. « La plupart des séjours sans RSS sont des consultations externes » est une hypothèse, dans l'issue.

Raison : le contrôle lit seulement le dépôt, et l'issue finit fermée.
