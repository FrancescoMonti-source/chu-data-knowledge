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
Résultats reçus le 2026-10-26 (20261026-structure-fichier-vs-cora-resultat, 20261026-structure-mouvements-hors-fichier-resultat) ; les claims restent à écrire avec Pierre (étape 5 du plan, #108).
- Le Code UF du fichier est un CODE_UNITE de TB_UNITE pour 675 des 1 187 UF ; 235 sont aussi un CODE_UNITE_MED, avec le même libellé pour 220 ; 512 ne sont dans aucune des deux tables.
- Dans CORA, 241 des 246 UF liées à une UM l'ont avec une UM de même code : au niveau du code, UF et UM ne se distinguent pas pour ces UF.
- Le pôle du fichier a le libellé du pôle de CORA pour 161 des 225 UF qui ont un pôle dans CORA, avec un autre code ; 64 diffèrent par le code et le libellé.
- Aucune UF du fichier n'a de date de fin passée : le fichier ne garde pas les UF fermées. Une seule version du fichier : son historique n'est pas établi.
- Mouvements 2022-2025 hors fichier : 1 028, 880, 714 et 604 par an, sur plus de 900 000.

Vérification des colonnes d'unité (2026-10-26, 20261026-tb-unite-drapeaux-uf-um-resultat, 20261026-rum-um-et-uf-2025-resultat) :
- Les 838 lignes de TB_UNITE ont le drapeau UF à O ; 711 ont aussi le drapeau UM à O, alors que TB_UNITE_MEDICALE n'a que 281 UM : le drapeau UM ne repère pas les UM. Aucune ligne n'a de fils (ID_PERE ne désigne aucun TB_UNITE.ID_UNITE).
- RUM de janvier à septembre 2025 (182 312) : ID_UNITE_MEDICALE est une UM pour tous ; ID_UNITE_HEBERG est une UF reliée à cette UM par TB_UNITE_M_UNITE pour tous, et égale à l'UF d'un de ses mouvements pour 182 252. Les tests croisés par identifiant (ID_UNITE_MEDICALE comme TB_UNITE.ID_UNITE : 100 % ; ID_UNITE_HEBERG comme ID_UNITE_MED : 33 %) ne distinguent rien : les numéros se recouvrent.
