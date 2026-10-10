# Enquêtes

Une enquête répond à une question précise. Un dossier par enquête, nommé par son sujet : `investigations/uf-vs-rum/`.

```text
investigations/uf-vs-rum/
  README.md   la question, le cadrage, le plan, les choix, les conclusions
  claims/     les claims d'enquête
```

Les preuves ne vont pas ici : elles vont dans systems/ ou domains/, où d'autres enquêtes les retrouveront.

## Le README.md d'une enquête

```markdown
# <la question, en une phrase>

Personne : <qui mène l'enquête>
Issue : <#N, quand le dépôt sera sur GitHub>

## Cadrage
But, population, période, unité d'analyse, mesure, comparaison.

## Plan
1. <étape> : <à quoi elle sert>

## Choix
Pourquoi une étape a été ajoutée ou sautée ; les décisions de méthode.

## Conclusions
Les claims de l'enquête, avec leur état de relecture.
```

Le plan est un échafaudage. Sur GitHub, il vit dans l'issue, et un plan revu est un nouveau commentaire « Plan revu ». Tant que le dépôt est local, il vit ici : un plan revu s'ajoute en dessous, avec sa date et sa raison, sans réécrire l'ancien. Le plan valable est le dernier.
