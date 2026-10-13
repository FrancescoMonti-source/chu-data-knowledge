# Que faut-il savoir de TB_SEJOUR et de ses liens dans CORA avant de compter des séjours ?

Personne : Pierre
Issue : #24

## Cadrage
But : faire entrer dans le dépôt les pièges de CORA qui faussent un comptage de séjours, depuis la base de connaissances de dim-code (vague 1 de la migration).
Population : les séjours de TB_SEJOUR, avec leurs mouvements, RUM et RSS.
Période : 2014-2025, selon ce que chaque claim mesure.
Unité d'analyse : le séjour CORA (un enregistrement de TB_SEJOUR).
Mesure : une par claim (part de séjours sans RSS, sans date de sortie…).
Comparaison : sans objet.

## Choix
- Les mesures de dim-code sont rejouées par relay, plutôt que reprises du rapport d'analyse : une preuve d'exécution donne un claim observed, et le résultat brut reste dans le dépôt.
- La structure d'une table se prouve par une lecture du dictionnaire CORA 2020, quand il la décrit.
- Une fiche de dim-code peut donner plusieurs claims : une affirmation par test possible (claims.md, « Taille »).
- Le lien séjour → RSS passe par les mouvements (TB_MVT → TB_MVT_RUM) ; la jointure directe par TB_SYNTH_RSS.ID_SEJOUR est contestée dans dim-code et n'est pas utilisée ici.

## Conclusions
