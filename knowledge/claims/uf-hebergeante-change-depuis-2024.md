---
review: unreviewed
id: uf-hebergeante-change-depuis-2024
kind: empirical
author: Pierre
statement: "Dans CORA, jusqu'en 2023 tous les RUM d'une UM sont hébergés par l'UF de même code ; depuis 2024, quelques UM de plusieurs pôles sont hébergées par une autre UF (4 UM sur 185 changent d'UF principale, 6 UM ont plusieurs UF hébergeantes en 2026) : une série par UF ou par UM perd alors des RUM qui réapparaissent sous une autre unité."
scope: "CORA de production (CWPROD, schéma CORA_REC), TB_SYNTH_RUM.ID_UNITE_HEBERG, tous les pôles, RUM terminés de janvier à septembre de 2022 à 2026, lus le 2026-11-03"
refuted_if: "une nouvelle lecture de TB_SYNTH_RUM sur la même période trouve, avant 2024, des RUM hébergés par une UF de code différent de leur UM, ou, après 2024, aucune UM hébergée par plusieurs UF"
maturity: observed
lifecycle: active
terms: [cora:uf, cora:um, cora:rum]
tables: [cora:TB_SYNTH_RUM, cora:TB_UNITE, cora:TB_UNITE_MEDICALE, cora:TB_UNITE_M_UNITE]
supported_by: [20261026-um-uf-hebergeante-par-annee-tous-poles-resultat, 20261022-um-pole-fme-uf-trois-sources-resultat, 20261022-um-pole-fme-lien-um-uf-dates-resultat]
depends_on: [uf-du-rum-hebergement]
---
## Pour s'en servir

Avant de suivre une UF ou une UM sur plusieurs années, relever pour chaque UM l'UF qui héberge ses RUM chaque année (ID_UNITE_HEBERG joint à TB_UNITE), et regrouper les UF liées. Un écart de volume d'une UF ou d'une UM entre deux années est d'abord un changement d'hébergement à vérifier, pas un changement d'activité. Le piège ne touche qu'une minorité d'UM, mais dans plusieurs pôles : ne pas le limiter au pôle femme-mère-enfant ni à 2026.

Cas connus (même lecture) : UM 5530 (surveillance continue cardiologique) hébergée par l'UF 5522 depuis 2024 ; UM 6241 (chirurgie cardiaque, soins continus) par l'UF 6245 depuis 2025 ; UM 5618 et 5619 par les UF 5622 et 5623 depuis 2025 ; UM 5627 en partie par l'UF 5616 en 2026.

## Ce qui l'appuie

Pour 145 UM en 2022 à 164 en 2026, la lecture des RUM par UM et UF hébergeante (20261026-um-uf-hebergeante-par-annee-tous-poles-resultat ; cellules <10 comptées pour 0) donne :
- 2022 et 2023 : une seule UF par UM, de même code que l'UM, pour tous les RUM ;
- part des RUM hébergés par une UF de code différent de leur UM : 0,6 % en 2024, 2,2 % en 2025, 2,0 % en 2026 ;
- UM dont l'UF principale change entre 2022 et 2026 : 4 sur 185 : 5530 (5530 puis 5522 dès 2024), 5618 (5618 puis 5622 dès 2025), 5619 (5619 puis 5623 dès 2025) et 6241 (6241 puis 6245 dès 2025) ;
- UM hébergées par plusieurs UF dans l'année : 1 en 2024, 4 en 2025, 6 en 2026 (par exemple 5530 : 1 037 RUM sous l'UF 5522 et 443 sous la 5530 en 2024).
Le détail du pôle femme-mère-enfant (UM 5618, 5619, 5627 ; UF 5616, 5622, 5623) est dans 20261022-um-pole-fme-uf-trois-sources-resultat ; le lien UM-UF 5618-5622 débute le 2025-01-01 (20261022-um-pole-fme-lien-um-uf-dates-resultat).

Points ouverts : le nombre d'UM touchées est une borne basse (cellules <10 masquées, 11 en 2025 et 2026) ; d'autres déplacements peuvent exister (hémato-oncologie pédiatrique 5612 et 5613, surveillance continue de chirurgie pédiatrique 6152) ; la table complète des changements de numéros n'est pas faite.
