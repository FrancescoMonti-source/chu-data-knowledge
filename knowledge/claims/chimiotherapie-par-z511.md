---
review: unreviewed
id: chimiotherapie-par-z511
kind: decision
author: Pierre
statement: "Au CHU, la chimiothérapie antitumorale ne se cherche pas dans les actes, la CCAM n'en a pas : on la repère par le code CIM-10 Z511, en diagnostic principal (séances ou hospitalisation complète) ou, en hospitalisation complète à DP autre, en diagnostic associé."
scope: "CORA de production (CWPROD, schéma CORA_REC), RSS finis de 2022 à 2025 ; règle du guide méthodologique MCO 2026 et de Pierre, sans mesure de son exhaustivité"
responsible: Pierre
reconsider_when: "l'ATIH crée un acte CCAM de chimiothérapie ou change la règle de codage de Z51.1 dans le guide MCO ; une mesure montre que des chimiothérapies n'ont ni Z511 en DP ni en DAS"
maturity: observed
lifecycle: active
terms: [cora:diagnostic, pmsi:acte-ccam]
tables: [cora:TB_SYNTH_RSS, cora:TB_DIAG, cora:TB_MVT]
supported_by: [20261120-guide-mco-z51-chimiotherapie, 20261120-guide-mco-seances-chimiotherapie-tumeur, 20261120-precision-chimiotherapie-z511, 20261120-z511-dp-das-par-annee-resultat, 20261120-z511-type-diag-resultat]
depends_on: [code-cim10-sans-point, chemin-actes-diags-par-mouvement]
---
## Pour s'en servir

Ne pas chercher de code CCAM de chimiothérapie pour repérer les séjours de chimiothérapie : il n'y en a pas à chercher. Chercher Z511 par sa racine (`Z511%`, sans point) :

- **en DP** (séances et séjours de chimiothérapie) : `TB_SYNTH_RSS.DP_RETENU LIKE 'Z511%'`. C'est le cas presque général des séances (CMD 28) : compter les séances par le DP suffit ;
- **en DAS, pour l'hospitalisation complète** : `TB_DIAG.TYPE_DIAG = 'S'` et `CODE_DIAG LIKE 'Z511%'`, relié au séjour par le mouvement (`TB_DIAG.ID_MVT` → `TB_MVT.ID_SEJOUR`). Ne pas le négliger : environ un tiers des séjours d'hospitalisation complète avec Z511 ne l'ont qu'en DAS.

Pour savoir quel cancer a été traité quand Z511 est en DP, lire le diagnostic relié (`TB_SYNTH_RSS.DR_RETENU`) ; quand Z511 est en DAS, il n'y a pas de DR, le cancer est le DP ou un autre diagnostic du séjour.

## Ce qui l'appuie

Le guide méthodologique MCO 2026 de l'ATIH fait enregistrer toute chimiothérapie, « qu'il s'agisse de séances ou d'hospitalisation complète », avec Z51 en DP, donc Z51.1 pour la chimiothérapie de tumeur, la tumeur traitée étant en diagnostic relié (20261120-guide-mco-z51-chimiotherapie, p. 99 ; 20261120-guide-mco-seances-chimiotherapie-tumeur, p. 144). Sa note 41 ajoute que Z51.1 n'est pas redondant avec un acte, faute d'acte CCAM : « La chimiothérapie antitumorale ne peut être enregistrée qu'avec ce code ». D'où l'absence d'acte à chercher.

Pierre (20261120-precision-chimiotherapie-z511) précise l'usage du CHU : Z511 en DP pour l'hôpital de jour comme pour l'hospitalisation complète, et en DAS en hospitalisation complète. Le guide ne parle que du DP ; le DAS vient de Pierre, et il est mesuré :

- **Le DAS se lit TYPE_DIAG = 'S'** : les séjours à Z511 de 2022 à 2025 le portent en P (13 177 à 16 209 par an) ou en S (235 à 387 par an), jamais en R ni en D (20261120-z511-type-diag-resultat).
- **En 2025** (20261120-z511-dp-das-par-annee-resultat, séjours) : en séance, 15 552 RSS ont Z511 en DP, dont 99,4 % avec un DR de cancer (15 457), et 28 seulement l'ont en DAS ; en hospitalisation complète, 559 séjours ont Z511 en DP, 169 l'ont en DAS avec un DP de cancer et 142 en DAS avec un autre DP, soit 311 sur 870 (36 %) qui ne l'ont qu'en DAS. Même ordre les années précédentes : 29 % en 2022, 36 % en 2023, 34 % en 2024. En ambulatoire de 0 nuit hors séance, Z511 en DAS ne touche que 13 à 19 séjours par an (DP autre) ; avec un DP de cancer, moins de 10.
- **Quand Z511 est en DAS, le DR de cancer est vide** (0 dans les groupes à DP de cancer), ce qui est normal : le DR n'est requis que sous un DP en Z51.

Points ouverts : l'exhaustivité du repérage n'est pas mesurée (hospitalisations de chimiothérapie qui n'ont Z511 ni en DP ni en DAS : les 3 166 séjours d'hospitalisation complète à DP de cancer sans Z511 de 2025 en contiennent peut-être) ; les DP « autre » à Z511 en DAS (142 en 2025) ne sont pas décrits ; la radiothérapie (Z510) n'est pas couverte par ce claim.
