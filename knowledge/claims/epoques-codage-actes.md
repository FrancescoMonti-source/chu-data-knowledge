---
review: unreviewed
id: epoques-codage-actes
kind: empirical
author: Pierre
statement: "Dans CORA, les actes ne viennent pas de la même source selon la période : 2014-2016, une reprise d'historique (application −3010) ; 2017, presque rien (environ 9 000 actes contre 280 000 à 340 000 les autres années) ; de 2018 à 09/2020, une seconde reprise sans application mais importée (TYPE_TRANSFERT = 'R') ; depuis 10/2020, le codage contemporain, flux CPage (application 10) et saisie dans CORA (sans application, ECRAN renseigné), qui fait passer le volume à environ 800 000 actes par an."
scope: "CORA de production (CWPROD, schéma CORA_REC), table TB_ACTE, actes datés de 2014 à 2025, lus le 2026-10-14"
refuted_if: "une année de 2014 à 2016 compte plus de 5 % d'actes hors application −3010, ou les actes sans application de 2018-2019 ont ECRAN renseigné pour plus de 5 % d'entre eux"
maturity: observed
lifecycle: active
terms: [cora:acte]
tables: [cora:TB_ACTE]
supported_by: [20261014-epoques-actes-resultat, 20261014-chemin-rss-actes-diags-resultat]
depends_on: []
---
## Pour s'en servir

- **Une série d'actes sur plusieurs années :** la faire partir d'octobre 2020, ou découper aux ruptures (fin 2016, 2017, octobre 2020) et le dire. Le volume d'actes est multiplié par 2,5 en 2021 : ce n'est pas une hausse d'activité, c'est l'arrivée du codage de l'activité externe.
- **2017 :** l'exclure de toute série d'actes, et le signaler. La lacune touche aussi les diagnostics et les RSS (dater-diagnostic-par-mouvement, joindre-rss-par-id-sejour).
- **Distinguer la saisie dans CORA d'un import :** par ECRAN renseigné et TYPE_TRANSFERT, jamais par l'absence d'application. Sans application, un acte de 2018-2020 est importé (TYPE_TRANSFERT = 'R'), alors qu'un acte d'après octobre 2020 est saisi dans CORA.

## Ce qui l'appuie

Actes par mois et par application d'origine (20261014-epoques-actes-resultat) :

- **2014-2016 :** application −3010, tous TYPE_TRANSFERT = 'R' (279 986 actes en 2014, 300 156 en 2015, 283 968 en 2016) ; moins de 10 actes par mois sous une autre application.
- **2017 :** environ 9 000 actes, presque tous sans application ; la reprise suivante commence en septembre 2017 et atteint 28 000 actes en janvier 2018.
- **2018 à septembre 2020 :** de 20 000 à 47 000 actes par mois sans application, presque tous TYPE_TRANSFERT = 'R', ECRAN renseigné pour moins de 1 % (403 en 2018, 513 en 2019).
- **Bascule de juin à octobre 2020 :** le flux CPage (application 10) passe de 2 083 actes en juin à 61 349 en octobre ; les actes sans application cessent d'être importés en octobre 2020 (moins de 10 avec TYPE_TRANSFERT = 'R') et deviennent de la saisie CORA (ECRAN renseigné).
- **Depuis 2021 :** 788 000 à 831 000 actes par an (20261014-chemin-rss-actes-diags-resultat) ; la saisie CORA (ECRAN renseigné) passe de 31 000 actes en 2021 à 89 000 en 2024 et 182 000 en 2025.
