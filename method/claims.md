# Claims

Un claim est une affirmation sur les données du CHU, soutenue par des preuves. Un fichier par claim, dans knowledge/claims/.

Un claim s'écrit pour l'agent suivant, celui qui interrogera les données : il lui dit ce qu'il peut faire ou doit éviter. Une variable fiable ou non, et depuis quand ; une jointure ; un piège ; une méthode pour retrouver ou classer quelque chose. Les chiffres appuient le claim : ils vont dans son corps. statement n'en garde un que si la consigne en dépend.

## Ce qui mérite un claim

Un claim se justifie s'il apprend à l'agent ce que les sources ne lui disent pas :

- il contredit une source : le dictionnaire dit une chose, les données une autre ;
- il dit ce qu'aucune source ne dit et qui change la façon d'interroger : un piège, une période de validité, une jointure, une méthode ;
- il pose une décision de l'équipe.

Ce qu'une source dit déjà, et qu'un agent trouve en l'ouvrant (une colonne, un lien du dictionnaire), n'est pas recopié en claim. Une mesure qui n'oriente encore aucun usage n'est pas un claim non plus, même quand elle répond à la question d'une enquête. Ce que deviennent alors sa preuve et sa requête, et un claim jugé inutile : investigations/README.md, « L'issue ou le dépôt ».

```markdown
---
review: unreviewed
id: mvt-rum-lien
kind: empirical
author: Francesco
statement: "Dans CORA, depuis 2021, TB_MVT_RUM ne contient que les mouvements entrés dans un RSS : une jointure interne sur cette table perd la majorité des actes."
scope: "CORA, 2021-2026"
refuted_if: "pour une année depuis 2021, plus de 60 % des actes ont leur mouvement dans TB_MVT_RUM"
maturity: observed
lifecycle: active
terms: [cora:mouvement, cora:rum]
tables: [cora:TB_ACTE, cora:TB_MVT, cora:TB_MVT_RUM]
supported_by: [20261008-mvt-rum]
depends_on: []
---
## Pour s'en servir

Partir de TB_MVT pour voir tous les mouvements. Ne filtrer sur TB_MVT_RUM que pour le champ PMSI, et le dire.

## Ce qui l'appuie

Le dictionnaire dit que TB_MVT_RUM relie les mouvements aux RUM ; il ne dit pas lesquels y manquent. Une jointure interne perd plus de la moitié des actes depuis 2021 (20261008-mvt-rum). Raisonnement et limites.

Points ouverts : non vérifié sur l'instance de production.
```

## Les champs

| Champ | Valeurs |
|---|---|
| review | toujours le premier champ : unreviewed, ou un bloc de relecture (review.md) |
| id | le nom du fichier |
| kind | documentary · empirical · decision |
| author | la personne pour qui l'agent écrit (« Les personnes ») |
| statement | l'affirmation qui guide un agent qui découvre les données, en une phrase. Test : si l'agent l'ignore, écrit-il une requête fausse ou tire-t-il une conclusion fausse ? Un constat chiffré (« en telle année, tant de tel événement ») ne passe pas le test : il va dans « Ce qui l'appuie ». Un chiffre n'entre dans le statement que si l'usage en dépend |
| scope | où et quand elle vaut : système, champ, période |
| maturity | documented · observed · provisional |
| lifecycle | active · challenged · superseded · withdrawn |
| terms | les termes, avec leur contexte : au moins un (layout.md, « Termes et glossaires ») |
| tables | les tables nommées, chacune avec son système (cora:TB_MVT_RUM), ou [] |
| supported_by | les ids des preuves, ou [] pour un claim qui ne s'appuie que sur des prémisses |
| depends_on | les ids des prémisses, ou [] |
| refuted_if · responsible, reconsider_when | selon la sorte (« Trois sortes ») |
| challenges, supersedes | facultatifs : les ids contestés ou remplacés (review.md) |

Clés et valeurs en anglais ; texte libre en français. Toutes les valeurs sont lues comme du texte : no reste « no ».

Le texte libre de l'en-tête (statement, scope, refuted_if, responsible, reconsider_when, work ; dans les preuves et les sources : locator, title, publisher, location) s'écrit entre guillemets doubles : sans eux, « : » rend l'en-tête illisible et « # » coupe la valeur. Cette règle vaut pour tous les en-têtes du dépôt.

## Les personnes

Une personne s'écrit toujours de la même façon, dans author, responsible, executed_by, read_by et le by d'une relecture : son prénom, plus l'initiale du nom si deux personnes ont le même prénom (Marie D.). Avant d'écrire une personne pour la première fois, chercher comment le dépôt l'écrit déjà. Le contrôle compare ces textes : deux écritures d'une même personne comptent pour deux personnes.

## Trois sortes (kind)

- **documentary :** ce qu'un document dit. Cite au moins une lecture. Il se justifie quand il rapproche plusieurs passages ou plusieurs sources, ou quand il tire d'une source une conséquence pour la requête (« le guide rattache le séjour à sa sortie : prendre TB_SEJOUR.DATE_SORTIE ») ; pas quand il recopie une ligne qu'un agent lirait en ouvrant la source.
- **empirical :** ce qu'on observe dans les données. Ajoute refuted_if : l'observation qui le contredirait, c'est-à-dire le test à lancer pour l'éprouver.
- **decision :** un choix de l'équipe qui vaut pour toutes les enquêtes, par exemple une façon de compter adoptée au CHU, ou une méthode pour reconstruire ce qu'une variable ne donne pas (classer les séjours par type de prise en charge). Ajoute responsible (qui a décidé) et reconsider_when (ce qui ferait revoir le choix). Il cite la lecture du document où il est écrit (compte rendu, note : une source local). Une décision propre à une enquête n'est pas un claim : c'est une ligne de la section Choix de son README (investigations/README.md, « Choix »).

## Maturité

- **documented :** appuyé sur des lectures.
- **observed :** appuyé sur au moins une exécution dont tout le contexte est connu (aucune valeur unknown). Contrôlé pour les claims empiriques.
- **provisional :** appui partiel, à confirmer.

## Claim sans preuve propre

Un claim peut ne citer que des prémisses (supported_by: []). Il prend la sorte de sa conclusion. Sa maturité vient de ses prémisses : provisional si l'une d'elles l'est ; sinon observed s'il est empirical et qu'une prémisse au moins est observed ; sinon documented. documented et observed disent ce qui appuie un claim, pas à quel point il est sûr : seul provisional est plus faible. L'auteur peut toujours choisir provisional, par prudence. Ses appuis sont contrôlés à travers ses prémisses. Un claim sans preuve et sans prémisse bloque.

## Taille

Un claim est ce qu'on peut réfuter avec un seul test. Deux affirmations sont séparées si l'une peut être fausse alors que l'autre reste vraie, ou si quelqu'un pourrait réutiliser l'une sans l'autre. Le raisonnement qui tient ou tombe avec elle reste dans le corps, comme les chiffres qui ne servent qu'à l'appuyer : on ne fait pas un claim par chiffre, mais un claim par usage.

Une règle d'usage qui découle d'un constat se sépare de lui quand elle dépend d'un choix : le constat (« TYPE_SEJOUR change de codage en 2020 ») est empirical ; la méthode qu'on adopte à la place est un claim decision qui déclare depends_on vers lui.

Un claim qui combine plusieurs faits déclare depends_on vers les claims atomiques : si l'un d'eux tombe, on sait quoi revoir.

## Le corps

Sous l'en-tête, deux sections :

- **Pour s'en servir :** ce que l'agent fait de ce claim quand il interroge les données. La variable à prendre ou à éviter, le filtre, la jointure, les étapes d'une méthode, ou le claim qui les donne. Un agent qui ne lit que cette section sait quoi faire.
- **Ce qui l'appuie :** le raisonnement, les chiffres tirés des preuves, les limites, puis « Points ouverts : … ». Ce qui n'est pas vérifié va dans les points ouverts.

## Autorité

Le claim n'a pas de champ authority : l'autorité est dans la fiche de la source (evidence.md).

## Citer un claim

Toute réponse qui utilise un claim cite son état de relecture : « mvt-rum-lien (unreviewed) », même pour un claim lu sans le déclarer dans depends_on.

Un reviewed peut être périmé : `python checks/check.py` le signale en ORANGE. Un agent qui ne peut pas lancer le script (app web) écrit « reviewed, à jour non vérifié ».
