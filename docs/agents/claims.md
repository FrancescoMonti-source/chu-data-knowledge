# Claims

Un claim est une affirmation sur les données du CHU, soutenue par des preuves. Un fichier par claim, dans le dossier claims/ de son sujet (layout.md).

```markdown
---
review: unreviewed
id: mvt-rum-lien
kind: empirical
author: Francesco
statement: "Dans CORA, TB_MVT_RUM relie chaque mouvement aux RUM qui le contiennent."
scope: "CORA, MCO, 2023-2026"
refuted_if: "un mouvement MCO sans aucune ligne dans TB_MVT_RUM"
maturity: observed
lifecycle: active
terms: [cora:mouvement, cora:rum]
tables: [TB_MVT, TB_MVT_RUM]
supported_by: [20261008-mvt-rum]
depends_on: []
---
Raisonnement et limites.

Points ouverts : non vérifié sur l'instance de production.
```

## Les champs

| Champ | Valeurs |
|---|---|
| review | toujours le premier champ : unreviewed, ou un bloc de relecture (review.md) |
| id | le nom du fichier |
| kind | documentary · empirical · decision |
| author | la personne pour qui l'agent écrit (« Les personnes ») |
| statement | l'affirmation, en une phrase |
| scope | où et quand elle vaut : système, champ, période |
| maturity | documented · observed · provisional |
| lifecycle | active · challenged · superseded · withdrawn |
| terms | les termes, avec leur contexte, ou [] |
| tables | les tables nommées, ou [] |
| supported_by | les ids des preuves, ou [] pour un claim d'enquête |
| depends_on | les ids des prémisses, ou [] |
| challenges, supersedes | facultatifs : les ids contestés ou remplacés (review.md) |

Clés et valeurs en anglais ; texte libre en français. Toutes les valeurs sont lues comme du texte : no reste « no ».

Le texte libre de l'en-tête (statement, scope, refuted_if, responsible, reconsider_when, work ; dans les preuves et les sources : locator, title, publisher, location) s'écrit entre guillemets doubles : sans eux, « : » rend l'en-tête illisible et « # » coupe la valeur. Cette règle vaut pour tous les en-têtes du dépôt.

## Les personnes

Une personne s'écrit toujours de la même façon, dans author, responsible, executed_by, read_by et le by d'une relecture : son prénom, plus l'initiale du nom si deux personnes ont le même prénom (Marie D.). Avant d'écrire une personne pour la première fois, chercher comment le dépôt l'écrit déjà. Le contrôle compare ces textes : deux écritures d'une même personne comptent pour deux personnes.

## Trois sortes (kind)

- **documentary :** ce qu'un document dit. Cite au moins une lecture.
- **empirical :** ce qu'on observe dans les données. Ajoute refuted_if : l'observation qui le contredirait, c'est-à-dire le test à lancer pour l'éprouver.
- **decision :** un choix de l'équipe, par exemple une façon de compter. Ajoute responsible (qui a décidé) et reconsider_when (ce qui ferait revoir le choix). Une décision propre à une enquête vit dans l'enquête ; une décision qui vaut pour tous va dans domains/ et cite la lecture du document où elle est écrite (compte rendu, note : une source local).

## Maturité

- **documented :** appuyé sur des lectures.
- **observed :** appuyé sur au moins une exécution dont tout le contexte est connu (aucune valeur unknown). Contrôlé pour les claims empiriques.
- **provisional :** appui partiel, à confirmer.

## Claim sans preuve propre

Un claim d'enquête peut ne citer que des prémisses (supported_by: []) : c'est le cas de la réponse à une question. Il prend la sorte de sa conclusion, et une maturité qui ne dépasse pas celle de sa prémisse la moins mûre. Ses appuis sont contrôlés à travers ses prémisses. Un claim sans preuve et sans prémisse bloque.

## Taille

Un claim est ce qu'on peut réfuter avec un seul test. Deux affirmations sont séparées si l'une peut être fausse alors que l'autre reste vraie, ou si quelqu'un pourrait réutiliser l'une sans l'autre. Le raisonnement qui tient ou tombe avec elle reste dans le corps.

La réponse à une question combine plusieurs faits : elle devient un claim d'enquête qui déclare depends_on vers les claims atomiques. Si l'un d'eux tombe, on sait quoi revoir.

## Le corps

Sous l'en-tête : le raisonnement et les limites, puis « Points ouverts : … ». Ce qui n'est pas vérifié va dans les points ouverts.

## Autorité

Le claim n'a pas de champ authority : l'autorité est dans la fiche de la source (evidence.md).

## Citer un claim

Toute réponse qui utilise un claim cite son état de relecture : « mvt-rum-lien (unreviewed) ». Un agent lit aussi les claims qu'il ne déclare pas.

Un reviewed peut être périmé : `python checks/check.py` le signale en ORANGE. Un agent qui ne peut pas lancer le script (app web) écrit « reviewed, à jour non vérifié ».
