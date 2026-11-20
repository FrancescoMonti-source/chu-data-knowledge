---
review: unreviewed
id: lien-enfant-mere-par-no-sejour
kind: empirical
author: Francesco
statement: "Dans CORA, le séjour de naissance porte le numéro du séjour de la mère dans TB_SEJOUR.NO_SEJOUR_DOSSIER_MERE, qui se joint à TB_SEJOUR.NO_SEJOUR de la mère : c'est le lien enfant-mère ; il manque pour environ un séjour de naissance sur vingt."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours de naissance entrés de 2018 à 2025 et séjours d'enfant P95+0 ou P95+1 de 2019 à 2025"
refuted_if: "pour une année de 2018 à 2025, moins de 80 % des séjours de naissance ont un NO_SEJOUR_DOSSIER_MERE égal au NO_SEJOUR d'un séjour de CORA"
maturity: observed
lifecycle: active
terms: [pmsi:sejour-naissance, cora:sejour]
tables: [cora:TB_SEJOUR]
supported_by: [20261102-naissances-remplissage-resultat, 20261103-mfs-enfant-mere-22sa-resultat, 20261102-mortnes-lien-mere]
depends_on: []
---
## Pour s'en servir

Joindre `TRIM(enfant.NO_SEJOUR_DOSSIER_MERE) = TRIM(mere.NO_SEJOUR)` sur TB_SEJOUR, puis lire les diagnostics de la mère par son séjour (Z37 pour l'issue de l'accouchement, O03 ou O04 pour un avortement). Faire une jointure externe : environ 5 % des séjours de naissance n'ont pas de numéro, et un comptage par jointure interne les perd sans le dire. TB_PATIENT.IPP_MERE donne la mère, pas son séjour.

## Ce qui l'appuie

L'instruction de 2021 demande le numéro de séjour administratif de la mère sur le séjour du bébé dans les établissements ex-DGF (20261102-mortnes-lien-mere). Le dictionnaire CORA liste la colonne sans dire ce qu'elle contient.

Séjours de naissance repérés par la date de naissance (20261102-naissances-remplissage-resultat) : NO_SEJOUR_DOSSIER_MERE rempli pour 2 792 sur 2 929 en 2018, de 95 à 97 % les autres années (2 820 sur 2 912 en 2021) ; le numéro est retrouvé comme NO_SEJOUR d'un séjour de CORA pour 2 776 des 2 787 séjours qui l'ont en 2020, pour tous en 2021 et 2024, les autres années étant masquées. Séjours d'enfant P95+1 (20261103-mfs-enfant-mere-22sa-resultat) : séjour de la mère retrouvé pour tous de 2020 à 2022, en 2024 et en 2025.

Points ouverts : l'heure d'exécution de 20261102-naissances-remplissage-resultat est inconnue ; on ne sait pas si un numéro retrouvé désigne toujours le bon séjour (accouchement de la même date).
