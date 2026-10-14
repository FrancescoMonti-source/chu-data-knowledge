---
review: unreviewed
id: drapeau-urgence-uf-non-fiable
kind: empirical
author: Pierre
statement: "Dans CORA, le drapeau URGENCE de TB_UNITE ne repère pas les UF d'urgences : les UF qui reçoivent les passages (5701, 5802, 5709, 5015, 5010, 5720) ne l'ont pas, alors qu'il est posé sur des UF annexes (variantes « - EXT », accueil, plan blanc)."
scope: "CORA de production (CWPROD, schéma CORA_REC), thésaurus TB_UNITE lu le 2026-10-14, séjours entrés de 2014 à 2025"
refuted_if: "URGENCE = 'O' sur toutes les lignes de TB_UNITE de l'une des UF 5701, 5015 ou 5720"
maturity: observed
lifecycle: active
terms: [cora:uf, cora:passage-urgences]
tables: [cora:TB_UNITE, cora:TB_SEJOUR]
supported_by: [20261014-reperer-urgences-resultat, 20261014-dictionnaire-urgence]
depends_on: []
---
## Pour s'en servir

Ne pas filtrer les UF sur TB_UNITE.URGENCE = 'O' pour trouver les urgences : le filtre perd les UF qui reçoivent presque tous les passages. Pour repérer un passage aux urgences, suivre reperer-passage-urgences.

## Ce qui l'appuie

Le dictionnaire CORA 2020 définit URGENCE comme « Unité d'Urgence (si ="O") » (20261014-dictionnaire-urgence) ; les données le contredisent (20261014-reperer-urgences-resultat).

Les UF qui reçoivent les passages ont GESTION_PMSI = 'O' et URGENCE vide : 5701 (279 837 séjours entrés en 2014-2019, 467 052 en 2020-2025), 5015, 5720, 5010, 5802, 5709. Les 13 UF qui ont URGENCE = 'O' sont des variantes « - EXT A/B » (501A, 501B, 570A, 572A, 580A), des UF de consultation (570B, 8001, 8006), un ancien accueil (5700), le plan blanc (9512) et les UF d'accueil créées vers 2020 (8012, 8013, 8014 : 36 851 séjours entrés en 2020-2025 à elles trois). Chaque code n'a qu'une ligne dans TB_UNITE pour toutes ces UF.

Points ouverts : la mesure ne porte que sur les UF dont le libellé contient « URG », qui ont le drapeau ou qui sont citées par un champ d'urgence du séjour ; une UF d'urgences sans aucun de ces signes lui échappe.
