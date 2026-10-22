---
review: unreviewed
id: uf-hebergeante-change-en-2026
kind: empirical
author: Pierre
statement: "Dans le pôle femme-mère-enfant, les numéros d'UF restent stables quand des UM sont renumérotées (2025), mais l'UF hébergeante d'une même activité peut changer d'une année à l'autre (2026) : une série par UF perd alors des RUM qui réapparaissent sous une autre UF."
scope: "CORA de production (CWPROD), TB_SYNTH_RUM.ID_UNITE_HEBERG et TB_UNITE_M_UNITE, pôle FME, RUM terminés de janvier à septembre de 2022 à 2026, lus le 2026-10-22"
refuted_if: "en 2026, aucun RUM de l'UM 5627 n'est hébergé par l'UF 5616, ou des RUM des UM 5618 et 5619 ne sont plus hébergés par les UF 5618 et 5619 en 2026"
maturity: observed
lifecycle: active
terms: [cora:uf, cora:um, cora:rum]
tables: [cora:TB_SYNTH_RUM, cora:TB_UNITE, cora:TB_UNITE_M_UNITE]
supported_by: [20261022-um-pole-fme-uf-trois-sources-resultat, 20261022-um-pole-fme-lien-um-uf-dates-resultat]
depends_on: [uf-du-rum-hebergement]
---
## Pour s'en servir

Avant de suivre une UF du pôle FME sur plusieurs années, regarder pour chaque UM quelle UF héberge ses RUM chaque année, et regrouper les UF liées (UF 5622 avec 5618, UF 5623 avec 5619, UF 5627 avec 5616). Un écart de volume d'une UF entre deux années est d'abord un changement d'hébergement à vérifier, pas un changement d'activité. Raisonner par UM seule n'est pas plus sûr : les UM 5618 et 5619 reçoivent depuis 2025 les RUM des UF 5622 et 5623.

## Ce qui l'appuie

Les UF 5622 et 5623 gardent leur numéro, mais leurs RUM passent de l'UM 5622 (1 129 RUM en 2022) à l'UM 5618 en 2025 (1 004) et 2026 (858), de l'UM 5623 (608 en 2022) à l'UM 5619 en 2025 (638) et 2026 (411) ; le lien UM-UF 5618-5622 débute le 2025-01-01 (20261022-um-pole-fme-lien-um-uf-dates-resultat). En 2026 seulement, 112 RUM de l'UM 5627 sont hébergés par l'UF 5616, et les UF 5618 et 5619 hébergent 238 et 272 RUM de leur propre UM, contre 126 et 128 en 2025 (20261022-um-pole-fme-uf-trois-sources-resultat).

Points ouverts : d'autres déplacements peuvent exister (hémato-oncologie pédiatrique 5612 et 5613, surveillance continue de chirurgie pédiatrique 6152) ; la table complète des changements de numéros n'est pas faite.
