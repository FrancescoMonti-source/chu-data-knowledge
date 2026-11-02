---
review: unreviewed
id: montant-acte-tarif-modificateurs
kind: empirical
author: Pierre
statement: "Dans CORA, pour valoriser des actes de bloc, prendre MNT_TOTAL tel quel et le nommer ; ne pas le reconstituer par MNT_ACTIVITE + MNT_MODIFICATEUR + MNT_DEPASS, dont la somme le dépasse chaque année, et ne pas lui substituer MNT_ACTIVITE, qui s'en écarte dans les deux sens selon l'année."
scope: "CORA de production (CWPROD, schéma CORA_REC), activités d'actes (TB_DET_ACTE, ID_ACTIVITE = 1) des actes de site de bloc (TB_SITE.BLOC = 'O', hors site 2620), datés de 2022 à octobre 2026, lu le 2026-10-19"
refuted_if: "pour une année complète de 2022 à 2025, la somme MNT_ACTIVITE + MNT_MODIFICATEUR + MNT_DEPASS de ces activités égale la somme de MNT_TOTAL à 1 % près"
maturity: observed
lifecycle: active
terms: [cora:acte]
tables: [cora:TB_DET_ACTE, cora:TB_ACTE, cora:TB_SITE]
supported_by: [20261019-bloc-montants-actes-resultat]
depends_on: [reperer-actes-de-bloc]
---
## Pour s'en servir

Valoriser des actes de bloc par `SUM(MNT_TOTAL)` et dire que c'est cette valorisation. Ne pas additionner MNT_ACTIVITE, MNT_MODIFICATEUR et MNT_DEPASS pour retrouver MNT_TOTAL : la somme est supérieure de 9,7 % à 13,2 % selon l'année (calculé (MNT_ACTIVITE + MNT_MODIFICATEUR + MNT_DEPASS) / MNT_TOTAL − 1 sur les sommes du tableau), soit de 27,79 € à 32,32 € par activité. Ne pas comparer deux analyses valorisées différemment (MNT_TOTAL contre MNT_ACTIVITE). MNT_DEPASS est négligeable ici : l'ignorer ou le sommer ne change rien.

## Ce qui l'appuie

Activités d'actes de bloc, sommes par année de DATE_ACTE (20261019-bloc-montants-actes-resultat), en millions d'euros :

| Année | MNT_TOTAL | MNT_ACTIVITE | MNT_MODIFICATEUR | MNT_DEPASS | MNT_TOTAL / MNT_ACTIVITE | somme des trois, au-dessus de MNT_TOTAL de |
|---|---|---|---|---|---|---|
| 2022 | 8,68 | 8,99 | 0,65 | 302 € | 0,965 | 11,1 % |
| 2023 | 9,99 | 9,51 | 1,55 | 0 | 1,050 | 10,8 % |
| 2024 | 10,33 | 9,84 | 1,49 | 0 | 1,049 | 9,7 % |
| 2025 | 11,51 | 11,30 | 1,46 | 0 | 1,018 | 10,9 % |
| 2026 (au 19 octobre) | 8,92 | 9,23 | 0,87 | 0 | 0,966 | 13,2 % |

- L'écart moyen par activité MNT_TOTAL − (MNT_ACTIVITE + MNT_MODIFICATEUR + MNT_DEPASS) est de −28,68 € en 2022, −30,26 € en 2023, −27,79 € en 2024, −28,68 € en 2025 et −32,32 € en 2026 : MNT_TOTAL n'est pas la somme de ses composants, sans que cette mesure dise pourquoi (la règle d'association, qui minore le deuxième acte, est une explication possible, non vérifiée).
- MNT_ACTIVITE s'écarte de MNT_TOTAL dans les deux sens : MNT_TOTAL est de 3,5 % sous MNT_ACTIVITE en 2022 et de 3,4 % en 2026, de 5,0 % et 4,9 % au-dessus en 2023 et 2024, de 1,8 % au-dessus en 2025 (rapport MNT_TOTAL / MNT_ACTIVITE du tableau moins 1, sur les sommes de toutes les activités de l'année). Les modificateurs pèsent de 7 % à 16 % de MNT_ACTIVITE selon l'année (MNT_MODIFICATEUR / MNT_ACTIVITE : 0,65 sur 8,99 M€ en 2022, 1,55 sur 9,51 M€ en 2023, 1,49 sur 9,84 M€ en 2024, 1,46 sur 11,30 M€ en 2025, 0,87 sur 9,23 M€ en 2026).
- MNT_DEPASS : moins de 10 activités à dépassement positif chaque année (sur 33 545 à 43 564), 302 € au total en 2022, rien ensuite.

Points ouverts : la comparaison de MNT_ACTIVITE au tarif CCAM (hors CORA, non faite) ; un constat antérieur sur la base de test QBLOCT, MNT_TOTAL de 5 à 10 % au-dessus de la somme des tarifs, n'est pas retrouvé ici (de −3,5 % à +5,0 % par rapport à MNT_ACTIVITE) ; la cause de l'écart de 27,79 à 32,32 € par activité ; les actes hors bloc.
