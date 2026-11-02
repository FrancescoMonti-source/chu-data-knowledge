---
review: unreviewed
id: ip-dms-expliquer-casemix-niveaux-exces
kind: decision
author: Pierre
statement: "Pour expliquer la hausse d'une IP-DMS entre deux périodes, décomposer la variation de la DMS observée en quatre termes qui s'additionnent : déplacement entre racines de GHM, déplacement entre niveaux de sévérité d'une même racine, changement de la DMS nationale de référence, et excès (observée − attendue) ; un changement de codage ne se lit que dans le deuxième terme, comparé à la déformation habituelle des GHM d'une année à l'autre."
scope: "CHU de Rouen, RSS d'hospitalisation complète, DMS nationale OVALIDE par GHM et année PMSI ; méthode mise au point sur la cardiologie, S1 2025 contre S1 2026"
responsible: Pierre
reconsider_when: "la référence nationale n'est plus la DMS par GHM d'OVALIDE ; une enquête sur les diagnostics associés montre qu'un changement de codage se lit autrement ; la méthode est relue et contestée (review.md)"
maturity: documented
lifecycle: active
terms: [pmsi:ip-dms, pmsi:ghm]
tables: []
supported_by: [20261027-etude-dim-code-methode-ip-dms]
depends_on: []
---
## Pour s'en servir

Pour répondre à « pourquoi l'IP-DMS monte-t-il » (service, UF ou autre découpage) :

1. Calculer l'IP-DMS comme somme des nuitées observées ÷ somme des DMS nationales du GHM de chaque RSS, à l'année PMSI du séjour ; au-dessus de 1, les séjours sont plus longs que la référence. Quand l'année PMSI n'a pas de référence (2026 au moment de l'étude), prendre la dernière année disponible, et le dire : le terme « référence » est alors nul.
2. Compter les nuitées du RSS entier, toutes unités traversées ; les transferts vers le SMR ouvrent un autre séjour et n'y figurent pas (mutation-mco-smr-mode-6-depuis-2021).
3. Écrire la variation de la DMS observée = casemix + excès. Le casemix (variation de la DMS attendue) se coupe en : déplacement entre racines (poids des racines, référence figée à la première année), déplacement entre niveaux de sévérité à l'intérieur des racines (variation de la référence moyenne d'une racine), changement de la DMS nationale d'une année PMSI à l'autre. À GHM égal, seul l'excès fait monter l'IP-DMS.
4. Donner un intervalle bootstrap par RSS à chaque terme ; ne conclure à un effet que si 0 est hors de l'intervalle.
5. Pour juger d'un changement de codage ou de groupage : mesurer la part des RSS dont le GHM change de place d'une année à l'autre (moitié de la somme des écarts de poids, en GHM complet et en racine) et la comparer aux années précédentes ; une valeur dans la plage habituelle et un terme « niveaux » non significatif ne montrent aucun changement. Les diagnostics associés (CMA) ne sont pas lus par cette méthode : ils sont nécessaires pour conclure sur le codage lui-même.
6. Un RSS compte dans chaque UF qu'il traverse : les UF ne s'additionnent pas ; l'ensemble du service compte chaque RSS une fois.

Le code est dans DIM-code (src/rapport_cardio.py, fonctions casemix_detaille et deformation_ghm).

## Ce qui l'appuie

La méthode figure au cadrage du rapport comparatif de la cardiologie (20261027-etude-dim-code-methode-ip-dms). Appliquée au service de cardiologie, S1 2025 contre S1 2026, elle donne : IP-DMS de 0,98 à 1,15, casemix −0,28 nuitée par RSS (intervalle −0,67 à +0,10), excès +0,98 (+0,56 à +1,39), part des RSS dont le GHM change de place de 16 % contre 16 à 23 % les années précédentes. L'application ne sert qu'à illustrer ; elle décrit une période, donc elle n'est pas un claim.

Points ouverts : la méthode n'a pas été relue par une autre personne ; elle n'est pas validée sur une autre spécialité ; l'extraction des DAS est activée mais le rapport ne les lit pas encore ; la décomposition en racines et niveaux dépend de la référence figée à la première année.
