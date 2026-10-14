# Les préadmissions et les séjours sans mouvement, sans date de sortie, sont-ils reliés à quelque chose ?

Personne : Pierre
Issue : #32

## Cadrage
But : décider si les séjours sans date de sortie qui sont des préadmissions ou qui n'ont aucun mouvement peuvent être exclus des comptages de séjours, faute de lien avec une activité.
Population : séjours de TB_SEJOUR entrés de 2014 à 2025, sans DATE_SORTIE, préadmissions (STATUT_PROG = 'P') ou sans aucune ligne dans TB_MVT.
Période : années d'entrée 2014-2025.
Unité d'analyse : le séjour CORA.
Mesure : part des séjours reliés à au moins un acte, un diagnostic, un mouvement, un RSS ; part reliés à rien.
Comparaison : préadmissions avec mouvement, préadmissions sans mouvement, autres séjours sans mouvement.

## Choix
- Un acte ou un diagnostic est relié au séjour par TB_ACTE.ID_SEJOUR ou TB_DIAG.ID_SEJOUR (lien secondaire du dictionnaire), ou par un mouvement du séjour (TB_ACTE.ID_MVT, TB_DIAG.ID_MVT, lien principal) : un séjour sans mouvement n'a que le premier.
- La décision d'exclure les séjours reliés à rien est de Pierre, posée avant la mesure ; elle est consignée dans un commentaire de #32, qui sert de source.
- Les séjours restés ouverts (un mouvement ouvert) relèvent de #33, pas de cette enquête.

## Conclusions
- sejour-sans-sortie-ni-mouvement-vide (unreviewed)
- exclure-sejours-sans-sortie-ni-mouvement (unreviewed)
