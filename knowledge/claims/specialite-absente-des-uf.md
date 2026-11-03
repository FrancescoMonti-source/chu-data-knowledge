---
review: unreviewed
id: specialite-absente-des-uf
kind: empirical
author: Pierre
statement: "Dans CORA, aucune colonne d'UF ne donne une spécialité : TB_UNITE.TYPE_ACTIVITE est vide pour les 839 UF, et le fichier Structure n'a pas de colonne de spécialité ; ne pas écrire de requête qui déduirait la spécialité d'un service ou d'une UF d'une colonne de TB_UNITE, et la demander à la personne (table de correspondance) ou la déduire de l'activité."
scope: "CORA de production (CWPROD), TB_UNITE (839 UF) lue le 2026-11-03 ; fichier Structure du 2026-10-09 ; tables de spécialité repérées par le catalogue, contenu non lu"
refuted_if: "au moins une UF de TB_UNITE a un TYPE_ACTIVITE renseigné, ou une colonne de TB_UNITE, TB_UNITE_MEDICALE ou du fichier Structure porte une spécialité médicale"
maturity: observed
lifecycle: active
terms: [cora:uf, structure:service, structure:uf]
tables: [cora:TB_UNITE, cora:TB_THES_TYPE_ACTIVITE, cora:TB_SPECIALITE, cora:TB_THESAURUS_SPECIALITE]
supported_by: [20261103-uf-type-activite-resultat, 20261103-colonnes-exclusions-specialites-resultat, 20261026-structure-chu-colonnes]
depends_on: [service-et-pole-depuis-fichier-structure]
---
## Pour s'en servir

Quand une question demande une spécialité (« par spécialité », « chirurgie digestive »), ne pas la chercher sur l'UF, l'UM ou le service :

- **Ne pas utiliser** TB_UNITE.TYPE_ACTIVITE (vide pour les 204 UF inactives comme pour les 635 actives) ni le « Type prise en charge » du fichier Structure, qui décrit le mode de prise en charge.
- **Spécialité de l'intervention :** voir specialite-et-etat-intervention (OpRoom).
- **Référentiel de spécialités médicales :** CORA_UTIL.TB_SPECIALITE_MED (72 lignes d'après les statistiques ; ID_SPE_MED, CODE_SPE_MED, LIBELLE_SPE_MED, codes officiels et métier) liste des spécialités de médecins ; aucune colonne ne la relie à une UF ou à un service. Son contenu n'est pas lu.
- **Spécialités de la CCAM :** CORA_CCAM.CCAM_CODE_SPE (CODE_SPE, LIB_SPE, 96 lignes) et CCAM_SPE_CCAM (CLE, LIB_CODE_SPE) concernent les actes, pas l'UF.
- **TB_SPECIALITE** (CORA_REC : ID_SPECIALITE, LIBELLE_SPECIALITE, CODE_EXPORT, 3 lignes d'après les statistiques) et TB_THESAURUS_SPECIALITE (CORA_REC, type d'intervention) existent mais leur rôle n'est pas établi : ne pas les utiliser avant de les avoir lues.

Pour une spécialité par service ou par UF, demander à la personne la correspondance qu'elle utilise, ou la déduire de l'activité (par exemple la spécialité de l'intervention) en le disant.

## Ce qui l'appuie

20261103-uf-type-activite-resultat : les 839 UF de TB_UNITE (204 inactives, 635 actives) ont un TYPE_ACTIVITE vide, alors que TB_THES_TYPE_ACTIVITE a 30 lignes. 20261103-colonnes-exclusions-specialites-resultat donne les colonnes des tables de spécialité. La fiche du fichier Structure (20261026-structure-chu-colonnes) n'a ni spécialité ni discipline.

Points ouverts : le rôle de TB_SPECIALITE et de TB_THESAURUS_SPECIALITE ; les colonnes des autres tables de TB_UNITE (CODE_SAE, CODE_FA, CODE_NATURE_PEC) ne sont pas une spécialité mais n'ont pas été lues.
