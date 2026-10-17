# Contrôles

Les contrôles vérifient la forme, pas la vérité. On lance `python checks/check.py` avant chaque commit ; sur GitHub, la CI le lance à chaque PR et à chaque push sur main ou sur une branche d'enquête.

- **ROUGE :** quelque chose est cassé. À corriger avant le merge. Le script sort avec le code 1.
- **ORANGE :** du travail reste à faire. Ne bloque pas : un résultat partiel ou une contestation peuvent entrer.

Chaque message donne le fichier, le champ et le problème, puis, à la ligne suivante, la correction.

## La liste

| Niveau | Contrôle |
|---|---|
| ROUGE | fichier en UTF-8 ; en-tête lisible, sans clé répétée, sans « # » hors guillemets (aussi celui de chaque SKILL.md) |
| ROUGE | id = nom du fichier ; minuscules, chiffres, tirets ; unique dans le dépôt |
| ROUGE | champs obligatoires présents, valeurs admises (claims.md, evidence.md, queries.md) |
| ROUGE | review en premier champ ; bloc de relecture complet ; reviewed signé par une autre personne que l'author, author-reread par l'author |
| ROUGE | pas de champ authority dans un claim |
| ROUGE | claim : au moins un terme, écrit avec son contexte et défini dans son glossaire (pmsi:x dans knowledge/glossaries/pmsi.md) ; un glossaire ne définit que les termes de son contexte, chacun une seule fois |
| ROUGE | table écrite avec son système (cora:TB_MVT_RUM) ; system d'une requête et système d'une table : un contexte qui a son glossaire |
| ROUGE | liens vers des ids qui existent, du bon type |
| ROUGE | claim : au moins une preuve ou une prémisse |
| ROUGE | s'il cite des preuves : documentary, au moins une lecture ; empirical observed, une exécution sans unknown |
| ROUGE | superseded : un autre claim déclare le remplacer |
| ROUGE | claim sans preuve propre : maturité qui suit ses prémisses, ou provisional (claims.md) |
| ROUGE | exécution : même person_data que sa requête, sans champ system, version exécutée dans le langage de la requête si modified: yes ; si masked, rien hors du tableau Markdown du résultat, sauf un bloc ```sql (```r ou ```python pour un script) |
| ROUGE | lecture : une citation |
| ROUGE | requête, lue sans ses commentaires (le texte entre guillemets reste) : SELECT * seulement avec WHERE 1=0 et un seul SELECT ; si masked, hors requête des colonnes : l'id dans le résultat, un agrégat, le seuil < 10 ; un script .R ou .py, lu sans ses commentaires # : si masked, l'id entre guillemets, un comptage, le seuil < 10 |
| ROUGE | routine : dans knowledge/routines/<id>/, avec son README.md ; en-tête id, system, purpose ; aucun script de knowledge/queries/ ne charge une routine |
| ROUGE | dans tout fichier texte : NIR à clé valide, date de naissance ; dans un résultat masqué : effectif de 1 à 9 en clair |
| ROUGE | depends_on vers le claim d'une autre personne sans relecture à jour (ORANGE si le claim est provisional) |
| ROUGE | .claude/skills identique à .agents/skills |
| ROUGE | aucun fichier sous systems/, domains/, docs/agents/ ou docs/adr/ (anciens dossiers, method/adr/0018) ; dans knowledge/ et investigations/, aucun fichier que le contrôle ne lit pas, sauf un fichier caché comme .gitkeep (layout.md) |
| ORANGE | relecture périmée : l'empreinte a changé |
| ORANGE | prémisse, même indirecte, challenged, superseded ou withdrawn : à réexaminer |

## Limites

- Le contrôle voit que le masquage est présent, pas qu'il est juste (surtout la suppression secondaire).
- La recherche de valeurs ne garantit pas l'anonymat : un nom, une adresse ou un IPP ne sont pas reconnus.
- Les valeurs ne sont cherchées que dans les fichiers texte connus (SCANNED, dans check.py) : hors de knowledge/ et investigations/, un export brut (.xlsx, .rpt) n'est pas lu.
- Les effectifs de 1 à 9 ne sont cherchés que dans les colonnes N_… et NB_… (queries.md, règle 1), et dans les colonnes N et NB, que des preuves emploient aussi.
- L'author et le relecteur sont déclarés, pas prouvés.
- Aucun contrôle ne sait si un claim est vrai.

## Quand un contrôle échoue

L'agent corrige le contenu et relance. Il n'y a pas d'arrêt obligé après plusieurs échecs (method/adr/0001). S'il ne sait pas corriger, il le dit à la personne.

## Règles de confiance

Ce que rien ne contrôle reste une règle, déclarée comme telle :

- l'agent corrige le contenu, jamais le contrôle ;
- work dit ce qui a été vraiment refait ;
- on n'approuve qu'après avoir lu ;
- une prémisse retirée est expliquée ;
- son propre claim, réutilisé depuis une autre enquête, est relu en author-reread ;
- au réemploi, la portée du claim couvre le nouvel usage ;
- la carte liste chaque glossaire avec sa sorte ;
- le system d'une requête, comme celui d'une table, est un système de la carte, pas un domaine ;
- une requête exécutée ne change plus ;
- le résultat d'une routine reste à l'hôpital ; non masqué, il ne se colle pas dans une conversation.

## Pas encore construit

Le dépôt est sur GitHub, mais ces contrôles restent à écrire : « Refs #N » au lieu de « Closes #N » dans une PR, étiquette dormant.

## Tests

`python -m unittest discover checks`. Un contrôle nouveau arrive avec son test. Les exemples de method/ (blocs markdown, sql et r) passent aussi par le contrôle : un test les recopie dans un dépôt d'essai. Changer une règle, c'est aussi mettre ces exemples à jour.
