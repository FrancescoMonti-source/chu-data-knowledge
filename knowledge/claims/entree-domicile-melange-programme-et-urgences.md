---
review: unreviewed
id: entree-domicile-melange-programme-et-urgences
kind: empirical
author: Pierre
statement: "Dans le PMSI MCO, le mode d'entrée ne sépare pas séjours programmés et urgents : ENT_MOD = 8 (domicile) recouvre les deux, et la Cnam ne repère le passage par les urgences qu'avec la provenance (ENT_PRV), STC_URG ou le type de la première UM ; SEJ_NP est peu renseigné et ne recoupe presque pas STC_URG. Au CHU en 2025 (hors GHM 90 et CMD 28), 98 % des séjours ont ENT_MOD = 8, 30 % de ceux-là STC_URG = 5, et SEJ_NP n'est renseigné que pour 9 % des séjours. Pour repérer le passage par les urgences, appliquer la règle de la macro CNAM (sejour-passe-par-les-urgences-regle-cnam), pas STC_URG seul."
scope: "PMSI MCO en général pour le rôle de ENT_MOD (macro et guide CNAM) ; décompte observé sur les séjours du CHU de Rouen (FINESS juridique 760780239) sortis en 2025 hors GHM 90 et CMD 28, portail SNDS, profil 108"
refuted_if: "un décompte d'un autre établissement ou d'une autre année montre un mode d'entrée qui sépare programmé et urgent, ou la documentation du format ATIH donne à ENT_MOD, SEJ_NP ou STC_URG un sens qui contredit la règle CNAM"
maturity: observed
lifecycle: active
terms: [snds:portail, snds:profil-108, snds:table-pmsi-annuelle]
tables: [snds:T_MCOaaB]
supported_by: [20261105-snds-sej-np-croisements-mco-chu-resultat, 20261116-macro-sej-urg-cnam, 20261116-guide-codification-urgences-cnam]
depends_on: [sej-np-stc-urg-codes-non-binaires, sejour-passe-par-les-urgences-regle-cnam]
---
## Pour s'en servir

Pour repérer un séjour passé par les urgences, ne pas partir du mode d'entrée : ENT_MOD = 8 recouvre aussi bien les entrées programmées que celles venues des urgences. Appliquer la règle de la macro CNAM (sejour-passe-par-les-urgences-regle-cnam : première UM de type 07, ou ENT_MOD et ENT_PRV, ou STC_URG selon l'année de la table), et nommer le résultat « passé par les urgences », pas « non programmé ». STC_URG = 5 seul n'est plus qu'un des critères de cette règle. Ne pas utiliser SEJ_NP comme marqueur de non programmé.

## Ce qui l'appuie

La règle de la Cnam combine ENT_MOD = 8 (ou 7) avec ENT_PRV ou STC_URG : le mode d'entrée seul ne désigne donc pas les urgences, dans tout le MCO (20261116-macro-sej-urg-cnam, 20261116-guide-codification-urgences-cnam). Le décompte du CHU l'illustre.

Séjours du CHU sortis en 2025, hors GHM 90 et CMD 28, environ 149 500 (20261105-snds-sej-np-croisements-mco-chu-resultat) :
- ENT_MOD vaut 8 pour environ 142 300 séjours ; parmi eux 43 401 ont STC_URG = 5 et 98 760 un STC_URG vide. STC_URG = 5 concerne environ 29 % de tous les séjours.
- SEJ_NP est renseigné (1 ou 2) pour environ 14 000 séjours, soit 9 %, presque tous avec ENT_MOD = 8 et une provenance vide ; croisé avec STC_URG, SEJ_NP = 2 et STC_URG = 5 ne se rencontrent que dans 11 séjours, SEJ_NP = 1 et STC_URG = 5 dans moins de 10.
- SEJ_NP = 2 porte surtout sur des GHM médicaux (7501), chirurgicaux (2892) et K (1735) ; SEJ_NP = 1 surtout sur des GHM médicaux (883) et chirurgicaux (540).

Points ouverts : le sens de 1 et 2 (5, U et V sont donnés par le guide CNAM) ; l'hypothèse que le mode d'entrée distingue les urgences est contredite par ce décompte mais elle n'a pas été testée sur la provenance, dont la valeur 5 n'apparaît pas (valeurs vues : 1, 2, 3, 4, 6, 7, R, vide).
