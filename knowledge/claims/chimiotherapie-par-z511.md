---
review: unreviewed
id: chimiotherapie-par-z511
kind: decision
author: Pierre
statement: "Au CHU, la chimiothérapie antitumorale ne se cherche pas dans les actes, la CCAM n'en a pas : on la repère par le code CIM-10 Z511, en diagnostic principal (séances ou hospitalisation complète) ou, en hospitalisation complète à DP autre, en diagnostic associé."
scope: "CORA et PMSI MCO du CHU, séjours de cancer ; règle du guide méthodologique MCO 2026 et de Pierre, sans mesure de son exhaustivité dans CORA"
responsible: Pierre
reconsider_when: "l'ATIH crée un acte CCAM de chimiothérapie ou change la règle de codage de Z51.1 dans le guide MCO ; une mesure montre que des chimiothérapies n'ont ni Z511 en DP ni en DAS"
maturity: documented
lifecycle: active
terms: [cora:diagnostic, pmsi:acte-ccam]
tables: [cora:TB_SYNTH_RSS, cora:TB_DIAG, cora:TB_MVT]
supported_by: [20261120-guide-mco-z51-chimiotherapie, 20261120-guide-mco-seances-chimiotherapie-tumeur, 20261120-precision-chimiotherapie-z511]
depends_on: [code-cim10-sans-point, chemin-actes-diags-par-mouvement]
---
## Pour s'en servir

Ne pas chercher de code CCAM de chimiothérapie pour repérer les séjours de chimiothérapie : il n'y en a pas à chercher. Chercher Z511 par sa racine (`Z511%`, sans point) :

- **en DP** (séances et séjours de chimiothérapie, hôpital de jour ou hospitalisation complète) : `TB_SYNTH_RSS.DP_RETENU LIKE 'Z511%'` ;
- **en DAS** (hospitalisation complète, DP autre, par exemple le cancer) : `TB_DIAG.TYPE_DIAG = 'S'` et `CODE_DIAG LIKE 'Z511%'`, relié au séjour par le mouvement (`TB_DIAG.ID_MVT` → `TB_MVT.ID_SEJOUR`).

Pour savoir quel cancer a été traité quand Z511 est en DP, lire le diagnostic relié (`TB_SYNTH_RSS.DR_RETENU`).

## Ce qui l'appuie

Le guide méthodologique MCO 2026 de l'ATIH fait enregistrer toute chimiothérapie, « qu'il s'agisse de séances ou d'hospitalisation complète », avec Z51 en DP, donc Z51.1 pour la chimiothérapie de tumeur, la tumeur traitée étant en diagnostic relié (20261120-guide-mco-z51-chimiotherapie, p. 99 ; 20261120-guide-mco-seances-chimiotherapie-tumeur, p. 144). Sa note 41 ajoute que Z51.1 n'est pas redondant avec un acte, faute d'acte CCAM : « La chimiothérapie antitumorale ne peut être enregistrée qu'avec ce code ». D'où l'absence d'acte à chercher.

Pierre (20261120-precision-chimiotherapie-z511) précise l'usage du CHU : Z511 en DP pour l'hôpital de jour comme pour l'hospitalisation complète, et en DAS en hospitalisation complète. Le guide ne parle que du DP et de la redondance avec un acte ; le DAS en hospitalisation complète vient de Pierre.

Points ouverts : l'exhaustivité du repérage n'est pas mesurée dans CORA (séjours de chimiothérapie sans Z511 en DP ni en DAS) ; la radiothérapie (Z510) n'est pas couverte par ce claim.
