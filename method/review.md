# Relecture et contestation

Un claim est relu quand quelqu'un le réutilise, pas quand il entre. N'importe qui peut le contester à tout moment.

## Quand relire

- **Au réemploi.** Avant qu'un claim dépende (depends_on) du claim d'une autre personne, celle qui le réutilise, avec son agent, relit les preuves et refait les calculs à partir des résultats conservés, sans nouvel aller-retour à l'hôpital. Sans relecture à jour, le contrôle bloque (ROUGE). Un claim provisional peut quand même s'appuyer dessus : ORANGE.
- **Son propre claim, depuis une autre enquête :** relecture dans une nouvelle session, sans le raisonnement d'origine. Elle s'écrit author-reread : ce n'est pas une deuxième personne, et elle ne compte pas comme relecture pour les autres. Règle de confiance : le contrôle ne l'exige pas.
- **La portée, à chaque réemploi.** Un claim vaut dans la portée qu'il déclare (scope). Avant de s'appuyer dessus, vérifier qu'elle couvre le nouvel usage : la réponse d'une enquête vaut pour le cadrage de cette enquête. Règle de confiance : le contrôle ne lit pas le scope.

## Écrire la relecture

1. Relire et refaire. Si le claim doit changer, le corriger d'abord.
2. Calculer l'empreinte : `python checks/check.py --fingerprint <id>`
3. Remplacer `review: unreviewed` par le bloc :

```yaml
review:
  status: reviewed
  by: Marie
  at: 2026-10-12
  work: "recalculé depuis 20261008-mvt-rum, mêmes chiffres"
  fingerprint: 3f9a1c2e4b5d
```

- **status :** reviewed, par une autre personne que l'author ; author-reread, par l'author.
- **work :** ce qui a été refait. Un agent pourrait l'inventer, mais le raccourci devient un mensonge écrit et visible.
- **fingerprint :** la valeur de l'étape 2.

## Relecture périmée

L'empreinte couvre l'en-tête du claim (sauf review et lifecycle), son corps, la définition de ses termes dans leur glossaire (sans la ligne « Aussi dit »), le texte de ses preuves avec leur requête ou leur source, et l'empreinte de ses prémisses. Si l'un d'eux change, la relecture est périmée : ORANGE. Une contestation ne périme pas la relecture : elle passe par lifecycle, et les claims qui dépendent du claim contesté reçoivent leur propre ORANGE (« Contestation »). On relit à nouveau et on recopie la nouvelle empreinte. Pour ceux qui en dépendent, un claim à la relecture périmée compte comme non relu.

## Contestation

1. La personne qui trouve une preuve contraire passe le claim à `lifecycle: challenged`, et écrit un claim avec `challenges: [<id>]` et ses preuves. Ça entre dès que les contrôles passent.
2. L'auteur et la personne qui conteste décident ensemble ; s'ils ne sont pas d'accord, le mainteneur tranche. Trois dénouements :
   - **confirmé :** le claim revient à active ;
   - **remplacé :** un claim corrigé déclare `supersedes: [<id>]`, et l'ancien passe à superseded ;
   - **retiré :** le claim passe à withdrawn.
3. Les preuves restent. Chaque claim qui dépend, même indirectement, d'un claim challenged, superseded ou withdrawn reçoit un ORANGE « à réexaminer » : le confirmer, le corriger ou le retirer.

## Retirer une prémisse

Retirer une ligne de depends_on pour faire passer un contrôle, c'est le contourner. Quand on retire une prémisse, la raison va dans le message de commit (ou dans la description de la PR). Règle de confiance : rien ne le contrôle encore.
