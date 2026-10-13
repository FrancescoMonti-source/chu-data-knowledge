# 0018 — Ranger par type de fichier : knowledge/ et method/

Statut : accepté, 2026-10-12 (Francesco, après une revue de la structure du dépôt). L'extension du point 9 aux fichiers non lus, ajoutée pendant la mise en œuvre, acceptée le 2026-10-13.

## Contexte

Un collègue a compris sources/ tout de suite, mais pas ce qui sépare docs/ de domains/. Le mainteneur l'oubliait aussi. Il y a deux causes.

- docs/ ne dit pas ce qu'il contient : on y cherche une documentation sur les données, alors qu'il contient les règles du dépôt.
- systems/, domains/ et investigations/ rangent un fichier selon son sujet. Choisir le sujet demande un jugement à chaque fichier. La plupart des règles de layout.md servent à ce choix : le sujet, l'exécution, la lecture, la promotion, la position. Et un pont entre deux contextes, par exemple entre edsan:uf et pmsi:um, n'a aucun dossier. sources/, au contraire, range un fichier selon ce qu'il est, la fiche d'un document : c'est un fait, sans jugement.

Le dépôt n'a encore aucun claim, aucune preuve, aucune requête. Changer maintenant ne déplace aucun contenu. Le nouvel arbre a aussi moins de dossiers : cinq au lieu d'une vingtaine.

## Décision

```text
sources/                une fiche par document (inchangé)
knowledge/
  claims/               un claim par fichier, quel que soit son sujet
  evidence/             une preuve par fichier : lectures et exécutions
  queries/              les requêtes préparées (.sql)
  glossaries/           un glossaire par contexte (pmsi.md, cora.md…) ; README.md : la carte des contextes
investigations/<id>/    README.md seulement
method/                 les conventions (ancien docs/agents/)
method/adr/             les ADR (ancien docs/adr/)
```

AGENTS.md, README.md, checks/ et .agents/skills/ ne bougent pas.

1. **Le type décide du dossier.** Le sujet d'un fichier ne choisit plus rien. Un pont entre deux contextes est un claim de knowledge/claims/, comme les autres.
2. **Plus de promotion.** La réponse d'une enquête va dans knowledge/claims/ dès qu'elle est écrite, et le README de l'enquête la cite dans Conclusions. Rien ne bouge quand une autre enquête la réutilise. La relecture au réemploi reste (review.md) : le contrôle donne déjà un ROUGE quand on s'appuie sur le claim d'une autre personne sans relecture à jour, un ORANGE si le nouveau claim reste provisional.
3. **Le contexte s'écrit dans le fichier.** Trois règles remplacent ce que disait le dossier :
   - une requête porte `-- system: <contexte>` dans son en-tête ; une exécution prend ce système par sa requête, sans le recopier ;
   - un claim cite au moins un terme dans terms ;
   - une table s'écrit avec son système : `cora:TB_MVT_RUM`.
4. **Un préfixe, un glossaire.** Le terme `pmsi:x` est défini dans knowledge/glossaries/pmsi.md, et seulement là. Le contrôle le vérifie ; aujourd'hui, il accepte un terme défini dans n'importe quel glossaire. La carte des contextes donne la sorte de chacun : système (un logiciel, comme CORA) ou domaine (des concepts et des règles, comme le PMSI). Les autres textes renvoient à la carte au lieu de recopier la liste.
5. **Le savoir propre au CHU**, une convention ou une façon de compter, est un claim comme les autres. S'il demande des termes nouveaux, leur contexte naît avec ce premier claim : un glossaire et une ligne dans la carte. Aucun contexte « chu » n'est créé d'avance.
6. **Chercher dans knowledge/claims/**, pas dans tout le dépôt : les plus de mille fichiers de sources/ noient la recherche. method/layout.md donne la commande : `git grep -n "cora:mouvement" -- knowledge/claims/`. Le contrôle ne gagne pas de commande de recherche.
7. **Des noms anglais dans tous les chemins.** La branche d'une enquête devient `investigation/<id>`, le modèle d'issue `.github/ISSUE_TEMPLATE/investigation.md`, et la CI suit `investigation/**`. Le texte écrit pour les personnes reste en français.
8. **L'exemple de la carte** montre un vrai même mot dans deux contextes : pmsi:rum, le résumé défini par l'ATIH, et cora:rum, le RUM tel que CORA l'enregistre. Leur correspondance est un claim à prouver, pas un acquis.
9. **Les anciens chemins bloquent.** Un fichier sous systems/, domains/, docs/agents/ ou docs/adr/ reçoit un ROUGE qui nomme le nouveau dossier. Cela arrête un agent qui suivrait une ancienne mémoire, et domain-modeling, qui écrit ses ADR dans docs/adr/ par défaut. AGENTS.md lui indique method/adr/. De même, un fichier de knowledge/ ou d'investigations/ que le contrôle ne lit pas reçoit un ROUGE, sauf un fichier caché comme .gitkeep. Sinon, un claim rangé dans un sous-dossier, ou dans le dossier d'une enquête, échapperait à tous les contrôles, et un export brut (.xlsx, .rpt) à la recherche de données personnelles.

## Ce qu'on perd, et ce qui le remplace

| Perdu | Remplacé par |
|---|---|
| tout ce qui concerne CORA, réuni dans un dossier | `git grep -n "cora:" -- knowledge/claims/`, ou la question posée à l'agent |
| le système d'une requête, donné par son chemin | le champ system |
| le contexte d'un claim, donné par son dossier | ses terms, au moins un, contrôlés contre leur glossaire |
| l'interdiction, pour un claim de systems/ ou domains/, de s'appuyer sur une réponse d'enquête | la relecture au réemploi, contrôlée, et la portée du claim, relue à ce moment (règle de confiance) |
| le ROUGE du contrôle quand deux enquêtes donnent le même id à deux claims | un conflit add/add de git quand la branche de l'une fait entrer main ; investigations/README.md dit comment le résoudre |

Le sens des contextes reste : chaque contexte garde son glossaire, et une correspondance entre deux contextes reste un claim, avec ses preuves et ses limites.

## Alternatives écartées

- **Expliquer la frontière par une phrase-test** dans le README et layout.md. Essayé : le texte demandait plus d'effort et ne rendait pas la frontière visible.
- **Tout regrouper sous hospital/.** Le PMSI et les guides de l'ATIH sont nationaux, pas propres à l'hôpital.
- **knowledge/systems/ et knowledge/domains/.** Le regroupement se voit, mais chaque fichier demande encore le choix du sujet, et le pont reste sans dossier.
- **Renommer seulement docs/ en method/.** Le mot vague disparaît, pas le rangement par sujet.

## Conséquences

- method/layout.md perd les règles de rangement par sujet et la promotion. claims.md, evidence.md, queries.md, investigations/README.md, les skills, AGENTS.md et le README suivent les nouveaux chemins ; le README montre l'arbre. review.md, checks.md et sediment écrivent la règle de confiance sur la portée.
- Le contrôle lit knowledge/. Il perd les trois ROUGE de rangement : tables dans domains/, exécution hors de systems/, appui d'un claim de systems/ ou domains/ sur une réponse d'enquête. Il gagne les contrôles des points 3, 4 et 9, chacun avec son test.
- Les ADR 0005, 0009, 0010, 0012, 0016 et 0017 gardent leur texte ; leur Statut dit « modifié par 0018 ». Dans les ADR plus anciens, docs/agents/ désigne method/, docs/adr/ method/adr/, et un GLOSSARY.md un glossaire de knowledge/glossaries/.
- sources/ ne bouge pas.

## Hors de cette décision

- Les éditions du PMSI : quand une règle change d'une année à l'autre, distinguer une règle d'une autre période d'une erreur (superseded). Ce point aura son propre ADR.
- Une commande de recherche dans le contrôle, et un contrôle des périodes écrites dans scope.
