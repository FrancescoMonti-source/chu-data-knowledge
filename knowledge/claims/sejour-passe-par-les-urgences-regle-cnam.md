---
review: unreviewed
id: sejour-passe-par-les-urgences-regle-cnam
kind: documentary
author: Pierre
statement: "Dans le PMSI MCO du SNDS, un séjour est « passé par les urgences » selon la règle de la macro SEJ_URG de la Cnam : sa première UM (RUM_ORD_NUM = 1 de T_MCOaaUM) est de type d'autorisation 07 (UHCD), ou son ENT_MOD vaut 8 (7 aussi dès les tables 2023) avec ENT_PRV = 5 ou U, ou (tables 2023 et après) STC_URG = 5, U ou V ; cette règle repère l'urgence, pas le « non programmé »."
scope: "PMSI MCO du SNDS, tables T_MCOaaB et T_MCOaaUM, macro et guide lus dans la documentation du HDH au commit du 2026-11-02 ; règle non éprouvée sur les données du CHU"
maturity: documented
lifecycle: active
terms: [snds:passage-urgences, snds:rum, snds:table-pmsi-annuelle]
tables: [snds:T_MCOaaB, snds:T_MCOaaUM]
supported_by: [20261116-macro-sej-urg-cnam, 20261116-guide-codification-urgences-cnam]
depends_on: [um-mco-sans-service-ni-dates]
---
## Pour s'en servir

Pour repérer les séjours MCO venus des urgences dans le SNDS, reproduire la macro SEJ_URG au lieu de choisir une variable :

1. Joindre T_MCOaaB à T_MCOaaUM sur ETA_NUM et RSA_NUM, et ne garder que la première UM du séjour (RUM_ORD_NUM = 1 ; UM_ORD_NUM = 1 pour les tables 2019 et avant).
2. Séjour « passé par les urgences » si, dans l'ordre de la macro :
   - substr(AUT_TYP1_UM, 1, 2) = '07' (UHCD) ; ou
   - tables 2022 et avant : ENT_MOD = '8' et ENT_PRV dans ('5','U') ; ou
   - tables 2023 et après : ENT_MOD dans ('8','7') et (ENT_PRV dans ('5','U') ou STC_URG dans ('5','U','V')).
3. Choisir la table selon l'année de sortie du séjour ; ne pas appliquer la règle des tables 2023 à une table plus ancienne.
4. Nommer le résultat « passé par les urgences », jamais « non programmé » : un séjour sans passage par les urgences n'est pas pour autant programmé. Ne pas utiliser SEJ_NP (entree-domicile-melange-programme-et-urgences).
5. La macro ne couvre pas les passages aux urgences sans hospitalisation (macro ACE_URG : ATU, forfaits FU0 à FU4) ; ils sont hors du champ d'un séjour MCO.

ENT_PRV = 5 n'est plus codé depuis mars 2023 (STC_URG le remplace) : ne pas s'étonner de ne plus le trouver dans les données récentes.

## Ce qui l'appuie

La macro (20261116-macro-sej-urg-cnam) donne les conditions ; le guide qui l'accompagne (20261116-guide-codification-urgences-cnam) donne le sens de ENT_PRV 5 et U, de STC_URG 5, U et V, le type 07 (07A urgences générales, 07B pédiatriques) et la raison de ne regarder que la première UM : certains établissements ne codent pas la provenance mais renseignent l'UM. Le sens de STC_URG tranche donc ce que sej-np-stc-urg-codes-non-binaires laissait ouvert.

Points ouverts : la règle n'a pas été confrontée à une exécution sur les données du CHU (part de séjours repérés par chacune des conditions) ; le sens de SEJ_NP reste inconnu ; la macro est un programme partagé, non un texte réglementaire.
