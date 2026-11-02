---
review: unreviewed
id: sejours-sans-rss-venues-externes
kind: empirical
author: Pierre
statement: "Dans CORA, les séjours clos sans RSS sont surtout des venues externes : un seul mouvement, dans une UF qui n'est pas soumise au PMSI, TYPE_SEJOUR EXT ; de 2020 à 2023, la plupart durent plus d'une semaine (un dossier d'externe ouvert sur une période), alors qu'en 2018-2019 et 2024-2025 ils durent 0 jour. Pour compter les hospitalisations MCO, partir des séjours qui ont un RSS."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours sortis de 2018 à 2025 hors préadmissions, RSS par TB_SYNTH_RSS.ID_SEJOUR, lus le 2026-10-15"
refuted_if: "pour une année, plus de 20 % des séjours sans RSS ont plusieurs mouvements, ou plus de 20 % sont dans une UF soumise au PMSI"
maturity: observed
lifecycle: active
terms: [cora:sejour, cora:rss, cora:uf, cora:type-sejour]
tables: [cora:TB_SEJOUR, cora:TB_SYNTH_RSS, cora:TB_MVT, cora:TB_UNITE, cora:TB_MVT_HAD, cora:TB_MVT_SSR_SEM, cora:TB_MVT_PSY_SEQ]
supported_by: [20261015-sejours-sans-rss-profil-resultat]
depends_on: [joindre-rss-par-id-sejour, joindre-uf-par-code, type-prise-en-charge-mco]
---
## Pour s'en servir

- **Hospitalisations MCO :** les séjours qui ont un RSS (joindre-rss-par-id-sejour), classés par type-prise-en-charge-mco. Un compte de TB_SEJOUR sans filtre compte surtout des consultations.
- **Venues externes :** les séjours sans RSS dans une UF non soumise au PMSI (`TB_UNITE.GESTION_PMSI` différent de 'O'). Ne pas leur calculer de durée : de 2020 à 2023, la date de sortie d'un dossier d'externe peut tomber des semaines après l'entrée.
- **SMR, psychiatrie, HAD :** quelques milliers de séjours sans RSS MCO par an, repérables par TB_MVT_SSR_SEM, TB_MVT_PSY_SEQ, TB_MVT_HAD ou TYPE_UNITE_PSY. Les traiter à part.
- **Point ouvert (#25) :** 46 000 à 73 000 séjours par an n'ont pas de RSS alors que l'UF de leur dernier mouvement est soumise au PMSI (TYPE_SEJOUR MCO). Ce ne sont pas des venues externes évidentes : ne pas les compter comme hospitalisations sans le dire.

## Ce qui l'appuie

Séjours clos par année de sortie, avec et sans RSS (20261015-sejours-sans-rss-profil-resultat) :

- **Mouvements :** sans RSS, un seul mouvement pour plus de 98 % des séjours chaque année (537 423 sur environ 539 000 en 2020, 713 251 sur environ 714 000 en 2025).
- **Champ de l'UF du dernier mouvement :** sans RSS, « autre » (non soumise au PMSI) pour 580 910 en 2018 et 647 913 en 2025 ; « MCO PMSI » pour 46 503 à 72 794 par an ; SMR, 3 000 à 5 100 ; psychiatrie, moins de 80. Avec RSS : presque tous « MCO PMSI ».
- **Durée :** sans RSS, 0 jour pour 587 694 séjours en 2018 et 562 284 en 2025, mais seulement 41 733 en 2020 et 104 647 en 2022, où 8 à 30 jours (149 924 ; 285 976) et plus de 30 jours (314 015 ; 199 957) dominent. Avec RSS, la répartition des durées est stable d'une année à l'autre.
- **TYPE_SEJOUR :** sans RSS, surtout EXT (460 460 en 2020), puis MCO (46 586 à 70 899 par an), SSR et URG.
