---
review: unreviewed
id: ccam-nv-une-ligne-par-code
kind: empirical
author: Pierre
statement: "Dans CORA, V_CCAM_NV porte une ligne par code d'acte (TYPE = 'A') et des lignes de menu (TYPE = 'M') à CODE vide : joindre TB_ACTE.CODE_ACTE à V_CCAM_NV.CODE ne duplique aucun acte et n'exige pas de dédoublonnage ; pour compter ou lister les codes de la vue, filtrer TYPE = 'A'."
scope: "CORA de production (CWPROD, schéma CORA_REC), vue V_CCAM_NV entière et actes de TB_ACTE datés du 2018-01-01 au 2026-10-19, lus le 2026-10-20 ; jointure mesurée sur TRIM(CODE_ACTE) = TRIM(CODE)"
refuted_if: "un code non vide de V_CCAM_NV porte plus d'une ligne (en TYPE = 'A' ou en tous types), ou la jointure de TB_ACTE.CODE_ACTE sur V_CCAM_NV.CODE (TRIM des deux côtés) donne plus de lignes que d'actes pour une année"
maturity: observed
lifecycle: active
terms: [cora:acte]
tables: [cora:V_CCAM_NV, cora:TB_ACTE]
supported_by: [20261019-ccam-nv-vue-resultat, 20261019-ccam-nv-actes-resultat]
depends_on: []
---
## Pour s'en servir

- **Pour associer un libellé à un acte :** `JOIN CORA_REC.V_CCAM_NV v ON TRIM(v.CODE) = TRIM(a.CODE_ACTE)` suffit, sans sous-requête `GROUP BY CODE` : la jointure n'ajoute aucune ligne. Elle ne perd pas non plus d'acte : tous les codes de TB_ACTE de 2018 à 2026 sont dans la vue, donc un `LEFT JOIN` n'est pas nécessaire pour les garder.
- **Pour compter ou lister les codes de la vue :** ajouter `WHERE TYPE = 'A'`. Sans ce filtre, les lignes de menu (TYPE = 'M') s'ajoutent : elles ont toutes un CODE vide et gonflent le compte de lignes d'environ 19 % (1 725 lignes en plus de 9 211).
- Vérifier malgré tout, quand une requête a un sens (libellés d'un compte d'actes), que le nombre d'actes ne change pas après la jointure.

## Ce qui l'appuie

Le dictionnaire 2020 décrit CCAM_NV comme la nomenclature CCAM « contenant aussi les menus hiérarchiques » : TYPE vaut 'A' pour un acte et 'M' pour un menu (sources/dictionnaire-cora-2020/CCAM_NV.txt). Les données précisent ce que cela donne dans la vue de production.

Vue seule (20261019-ccam-nv-vue-resultat, comptages exacts, référentiel sans donnée de personne) : 10 936 lignes. TYPE = 'A' : 9 211 lignes pour 9 211 codes distincts, au plus une ligne par code, aucun code vide. TYPE = 'M' : 1 725 lignes, toutes à CODE vide. Au total 9 212 codes distincts, dont le code vide ; un seul code porte plusieurs lignes : le code vide (1 725 lignes).

Jointure aux actes (20261019-ccam-nv-actes-resultat, par année de DATE_ACTE, 5 692 872 actes de 2018 à 2026, de 293 441 en 2018 à 831 423 en 2025) : pour chaque année, le nombre d'actes dont le code est dans la vue est égal au nombre d'actes, et le nombre de lignes qu'ajouterait une jointure directe est inférieur à 10, en tous types comme en TYPE = 'A'. Le seul code à plusieurs lignes étant le code vide, que l'égalité `TRIM(CODE_ACTE) = TRIM(CODE)` ne retrouve jamais (un vide Oracle est NULL), le nombre exact est zéro : c'est une conséquence de la forme de la jointure, la requête n'a sorti que « moins de 10 ».

Le brouillon de ce claim, repris de l'analyse DIM-code (« la vue porte plusieurs lignes par code d'acte et la jointure duplique les actes »), est contredit : il confondait les lignes de menu à code vide avec des doublons de codes d'actes.

Points ouverts : un acte sans code (CODE_ACTE vide) serait compté dans N_ACTES mais pas parmi les codes présents dans la vue : l'égalité des deux colonnes dans toutes les années dit qu'il n'y en a aucun, mais ils n'ont pas été comptés à part ; la jointure sans TRIM n'a pas été mesurée ; la vue n'a pas été lue sur ses dates de fin (DT_FIN) ni sur sa version (VERSION) : une ligne par code d'acte ne dit pas que le libellé est celui de la date de l'acte.
