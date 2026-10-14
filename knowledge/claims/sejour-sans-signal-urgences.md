---
review: unreviewed
id: sejour-sans-signal-urgences
kind: empirical
author: Pierre
statement: "Dans CORA, aucun champ du séjour ne repère un passage aux urgences : TB_SEJOUR.UF_URGENCE et TYPE_SEJOUR = 'URG' restent presque toujours vides pour les séjours entrés par les grandes UF d'urgences, et ne sont remplis qu'en partie pour quelques autres."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours entrés de 2014 à 2025"
refuted_if: "UF_URGENCE renseignée, ou TYPE_SEJOUR = 'URG', pour plus de 90 % des séjours entrés par 5701, 5015 ou 5720 sur 2014-2019 ou sur 2020-2025"
maturity: observed
lifecycle: active
terms: [cora:sejour, cora:type-sejour, cora:passage-urgences]
tables: [cora:TB_SEJOUR]
supported_by: [20261014-reperer-urgences-resultat, 20261014-dictionnaire-urgence]
depends_on: []
---
## Pour s'en servir

Ne pas repérer les passages aux urgences par TB_SEJOUR.UF_URGENCE ni par TYPE_SEJOUR = 'URG' : ces filtres perdent presque tous les séjours entrés par les grandes UF d'urgences. Suivre reperer-passage-urgences.

## Ce qui l'appuie

Séjours entrés par UF, et parmi eux ceux de TYPE_SEJOUR 'URG' ; séjours qui citent l'UF dans UF_URGENCE (20261014-reperer-urgences-resultat) :

- 2014-2019 : 5701, 146 'URG' et 614 citations pour 279 837 séjours entrés ; 5720, 446 et 585 pour 83 037 ; 5802, 358 et 877 pour 66 156 : moins de 1,5 % chaque fois. 5015 et 5010 : moins de 10.
- 2020-2025 : moins de 10 pour 5701 (467 052 séjours entrés), 5720, 5015 et 5010.
- Les deux champs ne servent que pour quelques UF, et en partie : les UF d'accueil 8012, 8013 et 8014 depuis 2020 (TYPE_SEJOUR 'URG' pour 44 à 68 % de leurs entrées), les urgences gynéco-obstétricales 8005 (10 à 14 %), la permanence des soins 5703 avant 2020.

Le dictionnaire CORA 2020 présente UF_URGENCE comme l'UF d'urgence d'un patient passé aux urgences avant son hospitalisation (20261014-dictionnaire-urgence) ; au CHU, elle n'est presque jamais remplie pour les grandes UF d'urgences. TYPE_SEJOUR n'est pas non plus fiable pour classer les séjours MCO (type-sejour-non-fiable).

Points ouverts : la mesure compte les séjours par UF d'entrée ; un passage enregistré comme mouvement en cours de séjour n'est pas mesuré.
