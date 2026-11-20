---
review: unreviewed
id: mn-diagnostique-ccam-ql-faux-positifs
kind: documentary
author: Pierre
statement: "Repérer la médecine nucléaire diagnostique par les actes CCAM en __QL% (action Q, technique L), mais en écarter ZZQL008 (test respiratoire à isotope stable, pas de la médecine nucléaire) et ZZQL021 (fusion d'images, geste complémentaire) ; ZZQL010, détection peropératoire faite par le chirurgien, est aussi un geste complémentaire à garder ou écarter explicitement."
scope: "CCAM descriptive à usage PMSI 2026 ; actes des séjours et des consultations externes du PMSI MCO, dont le SNDS (T_MCOaaA.CDC_ACT, T_MCOaaFMSTC.CCAM_COD)"
maturity: documented
lifecycle: active
terms: [pmsi:acte-ccam, pmsi:medecine-nucleaire]
tables: [snds:T_MCOaaA, snds:T_MCOaaFMSTC]
supported_by: [20261117-ccam-zzql008-isotope-stable, 20261117-ccam-zzql021-zzql010-gestes-complementaires, 20261117-ccam-hpml001-controle-catheter, 20261117-sae-mednuc-comptage]
depends_on: []
---
## Pour s'en servir

Filtrer `CDC_ACT LIKE '__QL%'` (séjours) ou `CCAM_COD LIKE '__QL%'` (consultations externes), puis retirer ZZQL008 et ZZQL021. Dire dans l'analyse si ZZQL010 (détection peropératoire, ganglion sentinelle) est compté : c'est un geste du chirurgien au bloc, que la SAE ne compte pas comme activité de médecine nucléaire. ZZQL013 (détection préopératoire par injection, avec détection peropératoire) est rangé avec les scintigraphies. HPML001 (contrôle radio-isotopique d'un cathéter intrapéritonéal) est de la médecine nucléaire hors du motif ; l'ajouter si l'étude doit être exhaustive. Pour la médecine nucléaire thérapeutique : mn-therapeutique-liste-sae-pas-nl.

## Ce qui l'appuie

La 4e lettre L de la CCAM ne désigne pas la seule médecine nucléaire : ZZQL008 est un « breath test au carbone 13 », rangé dans les épreuves fonctionnelles du tube digestif (20261117-ccam-zzql008-isotope-stable) ; ZZQL021 (fusion d'images, utile à la préparation de la radiothérapie) et ZZQL010 sont des gestes complémentaires du chapitre 18 (20261117-ccam-zzql021-zzql010-gestes-complementaires), que le bordereau MEDNUC de la SAE exclut du compte de l'activité de médecine nucléaire, comme les suppléments YYYY du chapitre 19 (20261117-sae-mednuc-comptage). Le motif ne capte pas HPML001, dont la 3e lettre est M, alors que la CCAM le range dans les scintigraphies de l'appareil digestif (20261117-ccam-hpml001-controle-catheter).

Points ouverts : le motif n'a été confronté qu'aux libellés de la CCAM 2026 et aux codes observés en 2024 dans deux établissements ; la table officielle des modes d'accès et techniques (4e lettre) n'a pas été lue ; les forfaits techniques de la TEP ne sont pas des actes CCAM et ne sont pas couverts. ZZQL010 a aussi une activité 4 (anesthésie) : compter des actes sans filtrer l'activité peut le compter deux fois.
