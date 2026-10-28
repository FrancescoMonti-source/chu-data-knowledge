---
review: unreviewed
id: reintervention-bariatrique-par-actes-du-retour
kind: empirical
author: Francesco
statement: "Dans CORA, une réintervention après chirurgie bariatrique ne se repère pas par un second acte de chirurgie bariatrique : par code et par an, moins de 10 séjours de sleeve (HFFC018) ou de bypass (HFCC003) suivent un autre acte de la subdivision dans les 90 jours. La repérer par les actes de complication du séjour de retour."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours avec un acte de la subdivision CCAM 07.03.02.09 réalisé de 2022 au 2026-10-28 ; retours de J1 à J90 après une sleeve ou un bypass de 2022 à 2025"
refuted_if: "pour une année de 2022 à 2025, 10 séjours ou plus avec HFFC018, ou 10 ou plus avec HFCC003, ont un autre acte de la subdivision 07.03.02.09 dans un autre séjour du même patient des 90 jours précédents"
maturity: provisional
lifecycle: active
terms: [cora:acte, cora:sejour]
tables: [cora:TB_ACTE, cora:TB_SEJOUR, cora:TB_SYNTH_RSS]
supported_by: [20261028-actes-bariatriques-par-an-resultat, 20261028-retours-j90-grade-resultat, 20261027-ccam-actes-obesite]
depends_on: [joindre-rss-par-id-sejour, sejour-cree-avant-entree-programme]
---
## Pour s'en servir

- **Intervention index :** HFFC018 et HFFA011 (sleeve), HFCC003 et HFCA001 (bypass). Les autres codes de la subdivision 07.03.02.09 sont rares (stimulateur gastrique, anneau repositionné ou retiré) ou absents depuis 2022 ; J0 est le jour du premier de ces actes dans le séjour.
- **Réintervention :** un acte des listes de la requête 20261028-retours-j90-grade dans le séjour de retour : grade IV (actes de grade IV de la table S3 de Tzedakis et al. 2026, forfaits de réanimation YYYY015 et YYYY020 compris), grade III (actes de grade III gardés, plus les actes ajoutés pour la chirurgie bariatrique). Les actes biliaires restent à part : une lithiase après l'amaigrissement n'est pas une complication de l'intervention.
- **Non programmée :** un retour qui n'est pas créé avant son jour d'entrée (sejour-cree-avant-entree-programme).
- **Effectifs :** quelques cas par an. Le compte d'une année se fait à l'hôpital, sur une copie non masquée de la requête ; le dépôt ne garde que le résultat masqué. Les retours dans un autre établissement manquent.

## Ce qui l'appuie

La subdivision 07.03.02.09 de la CCAM 2026 couvre la chirurgie bariatrique initiale et la réintervention (20261027-ccam-actes-obesite). Au CHU, de 2022 à 2025, HFFC018 compte 143, 84, 70 et 97 séjours par an, et HFCC003 18, 17, 24 et 13 ; pour chacun, moins de 10 séjours par an ont un autre acte de la subdivision dans un autre séjour des 90 jours précédents. Les autres codes ont moins de 10 séjours par an, ou aucun (20261028-actes-bariatriques-par-an-resultat).

Les complications passent donc par d'autres actes. Sur les retours de J1 à J90 après une sleeve ou un bypass de 2022 à 2025 (20261028-retours-j90-grade-resultat) : au moins 53 retours, dont la plupart sans acte des listes ; des retours de grade III ou IV, moins de 10 par case, tous entrés par les urgences ou créés le jour de leur entrée ; aucune ligne de retour dont le seul signal serait un acte ajouté, un acte biliaire ou un acte retiré. Dans le séjour index, moins de 10 séjours par grade.

Points ouverts : aucun dossier n'a été relu par un chirurgien pour confirmer le grade ; les listes de Tzedakis et al. sont validées en chirurgie hépatobiliaire, pas bariatrique ; l'unité du questionnaire (séjour de retour, réintervention ou patient) n'est pas tranchée.
