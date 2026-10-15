---
review: unreviewed
id: acte-principal-icr
kind: decision
author: Pierre
statement: "Au DIM, pour ranger une intervention de bloc dans une strate d'actes CCAM, l'acte principal est l'acte chirurgical d'ICR le plus élevé, hors actes complémentaires (codes commençant par Y ou Z) ; à égalité, le tarif CCAM le plus élevé, puis l'ordre alphabétique du code."
scope: "CORA, actes CCAM de bloc rattachés à une intervention OpRoom, 2023-2026 ; ICR de la version 2021 de l'ATIH pour toutes les années"
responsible: Pierre
reconsider_when: "l'ATIH publie une version plus récente des ICR, ou un contrôle montre que la règle déplace des interventions entre strates d'une année à l'autre"
maturity: documented
lifecycle: active
terms: [pmsi:icr, pmsi:ccam, oproom:intervention]
tables: [cora:TB_ACTE]
supported_by: [20261015-decision-acte-principal-icr, 20261015-atih-icr-structure]
depends_on: []
---
## Pour s'en servir

Pour classer une intervention par un seul acte :

1. prendre ses actes CCAM chirurgicaux (activité 1) ;
2. écarter ceux dont le code commence par Y ou Z (suppléments d'imagerie, gestes complémentaires, divers), tant qu'il reste un autre acte ;
3. parmi les restants, prendre celui dont l'ICR médecin salarié est le plus élevé (feuille ICR de icr_v3_2021, clé Code_principal et activité) ;
4. à égalité, le tarif CCAM le plus élevé, puis le code par ordre alphabétique.

Une intervention sans acte rattaché n'a pas de strate : le dire, et comparer les années sur les seules interventions avec acte. Les actes de bloc se repèrent et se rattachent aux interventions comme dit reperer-actes-de-bloc et rattacher-actes-bloc-sans-cle ; le chaînage direct étant récent, l'acte principal d'une même intervention peut changer avec le niveau de rattachement : le dire quand on compare des années.

## Ce qui l'appuie

L'ICR est construit par l'ATIH pour peser les actes en ressources de bloc : c'est l'attribut d'un acte le plus proche de ce que mesure le TMI. La version 2021 est unique, alors que le tarif change à chaque campagne et pourrait déplacer l'acte principal d'une année sur l'autre, ce qui créerait un faux effet de structure. La règle du tarif reste calculée en comparaison.

Contrôles faits dans l'étude (QBLOCP, 2025-2026), non rejoués par relay : les deux règles désignent le même acte pour environ 96 % des interventions ; la part de variance du TMI expliquée (R² ajusté) est du même ordre avec l'une ou l'autre (environ 0,8, pour environ 2 000 actes distincts) ; environ 94 à 96 % des interventions ont un acte rattaché.

Points ouverts : la règle suppose que l'acte d'ICR le plus élevé « fait » l'intervention ; les contrôles ci-dessus ne sont pas des preuves du dépôt.
