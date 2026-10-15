# Pour les RSS MCO sortis de janvier à août 2026, combien ont reçu, après l'envoi M8, un DAS de l'un des six thèmes, et combien cela rapporte-t-il ?

Personne : Francesco
Issue : #49

## Cadrage
But : mesurer, par thème, ce que le codage a récupéré après l'envoi M8 : Dénutrition, Escarres, Rétention d'urine, Douleur chronique, Résistance aux antibiotiques, Isolement prophylactique (demande de la cheffe de Francesco).
Population : les RSS MCO de TB_SYNTH_RSS finis du 1er janvier au 31 août 2026.
Période : l'état de l'envoi M8 comparé à l'état actuel de CORA.
Unité d'analyse : le RSS.
Mesure : d'abord le nombre de RSS qui ont reçu un DAS du thème après leur premier groupage sans erreur (« récupéré ») ; ensuite, le gain en euros.
Comparaison : premier codage contre ajouts après le premier groupage sans erreur, par mois de sortie ; l'envoi M8 sépare ce qui est déjà transmis de ce qui reste à transmettre.

## Choix
- Le RSS est l'unité, pas le séjour : un séjour sur 30 à 100 ayant un RSS en a plusieurs (joindre-rss-par-id-sejour), et l'envoi PMSI se fait par RSS.
- Seuls les DAS comptent (TYPE_DIAG = 'S') : ce sont eux qui jouent comme CMA sur le niveau de sévérité (Francesco, 15/10).
- Codes des thèmes, confirmés par Francesco le 15/10 : E40-E46 ; L89 ; R33 ; R52.1 et R52.2 ; U82-U85 ; Z29.0. L'isolement est l'isolement prophylactique, pas l'isolement en psychiatrie.
- Date de l'état M8 : le fichier groupé de l'envoi, 20261002_074740_RSS_Final, soit le 2 octobre 2026 à 07:47:40 (dossier M8 du DIM vu par Francesco le 15/10 ; les tables OVALIDE de M8 sont revenues d'ePMSI).

- « Récupéré » = un DAS ajouté à un RSS après son premier groupage sans erreur (TB_CHRONO_CODAGE.DATE_GRP), et non plus « ajouté après l'envoi M8 » : presque rien n'a été ajouté dans les 13 jours après M8 (20261015-m8-ecart-themes-resultat), et une date de coupure au 31 août mêlerait le codage tardif habituel au rattrapage (Francesco, 15/10).
- Un DAS créé moins de 24 heures après le premier groupage sans erreur compte comme premier codage : le groupage peut tourner au cours de la même saisie.

- L'envoi sur ePMSI a eu lieu le 2 octobre à 9:48 (Francesco, 15/10) ; la coupure reste l'heure du fichier groupé (07:47:40), qui fixe le contenu de M8.

## Conclusions
Aucune pour l'instant.
