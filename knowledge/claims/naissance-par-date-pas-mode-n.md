---
review: unreviewed
id: naissance-par-date-pas-mode-n
kind: empirical
author: Francesco
statement: "Dans CORA, MODE_ENTREE = 'N' des mouvements ne repère pas les séjours de naissance : selon l'année, il en marque presque tous ou presque aucun ; repérer un séjour de naissance par TB_PATIENT.DATE_NAIS égale au jour d'entrée du séjour."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours entrés de 2018 à 2025"
refuted_if: "pour chaque année de 2018 à 2025, MODE_ENTREE = 'N' marque au moins 90 % des séjours dont la date de naissance du patient est le jour d'entrée"
maturity: observed
lifecycle: active
terms: [pmsi:sejour-naissance, pmsi:mode-entree-sortie, cora:mouvement]
tables: [cora:TB_MVT, cora:TB_PATIENT, cora:TB_SEJOUR]
supported_by: [20261102-naissances-remplissage-resultat, 20261102-deces-0-28-jours-resultat, 20261102-guide-mode-entree-n]
depends_on: []
---
## Pour s'en servir

Un séjour de naissance : `TRUNC(TB_PATIENT.DATE_NAIS) = TRUNC(TB_SEJOUR.DATE_ENTREE)`. Ce repère prend aussi les enfants mort-nés, dont les dates d'entrée et de naissance sont identiques. Ne pas filtrer sur `TB_MVT.MODE_ENTREE = 'N'` : selon l'année, le filtre perd presque toutes les naissances.

## Ce qui l'appuie

Le guide MCO demande le mode d'entrée N pour tout nouveau-né qui a un séjour, mort-nés compris (20261102-guide-mode-entree-n).

Séjours dont la date de naissance est le jour d'entrée (20261102-naissances-remplissage-resultat) : de 2 787 à 3 095 par an. Parmi les séjours de naissance, ceux qui ont un mouvement en mode N : 2 630 en 2019, 2 169 en 2020, 26 en 2021, 34 en 2022, 1 849 en 2023, 530 en 2024, 510 en 2025, et moins de 10 en 2018. Même saut sur les décès à J0 (20261102-deces-0-28-jours-resultat) : 126 enfants avec un mouvement en mode N sur 330 en 2018-2021, 33 sur 347 en 2022-2025.

Points ouverts : la cause des variations de MODE_ENTREE = 'N' n'est pas connue. Un enfant transféré d'un autre établissement le jour de sa naissance passe aussi le repère par la date : en exclure l'entrée par transfert (mode 7) si le comptage ne veut que les naissances de l'établissement. L'heure d'exécution de 20261102-naissances-remplissage-resultat est inconnue.
