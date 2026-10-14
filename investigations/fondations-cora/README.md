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
- Sorties manquantes (étape 3) : les deux constats entrent comme claims ; la date de référence du séjour (claim decision) attend #32 (préadmissions et séjours sans mouvement : les exclure ?) et #33 (séjours restés ouverts).
- Période d'analyse par défaut : 2018 et après, décision de Pierre (« le foutoir avant 2018 »), consignée dans un commentaire de #24 qui sert de source (claim periode-analyse-cora-2018).
- Le préfixe de NO_SEJOUR (étape 10, kb : no-sejour-is-a-counter) n'est pas migré : un agent n'a pas de raison de dater un séjour par son numéro (Pierre).
- Lot du 14/10 (Pierre : « de manière industrielle ») : les fiches CORA restantes sont triées en une fois ; huit requêtes, exécutées ensemble par scripts/cdk/executer_requetes_cdk.py de dim-code (branche migration-cdk), couvrent celles qui se mesurent : stay-to-rss-link (20261014-lien-sejour-rss) ; rss-path-scope (20261014-chemin-rss-actes-diags) ; act-history-epochs, act-origin, act-site-missing-2021, surgical-acts-coded-in-cora, no-intervention-bloc-screen-only (20261014-epoques-actes) ; intervention-table-is-oproom-flow (20261014-interventions-cora) ; convention.intervention-id-no-intervention-ccam (20261014-groupes-ccam) ; rss-before-validation (20261014-rss-recents) ; convention.age-at-admission (20261014-age-entree) ; convention.exit-mode et convention.last-movement-uf (20261014-sortie-et-dernier-mvt).
- Fiches CORA non migrées : stay-duration-from-stay-dates (principe sans mesure, qu'un agent applique déjà en partant des dates du séjour) ; definition.intervention-numbers (recopie le dictionnaire) ; or-act-included-in-ghs (règle de financement, pas un fait des données CORA) ; definition.ghm-to-ghs-table (un emplacement de table : un terme de glossaire si un claim en a besoin) ; or-site-flag-incomplete (demande OpRoom : avec la migration d'OpRoom) ; les sept fiches propres à un projet (casemix-bloc, pmct-6103, smr-onco), qui restent dans dim-code.
- Conventions qui deviennent des claims decision au nom de Pierre, sans requête propre : convention.length-of-stay ; convention.reference-date attend #33.
- Le lien séjour → RSS passe par les mouvements (TB_MVT → TB_MVT_RUM) ; la jointure directe par TB_SYNTH_RSS.ID_SEJOUR est contestée dans dim-code et n'est pas utilisée ici.

## Conclusions
- type-sejour-non-fiable (unreviewed)
- type-prise-en-charge-mco (unreviewed)
- drapeau-urgence-uf-non-fiable (unreviewed)
- sejour-sans-signal-urgences (unreviewed)
- date-sortie-manquante (unreviewed)
- dernier-mouvement-date-la-sortie (unreviewed)
- periode-analyse-cora-2018 (unreviewed)
- joindre-uf-par-code (unreviewed)
- borner-entree-date-extraction (unreviewed)
