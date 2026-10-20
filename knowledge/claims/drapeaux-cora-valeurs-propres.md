---
review: unreviewed
id: drapeaux-cora-valeurs-propres
kind: empirical
author: Pierre
statement: "Dans CORA, chaque drapeau a sa propre convention : 'O' ou 'N' ou vide pour la plupart (jamais '1'), 'X' ou vide pour ETAT et DP_MVT_RETENU, 'N' ou vide pour FLAG_MVT_SITE depuis 2018 : lire un GROUP BY avant de filtrer un drapeau, traiter le vide à part, et ne pas chercher avec 'O' un drapeau de TB_UNITE qui n'a jamais cette valeur (AMBULATOIRE, EXT_MED_TECH, UHCD)."
scope: "CORA de production (CWPROD, schéma CORA_REC), drapeaux de TB_DET_ACTE (tout l'historique), de TB_MVT (mouvements commencés de 2018 à octobre 2026), de TB_SYNTH_RUM (tout l'historique), de TB_UNITE et de TB_SITE (tous les enregistrements), lus le 2026-10-19 (TB_UNITE et TB_SITE : le 2026-10-20)"
refuted_if: "un GROUP BY de TB_MVT.FLAG_MVT_SITE sur les mouvements commencés depuis 2018 sort une valeur autre que 'N' ou vide, ou un GROUP BY de TB_DET_ACTE.FACTURABLE, TB_DET_ACTE.ETAT, TB_SYNTH_RUM.DP_MVT_RETENU ou d'un drapeau de TB_UNITE ou de TB_SITE sort une valeur autre que celles du tableau, ou TB_UNITE.AMBULATOIRE, EXT_MED_TECH ou UHCD sort 'O'"
maturity: observed
lifecycle: active
terms: [cora:acte, cora:mouvement, cora:rss, cora:uf]
tables: [cora:TB_DET_ACTE, cora:TB_MVT, cora:TB_SYNTH_RUM, cora:TB_UNITE, cora:TB_SITE]
supported_by: [20261019-drapeaux-activite-resultat, 20261019-drapeaux-referentiels-2-resultat, 20261019-catalogue-types-colonnes-g3-resultat]
depends_on: []
---
## Pour s'en servir

Avant tout filtre sur un drapeau, lancer `SELECT TRIM(drapeau), COUNT(*) FROM table GROUP BY TRIM(drapeau)` et filtrer sur la valeur lue. Valeurs observées :

| Table | Drapeau | Valeurs |
|---|---|---|
| TB_DET_ACTE | FACTURABLE, ACTE_GRATUIT, POUR_MEMOIRE | O, N, vide |
| TB_DET_ACTE | ETAT | X, vide (le dictionnaire dit « X : activité non réalisée ») |
| TB_MVT | BLOCAGE_RSS | O, N, vide |
| TB_MVT | FLAG_MVT_SITE | N, vide : jamais O ni X |
| TB_SYNTH_RUM | DP_MVT_RETENU | X, vide (le dictionnaire dit « X : diagnostic du RUM retenu comme DP du RSS ») |
| TB_UNITE | ACTIF, EXTERNE, GESTION_PMSI, HJ, REA, SEANCE, UM, URGENCE | O, N |
| TB_UNITE | UF | O seulement, sur toutes les lignes |
| TB_UNITE | AMBULATOIRE, EXT_MED_TECH, UHCD | N, vide : jamais O |
| TB_SITE | ACTIF | O, N |
| TB_SITE | BLOC, LIEU_REAL_ACTE | O, N, vide |

- **Le vide est une valeur :** il pèse jusqu'à un quart des lignes (DP_MVT_RETENU : 636 478 RUM sur 2 494 650, soit 25,5 % ; POUR_MEMOIRE : 1 592 509 lignes sur 6 980 651, soit 22,8 %). `= 'N'`, `<> 'N'` et `= 'O'` l'écartent tous trois : écrire `NVL(TRIM(x), 'N')` ou `x IS NULL` selon la lecture voulue, et la dire. Le dictionnaire donne FACTURABLE vide pour 'O' et ACTE_GRATUIT vide pour 'N' : non vérifié.
- **FLAG_MVT_SITE :** ne pas chercher les mouvements de plateau technique avec ce drapeau depuis 2018 : un filtre sur 'O' ou 'X' ne retient rien.
- **Drapeaux de TB_UNITE :** pour repérer des unités d'urgence, de réanimation, d'hospitalisation de jour ou soumises au PMSI, filtrer URGENCE, REA, HJ ou GESTION_PMSI sur 'O' : ces valeurs existent. Un filtre `AMBULATOIRE = 'O'`, `EXT_MED_TECH = 'O'` ou `UHCD = 'O'` ne retient aucune unité : repérer l'ambulatoire et l'UHCD autrement. `UF = 'O'` vaut pour toutes les lignes (le dictionnaire 2020 marque UF et UM « NE PLUS UTILISER OBSOLETE », d'après la mise en page de TB_UNITE.txt) : il ne distingue pas les unités ; UM sépare des lignes (711 'O', 127 'N'). Un `ACTIF = 'N'` écarte les unités fermées (204 lignes sur 838) : dire si on les garde.
- **Drapeaux de TB_SITE :** BLOC = 'O' marque les sites de bloc opératoire (le dictionnaire : « ce site est un bloc opératoire ») ; la valeur vide existe (moins de 10 lignes pour BLOC et pour LIEU_REAL_ACTE), à traiter à part.

## Ce qui l'appuie

Valeurs distinctes et effectifs des drapeaux d'activité (20261019-drapeaux-activite-resultat ; les lignes à moins de 10 sortent en <10, aucune n'est sortie ; chaque pourcentage est calculé sur le nombre de lignes de la table donné entre parenthèses) :

- **TB_DET_ACTE** (6 980 651 lignes) : FACTURABLE N 3 767 825 (54,0 %), O 2 230 171 (31,9 %), vide 982 655 (14,1 %) ; ACTE_GRATUIT N 5 938 087, O 59 909 (0,9 %), vide 982 655 ; POUR_MEMOIRE N 5 383 906, O 4 236, vide 1 592 509 (22,8 %) ; ETAT vide 6 975 463, X 5 188.
- **TB_MVT** (8 207 039 mouvements commencés depuis 2018) : BLOCAGE_RSS N 7 531 688, O 668 996 (8,2 %), vide 6 355 ; FLAG_MVT_SITE N 8 207 003, vide 36.
- **TB_SYNTH_RUM** (2 494 650 RUM) : DP_MVT_RETENU X 1 858 172 (74,5 %), vide 636 478.

Valeurs des référentiels (20261019-drapeaux-referentiels-2-resultat, une ligne par unité ou par site, comptage exact sans masquage ; les « vide » sont ceux de TRIM) :

- **TB_UNITE** (838 lignes ; chaque drapeau y est lu sur les 838) : ACTIF N 204, O 634 ; AMBULATOIRE N 811, vide 27 ; EXTERNE N 295, O 543 ; EXT_MED_TECH N 811, vide 27 ; GESTION_PMSI N 599, O 239 ; HJ N 755, O 83 ; REA N 821, O 17 ; SEANCE N 835, O moins de 10 ; UF O 838 ; UHCD N 813, vide 25 ; UM N 127, O 711 ; URGENCE N 825, O 13.
- **TB_SITE** (796 lignes) : ACTIF N 192, O 604 ; BLOC N 611, O 183, vide moins de 10 ; LIEU_REAL_ACTE N moins de 10, O 787, vide moins de 10.

Aucun de ces drapeaux ne porte 'X' ni '1' : la convention 'O'/'N' vaut pour tous les drapeaux des deux référentiels, et 'X' reste propre à ETAT et à DP_MVT_RETENU.

Catalogue (20261019-catalogue-types-colonnes-g3-resultat) : ces drapeaux sont de type CHAR(1) pour FACTURABLE, ACTE_GRATUIT, POUR_MEMOIRE, BLOCAGE_RSS et DP_MVT_RETENU, et VARCHAR2(1) pour ETAT, FLAG_MVT_SITE, et les drapeaux de TB_SITE (ACTIF, BLOC, LIEU_REAL_ACTE) et de TB_UNITE.

Les effectifs de TB_MVT et TB_DET_ACTE couvrent des périodes différentes (voir scope) : ne pas les rapprocher.

Points ouverts : le sens des lignes à drapeau vide (TB_DET_ACTE, TB_MVT, TB_UNITE, TB_SITE) ; ce qui distingue les 27 unités à AMBULATOIRE et EXT_MED_TECH vides et les 25 à UHCD vide (non lu : même ensemble ou non) ; pourquoi aucune unité n'a AMBULATOIRE, EXT_MED_TECH ou UHCD à 'O' (drapeaux inutilisés, ou remplacés par un autre repère) ; FLAG_MVT_SITE avant 2018 ; une répartition par année de FACTURABLE (elle change fortement : voir acte-non-facturable-montant-non-nul) ; la lecture de la mise en page du dictionnaire pour UF et UM (« obsolète ») n'est pas confirmée par une personne.
