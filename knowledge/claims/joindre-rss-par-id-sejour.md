---
review: unreviewed
id: joindre-rss-par-id-sejour
kind: empirical
author: Pierre
statement: "Dans CORA, TB_SYNTH_RSS.ID_SEJOUR relie chaque RSS à son séjour : la jointure directe retrouve autant de séjours que le chemin par les mouvements depuis 2018, et elle est la seule à retrouver ceux de 2016 ; CHRONO_RSS ne vaut presque jamais 1, et un séjour sur 30 à 100 ayant un RSS en a plusieurs."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours sortis et RSS finis de 2014 à 2025, lus le 2026-10-14"
refuted_if: "pour une année depuis 2018, la jointure par TB_SYNTH_RSS.ID_SEJOUR retrouve moins de 99 % des séjours reliés à un RSS par les mouvements, ou plus de 10 RSS d'une année ont CHRONO_RSS = 1"
maturity: observed
lifecycle: active
terms: [cora:rss, cora:sejour, cora:mouvement]
tables: [cora:TB_SYNTH_RSS, cora:TB_SEJOUR, cora:TB_MVT, cora:TB_MVT_RUM]
supported_by: [20261014-lien-sejour-rss-resultat]
depends_on: []
---
## Pour s'en servir

Pour relier un séjour à son RSS, joindre directement :

```sql
JOIN CORA_REC.TB_SYNTH_RSS r ON r.ID_SEJOUR = s.ID_SEJOUR
```

Ne pas filtrer `CHRONO_RSS = 1` : presque aucun RSS ne porte cette valeur, et le filtre vide le résultat. C'est ce filtre, et non la jointure par ID_SEJOUR, qui faisait dire à la kb de DIM-code que la jointure directe ne ramène rien.

Un séjour peut avoir plusieurs RSS (1 à 3 % des séjours qui en ont) : agréger par séjour, ou choisir le RSS voulu (par exemple le dernier par DATE_FIN), et le dire.

Le chemin par les mouvements (TB_MVT → TB_MVT_RUM → TB_SYNTH_RSS) donne le même résultat depuis 2018, mais ne retrouve que 5 707 des 142 174 séjours de 2016 qui ont un RSS. Un claim qui l'a utilisé sur 2016 sous-estime les RSS de cette année. En 2017, il n'y a presque aucun RSS par aucun chemin.

## Ce qui l'appuie

Séjours clos par année de sortie (20261014-lien-sejour-rss-resultat, niveau SEJOURS) : de 2018 à 2025, les séjours avec un RSS par les mouvements (N_C1) sont aussi ceux dont le RSS porte le même ID_SEJOUR (N_C3, égal chaque année), et la jointure par ID_SEJOUR en retrouve autant ou quelques-uns de plus (N_C4 : moins de 10 de plus en 2019, 85 de plus en 2022, 93 en 2025) ; presque tous ont un CODE_GHM (N_C5). En 2016 : 5 707 séjours par les mouvements, 142 174 par ID_SEJOUR. En 2017 : moins de 10 par l'un et l'autre chemin. Séjours à plusieurs RSS (N_C2) : 1 542 en 2018, de 3 768 à 4 095 par an de 2020 à 2025.

RSS par année de fin (niveau RSS) : chaque année, tous ont ID_SEJOUR renseigné (N_C1 = N) et figurent dans TB_MVT_RUM ; moins de 10 par an ont CHRONO_RSS = 1 (N_C4). 149 RSS seulement finissent en 2017.
