---
review: unreviewed
id: referentiels-hdh-absents-profil-108
kind: empirical
author: Pierre
statement: "IR_ACS_R, IR_ESM_R et IR_VAC_F, décrites dans le schéma du SNDS du HDH, ne sont pas visibles depuis le profil 108 : ne pas les utiliser dans une requête du portail."
scope: "portail SNDS de la Cnam, base IPIAMPR2, profil 108, catalogue du 2026-11-04"
refuted_if: "ALL_OBJECTS, lu depuis le profil 108, montre une table, une vue ou un synonyme nommé IR_ACS_R, IR_ESM_R ou IR_VAC_F"
maturity: observed
lifecycle: active
terms: [snds:profil-108, snds:referentiel-ir]
tables: [snds:IR_ACS_R, snds:IR_ESM_R, snds:IR_VAC_F]
supported_by: [20261104-snds-familles-tables-resultat]
depends_on: []
---
## Pour s'en servir

Avant d'écrire une requête qui joint IR_ACS_R, IR_ESM_R ou IR_VAC_F, chercher une autre source pour la même information, ou demander l'accès à la Cnam. Les autres tables hors PMSI du schéma du HDH sont visibles (ER_PRS_F, IR_BEN_R, IR_IMB_R, KI_CCI_R, DE_DEP_F…).

## Ce qui l'appuie

La requête 20261104-snds-familles-tables cherche dans ALL_OBJECTS tous les noms commençant par IR_, et ne remonte aucun objet nommé IR_ACS_R, IR_ESM_R ou IR_VAC_F (20261104-snds-familles-tables-resultat). Ces trois tables sont décrites dans le schéma du HDH (schema-snds-20260427).

Points ouverts : une copie sous un autre nom (avec un suffixe d'année, par exemple) n'est pas exclue.
