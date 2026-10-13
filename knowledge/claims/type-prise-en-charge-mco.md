---
review: unreviewed
id: type-prise-en-charge-mco
kind: decision
author: Pierre
statement: "Au CHU, le type de prise en charge d'un séjour CORA se reconstruit depuis son RSS, jamais depuis TYPE_SEJOUR : sans RSS, non classé ; CMD 28, séance ; durée du RSS de 0 nuit, ambulatoire ; sinon, hospitalisation complète."
scope: "CORA, séjours MCO, toutes années où le lien séjour → RSS par TB_MVT puis TB_MVT_RUM existe"
responsible: Pierre
reconsider_when: "une variable de CORA classe les séjours de façon constante dans le temps ; une méthode est établie pour les séjours sans RSS (#25) ; l'ATIH change la définition des séances ou des séjours de 0 nuit"
maturity: documented
lifecycle: active
terms: [cora:sejour, cora:rss, cora:type-sejour]
tables: [cora:TB_SEJOUR, cora:TB_MVT, cora:TB_MVT_RUM, cora:TB_SYNTH_RSS]
supported_by: [20261013-kb-type-sejour-rss]
depends_on: [type-sejour-non-fiable]
---
## Pour s'en servir

Relier le séjour à son RSS par les mouvements (TB_MVT → TB_MVT_RUM → TB_SYNTH_RSS), puis appliquer les règles dans cet ordre :

1. aucun RSS : non classé ;
2. TB_SYNTH_RSS.CODE_CMD = '28' : séance ;
3. TB_SYNTH_RSS.DUREE_SEJOUR = 0 : ambulatoire (hôpital de jour de médecine et chirurgie ambulatoire confondus) ;
4. sinon : hospitalisation complète ; DUREE_SEJOUR vide : non renseigné.

Un séjour qui porte plusieurs RSS (rare) se classe sur un RSS choisi explicitement ; le dire dans l'analyse.

## Ce qui l'appuie

TYPE_SEJOUR change de codage en 2020-2021 (type-sejour-non-fiable). Le RSS porte les informations du groupage, stables dans le temps.

La méthode ne classe pas les séjours sans RSS : consultations externes, autres champs PMSI, séjours non groupés, sans moyen sûr de les séparer aujourd'hui (#25). Elle ne sépare pas non plus l'hôpital de jour de médecine de la chirurgie ambulatoire.

La règle vient d'une convention de dim-code écrite pour l'étude du casemix du bloc ; elle vaut ici pour tous les séjours MCO.

Points ouverts : classer les séjours sans RSS (#25) ; séparer hôpital de jour et chirurgie ambulatoire (racines de GHM, unités).
