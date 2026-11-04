---
review: unreviewed
id: tables-snds-vues-profil-108
kind: empirical
author: Pierre
statement: "Sur le portail (profil 108), les tables du SNDS sont des vues du schéma PROFIL_108, lisibles sans préfixe par des synonymes privés de l'utilisateur ; ces synonymes manquent pour le PMSI de 2006 et pour une douzaine de vues : une requête sur T_MCO06B sans préfixe échoue, il faut écrire PROFIL_108.T_MCO06B."
scope: "portail SNDS de la Cnam, base IPIAMPR2, profil 108, catalogue du 2026-11-04"
refuted_if: "les synonymes de l'utilisateur couvrent les tables PMSI de 2006 (T_MCO06B…), ou une requête sur T_MCO06B sans préfixe aboutit"
maturity: observed
lifecycle: active
terms: [snds:portail, snds:profil-108, snds:table-pmsi-annuelle]
tables: [snds:T_MCOaaB, snds:ER_PRS_F, snds:IR_BEN_R]
supported_by: [20261104-snds-familles-tables-resultat, 20261104-acces-r-oravue]
depends_on: []
---
## Pour s'en servir

Pour le PMSI de 2006 et les vues T_HADaaGJ, T_MCOaaGV10 et T_RIPaa_01IUM_CTL à T_RIPaa_10IUM_CTL, préfixer le nom par le schéma : `PROFIL_108.T_MCO06B`. Pour les autres tables, le nom seul suffit (`ER_PRS_F`, `T_MCO23B`). Une requête qui balaie plusieurs années peut préfixer partout, ce qui marche dans tous les cas. Ne pas chercher les tables dans ORAVUE : pour ce profil, elles n'y sont pas.

## Ce qui l'appuie

Dans le catalogue du 4 novembre 2026 (20261104-snds-familles-tables-resultat), les familles de tables du schéma du HDH sont des vues de PROFIL_108 (1696 familles) et des synonymes privés de l'utilisateur (1684, propriétaire noté UTILISATEUR dans la preuve). Pour 23 familles du PMSI, PROFIL_108 a 20 vues de 2006 à 2025, et les synonymes n'en ont que 19, de 2007 à 2025. Quatre autres familles perdent aussi leur année 2006. Douze vues de PROFIL_108 n'ont aucun synonyme : T_HADaaGJ, T_MCOaaGV10, T_RIPaa_01IUM_CTL à T_RIPaa_10IUM_CTL. Aucun synonyme ne pointe vers une vue absente. La note d'accès à R de la Cnam situe les tables de l'accès permanent dans ORAVUE (20261104-acces-r-oravue) ; aucun objet de ce schéma n'apparaît parmi les familles cherchées.

Points ouverts : la requête montre que les vues de 2006 sont visibles, pas qu'elles se lisent ; une lecture de PROFIL_108.T_MCO06B reste à faire. Le catalogue peut changer quand la Cnam charge une nouvelle année.
