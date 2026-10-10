# Contrôles

Les contrôles vérifient la forme, pas la vérité. On lance `python checks/check.py` avant chaque commit ; sur GitHub, la CI le lancera à chaque PR.

- **ROUGE :** quelque chose est cassé. À corriger avant le merge. Le script sort avec le code 1.
- **ORANGE :** du travail reste à faire. Ne bloque pas : un résultat partiel ou une contestation peuvent entrer.

Chaque message donne le fichier, le champ et le problème, puis, à la ligne suivante, la correction.

## La liste

| Niveau | Contrôle |
|---|---|
| ROUGE | fichier en UTF-8 ; en-tête lisible, sans clé répétée, sans « # » hors guillemets |
| ROUGE | id = nom du fichier ; minuscules, chiffres, tirets ; unique dans le dépôt |
| ROUGE | champs obligatoires présents, valeurs admises (claims.md, evidence.md, requests.md) |
| ROUGE | review en premier champ ; bloc de relecture complet ; reviewed signé par une autre personne que l'author, author-reread par l'author |
| ROUGE | pas de champ authority dans un claim |
| ROUGE | termes présents dans un GLOSSARY.md ; liens vers des ids qui existent, du bon type |
| ROUGE | claim de systems/ ou domains/ : au moins une preuve, aucune prémisse d'enquête ; claim d'enquête : au moins une preuve ou une prémisse |
| ROUGE | claim de domains/ sans tables (docs/adr/0005) |
| ROUGE | s'il cite des preuves : documentary, au moins une lecture ; empirical observed, une exécution sans unknown |
| ROUGE | superseded : un autre claim déclare le remplacer |
| ROUGE | exécution : dans systems/, même person_data que sa requête, version exécutée si modified: yes |
| ROUGE | lecture : une citation |
| ROUGE | requête : SELECT * seulement avec WHERE 1=0 ; si masked et sans WHERE 1=0, l'id dans le résultat, un agrégat, le seuil < 10 |
| ROUGE | dans tout fichier texte : NIR à clé valide, date de naissance ; dans un résultat masqué : effectif de 1 à 9 en clair |
| ROUGE | depends_on vers le claim d'une autre personne sans relecture à jour (ORANGE si le claim est provisional) |
| ROUGE | .claude/skills identique à .agents/skills |
| ORANGE | relecture périmée : l'empreinte a changé |
| ORANGE | prémisse, même indirecte, challenged, superseded ou withdrawn : à réexaminer |

## Limites

- Le contrôle voit que le masquage est présent, pas qu'il est juste (surtout la suppression secondaire).
- La recherche de valeurs ne garantit pas l'anonymat : un nom, une adresse ou un IPP ne sont pas reconnus.
- L'author et le relecteur sont déclarés, pas prouvés.
- Aucun contrôle ne sait si un claim est vrai.

## Règles de confiance

Ce que rien ne contrôle reste une règle, déclarée comme telle :

- l'agent corrige le contenu, jamais le contrôle ;
- work dit ce qui a été vraiment refait ;
- on n'approuve qu'après avoir lu ;
- une prémisse retirée est expliquée ;
- son propre claim, réutilisé depuis une autre enquête, est relu en author-reread ;
- une requête exécutée ne change plus ;
- un claim sans preuve propre n'est pas plus mûr que sa prémisse la moins mûre.

## Pas encore construit

Ces contrôles viendront avec GitHub : « Refs #N » au lieu de « Closes #N » dans une PR, issue fermée sans section Frictions, étiquette dormant.

## Tests

`python -m unittest discover checks`. Un contrôle nouveau arrive avec son test.
