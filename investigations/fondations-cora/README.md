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
- Un claim n'entre que s'il apporte ce que les sources ne disent pas : il contredit la documentation, il mesure, ou il signale un piège que la structure ne laisse pas deviner. Ce que le dictionnaire CORA dit déjà n'est pas recopié en claim (étape 1 abandonnée ; diagnoses-attached-to-movement et ghm-code-without-cmd non migrés).
- La part des séjours sans RSS (étape 2) n'est pas un claim : la question n'est pas mûre. Elle passe dans l'issue #25 ; la requête 20261013-sejours-sans-rss et sa preuve 20261013-sejours-sans-rss-resultat restent dans le dépôt, citées par #25, jusqu'à ce qu'un claim s'en serve ou que #25 se ferme sans claim (elles sont alors supprimées).
- Repérer les UF d'urgences (étapes 11 à 13) : les deux constats sur les signaux de CORA entrent comme claims ; la méthode de repérage attend l'accès à la structure de Cora Admin Recueil et passe dans l'issue #30. Les requêtes 20261014-structure-uf-urgences et 20261014-chercher-structure-schemas et leurs preuves restent dans le dépôt, citées par #30, jusqu'à ce qu'un claim s'en serve ou que #30 se ferme sans claim.
- Le lien séjour → RSS passe par les mouvements (TB_MVT → TB_MVT_RUM) ; la jointure directe par TB_SYNTH_RSS.ID_SEJOUR est contestée dans dim-code et n'est pas utilisée ici.

## Conclusions
- type-sejour-non-fiable (unreviewed)
- type-prise-en-charge-mco (unreviewed)
- drapeau-urgence-uf-non-fiable (unreviewed)
- sejour-sans-signal-urgences (unreviewed)
