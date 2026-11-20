# Quels schémas de CWPROD portent la structure de l'établissement et les référentiels (ICR) ?

Personne : Pierre
Issue : #109

## Cadrage
- **But :** savoir où chercher, dans les schémas CORA que l'utilisateur DIM voit désormais sur CWPROD, les tables de structure de l'établissement (UF, UM, services, pôles, historique de rattachement) et les référentiels qui manquent, l'ICR en premier. L'enquête cartographie ; elle ne lit aucun contenu de table.
- **Ce que CDK sait déjà :** les structures de CORA_REC (TB_UNITE, TB_UNITE_MEDICALE, liens UF-UM et UM-pôle : enquête #108) ; l'absence d'ICR dans CORA_REC pour le compte de l'utilisateur DIM (claim icr-sans-table-cora, catalogue du 2026-10-19). Seul CORA_REC, INTEG et ZEXPLOIT étaient visibles le 2026-10-14.
- **Population et unité :** des objets du catalogue Oracle (schémas, tables, vues, colonnes) ; aucune personne.
- **Masquage :** sans objet, le catalogue ne contient pas de données de personne (no-person-data).
- **Limite :** le catalogue ne montre que ce que le compte peut lire ; NUM_ROWS vient des statistiques Oracle et peut être ancien ou absent.
- **Branche :** claude/project-thread-twadlg, imposée par la session, au lieu de investigation/schemas-cora.

## Choix
- **Trois requêtes .sql de catalogue, exécutées par executer_requetes_cdk.py de DIM-code :** une table de résultat chacune, sans script dédié ; le catalogue suffit.
- **Candidats repérés par le nom d'objet et par quelques noms de colonnes clés** (liste dans l'en-tête de 20261026-schemas-candidats-colonnes) : un filtre large vaut mieux qu'un objet manqué, la lecture écarte le bruit.

## Suite (2026-10-27)
Pierre veut savoir s'il faut prendre la structure (services, pôles, spécialités) dans CORA ou dans le fichier Structure. Les tables de CORA_REC vues par l'inventaire mais jamais comparées au fichier (TB_HIST_UNITE, TB_HIST_UNITE_M_UNITE) sont mesurées par 20261027-structure-historique-cora.py : UF fermées et hors fichier, rattachement UF-UM dans le temps, UM contre service du fichier. La spécialité n'a pas de colonne dans le fichier (sources/structure-chu-2026-10-09.md) ; côté CORA, TB_UNITE porte TYPE_ACTIVITE (thésaurus TB_THES_TYPE_ACTIVITE) : à mesurer ensuite si Pierre en a besoin.

## Conclusions
Résultats reçus le 2026-10-26 (catalogue) et le 2026-11-03 (historique). Claims (tous unreviewed) :
- schemas-cwprod-visibles : 8 schémas sur 93 ont des objets visibles ; les référentiels de codage sont dans CORA_CCAM, la structure seulement dans CORA_REC.
- icr-table-cora-ccam : PMSI_CCAM_ICR est visible dans CORA_CCAM ; remplace icr-sans-table-cora (superseded). Contenu non lu.
- service-d-une-um : une UM tient dans un seul service du fichier (234 UM sur 281 ont une UF dans le fichier).
- historique-rattachement-uf-um-cora : le lien UF-UM est quasi fixe ; 77 UF ont un lien sans date de début.
- Mis à jour : referentiels-pmsi-dans-cora (listes d'exclusion et CIM_HIERARCHIE désormais visibles, contenu non lu) et service-et-pole-depuis-fichier-structure (le fichier ne retire pas une UF fermée dans CORA : 68 UF inactives y restent, 136 en sont absentes).

Non établi : la spécialité (ni le fichier ni TB_UNITE n'en portent au niveau de l'UF) ; le contenu des tables vues dans CORA_CCAM ; la version du fichier avant 2026-10-09. L'enquête reste ouverte pour ces points.
