# 0019 — La définition d'un terme entre dans l'empreinte

Statut : accepté, 2026-10-13 (Francesco, sur la carte de décision de la revue de conception après 0018). Modifié par 0021 : la ligne « Alias » reste hors de l'empreinte.

## Contexte

Depuis 0018, un claim dit son contexte par ses termes : `terms: [cora:rum]`. Le sens du claim dépend donc de la définition de cora:rum dans knowledge/glossaries/cora.md. Mais l'empreinte ne lisait pas les glossaires.

Exemple : Marie écrit « chaque cora:mouvement donne un cora:rum », avec cora:rum défini comme une ligne par passage dans une unité médicale. Paul le relit et signe reviewed. Plus tard, une autre enquête redéfinit cora:rum : un RUM par séjour, toutes unités confondues. Le claim dit maintenant autre chose, mais la relecture de Paul restait à jour, et un troisième claim pouvait s'appuyer dessus sans ORANGE.

Un terme défini deux fois dans son glossaire passait aussi sans message : la règle « une seule définition » était une règle de confiance (checks.md).

Aucun claim n'existe encore : changer le calcul de l'empreinte ne périme aucune relecture.

## Décision

- L'empreinte d'un claim couvre aussi la définition de chacun de ses termes : le texte sous son titre `## ctx:terme`, jusqu'au titre suivant.
- Un terme défini deux fois dans son glossaire est ROUGE.

## Conséquences

- Changer la définition d'un terme périme la relecture de tous les claims qui le citent : ORANGE, puis on relit. Corriger une faute dans une définition coûte donc une relecture par claim. C'est déjà le cas pour une faute dans une fiche de source.
- La carte des contextes n'est toujours pas lue : sa sorte et sa liste restent une règle de confiance.

## Alternatives

- **Laisser tel quel :** une définition peut changer sans que personne ne relise les claims qui en dépendent. Contraire à review-on-reuse.
- **Le faire plus tard :** chaque relecture écrite d'ici là serait périmée le jour du changement.
