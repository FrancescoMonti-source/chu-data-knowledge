---
review: unreviewed
id: chainer-oproom-cora
kind: empirical
author: Pierre
statement: "Pour relier une intervention OpRoom à CORA, prendre dans TB_INTERVENTION.NO_INTERVENTION_EXT le nombre avant le tiret : c'est OR_INTERVENTIONS.I_KEY ; le chiffre après le tiret est la phase, et une intervention OpRoom peut avoir plusieurs lignes dans TB_INTERVENTION. Toutes les interventions du flux OpRoom ont ce numéro, sous la forme « nombre-chiffre »."
scope: "CORA de production (CWPROD, schéma CORA_REC), TB_INTERVENTION depuis novembre 2023, lue le 2026-10-15 ; correspondance avec OpRoom établie par DIM-code"
refuted_if: "une intervention de l'application 16 a un NO_INTERVENTION_EXT d'une autre forme que nombre-chiffre, ou le nombre ne se retrouve pas parmi les OR_INTERVENTIONS.I_KEY"
maturity: observed
lifecycle: active
terms: [cora:intervention, oproom:intervention]
tables: [cora:TB_INTERVENTION, cora:TB_ACTE, oproom:OR_INTERVENTIONS]
supported_by: [20261015-forme-no-intervention-ext-resultat, 20261015-dim-code-chainage-oproom]
depends_on: [interventions-cora-flux-oproom]
---
## Pour s'en servir

**Clé de chaînage :**

```sql
TO_NUMBER(REGEXP_SUBSTR(TRIM(i.NO_INTERVENTION_EXT), '^[0-9]+'))   -- = OR_INTERVENTIONS.I_KEY
```

Regrouper les lignes de TB_INTERVENTION par ce nombre avant de compter : une intervention OpRoom en a une par phase. Le numéro d'intervention des exports Excel d'OpRoom est le même nombre, complété par des zéros à gauche : retirer les zéros avant de comparer.

**Actes de l'intervention :** ceux dont `TB_ACTE.NO_INTERVENTION` vaut l'`ID_INTERVENTION` d'une de ces lignes, ou qui portent dans le même séjour le `NO_INTERVENTION_CCAM` de l'une d'elles (grouper-actes-par-no-intervention-ccam).

**Période :** ce chaînage ne vaut que depuis que TB_INTERVENTION reçoit le flux OpRoom, presque complet depuis 2026 (interventions-cora-flux-oproom). Avant, rapprocher par séjour et jour (#47).

## Ce qui l'appuie

Forme de NO_INTERVENTION_EXT depuis novembre 2023 (20261015-forme-no-intervention-ext-resultat), chaque chiffre remplacé par 9 : « 999999-9 » pour les 44 162 interventions de l'application 16 et pour 56 interventions sans application ; vide pour 354 interventions sans application ; aucune autre forme.

Que le nombre soit OR_INTERVENTIONS.I_KEY, et le second chiffre la phase, vient du chaînage écrit par Pierre dans DIM-code pour le mapping OpRoom → CCAM (20261015-dim-code-chainage-oproom). La kb de DIM-code parlait d'un numéro « sur 10 chiffres » : c'est la forme de l'export Excel d'OpRoom, pas celle de CORA.
