---
review: unreviewed
id: ipp-dans-tb-patient
kind: empirical
author: Pierre
statement: "Dans CORA, l'IPP d'un séjour se lit dans TB_PATIENT.IPP_PATIENT (par TB_SEJOUR.ID_PATIENT) : TB_SEJOUR.IPP_PATIENT existe mais est vide pour plus de 99 % des séjours."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours sortis de 2023 au 2026-11-16, lus le 2026-11-16"
refuted_if: "pour une année de 2023 à 2026, TB_SEJOUR.IPP_PATIENT est renseigné pour plus de 10 % des séjours, ou TB_PATIENT.IPP_PATIENT est vide pour plus de 1 % d'entre eux"
maturity: observed
lifecycle: active
terms: [cora:sejour]
tables: [cora:TB_SEJOUR, cora:TB_PATIENT]
supported_by: [20261116-ipp-patient-vs-sejour-resultat]
depends_on: []
---
## Pour s'en servir

Pour obtenir l'IPP d'un séjour, joindre TB_PATIENT et lire `p.IPP_PATIENT` :

```sql
JOIN CORA_REC.TB_PATIENT p ON p.ID_PATIENT = s.ID_PATIENT   -- IPP : p.IPP_PATIENT
```

Ne pas lire `s.IPP_PATIENT` : la requête ne plante pas (la colonne existe) et rend une colonne presque vide, sans erreur. Une extraction nominative reste en local (privacy.md) ; la requête d'une preuve ne sort jamais d'IPP.

## Ce qui l'appuie

Séjours sortis par année (20261116-ipp-patient-vs-sejour-resultat), en comptant les séjours dont l'IPP est non vide après TRIM : TB_PATIENT.IPP_PATIENT est renseigné pour tous (aucun séjour sans IPP du côté patient, ni seul renseigné du côté séjour : ces modalités n'apparaissent pas dans le résultat). TB_SEJOUR.IPP_PATIENT l'est pour 6 617 des 845 367 séjours de 2023 (0,8 %), 495 des 897 245 de 2024, 310 des 891 062 de 2025 et 131 des 819 004 de 2026. Quand les deux sont renseignés, ils diffèrent pour 29 à 61 séjours par année (40 à 48 en 2024-2025) : TB_SEJOUR.IPP_PATIENT n'est donc pas une copie fiable de celui du patient.

Origine : une extraction DIM-code (p-pinson/DIM-code#48) qui lisait TB_SEJOUR.IPP_PATIENT a rendu une colonne IPP vide ; cora_toolbox lit TB_PATIENT.IPP_PATIENT.

Points ouverts : l'IPP vide de TB_SEJOUR n'est pas expliqué (des séjours renseignés viennent peut-être d'un autre circuit de saisie) ; pas mesuré avant 2023.
