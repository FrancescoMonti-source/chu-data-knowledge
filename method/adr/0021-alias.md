# 0021 — Les alias dans les glossaires

Statut : proposé, 2026-10-13 (Pierre, avant la migration de la base de connaissances de dim-code). À accepter par le mainteneur.

## Contexte

Un agent cherche ce que sait le dépôt à partir des termes d'une question (layout.md, « Retrouver ce qu'on sait »). Mais une question arrive avec les mots de la personne : « DMS », « HDJ », « venue », « TMI », un nom de colonne. Le terme du glossaire porte un autre nom, ou l'agent ne connaît pas le jargon du CHU. Il ne trouve pas le claim, conclut que le dépôt ne sait rien et ouvre une enquête inutile.

0016 a écarté la ligne _Avoid_ de domain-modeling jusqu'à ce qu'une enquête rencontre deux mots pour une même chose. La migration de la base de connaissances de dim-code en apporte plusieurs dizaines : son glossaire relie déjà séjour, venue et hospitalisation, HDJ et hôpital de jour, TMI et TROS à leurs fiches.

## Décision

- Sous le titre `## ctx:terme`, une ligne facultative `Alias : mot, mot, …` liste les alias du terme : les autres mots employés pour lui, sigles et jargon compris.
- Elle sert à la recherche : research cherche les mots de la question dans les glossaires, titres et lignes « Alias », pour trouver les termes.
- Elle ne fait pas partie de la définition : le contrôle la retire avant de calculer l'empreinte. Ajouter un mot ne périme aucune relecture.
- Un mot qui a un autre sens dans le même contexte n'y entre pas : c'est un autre terme.

## Raisons

- La ligne _Avoid_ dit quels mots ne pas écrire ; la recherche a besoin des mots que les gens emploient. Ce sont souvent les mêmes, mais l'intention change ce qu'un agent y met : « Alias » décrit, _Avoid_ prescrit.
- Hors de l'empreinte : un alias ne change pas ce que dit un claim. Avec 0019 seul, enrichir un glossaire pendant la migration périmerait la relecture de chaque claim qui cite le terme.
- Une ligne de texte, lue par git grep : pas d'index, pas de nouveau fichier (layout.md, « Retrouver ce qu'on sait »).

## Alternatives

- **Un champ aliases dans chaque claim :** les mêmes mots répétés dans des dizaines de fichiers ; le glossaire est l'endroit unique du terme.
- **Un fichier de synonymes à part** (comme le glossary.yaml de dim-code) : un deuxième endroit pour un même terme, contre single-source-of-truth.
- **Laisser la ligne dans l'empreinte :** plus simple, mais chaque alias ajouté coûte une relecture par claim, sans que le sens ait changé.

## Conséquences

- Un mot ajouté à tort dans la ligne « Alias » ne se voit pas à la relecture des claims : la ligne est relue avec le glossaire. Règle de confiance : un mot à double sens n'y entre pas.
- Le contrôle ne vérifie ni la place de la ligne ni qu'un même mot n'appartient pas à deux termes du même contexte. À ajouter si une friction le demande.
