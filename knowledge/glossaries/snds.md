# Glossaire SNDS

Les termes du contexte snds : le Système national des données de santé tel que le portail de la Cnam le donne à lire (profil 108, accès permanent). Un titre par terme (## snds:terme), puis la définition en français. Règles : method/layout.md, « Termes et glossaires ».

## snds:portail

Alias : portail SNDS, portail de la Cnam, portail Cnam, IPIAMPR2, IPIAMPR2.WORLD, ORAVUE, RStudio SNDS, Citrix SNDS

Le portail SNDS de la Cnam, tel qu'un utilisateur du profil 108 l'atteint : une session Citrix, RStudio Server (Linux) et SAS Guide, et la base Oracle IPIAMPR2, où se lisent les tables du SNDS.

## snds:profil-108

Alias : profil 108, accès permanent, PROFIL_108, établissement de santé

Le profil d'habilitation du portail pour l'accès permanent des établissements de santé. Dans la base, c'est aussi le nom du schéma PROFIL_108, qui porte les vues que ce profil lit.

## snds:table-pmsi-annuelle

Alias : T_MCOaa, T_SSRaa, T_HADaa, T_RIPaa, T_MCO, T_SSR, T_HAD, T_RIP, tables PMSI, PMSI MCO, PMSI SSR, PMSI SMR, PMSI HAD, RIM-P

Une table du PMSI national dans le SNDS, déclinée par année : le nom porte l'année sur deux chiffres (T_MCO23B pour la table B du MCO de 2023, notée T_MCOaaB dans le schéma du HDH).

## snds:referentiel-ir

Alias : IR_, tables IR, référentiel, IR_BEN_R, IR_ESM_R, IR_VAC_F, IR_ACS_R, IR_IMB_R

Une table de référentiel du SNDS, dont le nom commence par IR_ (bénéficiaires, établissements, nomenclatures).
