# Pour les RSS MCO sortis de janvier à août 2026, combien ont reçu, après l'envoi M8, un DAS de l'un des six thèmes, et combien cela rapporte-t-il ?

Personne : Francesco
Issue : #49

## Cadrage
But : mesurer, par thème, ce que le codage a récupéré après l'envoi M8 : Dénutrition, Escarres, Rétention d'urine, Douleur chronique, Résistance aux antibiotiques, Isolement prophylactique (demande de la cheffe de Francesco).
Population : les RSS MCO de TB_SYNTH_RSS finis du 1er janvier au 31 août 2026.
Période : l'état de l'envoi M8 comparé à l'état actuel de CORA.
Unité d'analyse : le RSS.
Mesure : d'abord le nombre de RSS qui ont reçu un DAS du thème après M8 ; ensuite, le gain en euros.
Comparaison : état M8 contre état actuel, par mois de sortie, pour séparer le codage tardif habituel du rattrapage.

## Choix
- Le RSS est l'unité, pas le séjour : un séjour sur 30 à 100 ayant un RSS en a plusieurs (joindre-rss-par-id-sejour), et l'envoi PMSI se fait par RSS.
- Seuls les DAS comptent (TYPE_DIAG = 'S') : ce sont eux qui jouent comme CMA sur le niveau de sévérité (Francesco, 15/10).
- Codes des thèmes, confirmés par Francesco le 15/10 : E40-E46 ; L89 ; R33 ; R52.1 et R52.2 ; U82-U85 ; Z29.0. L'isolement est l'isolement prophylactique, pas l'isolement en psychiatrie.
- Date de l'état M8 : le fichier groupé de l'envoi, 20261002_074740_RSS_Final, soit le 2 octobre 2026 à 07:47:40 (dossier M8 du DIM vu par Francesco le 15/10 ; les tables OVALIDE de M8 sont revenues d'ePMSI).

## Conclusions
Aucune pour l'instant.
