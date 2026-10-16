# 0027 — Des routines pour les calculs qu'on refait

Statut : accepté, 2026-10-16 (Francesco, enquête revalorisation-chir-m8, issue #50).

## Contexte

L'enquête revalorisation-chir-m8 a écrit un script R qui compare deux états du codage, le fichier groupé d'un envoi et CORA aujourd'hui, et classe les RSS qui ont gagné un diagnostic. Francesco veut le refaire avec d'autres codes, d'autres fichiers (M7 contre M8, par exemple) et d'autres regroupements, et d'autres calculs de ce genre viendront. Une requête exécutée ne change plus (queries.md, règle 6) : chaque nouvelle exécution recopierait tout le script sous un nouvel id. La méthode du calcul (positions du fichier, classes, limites) n'aurait pas de place à elle : elle resterait dans les commentaires de chaque copie.

## Décision

Un calcul qu'on refait est une routine : un dossier knowledge/routines/<id>/ qui contient deux fichiers.

- `<id>.R` : le code. Il définit une fonction qui prend les réglages en paramètres et imprime un seul tableau d'agrégats masqués. Son en-tête est celui d'un script (queries.md), plus `version`, un entier. Ses premières colonnes : QUERY_ID, l'id de la requête qui l'appelle, et ROUTINE, « <id> v<version> ».
- `README.md` : la méthode, en français : ce que la routine compte, ses paramètres, d'où viennent les positions, ses limites, les claims sur lesquels elle s'appuie.

Une exécution reste une requête de knowledge/queries/ : un court script R, avec la ligne d'en-tête `# routine: <id>`, qui charge la routine et appelle sa fonction avec ses réglages. Le résultat est une preuve d'exécution de cette requête, comme avant.

Une routine change, contrairement à une requête : chaque changement du code augmente sa version de 1. L'empreinte d'un claim couvre le code de la routine de ses preuves : un changement périme sa relecture.

Le contrôle applique à la routine les règles d'un script (le texte « <id> v<version> » entre guillemets, un comptage, le seuil < 10), vérifie qu'elle a son README.md et que son dossier porte son id. Pour la requête qui l'appelle, il vérifie que la routine existe, que le script la charge, qu'il passe l'id de la requête et que person_data est le même.

## Raisons

- La requête garde ses règles : une exécution, un fichier daté qui ne change plus, qui dit exactement les réglages utilisés.
- La méthode a un seul endroit, le README de la routine, au lieu d'une copie par exécution.
- La version imprimée dans le résultat dit quel code a produit la preuve ; l'historique git garde chaque version.

## Alternatives écartées

- **Un dossier scripts/ hors de knowledge/ :** une routine compte des données du CHU et dépend de claims (les positions, le sens d'un TYPE_DIAG) : elle va avec ce qu'on apprend, et le contrôle doit la lire.
- **Recopier le script à chaque exécution :** la méthode se disperse, et une correction ne touche qu'une copie.

## Conséquences

- Seulement en R pour l'instant. Une routine SQL attendra une vraie enquête qui la demande.
- Le contrôle ne vérifie pas qu'une version a augmenté quand le code a changé : c'est une règle de confiance (checks.md).
- La première routine est revalorisation-entre-deux-etats, tirée de 20261015-classes-envoi.
