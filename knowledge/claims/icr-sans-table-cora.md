---
review: unreviewed
id: icr-sans-table-cora
kind: empirical
author: Pierre
statement: "Dans CORA de production, aucune table ni vue ICR n'est visible pour le compte de Pierre : PMSI_CCAM_ICR, que le dictionnaire 2020 décrit, est absente du catalogue, et V_CCAM_NV n'a pas de colonne ICR ; ne pas écrire de requête sur une table ICR de CORA, et prendre l'ICR d'un fichier ATIH joint par code d'acte."
scope: "CORA de production (CWPROD), catalogue Oracle de tous les schémas non maintenus par Oracle, objets visibles par le compte de Pierre, lu le 2026-10-19"
refuted_if: "ALL_OBJECTS, lu avec le compte de Pierre ou un autre, montre une table, une vue ou un synonyme nommé PMSI_CCAM_ICR ou contenant ICR entre soulignés, ou V_CCAM_NV a une colonne ICR"
maturity: observed
lifecycle: active
terms: [cora:acte]
tables: [cora:PMSI_CCAM_ICR, cora:V_CCAM_NV]
supported_by: [20261019-catalogue-objets-g3-resultat]
depends_on: []
---
## Pour s'en servir

Pour l'ICR d'un acte CCAM, ne pas chercher une table de CORA : demander à la personne le fichier ATIH des ICR de la CCAM descriptive à usage PMSI (un fichier externe, qui n'a pas de fiche dans sources/) et le joindre au code d'acte. Dire la version du fichier utilisée.

Avant d'écrire qu'un ICR n'existe pas dans CORA, vérifier que le compte qui interroge voit bien l'objet : le catalogue ne montre que ce que le compte peut lire.

## Ce qui l'appuie

Catalogue de CWPROD (20261019-catalogue-objets-g3-resultat) : la requête cherche, dans tous les schémas non maintenus par Oracle, les tables, vues, synonymes et vues matérialisées nommés PMSI_CCAM_ICR ou contenant ICR entre soulignés ou en bord de nom. Aucune ligne n'est revenue pour ces noms. Elle a trouvé V_CCAM_NV (vue valide de CORA_REC, 40 colonnes : CODE, CLE, TYPE, VERSION, LIBELLE_COURT, LIBELLE_LONG, DT_FIN, hiérarchie, drapeaux d'acte…) : aucune colonne n'y porte ICR. L'exécution directe `SELECT COUNT(*) FROM CORA_REC.PMSI_CCAM_ICR` (20261019-icr-lisible) a donné ORA-00942, table ou vue inexistante : Oracle renvoie la même erreur pour une table absente et pour une table sans droit de lecture, et ce résultat n'est pas enregistré comme preuve.

Points ouverts : la version de l'ICR à utiliser (le fichier ATIH 2021 est cité par les analyses de DIM-code) et la part d'actes sans ICR par année (90,9 % d'interventions entièrement couvertes en 2023 et 79,2 % en 2026 selon DIM-code) ne sont établies par aucune preuve de ce dépôt : à mesurer avec le fichier ATIH ; la lecture d'un ICR par un compte qui aurait le droit sur PMSI_CCAM_ICR ; si la table existe dans un schéma non visible.
