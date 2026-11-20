---
review: unreviewed
id: filtre-chainage-snds-patients-pas-activite
kind: documentary
author: Pierre
statement: "Dans le PMSI du SNDS, n'appliquer le filtre des codes retour du chaînage (tous à '0' dans la table C) que pour suivre ou compter des patients (NIR_ANO_17, BEN_IDT_ANO, chaînage entre PMSI ou avec le DCIR, mère-enfant) ; pour compter des séjours ou de l'activité, garder les séjours à chaînage invalide, même si la fiche « Synthèse des filtres » du HDH présente ce filtre sans condition."
scope: "PMSI MCO, SMR, HAD et RIM-P du SNDS, documentation HDH (commit 3d60148, 2026-11-02) et guide SpF de juillet 2024"
maturity: documented
lifecycle: active
terms: [snds:chainage-invalide, snds:table-pmsi-annuelle]
tables: [snds:T_MCOaaC, snds:T_MCOaaB]
supported_by: [20261120-hdh-synthese-filtres-chainage-mco, 20261120-hdh-filtre-chainage-pas-pour-activite, 20261120-hdh-essentiel-chainage-pas-si-comptage, 20261120-spf-codes-retour-pas-si-comptage, 20261120-hdh-ame-codes-retour]
depends_on: []
---
## Pour s'en servir

Avant d'écrire le filtre, regarder l'unité de l'analyse :

- **Séjours, actes, activité d'un établissement ou d'une région :** ne pas filtrer sur les codes retour. Les comptes restent comparables aux chiffres publiés (ATIH, DGOS, ScanSanté).
- **Patients :** dès qu'on compte des personnes, qu'on suit un patient d'un séjour à l'autre (réadmission, décès, parcours), qu'on joint au DCIR ou au référentiel IR_BEN_R, ou qu'on relie la mère à l'enfant, garder seulement les séjours dont tous les codes retour sont à '0'. Les COH_* n'existent que depuis 2013, DAT_RET depuis 2006.
- **Une étude qui fait les deux :** compter l'activité sur tous les séjours, puis restreindre aux chaînages valides pour la partie patients, et donner le nombre de séjours retirés. Ce filtre retire de fait les patients en AME ou à NIR provisoire : le dire si la population étudiée en compte.

## Ce qui l'appuie

La fiche « Synthèse des filtres SNDS » du HDH liste le filtre parmi ceux qu'il est « recommandé » d'appliquer aux séjours MCO, sans condition (20261120-hdh-synthese-filtres-chainage-mco). Trois autres passages le restreignent au chaînage des patients : la formation HDH (« ce filtre n'est pas nécessaire pour étudier l'activité des ES », 20261120-hdh-filtre-chainage-pas-pour-activite), l'essentiel du SNDS (« à mettre si chaînage de patients mais pas si comptage de séjours », 20261120-hdh-essentiel-chainage-pas-si-comptage) et le guide de Santé publique France (20261120-spf-codes-retour-pas-si-comptage). La fiche AME du HDH précise que le filtre exclut les bénéficiaires de l'AME, dont le NIR est provisoire (20261120-hdh-ame-codes-retour).

Dans l'étude CHIP de DIM-code (#56), les comptes de séjours sans ce filtre retombent exactement sur ceux de la DGOS, ce qui va dans le même sens.

Points ouverts : le sens officiel de chaque valeur des codes retour (1, 2, 3, 9) n'est pas lu ; la note de l'ATIH sur le chaînage n'a pas pu être téléchargée.
