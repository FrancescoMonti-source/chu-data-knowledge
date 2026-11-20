---
review: unreviewed
id: chimiotherapie-par-z511
kind: decision
author: Pierre
statement: "Au CHU, la chimiothérapie ne se cherche pas dans les actes : on la repère par le code CIM-10 Z511 en diagnostic principal (hôpital de jour ou hospitalisation complète) ou en diagnostic associé (hospitalisation complète)."
scope: "CORA et PMSI MCO du CHU, séjours de cancer ; règle de repérage de Pierre, sans mesure de son exhaustivité"
responsible: Pierre
reconsider_when: "un acte CCAM de chimiothérapie est codé de façon régulière dans CORA ; l'ATIH change la règle de codage de Z51.1 ; une mesure montre que des chimiothérapies n'ont ni Z511 en DP ni en DAS"
maturity: documented
lifecycle: active
terms: [cora:diagnostic, pmsi:acte-ccam]
tables: [cora:TB_SYNTH_RSS, cora:TB_DIAG, cora:TB_MVT]
supported_by: [20261120-precision-chimiotherapie-z511]
depends_on: [code-cim10-sans-point, chemin-actes-diags-par-mouvement]
---
## Pour s'en servir

Ne pas chercher de code CCAM de chimiothérapie pour repérer les séjours de chimiothérapie : il n'y en a pas à chercher. Chercher Z511 par sa racine (`Z511%`, sans point) :

- **en DP** (séances et séjours de chimiothérapie, hôpital de jour ou hospitalisation complète) : `TB_SYNTH_RSS.DP_RETENU LIKE 'Z511%'` ;
- **en DAS** (hospitalisation complète, DP autre, par exemple le cancer) : `TB_DIAG.TYPE_DIAG = 'S'` et `CODE_DIAG LIKE 'Z511%'`, relié au séjour par le mouvement (`TB_DIAG.ID_MVT` → `TB_MVT.ID_SEJOUR`).

Pour savoir quel cancer a été traité quand Z511 est en DP, lire le diagnostic relié (`TB_SYNTH_RSS.DR_RETENU`).

## Ce qui l'appuie

Précision de Pierre du 2026-11-20 (20261120-precision-chimiotherapie-z511), donnée en construisant la base de sondage d'une étude sur les patients de 70 ans et plus traités pour cancer, où le protocole demandait « un acte de chimiothérapie ».

Points ouverts : l'exhaustivité du repérage n'est pas mesurée (séjours de chimiothérapie sans Z511 ni en DP ni en DAS) ; la règle de codage de Z51.1 en DAS n'est pas lue dans le guide de l'ATIH ; la radiothérapie (Z510) n'est pas couverte par ce claim.
