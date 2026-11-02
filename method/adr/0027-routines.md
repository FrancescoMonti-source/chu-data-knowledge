# 0027 — Des routines pour les calculs qu'on refait

Statut : accepté, 2026-10-16 (Francesco, enquête revalorisation-chir-m8, issue #50).

## Contexte

Un même calcul revient d'une question à l'autre, avec d'autres réglages : d'autres codes, une autre période, un autre périmètre. La personne le lance à l'hôpital, pour son propre usage. Ses chiffres n'apprennent rien au dépôt ; ce qui s'y apprend, c'est ce que le calcul suppose sur les données : les positions d'un fichier, une clé de jointure. Une requête, elle, est faite pour revenir : son résultat devient une preuve, et une requête exécutée ne change plus (queries.md, règle 6). Faire de chaque calcul une requête recopierait le script à chaque réglage, et sa méthode resterait éparpillée dans les commentaires des copies.

## Décision

Un calcul qu'on refait est une routine : un dossier knowledge/routines/<id>/ avec son code et sa méthode, dans un README.md. Son résultat reste à l'hôpital et n'entre pas dans le dépôt. Ce que la routine suppose sur les données s'écrit en claims. Un chiffre qui doit devenir une preuve passe par une requête, qui recopie le calcul. Les règles : method/queries.md, « Une routine ».

## Raisons

- Le dépôt garde ce qu'on apprend, pas les chiffres qu'une routine produit à chaque exécution.
- La méthode a un seul endroit, le README de la routine ; les faits qu'elle suppose sont relus comme les autres, en claims.
- Le résultat ne revient pas : la routine peut tourner sans masquage, pour la personne seule. Le masquage reste la règle de ce qui revient, les requêtes.
- Une requête ne charge pas la routine : la routine change, et une preuve doit garder le code qui l'a produite.

## Alternatives écartées

- **Un dossier scripts/ hors de knowledge/ :** une routine dépend de ce qu'on sait des données ; elle va avec ce qu'on apprend, et le contrôle doit la lire.
- **Chaque exécution enregistrée comme une requête, avec une version de la routine :** le dépôt garderait des chiffres sans usage, et une preuve dépendrait d'un code qui change.

## Conséquences

- Le contrôle ne lit pas ce qu'une routine imprime : que son résultat reste à l'hôpital est une règle de confiance (checks.md).
