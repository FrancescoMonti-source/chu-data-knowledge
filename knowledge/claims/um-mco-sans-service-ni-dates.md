---
review: unreviewed
id: um-mco-sans-service-ni-dates
kind: documentary
author: Pierre
statement: "Le SNDS a bien des RUM pour le MCO (T_MCOaaUM, une ligne par RUM, jointe à T_MCOaaB sur ETA_NUM et RSA_NUM), mais sans code d'UM local, sans date par UM ni GHM par RUM : il donne l'ordre (RUM_ORD_NUM), le type d'autorisation (AUT_TYP1_UM, AUT_TYP2_UM) et le DP (DGN_PAL) de chaque RUM, et le service du CHU ne s'y lit pas."
scope: "schéma du SNDS au commit du 2026-04-27 (T_MCOaaUM) ; colonnes de T_MCO23UM relevées sur le portail, profil 108, le 2026-11-16"
maturity: documented
lifecycle: active
terms: [snds:rum, snds:table-pmsi-annuelle, snds:portail]
tables: [snds:T_MCOaaUM, snds:T_MCOaaB]
supported_by: [20261116-schema-t-mcoaaum, 20261116-snds-referentiels-libelles-resultat]
depends_on: []
---
## Pour s'en servir

Ne jamais écrire que le SNDS n'a pas d'UM ni de RUM. Pour décrire le parcours en UM d'un séjour du SNDS, lire T_MCOaaUM : l'ordre des RUM (RUM_ORD_NUM à partir de 2020, UM_ORD_NUM jusqu'en 2019), le type d'autorisation (AUT_TYP1_UM, AUT_TYP2_UM), le DP du RUM (DGN_PAL), IGS2_COD. Contrôler d'abord la liste des colonnes de la table de l'année : le schéma en annonce plus que le portail n'en montre : T_MCO23UM n'a ni UM_ORD_NUM ni UM_TYP, et la requête sur UM_ORD_NUM a échoué sur une table 2021.

Pour dire dans quel service du CHU un séjour est passé, ne pas chercher dans le SNDS : il n'a ni code d'UM local, ni date ou GHM par RUM. Le rattachement UM, UF puis service se lit dans CORA (service-et-pole-depuis-fichier-structure). Une UM du SNDS n'est pas une UM de CORA ni un service.

## Ce qui l'appuie

Le schéma (20261116-schema-t-mcoaaum) liste les champs de T_MCOaaUM et aucun ne porte une date ou un code local d'UM ; NUM_ANO_UM est un numéro séquentiel anonymisé.

La requête 20261116-snds-referentiels-libelles relève les colonnes de PROFIL_108.T_MCO23UM : ACT_RUM_NBR, AGE_GES, AUT_TYP1_UM, AUT_TYP2_UM, DGN_ASS_NBR, DGN_PAL, DGN_REL, ETA_NUM, ETA_NUM_GEO, IGS2_COD, NUM_ANO_UM, PAR_DUR_SEJ, RSA_NUM, RSS_NUM, RUM_ORD_NUM, SUP_TYP1_NAT, SUP_TYP1_NBR, SUP_TYP2_NAT, SUP_TYP2_NBR : pas de date, ni code d'UM local, ni GHM.

Points ouverts : seule l'année 2023 est relevée ; le sens de UM_TYP et de NUM_ANO_UM n'est pas établi.
