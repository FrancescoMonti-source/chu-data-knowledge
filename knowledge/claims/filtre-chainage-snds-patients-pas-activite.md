---
review: unreviewed
id: filtre-chainage-snds-patients-pas-activite
kind: documentary
author: Pierre
statement: "Dans le PMSI du SNDS, ne pas appliquer d'office le filtre des codes retour du chaînage (tous à '0' dans la table C), même si la fiche « Synthèse des filtres » du HDH le présente sans condition : au cadrage de toute étude SNDS, demander à la personne si l'on garde ou exclut les séjours à chaînage invalide, en lui disant ce qu'ils sont et les biais de chaque choix ; en pratique, compter des séjours, c'est les garder, et reconstruire des parcours de soins ou chaîner avec la ville (DCIR, IR_BEN_R), c'est les exclure."
scope: "PMSI MCO, SMR, HAD et RIM-P du SNDS, documentation HDH (commit 3d60148, 2026-11-02) et guide SpF de juillet 2024"
maturity: documented
lifecycle: active
terms: [snds:chainage-invalide, snds:table-pmsi-annuelle]
tables: [snds:T_MCOaaC, snds:T_MCOaaB]
supported_by: [20261120-hdh-synthese-filtres-chainage-mco, 20261120-hdh-filtre-chainage-pas-pour-activite, 20261120-hdh-essentiel-chainage-pas-si-comptage, 20261120-spf-codes-retour-pas-si-comptage, 20261120-hdh-ame-codes-retour]
depends_on: []
---
## Pour s'en servir

Au cadrage (frame) d'une étude SNDS, avant d'écrire le filtre, poser la question à la personne et lui donner trois choses :

- **Ce que sont ces séjours :** environ 1 % des séjours MCO depuis 2020, surtout des patients sans NIR exploitable (NIR_RET = 1 ou 2 : AME, NIR provisoire, résidents à l'étranger ou à Mayotte), plus des séjours sans identifiant transmis et des incohérences de date de naissance ou de sexe (chainage-invalide-mco-snds-inegal-selon-etablissement, nir-ret-1-2-hors-referentiel-beneficiaires).
- **Les biais de chaque choix :** les garder fait compter des séjours qu'on ne peut rattacher à aucun patient ni au DCIR ; les exclure retire inégalement des établissements, des territoires (étranger, Mayotte, Île-de-France) et des âges (18-44 ans), et, pour les seuls échecs de cohérence, des patients qu'on aurait pu chaîner.
- **La règle pratique :** compter des séjours, des actes, l'activité d'un établissement ou d'une région, c'est les garder (les comptes restent comparables à l'ATIH, à la DGOS, à ScanSanté) ; compter des personnes, reconstruire des parcours de soins (réadmission, décès), chaîner avec la ville (DCIR, IR_BEN_R) ou relier la mère à l'enfant, c'est les exclure. Les COH_* n'existent que depuis 2013, DAT_RET depuis 2006.

Une étude qui fait les deux compte l'activité sur tous les séjours, puis restreint aux chaînages valides pour la partie patients, en donnant le nombre de séjours retirés. Le choix de la personne s'écrit dans les conventions de l'étude.

## Ce qui l'appuie

La fiche « Synthèse des filtres SNDS » du HDH liste le filtre parmi ceux qu'il est « recommandé » d'appliquer aux séjours MCO, sans condition (20261120-hdh-synthese-filtres-chainage-mco). Trois autres passages le restreignent au chaînage des patients : la formation HDH (« ce filtre n'est pas nécessaire pour étudier l'activité des ES », 20261120-hdh-filtre-chainage-pas-pour-activite), l'essentiel du SNDS (« à mettre si chaînage de patients mais pas si comptage de séjours », 20261120-hdh-essentiel-chainage-pas-si-comptage) et le guide de Santé publique France (20261120-spf-codes-retour-pas-si-comptage). La fiche AME du HDH précise que le filtre exclut les bénéficiaires de l'AME, dont le NIR est provisoire (20261120-hdh-ame-codes-retour).

Dans l'étude CHIP de DIM-code (#56), les comptes de séjours sans ce filtre retombent exactement sur ceux de la DGOS, ce qui va dans le même sens. Demander plutôt qu'appliquer une règle : choix de Pierre à la relecture de la PR #149 (2026-11-20).

Points ouverts : le sens officiel de chaque valeur des codes retour (1, 2, 3, 9) n'est pas lu ; la note de l'ATIH sur le chaînage n'a pas pu être téléchargée.
