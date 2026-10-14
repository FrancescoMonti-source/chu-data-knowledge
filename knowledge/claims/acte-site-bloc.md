---
review: unreviewed
id: acte-site-bloc
kind: empirical
author: Pierre
statement: "Dans CORA, le site de réalisation d'un acte (TB_ACTE.ID_SITE) est vide pour environ 63 000 actes en 2020 et 147 000 en 2021, tous du flux CPage, et presque jamais ailleurs : un périmètre « acte de bloc » par TB_SITE.BLOC sous-estime ces deux années. Les actes de bloc viennent du flux CPage jusqu'en 2024 (71 à 97 % selon l'année), puis surtout de la saisie dans CORA en 2025 (62 %)."
scope: "CORA de production (CWPROD, schéma CORA_REC), tables TB_ACTE et TB_SITE, actes datés de 2014 à 2025, lus le 2026-10-14"
refuted_if: "plus de 10 000 actes d'une année autre que 2020 et 2021 ont ID_SITE vide, ou la saisie CORA porte moins de la moitié des actes de bloc de 2025"
maturity: observed
lifecycle: active
terms: [cora:acte]
tables: [cora:TB_ACTE, cora:TB_SITE]
supported_by: [20261014-epoques-actes-resultat]
depends_on: [epoques-codage-actes]
---
## Pour s'en servir

Un acte de bloc se repère par son site : `TB_ACTE.ID_SITE` vers `TB_SITE.BLOC = 'O'`. Dans une série d'actes de bloc, signaler 2020 et 2021 : une partie des actes n'a pas de site et sort du périmètre, sans que l'activité baisse.

Pour savoir d'où vient le codage d'une intervention : du flux CPage (application 10) jusqu'en 2024, de la saisie dans CORA en 2025. Une série qui distingue les deux sources doit s'attendre à cette bascule.

## Ce qui l'appuie

Actes par mois et par application (20261014-epoques-actes-resultat) :

- **Site vide :** environ 63 400 actes en 2020 et 147 000 en 2021, presque tous de l'application 10 ; environ 1 800 en 2018 et 2 900 en 2019 ; moins de 10 par mois et par application les autres années.
- **Actes sur un site de bloc :** environ 14 000 à 17 700 par an en 2014-2016 (application −3010), 10 000 à 12 400 en 2018-2019, puis 56 600 en 2021, 40 900 en 2022, 42 500 en 2023, 43 700 en 2024 et 52 500 en 2025. Part du flux CPage : 71 % en 2021, 97 % en 2022, 96 % en 2023, 88 % en 2024, 38 % en 2025.

Les sommes annuelles additionnent des cases mensuelles, dont certaines sont masquées (<10) : elles sont arrondies.
