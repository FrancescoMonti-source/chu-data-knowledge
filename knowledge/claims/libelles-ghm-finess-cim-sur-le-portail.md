---
review: unreviewed
id: libelles-ghm-finess-cim-sur-le-portail
kind: empirical
author: Pierre
statement: "Sur le portail SNDS (profil 108), les libellés des GHM et des établissements se lisent dans les fichiers sas7bdat du dossier ~/rfcommun, pas dans Oracle : ghm.sas7bdat (code_ghm, lib_ghm) et datasante_t_finess.sas7bdat (finess, finess8, rs, type, etat), noms de fichiers et de colonnes en minuscules, lus par haven::read_sas (le paquet sas7bdat n'est pas installé) ; les libellés de diagnostics viennent de IR_CIM_V (CIM_COD, CIM_LIB), un repli pour les établissements est BE_IDE_R (IDE_ETA_NUM, IDE_ETA_NOM)."
scope: "portail SNDS de la Cnam, profil 108, session RStudio de Pierre le 2026-11-16 ; contenu des référentiels (version, millésime) non relevé"
refuted_if: "une session du portail ne trouve pas ghm.sas7bdat ou datasante_t_finess.sas7bdat dans ~/rfcommun, ou ne lit pas leurs colonnes avec haven::read_sas, ou ALL_TAB_COLUMNS montre une table Oracle RFCOMMUN avec les libellés de GHM ou de FINESS"
maturity: observed
lifecycle: active
terms: [snds:portail, snds:profil-108, snds:referentiel-ir]
tables: [snds:IR_CIM_V, snds:IR_GHS_V, snds:BE_IDE_R]
supported_by: [20261116-snds-referentiels-libelles-resultat]
depends_on: []
---
## Pour s'en servir

Pour afficher un libellé de GHM, d'établissement ou de diagnostic dans une analyse du portail :

1. GHM : `haven::read_sas("~/rfcommun/ghm.sas7bdat")`, colonnes `code_ghm` et `lib_ghm` (3617 lignes). Écrire le nom du fichier et des colonnes en minuscules. Ne pas chercher RFCOMMUN dans Oracle ni IR_GHS_V : IR_GHS_V donne le libellé d'un GHS (GHS_NUM, GHS_LIB), pas d'un GHM, et se joint par T_MCOaaB.GHS_NUM.
2. Établissement : `~/rfcommun/datasante_t_finess.sas7bdat` (242 340 lignes ; `finess` sur 9 caractères, `finess8`, `rs` raison sociale, `type` EJ ou ET, `etat`, `ej_finess`, `et_finess`). Il peut y avoir plusieurs lignes par FINESS : garder `etat` actuel (valeurs ACTUEL ou OBSOLETE selon la table) et dire la règle. Repli si le fichier manque : BE_IDE_R (IDE_ETA_NUM, IDE_ETA_NOM, IDE_ETA_TYP, schéma PROFIL_108).
3. Diagnostic : IR_CIM_V (CIM_COD, CIM_LIB), table d'Oracle qui se lit par le schéma ERTVP, avec le code CIM-10 sur 3 caractères.
4. Lire avec `haven` et prévoir un repli sans libellé (code seul) si le fichier ou le paquet manque : ne pas faire échouer l'analyse.

## Ce qui l'appuie

La requête 20261116-snds-referentiels-libelles (20261116-snds-referentiels-libelles-resultat) liste dans ~/rfcommun les fichiers ghm.sas7bdat et datasante_t_finess.sas7bdat, donne leurs colonnes et leur taille, indique que haven est installé et sas7bdat non, et relève les colonnes de IR_CIM_V (schéma ERTVP), IR_GHS_V (ERTVP) et BE_IDE_R (PROFIL_108).

Points ouverts : Pierre a vu RFCOMMUN refusé par Oracle (ORA-00942) lors de l'analyse, ce qui n'a pas de preuve enregistrée ; le millésime des référentiels et la présence de plusieurs lignes par FINESS ne sont pas relevés ; l'accès à `ghm.sas7bdat` pour un GHM d'une version ancienne n'est pas vérifié.
