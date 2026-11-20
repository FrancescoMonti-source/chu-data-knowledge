---
review: unreviewed
id: tables-snds-vues-profil-108
kind: empirical
author: Pierre
statement: "Sur le portail (profil 108), les tables du SNDS sont des vues du schéma PROFIL_108, lisibles sans préfixe par des synonymes privés de l'utilisateur ; ces synonymes manquent ou ne se résolvent pas pour le PMSI de 2006, le PMSI MCO de 2025 (T_MCO25B, T_MCO25C), les lots de 2026 et une douzaine de vues : préfixer toutes les tables PMSI par PROFIL_108. (PROFIL_108.T_MCO25B se lit)."
scope: "portail SNDS de la Cnam, base IPIAMPR2, profil 108, catalogue et lectures du 2026-11-04"
refuted_if: "les synonymes de l'utilisateur couvrent les tables PMSI de 2006 (T_MCO06B…), ou une requête sur T_MCO06B ou T_MCO25C sans préfixe aboutit"
maturity: observed
lifecycle: active
terms: [snds:portail, snds:profil-108, snds:table-pmsi-annuelle]
tables: [snds:T_MCOaaB, snds:ER_PRS_F, snds:IR_BEN_R]
supported_by: [20261104-snds-familles-tables-resultat, 20261104-snds-lecture-pmsi-2006-resultat, 20261104-acces-r-oravue, 20261104-snds-profondeur-mco-deces-v2-resultat]
depends_on: []
---
## Pour s'en servir

Pour le PMSI de 2006, celui de 2025, les lots de 2026 et les vues T_HADaaGJ, T_MCOaaGV10 et T_RIPaa_01IUM_CTL à T_RIPaa_10IUM_CTL, préfixer le nom par le schéma : `PROFIL_108.T_MCO06B`. Pour les années 2007 à 2024 et les référentiels, le nom seul suffit (`ER_PRS_F`, `T_MCO23B`, `IR_BEN_R`). Une requête qui balaie plusieurs années peut préfixer partout, ce qui marche dans tous les cas. Ne pas chercher les tables dans ORAVUE : pour ce profil, elles n'y sont pas.

## Ce qui l'appuie

Dans le catalogue du 4 novembre 2026 (20261104-snds-familles-tables-resultat), les familles de tables du schéma du HDH sont des vues de PROFIL_108 (1696 familles) et des synonymes privés de l'utilisateur (1684, propriétaire noté UTILISATEUR dans la preuve). Pour 23 familles du PMSI, PROFIL_108 a 20 vues de 2006 à 2025, et les synonymes n'en ont que 19, de 2007 à 2025. Quatre autres familles perdent aussi leur année 2006. Douze vues de PROFIL_108 n'ont aucun synonyme : T_HADaaGJ, T_MCOaaGV10, T_RIPaa_01IUM_CTL à T_RIPaa_10IUM_CTL. Aucun synonyme ne pointe vers une vue absente. La note d'accès à R de la Cnam situe les tables de l'accès permanent dans ORAVUE (20261104-acces-r-oravue) ; aucun objet de ce schéma n'apparaît parmi les familles cherchées.

Le même jour, PROFIL_108.T_MCO06B se lit : la requête 20261104-snds-lecture-pmsi-2006 en ramène 1000 lignes (son plafond), comme T_MCO07B par le synonyme (20261104-snds-lecture-pmsi-2006-resultat).

Le script 20261104-snds-profondeur-mco-deces-v2 lit chaque table par son synonyme, puis par PROFIL_108. si cela échoue (un ORA-00980 avait arrêté la première version, en SQL). Résultat (20261104-snds-profondeur-mco-deces-v2-resultat) : T_MCO20C à T_MCO24C se lisent par leur synonyme ; T_MCO25C, T_MCO25B et les lots T_MCO26_01C à 05C ne se lisent que par PROFIL_108. ; IR_BEN_R se lit par son synonyme. Les noms T_MCO25B et T_MCO26_01B à 05B figurent pourtant dans ALL_OBJECTS.

Points ouverts : l'échec de T_MCO06B sans préfixe est déduit de l'absence de synonyme, pas observé. Seule T_MCO06B a été lue parmi les vues sans synonyme. Le catalogue peut changer quand la Cnam charge une nouvelle année.
