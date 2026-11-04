---
review: unreviewed
id: entree-domicile-melange-programme-et-urgences
kind: empirical
author: Pierre
statement: "Au CHU en 2025, pour les séjours MCO hors GHM 90 et hors séances (CMD 28), le mode d'entrée ne sépare pas séjours programmés et urgents : 98 % des séjours ont ENT_MOD = 8 (domicile) et 30 % de ceux-là ont STC_URG = 5 ; SEJ_NP n'est renseigné que pour 9 % des séjours et ne recoupe presque pas STC_URG = 5 (11 séjours) : STC_URG = 5 est le seul marqueur de passage par les urgences utilisable, à titre provisoire."
scope: "PMSI MCO du CHU de Rouen (FINESS juridique 760780239), séjours sortis en 2025 hors GHM 90 et hors CMD 28, portail SNDS, profil 108"
refuted_if: "la documentation du format ATIH donne à ENT_MOD, SEJ_NP ou STC_URG un sens qui contredit ce décompte, ou un croisement refait sur une autre année ou une autre population de séjours du CHU donne une autre répartition"
maturity: observed
lifecycle: active
terms: [snds:portail, snds:profil-108, snds:table-pmsi-annuelle]
tables: [snds:T_MCOaaB]
supported_by: [20261105-snds-sej-np-croisements-mco-chu-resultat]
depends_on: [sej-np-stc-urg-codes-non-binaires]
---
## Pour s'en servir

Pour repérer un séjour non programmé ou passé par les urgences, ne pas partir du mode d'entrée : ENT_MOD = 8 recouvre aussi bien les entrées programmées que celles venues des urgences. Utiliser STC_URG = 5 comme indicateur provisoire de passage par les urgences, en le nommant ainsi et pas « non programmé », jusqu'à avoir le sens des codes dans le format ATIH. Ne pas utiliser SEJ_NP comme marqueur de non programmé.

## Ce qui l'appuie

Séjours du CHU sortis en 2025, hors GHM 90 et CMD 28, environ 149 500 (20261105-snds-sej-np-croisements-mco-chu-resultat) :
- ENT_MOD vaut 8 pour environ 142 300 séjours ; parmi eux 43 401 ont STC_URG = 5 et 98 760 un STC_URG vide. STC_URG = 5 concerne environ 29 % de tous les séjours.
- SEJ_NP est renseigné (1 ou 2) pour environ 14 000 séjours, soit 9 %, presque tous avec ENT_MOD = 8 et une provenance vide ; croisé avec STC_URG, SEJ_NP = 2 et STC_URG = 5 ne se rencontrent que dans 11 séjours, SEJ_NP = 1 et STC_URG = 5 dans moins de 10.
- SEJ_NP = 2 porte surtout sur des GHM médicaux (7501), chirurgicaux (2892) et K (1735) ; SEJ_NP = 1 surtout sur des GHM médicaux (883) et chirurgicaux (540).

Points ouverts : le sens de 5, U, V, 1 et 2 ; l'hypothèse que le mode d'entrée distingue les urgences est contredite par ce décompte mais elle n'a pas été testée sur la provenance, dont la valeur 5 n'apparaît pas (valeurs vues : 1, 2, 3, 4, 6, 7, R, vide).
