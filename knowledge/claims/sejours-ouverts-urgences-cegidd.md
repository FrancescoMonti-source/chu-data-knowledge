---
review: unreviewed
id: sejours-ouverts-urgences-cegidd
kind: empirical
author: Pierre
statement: "Dans CORA, les séjours restés ouverts (sans DATE_SORTIE, hors préadmissions, avec un mouvement) sont presque tous des passages aux urgences jamais clôturés (UF 5701, 5720, 5015, 5010) et les venues du CeGIDD (UF 5645, ouvertes à 90-99 %) : un seul mouvement, resté ouvert, sans diagnostic, et sans acte jusqu'en 2020. Leur part dans une UF d'urgences varie de 0 à près de 90 % selon l'année : elle dépend des clôtures, pas de l'activité, et CORA ne marque pas ces séjours (STATUT, ETAT_ADM_DOSSIER, DATE_BLOCAGE)."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours entrés de 2018 à 2025, lus le 2026-10-15"
refuted_if: "pour une année, moins de la moitié des séjours restés ouverts sont dans les UF d'urgences ou du CeGIDD, ou plus de 20 % d'entre eux ont plusieurs mouvements"
maturity: observed
lifecycle: active
terms: [cora:sejour, cora:mouvement, cora:passage-urgences, cora:uf]
tables: [cora:TB_SEJOUR, cora:TB_MVT, cora:TB_ACTE, cora:TB_DIAG]
supported_by: [20261015-sejours-ouverts-uf-resultat, 20261015-sejours-statut-resultat]
depends_on: [exclure-sejours-sans-sortie-orphelins, joindre-uf-par-code]
---
## Pour s'en servir

- **Compter des passages aux urgences ou des venues au CeGIDD :** garder les séjours restés ouverts, et les dater par le début de leur mouvement (`DATE_DEBUT_MVT`). Les exclure ferait varier le nombre de passages d'une année à l'autre au rythme des clôtures. Une analyse qui exige une sortie les perd : le dire.
- **Actes :** depuis 2021, beaucoup de ces passages portent des actes ; une analyse d'actes par séjour clos les perd.
- **Durée, mode de sortie, UF de sortie :** ces séjours n'en ont pas. Les exclure de ces indicateurs, et dire combien.
- **Repérer un séjour clos :** par `DATE_SORTIE` seulement. `STATUT` ne vaut 'T' que pour une partie des séjours clos, et presque jamais en 2021-2022 ; `ETAT_ADM_DOSSIER` et `DATE_BLOCAGE` sont toujours vides.

En 2024-2025, une part croissante des séjours ouverts tombe dans d'autres UF (consultations, imagerie), par dizaines par UF : moins de 1 % de leurs séjours.

## Ce qui l'appuie

Séjours par année d'entrée et UF du dernier mouvement (20261015-sejours-ouverts-uf-resultat). Part des séjours restés ouverts : UF 5701, 30 % en 2018-2019, moins de 1 % en 2020-2021, 19 % en 2022, 1 % en 2023, 27 % en 2024-2025 ; UF 5015, de 0 % (2020) à 83 % (2022) ; UF 5010, de 0 % (2020) à 89 % (2022) ; UF 5720, de 1 % (2020) à 55 % (2018, 2022) ; UF 5645 (CeGIDD), 90 % en 2021, puis 97 à 99 %. Dans ces UF, presque tous les séjours ouverts ont un seul mouvement, resté ouvert, et moins de 10 ont un diagnostic par UF et par an (sauf quelques dizaines à partir de 2023). Ils n'ont pas d'acte en 2018-2020 ; depuis 2021, une grande part en a aux urgences (par exemple 17 237 sur environ 19 820 à l'UF 5015 en 2022, 7 009 sur environ 16 800 à l'UF 5701 en 2024), alors que ceux du CeGIDD n'en ont presque jamais. Leur dernier mouvement a commencé plus d'un an avant l'exécution, sauf pour les entrées de 2025.

Statut des séjours (20261015-sejours-statut-resultat) : STATUT vaut 'T' pour 110 000 à 175 000 séjours clos par an, sauf 2021 (95) et 2022 (946), vide sinon ; moins de 10 séjours ouverts par an ont 'T' ; ETAT_ADM_DOSSIER est vide et DATE_BLOCAGE renseignée pour moins de 10 séjours chaque année.
