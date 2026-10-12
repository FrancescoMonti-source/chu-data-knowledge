# 0015 — Document hors ligne fait de parties indépendantes : un fichier par partie

Statut : accepté, 2026-10-12 (Francesco).

## Contexte

Le dictionnaire des données CORA est entré en un seul fichier texte de 1,9 Mo, une section par table (docs/adr/0014). Les requêtes fournies par défaut dans CORA, 173 requêtes, ont d'abord suivi le même modèle. Francesco a vu le défaut : une recherche dans un gros fichier renvoie des lignes sans dire de quelle table ou de quelle requête elles viennent, et lire le fichier entier charge tout le document dans la conversation, dont presque rien ne sert à la question.

## Décision

Un document hors ligne fait de parties qui se lisent séparément entre dans sources/ comme un dossier du nom de sa fiche, avec un fichier texte par partie. Le fichier porte le nom de la partie : une table, une requête. Le document garde une seule fiche, à côté du dossier : une fiche décrit un document et son édition, pas chacune de ses parties.

## Alternatives

- Un seul fichier, comme avant : simple, mais l'agent ne peut pas n'ouvrir que la partie utile.
- Un index à côté du fichier unique : une deuxième source de vérité à tenir à jour.
- Une fiche par partie : 1083 fiches qui répètent le même éditeur, la même édition et la même autorité, à tenir d'accord à chaque correction.

## Conséquences

- Une preuve de lecture cite la fiche dans source et le fichier dans locator (evidence.md).
- La fiche garde son id : la règle « sous l'id de sa fiche » ne change pas.
- Les noms de partie sont ceux de la source. Deux sections du dictionnaire portent le même nom, TB_INT_MESSAGES_ACTIVITE : la seconde s'appelle TB_INT_MESSAGES_ACTIVITE-2.
- Changer location de la fiche périme la relecture des claims qui lisent cette source (docs/adr/0013). Aucun claim ne lit encore le dictionnaire.
