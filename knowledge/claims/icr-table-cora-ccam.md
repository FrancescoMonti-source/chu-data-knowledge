---
review: unreviewed
id: icr-table-cora-ccam
kind: empirical
author: Pierre
supersedes: [icr-sans-table-cora]
statement: "Dans CORA de production, l'ICR d'un acte CCAM se lit dans CORA_REC.PMSI_CCAM_ICR (synonyme de CORA_CCAM.PMSI_CCAM_ICR), lisible et renseignée pour les 29 800 lignes depuis le 2026-11-03, mais avec deux lignes par combinaison CODE, EXTENSION_ATIH, PHASE, ACTIVITE (14 900 clés) : une jointure sans le critère qui distingue ces lignes double les actes ; écrire la requête sur cette table plutôt que de joindre un fichier ATIH, après avoir identifié ce critère."
scope: "CORA de production (CWPROD), table lue avec le compte de Pierre le 2026-11-03 (comptages seulement) ; absente du catalogue le 2026-10-19 ; version de l'ICR et couverture des actes de CORA non établies"
refuted_if: "un comptage de CORA_REC.PMSI_CCAM_ICR donne ORA-00942, ou moins de 29 800 lignes, ou un ICR vide, ou autant de clés CODE, EXTENSION_ATIH, PHASE, ACTIVITE que de lignes"
maturity: observed
lifecycle: active
terms: [cora:acte]
tables: [cora:PMSI_CCAM_ICR]
supported_by: [20261026-schemas-objets-resultat, 20261026-schemas-candidats-colonnes-resultat, 20261103-icr-lecture-resultat]
depends_on: []
---
## Pour s'en servir

Pour l'ICR d'un acte, lire `CORA_REC.PMSI_CCAM_ICR` par le code de l'acte (CODE, CHAR(7)). Ne pas joindre sur CODE seul : chaque combinaison CODE, EXTENSION_ATIH, PHASE, ACTIVITE a deux lignes (ACTIVITE_LIBERALE est la colonne qui peut les distinguer, à confirmer). Avant d'écrire la jointure, lancer `20261103-icr-cle-liberale` (ou un comptage équivalent) pour savoir quelle colonne sépare les deux lignes et si l'ICR y diffère ; une jointure aveugle double les actes et fausse toute somme d'ICR. Dire quelle version de l'ICR la table contient : elle est inconnue (aucune colonne de date ni de version).

Si les actes de CORA n'y trouvent pas leur code, ou si la version ne convient pas, revenir au fichier ATIH des ICR de la CCAM descriptive à usage PMSI, joint par code d'acte, et le dire.

## Ce qui l'appuie

Le catalogue du 2026-10-19 ne montrait aucun objet ICR (20261019-catalogue-objets-g3-resultat) : seuls CORA_REC, INTEG et ZEXPLOIT étaient visibles. Le catalogue du 2026-10-26, après l'ajout des schémas CORA (20261026-schemas-objets-resultat), montre CORA_CCAM.PMSI_CCAM_ICR (table, environ 29 800 lignes d'après les statistiques Oracle, analysée le 2026-10-25) et son synonyme CORA_REC.PMSI_CCAM_ICR. Colonnes : CODE, EXTENSION_ATIH, PHASE, ACTIVITE, ACTIVITE_LIBERALE, ICR (20261026-schemas-candidats-colonnes-resultat). Cela explique l'ORA-00942 du 2026-10-19 : la table était hors de la vue du compte. La lecture directe du 2026-11-03 (20261103-icr-lecture-resultat) la confirme lisible : 29 800 lignes, ICR renseigné pour toutes, 8 917 codes distincts, 14 900 combinaisons CODE, EXTENSION_ATIH, PHASE, ACTIVITE (deux lignes chacune), 1 128 valeurs d'ICR de 0 à 2 875.

Points ouverts : ce qui distingue les deux lignes d'une clé et si leur ICR diffère (20261103-icr-cle-liberale, non exécutée) ; la version de l'ICR ; la couverture des codes d'actes de CORA ; la comparaison avec le fichier ATIH.
