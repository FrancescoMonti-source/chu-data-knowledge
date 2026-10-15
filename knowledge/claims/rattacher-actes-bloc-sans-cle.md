---
review: unreviewed
id: rattacher-actes-bloc-sans-cle
kind: empirical
author: Pierre
statement: "Pour rattacher un acte de bloc CORA à une intervention OpRoom sans la clé NO_INTERVENTION_EXT (avant 2026 surtout), passer par le séjour (n° d'admission OpRoom = séjour CORA) : s'il n'a qu'une intervention OpRoom, le rattachement est sûr ; s'il en a plusieurs, prendre celle de la date la plus proche, presque toujours juste ; départager le même jour par le mapping procédure → CCAM, nettement moins sûr."
scope: "CORA de production et extraction OpRoom, actes de bloc et interventions OpRoom de la période OpRoom, analyse de DIM-code exécutée le 2026-10-05 ; exactitude mesurée contre le chaînage direct depuis avril 2025"
refuted_if: "contre le chaînage par NO_INTERVENTION_EXT, le rattachement par intervention unique du séjour est faux pour plus de 2 % des actes, ou celui par date la plus proche pour plus de 5 %"
maturity: provisional
lifecycle: active
terms: [cora:acte, cora:intervention, oproom:intervention, cora:sejour]
tables: [cora:TB_ACTE, cora:TB_MVT, cora:TB_SEJOUR, oproom:OR_INTERVENTIONS]
supported_by: [20261015-dim-code-cascade-chainage]
depends_on: [chainer-oproom-cora, reperer-actes-de-bloc]
---
## Pour s'en servir

Rattacher chaque acte de bloc (reperer-actes-de-bloc) dans cet ordre, et garder le niveau utilisé dans une colonne :

1. **Chaîné :** par NO_INTERVENTION_EXT (chainer-oproom-cora).
2. **Intervention unique :** le séjour CORA de l'acte n'a qu'une intervention OpRoom (I_ADMISSION_NR = n° de séjour) : la lui rattacher, quel que soit l'écart de dates.
3. **Date la plus proche :** le séjour en a plusieurs : prendre celle dont la date est la plus proche de DATE_ACTE, si elle est unique ; signaler les écarts de plus d'un jour.
4. **Vote :** plusieurs interventions le même jour : départager par groupe d'actes (NO_INTERVENTION_CCAM) avec les scores du mapping procédure → CCAM ; sinon, « indécis ».

Dire la part des actes de chaque niveau. Un acte sans intervention OpRoom dans son séjour est attendu (environ un sur six) : certains blocs n'utilisent pas OpRoom. Une intervention OpRoom sans acte retrouvé vient surtout des UF 6510 et 5508 si on ne les a pas mises dans le périmètre.

L'implémentation est dans DIM-code, `analysis/2026-10_chainage_oproom_ccam/chainage.py`.

## Ce qui l'appuie

Analyse de DIM-code du 2026-10-05 (20261015-dim-code-cascade-chainage) : sur 207 671 actes de bloc, 82,5 % rattachés (chaîné 7,9 %, intervention unique 66,1 %, date la plus proche 8,0 %, vote 0,5 %) et 17,3 % sans intervention OpRoom dans le séjour. Exactitude contre le chaînage direct depuis avril 2025 : 100 % pour l'intervention unique, 99,4 % pour la date la plus proche, 85,9 % pour le vote (71 actes). Sur 144 643 interventions OpRoom : codage retrouvé pour 82,2 %, aucun pour 15,4 % (surtout UF 6510 et 5508), séjour absent de CORA pour 2,3 %.

Ces chiffres viennent d'une analyse de Pierre, faite avant ce dépôt, et non d'une requête de CDK : la refaire en suivant method/queries.md avant de les citer comme une mesure.
