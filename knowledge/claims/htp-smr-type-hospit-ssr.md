---
review: unreviewed
id: htp-smr-type-hospit-ssr
kind: empirical
author: Pierre
statement: "Dans CORA, les RHS de HTP SMR se repèrent par TB_MVT_SSR_SEM.TYPE_HOSPIT_SSR = 2 (1 = hospitalisation complète) ; TYPE_ACTIVITE, que le dictionnaire décrit comme 'SEM' ou 'HDJ', est vide pour tous les RHS de 2025."
scope: "CORA de production (CWPROD, schéma CORA_REC), RHS de TB_MVT_SSR_SEM dont la semaine débute en 2025 (DATE_DEBUT_SEM), lus le 2026-10-20"
refuted_if: "en 2025, un RHS de TYPE_HOSPIT_SSR = 2 porte un GME d'hospitalisation complète (5e caractère S, T ou U), ou TYPE_ACTIVITE est renseigné pour au moins 10 RHS"
maturity: observed
lifecycle: active
terms: [cora:rhs, pmsi:htp]
tables: [cora:TB_MVT_SSR_SEM]
supported_by: [20261020-rhs-htp-colonnes-2025-resultat, 20261020-rhs-htp-gn-gr-montants-2025-resultat, 20261020-patients-htp-2025-2-resultat]
depends_on: []
---
## Pour s'en servir

Pour la HTP, filtrer `TB_MVT_SSR_SEM.TYPE_HOSPIT_SSR = 2` ; ne pas filtrer sur `TYPE_ACTIVITE`, qui ne ramène rien. Les valeurs 6 (hospitalisation de jour en rééducation) et 3, 4, 7, 8 du dictionnaire ne sont pas utilisées en 2025. Vérifier la valeur sur une autre année avant de la reprendre.

## Ce qui l'appuie

En 2025, TB_MVT_SSR_SEM compte 15 010 RHS de TYPE_HOSPIT_SSR = 1 et 2 750 de TYPE_HOSPIT_SSR = 2, et aucune autre valeur (20261020-rhs-htp-colonnes-2025-resultat). TYPE_ACTIVITE est vide dans les deux lignes. Les 2 750 RHS de type 2 portent tous un GME dont le 5e caractère est I, J, K ou L, c'est-à-dire un groupe de réadaptation de HTP (20261020-rhs-htp-gn-gr-montants-2025-resultat), et ils concernent 158 patients, le nombre attendu par Pierre pour la HTP (20261020-patients-htp-2025-2-resultat).

Points ouverts : les autres années ne sont pas lues ; TYPE_HOSPIT_SSR = 2 est « hospitalisation de jour en soins de suite médicalisés » dans le dictionnaire, rien ne prouve ici qu'il ne couvre pas aussi une activité de rééducation.
