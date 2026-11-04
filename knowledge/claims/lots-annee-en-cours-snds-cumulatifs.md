---
review: unreviewed
id: lots-annee-en-cours-snds-cumulatifs
kind: empirical
author: Pierre
statement: "Sur le portail SNDS (profil 108), le PMSI MCO de l'année en cours est livré en lots cumulatifs (T_MCO26_01B à 05B, et C, A, D) : chaque lot contient les mois des lots précédents, donc lire seulement le dernier lot, jamais plusieurs : les réunir compterait les séjours plusieurs fois."
scope: "portail SNDS de la Cnam, profil 108, lots T_MCO26_01 à 05 vus le 2026-11-04, séjours du CHU de Rouen"
refuted_if: "une requête par mois de sortie sur T_MCO26_01C et T_MCO26_05C ramène des mois différents (lots disjoints), ou la somme d'un mois sur les lots ne correspond pas au double comptage"
maturity: observed
lifecycle: active
terms: [snds:portail, snds:profil-108, snds:table-pmsi-annuelle]
tables: [snds:T_MCOaaC]
supported_by: [20261104-snds-profondeur-mco-deces-v2-resultat]
depends_on: []
---
## Pour s'en servir

Pour l'année en cours, lire le dernier lot disponible (au 2026-11-04, T_MCO26_05B, T_MCO26_05C…), avec le préfixe PROFIL_108. (tables-snds-vues-profil-108). Pour savoir jusqu'où il va, compter les sorties par mois dans ce lot : le dernier mois plein est le dernier dont l'effectif est comparable aux précédents. Une table annuelle (T_MCO25B) remplace les lots quand l'année est livrée.

## Ce qui l'appuie

Les sorties du CHU par mois de sortie (20261104-snds-profondeur-mco-deces-v2-resultat) : le lot 01 compte janvier, février et mars 2026 ; le lot 02 ajoute avril ; le lot 03 mai ; le lot 04 juin ; le lot 05 juillet. Chaque lot reprend les mois précédents, avec des effectifs presque identiques (janvier : 16772, 16756, 16736, 16737, 16736 du lot 01 au lot 05). Le lot 05 donne 16653 sorties en juillet 2026, comparable aux mois pleins (14 000 à 18 000) ; le lot 04 avait 17781 sorties en juin contre 17939 dans le lot 05, soit environ 1 % de plus après un lot.

Points ouverts : l'effectif d'un mois commun baisse de quelques dizaines de séjours entre lots (36 en janvier) sans que la cause soit établie ; on ne sait pas pourquoi les séjours de mars sont déjà dans le lot 01 alors que le lot est dit couvrir « les premiers mois ». Seul le CHU de Rouen est observé.
