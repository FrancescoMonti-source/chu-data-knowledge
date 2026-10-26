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
- **Branche :** claude/project-thread-pvrmde, imposée par la session (PR #105 « structures »), au lieu de investigation/structures.

## Choix
- **Scripts Python, un par table de résultat :** le fichier est un xlsx confidentiel gardé à l'hôpital, la requête est un script sur un fichier (method/queries.md, « Un script sur un fichier »). `sources/structures/lire_structure.py` lit le fichier en mémoire sans les colonnes de personnes ; les deux scripts l'utilisent.
- **Aucun code ni libellé du fichier en sortie :** comparer par catégories (même code et même libellé, même code seulement…) plutôt que lister les écarts.
- **Version ancienne du fichier optionnelle :** une seule version est sur le poste de Pierre ; `--ancien` compare à une autre s'il en a une, sinon l'historique du fichier reste non établi.

## Conclusions
Résultats reçus et relus le 2026-10-26. Claims (tous unreviewed) :
- code-uf-du-fichier-structure : le Code UF du fichier est un code d'UF de CORA (99,9 % des mouvements de 2022 à 2025 y sont).
- pole-du-fichier-structure-et-cora : les codes de pôle diffèrent ; CORA n'a un pôle que pour 225 des 1 187 UF ; comparer par le libellé.
- tb-unite-drapeaux-uf-um-inutilisables : les drapeaux UF et UM de TB_UNITE ne distinguent rien ; les UM sont dans TB_UNITE_MEDICALE.
- service-et-pole-depuis-fichier-structure (mis à jour) : la méthode pour donner service et pôle à un séjour ou un mouvement.

Les mesures de la vérification des colonnes d'unité du RUM (20261026-rum-um-et-uf-2025-resultat) vont à l'enquête uf-um-rum (claim uf-du-rum-hebergement) : elles confirment que ID_UNITE_MEDICALE est une UM et ID_UNITE_HEBERG une UF liée à cette UM (TB_UNITE_M_UNITE, à une date quelconque) pour les 182 312 RUM de janvier à septembre 2025, et égale à l'UF d'un de leurs mouvements pour 182 252. Aucun claim de cette enquête ne les cite : si uf-um-rum ne les reprend pas avant la fermeture, la preuve et sa requête sont supprimées (investigations/README.md, « L'issue ou le dépôt »).

## Relecture des conclusions (2026-10-26)
Chaque affirmation du fil d'enquête, contre les preuves enregistrées.

**Établi par les preuves**
- Le fichier : 1 187 UF, codes tous distincts, aucune « Date fin UF » passée (structure-fichier-vs-cora, section FICHIER).
- Le Code UF est un code d'UF : 675 sont un CODE_UNITE de TB_UNITE, et 99,9 % des mouvements 2022-2025 ont leur code dans le fichier (mouvements-hors-fichier : 1 028, 880, 714, 604).
- TB_UNITE_MEDICALE ne se confond pas avec TB_UNITE : 281 UM, dont tous les codes sont aussi des codes de TB_UNITE ; les drapeaux UF (838 sur 838) et UM (711 sur 838) n'y distinguent rien.
- Le RUM porte l'UM (ID_UNITE_MEDICALE) et l'UF (ID_UNITE_HEBERG), reliées par TB_UNITE_M_UNITE pour 100 % des RUM de janvier à septembre 2025 ; l'UF du RUM est celle d'un de ses mouvements pour 99,97 %.
- Les codes de pôle du fichier et de CORA diffèrent presque toujours (6 identiques sur 225).

**Surinterprété ou non prouvé**
1. « TB_UNITE est bien le thésaurus des UF » : le drapeau UF vaut 'O' sur toutes les lignes, y compris celles qui ont un code d'UM ; il ne prouve rien. Ce qui l'appuie est ailleurs : les mouvements et ID_UNITE_HEBERG portent des codes ou identifiants de TB_UNITE, et le dictionnaire nomme ID_UNITE_HEBERG « l'UF d'hébergement ». L'idée de Pierre (TB_UNITE contient aussi les UM) n'est ni confirmée ni réfutée : au niveau du code, les 281 UM s'y trouvent toutes.
2. « Le glossaire tient, ce qui ne tient pas c'est CODE_UNITE = UM » : trop net. Le Code UF du fichier et le CODE_UNITE de TB_UNITE sont des codes d'UF ; mais 241 des 246 UF liées à une UM le sont à une UM de même code, donc pour elles l'UF et l'UM ont le même code. Le désaccord de départ vient de là.
3. « Une UM regroupe des UF » (cadrage, claim d'origine) : rarement vrai dans les liens en cours au 2026-10-09 : 236 UM ont un seul lien, 5 en ont plusieurs, 40 aucun. Et 592 des 838 UF de TB_UNITE n'ont aucune UM en cours : le lien UF-UM ne couvre qu'une minorité des UF.
4. « Le fichier n'a que les UF ouvertes, une UF fermée disparaît » : une seule version du fichier. Aucune date de fin passée n'est cohérent avec un fichier sans UF fermées, mais la mesure ne distingue pas une date vide d'une date à venir : la colonne est peut-être jamais renseignée. Que les 163 UF de CORA hors fichier (136 inactives, 27 actives) soient des UF « disparues » n'est pas établi : elles peuvent n'y avoir jamais figuré. « Ouvert » ne coïncide pas avec ACTIF : 68 UF du fichier sont inactives dans CORA.
5. « Pôle comparé par libellé, 28 % de désaccords » : 64 sur 225 n'ont pas de libellé de pôle identique après normalisation, ce qui n'est pas un désaccord prouvé (renommage, abréviation ou réorganisation ne sont pas distingués). La comparaison ne porte que sur 225 des 1 187 UF : CORA n'a aucun pôle pour 446 des 675 UF connues de TB_UNITE, et ne connaît pas les 512 autres. « 10 pôles sur 12 correspondent » veut dire que 10 pôles du fichier mènent à un seul pôle CORA parmi ceux vus, pas qu'ils sont égaux.
6. « Le fichier contient 164 services et 32 pôles » : lu par l'agent dans le fichier, non enregistré dans une preuve du dépôt.
7. « ID_PERE ne désigne aucune ligne de TB_UNITE, aucune ligne n'a de fils » : vrai, mais 810 lignes ont un parent : ce que désigne ID_PERE n'est pas établi.
8. « ID_UNITE_HEBERG est une UF » pour 100 % des RUM : le test « TB_UNITE.ID_UNITE » ne prouve rien (les identifiants d'UM existent aussi comme identifiants d'UF, 100 %). Le test qui compte est la paire dans TB_UNITE_M_UNITE, qui n'est pas bornée dans le temps, sur neuf mois de 2025 seulement.

**Hors du fil**
- structure-chu-2026-10-09__fichier-structure.txt (copie texte du fichier, 335 Ko) est sur la branche retours-cdk de DIM-code, alors que la fiche de la source dit que le contenu reste local : décision de Pierre (le retirer de la branche ne l'enlève pas de l'historique).
