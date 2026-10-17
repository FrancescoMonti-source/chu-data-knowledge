# Parmi les RSS MCO en GHM chirurgical sortis de janvier à août 2026, combien ont reçu un DAS de l'un des six thèmes après l'état M8, combien ont monté de niveau de sévérité, et pour quel montant ?

Personne : Francesco
Issue : #50

## Cadrage
But : mesurer la revalorisation obtenue depuis l'envoi M8 sur six thèmes de DAS (dénutrition, escarres, rétention d'urine, douleur chronique, résistance aux antibiotiques, isolement prophylactique), séparée du codage tardif (demande de la cheffe de Francesco).
Population : les RSS MCO de TB_SYNTH_RSS finis du 1er janvier au 31 août 2026, en GHM chirurgical.
Période : l'état M8 (2 octobre 2026, 07:47:40) comparé à l'état de CORA le jour de la requête.
Unité d'analyse : le RSS.
Mesure : les RSS qui ont gagné un thème, en trois classes (codage tardif, revalorisation, ajout sans effet), les pertes à part ; les euros de la revalorisation.
Comparaison : par thème et par mois de sortie, plus un total janvier-août par thème.

## Choix
- Repart de l'enquête recuperation-das-m8 (#49), fermée sans claim le 15/10 : la définition de « récupéré » y avait changé deux fois (Francesco).
- Le RSS est l'unité : un séjour sur 30 à 100 ayant un RSS en a plusieurs (joindre-rss-par-id-sejour), et l'envoi se fait par RSS.
- Seuls les DAS comptent (TYPE_DIAG = 'S') : ce sont eux qui jouent comme CMA (Francesco, 15/10).
- Codes des thèmes : E40-E46 ; L89 ; R33 ; R52.1, R52.2 ; U82-U85 ; Z29.0 (Francesco, 15/10).
- État M8 : l'horodatage du fichier groupé 20261002_074740_RSS_Final, 2 octobre 2026 à 07:47:40, qui fixe le contenu de M8 ; l'envoi sur ePMSI a eu lieu à 9:48 (Francesco, 15/10).
- La population vient de CORA aujourd'hui, l'état comparé à M8 (Francesco, 15/10).
- Trois classes pour un RSS qui a gagné un thème : codage tardif (CMD 90 à M8), revalorisation (groupé à M8, niveau de sévérité plus haut aujourd'hui), ajout sans effet (groupé à M8, même niveau). Seule la revalorisation est le « récupéré » (Francesco, 15/10 : « level up »).
- Les pertes (thème présent à M8, absent aujourd'hui) sont comptées à part, pour un gain net (Francesco, 15/10).
- GHM chirurgical = type C ; les K sont exclus (Francesco, 15/10). Le filtre porte sur le GHM d'aujourd'hui. Un DAS ne change pas le type du GHM, seulement le niveau (Francesco, 15/10) : un RSS dont le type a changé depuis M8 a changé pour une autre raison, un acte par exemple. Ces RSS sortent des classes A, B et C et sont comptés une fois, comme contrôle.
- Le reste du MCO est compté aussi, sur des lignes à part (hors_chirurgie), sans ligne qui somme les deux : en chirurgie, 17 RSS seulement ont reçu un DAS d'un thème après M8, trop peu pour être lisible (Francesco, 15/10).
- Les classes se comptent sur janvier-août, sans détail par mois : les effectifs sont trop petits.
- L'état d'un RSS à M8 est celui du fichier groupé envoyé (.grp), pas une reconstitution dans CORA : comparées au fichier mois par mois, ni LIGNES_GRP ni DATE_CREAT ne le redonnent (etat-envoi-dans-fichier-groupe). Remplace, le 15/10, le fichier comme simple contrôle, puis le choix de LIGNES_GRP.
- L'état d'aujourd'hui : les DAS de TB_DIAG, le GHM et le montant de TB_SYNTH_RSS. Un DAS saisi mais pas encore regroupé compte comme présent : 22 DAS dans ce cas sur les RSS à un seul RUM (20261015-das-m8-lignes-grp-vs-tb-diag-resultat).
- Les classes se calculent en joignant, RSS par RSS, le fichier .grp à CORA aujourd'hui, dans un script R lancé à l'hôpital (20261015-classes-m8-fichier) : seul le fichier donne le GHM à M8 (Francesco, 15/10). Le montant à M8 vient de VisualValoSejours.csv, valorisation du même envoi.
- Ce calcul devient la routine revalorisation-entre-deux-etats, réglable (codes, fichiers, regroupement, masquage), pour le refaire entre deux autres états, M7 et M8 par exemple (Francesco, 16/10, method/adr/0027).

## Conclusions
- etat-envoi-dans-fichier-groupe (unreviewed)
- joindre-fichier-groupe-par-no-rss (unreviewed)
- longueur-ligne-rss-groupe (unreviewed)
