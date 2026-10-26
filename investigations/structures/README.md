# Le fichier Structure et CORA décrivent-ils les mêmes UF, UM et pôles ?

Personne : Pierre
Issue : #108

## Cadrage
- **But :** pouvoir donner, pour un séjour ou un mouvement de CORA, le service et le pôle du fichier Structure (claim `service-et-pole-depuis-fichier-structure`), en sachant à quoi son Code UF correspond dans CORA. L'enquête ne produit pas d'étude : elle clôt les points ouverts de ce claim.
- **Sources :** le fichier Structure (sources/structure-chu-2026-10-09.md, local, jamais dans le dépôt) et les référentiels de CORA (TB_UNITE, TB_UNITE_MEDICALE, TB_UNITE_M_UNITE, TB_UNITE_POLE_UM, TB_UNITE_POLE) ; pour l'activité, TB_MVT. Pierre exécute à l'hôpital.
- **Questions :** (1) le Code UF est-il un CODE_UNITE de TB_UNITE ou un CODE_UNITE_MED de TB_UNITE_MEDICALE ? (2) le pôle du fichier est-il celui de CORA ? (3) le fichier garde-t-il l'historique, et que devient une UF fermée ? (4) quelle part de l'activité tombe hors du fichier ?
- **Le désaccord de départ :** le glossaire cora appelle UF le CODE_UNITE de TB_UNITE ; Pierre pense que c'est l'UM. Ce que l'on sait : une UM regroupe des UF par un lien daté (TB_UNITE_M_UNITE), et un tiers des codes de mouvement sont aussi des codes d'UM (joindre-uf-par-code). La requête mesure les deux tables contre le fichier ; la définition se tranche avec Pierre une fois les preuves reçues, pas avant.
- **Population et unité :** les codes (UF, UM, pôles), pas les personnes ; sauf l'étape 4, qui compte des mouvements commencés de 2022 à 2025.
- **Date de référence :** celle du nom du fichier (2026-10-09) pour les liens datés « en cours ».
- **Masquage :** l'étape 4 masque tout effectif de 1 à 9. Les étapes 1 à 3 ne comptent que des codes de référentiels et n'écrivent ni code ni libellé du fichier (contenu local, choix de Pierre) : un comptage par catégorie.
- **Branche :** claude/project-thread-27yyyx, imposée par la session (PR #105 « structures »), au lieu de investigation/structures.

## Choix
- **Scripts Python, un par table de résultat :** le fichier est un xlsx confidentiel gardé à l'hôpital, la requête est un script sur un fichier (method/queries.md, « Un script sur un fichier »). `sources/structures/lire_structure.py` lit le fichier en mémoire sans les colonnes de personnes ; les deux scripts l'utilisent.
- **Aucun code ni libellé du fichier en sortie :** comparer par catégories (même code et même libellé, même code seulement…) plutôt que lister les écarts.
- **Version ancienne du fichier optionnelle :** une seule version est sur le poste de Pierre ; `--ancien` compare à une autre s'il en a une, sinon l'historique du fichier reste non établi.

## Conclusions
En attente des résultats (étapes 1 à 4 du plan, #108).
