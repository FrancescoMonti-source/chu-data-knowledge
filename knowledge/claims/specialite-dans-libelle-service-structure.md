---
review: unreviewed
id: specialite-dans-libelle-service-structure
kind: empirical
author: Pierre
statement: "Aucune colonne de CORA ni du fichier Structure ne porte une spécialité normalisée : pour un service ou une UF, la spécialité se lit dans le Libellé Service du fichier Structure (un libellé par Code Service, 164 services pour 1 187 UF), qui mélange spécialités cliniques (CARDIOLOGIE, NEUROLOGIE), regroupements d'organisation (ACTIVITES POLAIRES POLE …, DEPT REA ANESTH MEDECINE PERI OPERATOIRE, BLOC SPECIALITES) et services non cliniques (RESTAURATION, LOGISTIQUE) ; ne pas déduire la spécialité de TB_UNITE.TYPE_ACTIVITE (vide pour les 839 UF), et ne pas compter le libellé comme une nomenclature : regrouper les libellés en spécialités est un choix à dire."
scope: "Fichier Structure du 2026-10-09 (1 187 lignes) et TB_UNITE de CORA de production (CWPROD, 839 UF) lue le 2026-11-03 ; la colonne « Type prise en charge » du fichier (22 valeurs) décrit un mode de prise en charge, pas une spécialité ; le contenu des tables de spécialité de CORA n'est pas lu"
refuted_if: "une colonne du fichier Structure ou de TB_UNITE porte, pour les UF, un code ou un libellé de spécialité normalisé ; ou un Code Service a plusieurs Libellé Service dans une version plus récente du fichier"
maturity: observed
lifecycle: active
terms: [cora:uf, structure:service, structure:uf]
tables: [cora:TB_UNITE, cora:TB_THES_TYPE_ACTIVITE, cora:TB_SPECIALITE, cora:TB_THESAURUS_SPECIALITE]
supported_by: [20261103-uf-type-activite-resultat, 20261103-colonnes-exclusions-specialites-resultat, 20261120-structure-colonnes-specialite-resultat]
depends_on: [service-et-pole-depuis-fichier-structure]
---
## Pour s'en servir

Quand une question demande une spécialité (« par spécialité », « chirurgie digestive »), partir du Libellé Service du fichier Structure, joint à l'UF par le Code UF (service-et-pole-depuis-fichier-structure) :

- Le libellé identifie le service, il ne le range pas dans une spécialité : 164 services dont une partie n'est pas clinique, d'autres couvrent plusieurs spécialités (PNEUMOLOGIE ONCO THORACI SI RESPIRATOIR). Écrire à la personne la table libellé → spécialité retenue, ou lui demander de la valider.
- **Ne pas utiliser** TB_UNITE.TYPE_ACTIVITE (vide pour les 204 UF inactives comme pour les 635 actives) ni « Type prise en charge » du fichier (Administrative, consultations, hospitalisation complète, Bloc…).
- **Spécialité de l'intervention :** voir specialite-et-etat-intervention (OpRoom).
- **Référentiel de spécialités médicales :** CORA_UTIL.TB_SPECIALITE_MED (72 lignes d'après les statistiques) liste des spécialités de médecins ; aucune colonne ne la relie à une UF ou à un service. Son contenu n'est pas lu.
- **Spécialités de la CCAM :** CORA_CCAM.CCAM_CODE_SPE et CCAM_SPE_CCAM concernent les actes, pas l'UF.
- **TB_SPECIALITE** et TB_THESAURUS_SPECIALITE (CORA_REC) existent mais leur rôle n'est pas établi : ne pas les utiliser avant de les avoir lues.

## Ce qui l'appuie

20261120-structure-colonnes-specialite-resultat : les 24 colonnes du fichier Structure ; « Libellé Service » a 164 valeurs pour 164 Code Service (aucun service à plusieurs libellés), mêlant services cliniques et non cliniques ; aucune colonne ne porte de spécialité ni de discipline ; « Type prise en charge » a 22 valeurs de mode de prise en charge. La piste vient de Pierre, qui a lu la spécialité dans Libellé Service (2026-11-20). 20261103-uf-type-activite-resultat : les 839 UF de TB_UNITE ont un TYPE_ACTIVITE vide.

Points ouverts : la table libellé → spécialité (choix de Pierre) ; le rôle de TB_SPECIALITE et de TB_THESAURUS_SPECIALITE ; les colonnes CODE_SAE, CODE_FA, CODE_NATURE_PEC de TB_UNITE n'ont pas été lues.
