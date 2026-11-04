---
review: unreviewed
id: joindre-pmsi-mco-referentiel-par-nir
kind: empirical
author: Pierre
statement: "Pour retrouver un patient du PMSI MCO dans le référentiel des bénéficiaires du SNDS, joindre T_MCOaaC.NIR_ANO_17 à IR_BEN_R.BEN_NIR_PSA : 99,6 % des NIR_ANO_17 des séjours du CHU en 2025 à chaînage valide s'y retrouvent."
scope: "séjours MCO du CHU de Rouen sortis en 2025, NIR_RET = 0, échantillon de 5000 NIR_ANO_17 distincts, portail SNDS, profil 108"
refuted_if: "sur un échantillon de NIR_ANO_17 du PMSI du CHU (NIR_RET = 0), moins de 95 % sont des BEN_NIR_PSA d'IR_BEN_R"
maturity: observed
lifecycle: active
terms: [snds:portail, snds:profil-108, snds:referentiel-ir]
tables: [snds:T_MCOaaC, snds:IR_BEN_R]
supported_by: [20261104-snds-valeurs-codes-mco-chu-v2-resultat]
depends_on: [tables-snds-vues-profil-108]
---
## Pour s'en servir

Joindre sur NIR_ANO_17 = BEN_NIR_PSA après avoir gardé les séjours à chaînage valide (NIR_RET = 0 et les autres codes retour de T_MCOaaC). IR_BEN_R est très grosse : la joindre à une liste bornée de NIR_ANO_17 plutôt qu'à la table entière. Un patient peut avoir plusieurs BEN_NIR_PSA ; BEN_IDT_ANO les relie.

## Ce qui l'appuie

La requête 20261104-snds-valeurs-codes-mco-chu-v2 prend 5000 NIR_ANO_17 distincts des séjours du CHU de 2025 à NIR_RET = 0 (les premiers dans l'ordre) : 4980 sont un BEN_NIR_PSA d'IR_BEN_R, 20 non (20261104-snds-valeurs-codes-mco-chu-v2-resultat). La documentation collaborative du HDH donne la même clé (fiche « Notions sur les bénéficiaires »).

Points ouverts : l'échantillon est les 5000 premiers NIR dans l'ordre alphabétique, pas un tirage au hasard ; une seule année ; l'unicité d'un patient par BEN_NIR_PSA n'est pas testée.
