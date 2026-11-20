# Dans CORA, la chimiothérapie antitumorale se repère-t-elle par Z511 en DP ou en DAS, et pour combien de séjours chaque cas compte-t-il ?

Personne : Pierre
Issue : #148

## Cadrage
- **But :** donner à l'agent la règle pour repérer la chimiothérapie dans CORA (il n'y a pas d'acte CCAM), née de l'étude DIM-code « onco 70 ans » (DIM-code#55).
- **Source :** le guide méthodologique MCO 2026 de l'ATIH pour la règle de codage ; CORA de production (CWPROD, schéma CORA_REC), requêtes exécutées par Pierre.
- **Population et période :** RSS de TB_SYNTH_RSS finis de 2022 à 2025 ; les mois récents ne sont pas encore codés (rss-mois-recents-non-codes, unreviewed).
- **Unité :** le séjour (ID_SEJOUR), puis le RSS ; les séances ont un RSS chacune.
- **Mesure :** effectifs de séjours et de RSS par groupe (DP Z511 ; DP de cancer avec Z511 en DAS ; DP de cancer sans ; autre DP avec Z511 en DAS), par type de prise en charge (type-prise-en-charge-mco, unreviewed) et par année.
- **Définitions :** Z511 par racine, sans point (code-cim10-sans-point, unreviewed) ; DAS = TB_DIAG.TYPE_DIAG = 'S', relié au séjour par le mouvement (chemin-actes-diags-par-mouvement, unreviewed).
- **Masquage :** effectifs < 10 masqués dans les requêtes.
- **Branche :** claude/project-thread-xdjajm, imposée par la session, au lieu de investigation/chimiotherapie-z511.

## Choix
- **Le guide ne dit rien de Z511 en DAS :** il fait mettre Z51.1 en DP pour toute chimiothérapie (séances ou hospitalisation complète). Le DAS en hospitalisation complète vient de Pierre ; l'enquête le mesure plutôt que de le supposer.

## Conclusions
- chimiotherapie-par-z511 (unreviewed) : pas d'acte de chimiothérapie, Z511 en DP et, en hospitalisation complète, en DAS (un tiers des séjours HC à Z511 l'ont seulement en DAS, TYPE_DIAG = 'S'). Appuyé sur le guide MCO 2026, la précision de Pierre, 20261120-z511-dp-das-par-annee-resultat et 20261120-z511-type-diag-resultat.
