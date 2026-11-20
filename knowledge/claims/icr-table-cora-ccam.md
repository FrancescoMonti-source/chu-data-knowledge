---
review: unreviewed
id: icr-table-cora-ccam
kind: empirical
author: Pierre
supersedes: [icr-sans-table-cora]
statement: "Dans CORA de production, l'ICR d'un acte CCAM est dans CORA_CCAM.PMSI_CCAM_ICR (synonyme CORA_REC.PMSI_CCAM_ICR), clé CODE, EXTENSION_ATIH, PHASE, ACTIVITE, valeur ICR : le compte de l'utilisateur DIM voit cette table depuis fin octobre 2026 ; écrire la requête sur elle plutôt que de joindre un fichier ATIH, après un comptage direct qui confirme qu'elle se lit et qu'ICR est renseigné."
scope: "CORA de production (CWPROD), catalogue Oracle lu avec le compte de l'utilisateur DIM le 2026-10-26 (la table n'y figurait pas le 2026-10-19) ; contenu de la table non lu"
refuted_if: "SELECT COUNT(*) FROM CORA_REC.PMSI_CCAM_ICR donne ORA-00942, ou 0 ligne, ou la colonne ICR est vide ou constante"
maturity: observed
lifecycle: active
terms: [cora:acte]
tables: [cora:PMSI_CCAM_ICR]
supported_by: [20261026-schemas-objets-resultat, 20261026-schemas-candidats-colonnes-resultat]
depends_on: []
---
## Pour s'en servir

Pour l'ICR d'un acte, lire PMSI_CCAM_ICR par le code de l'acte (CODE, CHAR(7)), avec EXTENSION_ATIH (CHAR(2)), PHASE et ACTIVITE : la clé n'est probablement pas le seul CODE, et une jointure sur CODE seul peut dupliquer les actes. Avant la première utilisation, lancer un comptage direct (`SELECT COUNT(*), COUNT(ICR), COUNT(DISTINCT CODE) FROM CORA_REC.PMSI_CCAM_ICR`) et compter les clés dupliquées. Dire quelle version de l'ICR la table contient : elle n'est pas connue (DATE de chargement absente des colonnes).

Si le comptage échoue (ORA-00942) ou revient vide, revenir au fichier ATIH des ICR de la CCAM descriptive à usage PMSI, joint par code d'acte, et le dire.

## Ce qui l'appuie

Le catalogue du 2026-10-19 ne montrait aucun objet ICR (20261019-catalogue-objets-g3-resultat) : seuls CORA_REC, INTEG et ZEXPLOIT étaient visibles. Le catalogue du 2026-10-26, après l'ajout des schémas CORA (20261026-schemas-objets-resultat), montre CORA_CCAM.PMSI_CCAM_ICR (table, environ 29 800 lignes d'après les statistiques Oracle, analysée le 2026-10-25) et son synonyme CORA_REC.PMSI_CCAM_ICR. Colonnes : CODE, EXTENSION_ATIH, PHASE, ACTIVITE, ACTIVITE_LIBERALE, ICR (20261026-schemas-candidats-colonnes-resultat). Cela explique l'ORA-00942 du 2026-10-19 : la table était hors de la vue du compte.

Points ouverts : la table n'est pas lue ; sa version de l'ICR, sa couverture des codes d'actes de CORA et la clé exacte restent à mesurer ; ce que la table dit de l'ICR n'est pas confronté au fichier ATIH.
