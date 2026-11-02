# Pourquoi l'IP-DMS de la cardiologie augmente-t-il entre le S1 2025 et le S1 2026 ?

Personne : Pierre Pinson
Issue : #111

## Cadrage
- Périmètre : service de cardiologie 5520 et ses UF, S1 2025 contre S1 2026, avec l'unité Laubry (5523) en point de mire, car la demande vient d'une dégradation forte de son IP-DMS et de tensions capacitaires.
- Question de fond : la hausse vient-elle d'un défaut de codage, d'un allongement pur de la DMS, ou des deux ? Le case-mix s'est-il déformé ?
- La réponse chiffrée vit dans l'étude DIM-code `analysis/2026-10_pmct_cardiologie` (PR #41 fusionnée), pas dans ce dépôt.

## Choix
- Décomposer la variation de DMS observée en quatre termes additifs (racines, niveaux, référence, excès) : seul le terme « niveaux » trahirait un changement de codage.
- Mesurer la déformation de la répartition des GHM par la distance en variation totale, comparée aux paires d'années précédentes : une valeur isolée ne dit rien.
- Repérer les urgences par les UF du service 5700 du fichier de structure, car le drapeau urgence des UF n'est pas fiable.
- Un RSS compte dans chaque UF qu'il traverse : les UF ne s'additionnent pas.

## Conclusions
- `ip-dms-expliquer-casemix-niveaux-exces` : comment expliquer une hausse d'IP-DMS (décision, Pierre, non relu).
- `uf-urgences-par-service-structure` : quelles UF sont les urgences (décision, Pierre, non relu). Répond aussi à l'issue #30.

Les deux claims reposent sur des claims non relus du même auteur : relecture à la réutilisation (method/review.md).
