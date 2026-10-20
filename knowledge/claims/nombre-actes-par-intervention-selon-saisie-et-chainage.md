---
review: unreviewed
id: nombre-actes-par-intervention-selon-saisie-et-chainage
kind: empirical
author: Pierre
statement: "Dans CORA, le nombre d'actes retrouvés pour une intervention dépend de l'outil de saisie des actes (CORA, ou un autre logiciel dont le flux est importé, CDP2 d'après Pierre) et de la méthode de rattachement (par NO_INTERVENTION, ou par séjour, jour et site de bloc) : ne comparer deux périodes ou deux groupes d'interventions qu'à outil de saisie et méthode de rattachement constants ; avant janvier 2026, prévenir l'utilisateur des biais possibles."
scope: "CORA de production (CWPROD, schéma CORA_REC), TB_ACTE et TB_INTERVENTION, novembre 2023 au 2026-10-19 ; moyennes sur les interventions seules dans leur séjour et leur jour ; lu le 2026-10-19"
refuted_if: "plus de 20 % des interventions dont aucun acte de bloc du jour n'a d'ECRAN ont au moins un acte rattaché par NO_INTERVENTION, sur un mois de mai 2025 à septembre 2026, ou la moyenne d'actes par intervention au niveau séjour-jour des interventions saisies dans CORA varie de plus de 0,3 entre 2025 et 2026"
maturity: observed
lifecycle: active
terms: [cora:acte, cora:intervention]
tables: [cora:TB_ACTE, cora:TB_INTERVENTION, cora:TB_SITE]
supported_by: [20261019-actes-par-intervention-rattachement-resultat, 20261019-actes-ecran-annee-resultat, 20261019-actes-origine-saisie-mois-resultat, 20261019-interventions-champs-flux-resultat, 20261019-interventions-par-bloc-resultat]
depends_on: [grouper-actes-par-no-intervention-ccam, interventions-cora-flux-oproom, epoques-codage-actes]
---
## Pour s'en servir

Question : combien d'actes retrouve-t-on pour une intervention de bloc, et peut-on comparer ce nombre entre 2024, 2025 et 2026 ?

Réponse : ce nombre dépend de deux choix qui ont changé entre 2024 et 2026 ; il ne mesure donc pas l'activité à lui seul.

1. Le moyen de saisie des actes. Un acte est saisi dans CORA (TB_ACTE.ECRAN renseigné) ou importé d'un autre logiciel (ECRAN vide ; CDP2 d'après Pierre). Entre 2024 et 2026, les actes de bloc passent de l'import à la saisie dans CORA. Les interventions dont les actes sont saisis dans CORA ont un peu plus d'actes que les autres (chiffres dans « Ce qui l'appuie »).
2. La méthode de rattachement des actes à l'intervention. Par TB_ACTE.NO_INTERVENTION : le numéro n'existe presque que pour les actes saisis dans CORA (surtout l'écran Bloc). Par séjour, jour et site de bloc : valable pour une intervention seule dans son séjour et son jour, elle couvre aussi les actes importés et retrouve plus d'actes que le numéro seul.

Pour comparer :
a. Dire le moyen de saisie et la méthode de rattachement de chaque chiffre.
b. Comparer 2024, 2025 et 2026 groupe par groupe (saisie CORA, importé) et méthode par méthode, sans mélanger.
c. Ne pas conclure à un changement d'activité si le nombre d'actes ne bouge que parce que la part de chaque groupe ou de chaque méthode a changé.
d. Avant janvier 2026, prévenir l'utilisateur que le nombre d'actes par intervention peut être biaisé : une grande partie des actes de bloc est encore importée d'un autre logiciel, le numéro d'intervention n'existe que pour une partie des actes, et TB_INTERVENTION ne couvre pas encore tous les blocs. Dire dans la réponse la période, le moyen de saisie et la méthode de rattachement employés. À partir de 2026, la saisie des actes de bloc dans CORA est presque générale, et la comparaison est plus sûre (chiffres dans « Ce qui l'appuie »).
e. Pour retrouver le plus d'actes possible, rattacher par séjour, jour et site de bloc (rattacher-actes-bloc-sans-cle) et se servir du numéro d'intervention pour confirmer, non comme seule clé ; pour regrouper les actes d'une intervention sans NO_INTERVENTION, voir grouper-actes-par-no-intervention-ccam.

Qu'une saisie dans CORA soit plus complète que le flux importé, ou que les deux groupes ne soient pas comparables, n'est pas établi.

## Ce qui l'appuie

Mesures du 19/10 sur CORA (CWPROD), à lire avec leurs preuves.

- **Origine de saisie des actes de bloc** (20261019-actes-ecran-annee-resultat) : la part d'actes importés (ECRAN vide) parmi les actes d'un site de bloc passe de 87 % en 2024 (38 094 sur 43 692) à environ 38 % en 2025 (19 718 sur 52 460) et environ 10 % en 2026 (4 410 sur 43 324), cases <10 comptées 0. Sur l'ensemble des actes, la saisie CORA reste minoritaire : ECRAN renseigné sur 10,8 % des actes en 2024 (88 790 sur 820 476), 21,8 % en 2025 (181 571 sur 831 386), 30,6 % en 2026 (170 598 sur 558 035).
- **Où le numéro d'intervention est posé** (même preuve) : presque tous les actes d'ECRAN = BLO (97 % en 2025, 12 482 sur 12 830 ; 98 % en 2026, 22 754 sur 23 142), une partie de ceux d'ECRAN = RSS (28 % en 2026, 5 166 sur 18 285) et peu de ceux d'ECRAN = RUM (6 % en 2026, 949 sur 16 436), presque aucun hors saisie CORA (258 actes sur 649 815 en 2025, moins de 10 en 2024 et en 2026). Le saut de mai 2025 (369 actes avec numéro en avril, 1 020 en mai, cases <10 comptées 0) coïncide avec l'arrivée des interventions dans TB_INTERVENTION (329 interventions de l'application 16 en avril, au moins 1 311 en mai : leur nombre total est masqué, 1 311 ont une entrée en salle renseignée), non avec la part de saisie CORA, qui monte sans saut (19,6 % des actes du mois à ECRAN renseigné en avril, 20,8 % en mai) (20261019-actes-origine-saisie-mois-resultat, 20261019-interventions-champs-flux-resultat).
- **Rattachement selon l'origine** (20261019-actes-par-intervention-rattachement-resultat, interventions seules dans leur séjour et leur jour) : des interventions saisies dans CORA, 88 % ont un acte rattaché par NO_INTERVENTION en 2024 (792 sur 901), 86 % en 2025 (9 087 sur 10 611), 95 % en 2026 (17 532 sur 18 404) ; hors CORA, 6 % de mai à décembre 2025 (187 sur 2 968 ; de 3 % à 9 % selon le mois) et moins de 10 par mois en 2024 et en 2026. Pour les mois où le nombre d'interventions saisies dans CORA est masqué (2024 : février à mai et août), il est lu comme le nombre d'interventions avec acte du séjour-jour, qui lui est égal dans les 62 lignes visibles.
- **Moyenne d'actes par intervention** (20261019-actes-par-intervention-rattachement-resultat, interventions seules dans leur séjour et leur jour ; actes du séjour-jour divisés par interventions avec acte du séjour-jour, mois de janvier à décembre en 2024 et 2025, de janvier à octobre en 2026, cases <10 comptées 0) : saisie CORA 1,85 en 2024 (1 669 actes pour 901 interventions), 1,80 en 2025 (19 120 pour 10 611), 1,73 en 2026 (31 753 pour 18 404) ; hors CORA 1,56 (287 pour 184), 1,24 (3 791 pour 3 066), 1,15 (2 819 pour 2 447). Elle baisse donc légèrement dans le groupe saisie CORA (moins de 0,08 par an), et plus nettement hors CORA de 2024 à 2025 (moins 0,32 ; moins 0,25 si l'on écarte décembre 2024, dont le nombre d'interventions hors CORA est <10 alors que 13 actes y sont comptés) puis de 0,08 ; elle ne monte pas. 2024 se compare : la moyenne du séjour-jour n'utilise que le nombre d'interventions avec acte, visible tous les mois pour la saisie CORA, même si le nombre total d'interventions est masqué pour 5 mois sur 12 (février à mai, août) ; pour 2024, 1 mois sur 12 est <10 hors CORA, et le nombre d'interventions hors CORA avec acte rattaché est <10 les 12 mois (2025 : 4 mois sur 12 ; 2026 : 10 mois sur 10), donc le niveau « numéro seul » hors CORA ne se calcule pas. Une version antérieure de ce texte annonçait une hausse : elle n'est pas retrouvée.

Points ouverts : la requête ne voit que les interventions déjà dans TB_INTERVENTION, et en 2023 et 2024 elles viennent d'un seul bloc (2618, chirurgie thoracique : 1 249 interventions sur 1 250 en 2024), de 89 à 121 par mois, puis de 92 à 103 par mois de janvier à mars 2025 ; d'autres blocs arrivent à partir d'avril 2025 (329 interventions) ; sans OpRoom, on ne sait pas si une intervention sans acte est réellement sans acte ou pas encore codée ; l'application 10 est nommée « flux CPage » dans applications-emettrices, et que ce soit le CDP2 de Pierre n'est pas écrit dans le dépôt.
