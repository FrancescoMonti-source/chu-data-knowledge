---
review: unreviewed
id: anesthesie-ast-top-ophtalmologie
kind: empirical
author: Pierre
statement: "Dans OpRoom, les types d'anesthésie AST et TOP ne servent qu'en ophtalmologie : ce sont les anesthésies locales de l'œil, à regrouper avec l'anesthésie locale et non avec l'anesthésie générale."
scope: "OpRoom de production (QBLOCP), interventions terminées ou clôturées commencées de janvier 2023 au 2026-10-09, par l'extraction de requete_oproom.py"
refuted_if: "AST ou TOP compte plus de 10 interventions dans une spécialité autre que ADULTE_OPH"
maturity: observed
lifecycle: active
terms: [oproom:intervention]
tables: [oproom:OR_INTERVENTIONS, oproom:OR_BASE_LISTS, oproom:OR_PROCEDURES, oproom:OR_SPECIALISMS]
supported_by: [20261015-oproom-anesthesie-specialite-resultat]
depends_on: [developper-sur-qbloct]
---
## Pour s'en servir

Pour regrouper les types d'anesthésie (I_ANESTHESIA_TYPE, libellés de OR_BASE_LISTS), ranger AST et TOP avec les anesthésies locales (AL), comme anesthésies locales de l'ophtalmologie. Les autres codes rares (AG VS, APB, APD, HYPNOSE, INDETERMINE) ont moins de 10 interventions par spécialité : les regrouper dans « autre », en le disant. Le tiret « - » (environ 5 600 interventions, surtout en gynéco-obstétrique, chirurgie cardiaque et ORL) n'est pas un type d'anesthésie : le garder à part, en « non renseigné ».

Que AST soit l'anesthésie sous-ténonienne et TOP l'anesthésie topique est une lecture des codes, à confirmer avec les anesthésistes.

## Ce qui l'appuie

Interventions par type d'anesthésie et spécialité, de 2023 au 2026-10-09 (20261015-oproom-anesthesie-specialite-resultat) : TOP, 257 interventions, toutes en ADULTE_OPH ; AST, la plus grande case est ADULTE_OPH (masquée par la suppression secondaire), et moins de 10 interventions en ADULTE_URG MAINS, aucune ailleurs. Type « - » : 3 514 en ADULTE_GYN OBS, 550 en ADULTE_CCARD, 414 en ADULTE_ORL, 174 en ADULTE_VASC, 106 en ADULTE_DIG, moins de 80 dans chacune des autres spécialités.
