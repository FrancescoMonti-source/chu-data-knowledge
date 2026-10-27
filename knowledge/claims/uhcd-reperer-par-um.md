---
review: unreviewed
id: uhcd-reperer-par-um
kind: empirical
author: Francesco
statement: "Dans CORA, un séjour d'UHCD du CHU se repère par l'UM de son RUM : 5701, 5720, 5015 ou 5010 (urgences et UHCD) ; un RSS dont l'unique RUM est dans l'une d'elles est groupé dans le GHS 5xxx de sa racine (GHS monorum UHCD), pas dans le GHS propre de son GHM."
scope: "CORA de production (CWPROD, schéma CORA_REC), RSS de TB_SYNTH_RSS finis en 2025, groupés, hors CMD 90 et GHS 9999, d'un seul RUM, UM lue dans TB_UNITE_MEDICALE ; lus le 2026-10-27"
refuted_if: "pour une année depuis 2022, plus de 5 % des RSS d'un seul RUM dans l'UM 5701, 5720, 5015 ou 5010 sont groupés hors d'un GHS 5xxx"
maturity: observed
lifecycle: active
terms: [cora:rss, cora:passage-urgences]
tables: [cora:TB_SYNTH_RSS, cora:TB_SYNTH_RUM, cora:TB_UNITE_MEDICALE]
supported_by: [20261027-tarif-ghs-5xxx-uhcd-resultat, 20261014-structure-uf-urgences-resultat]
depends_on: []
---
## Pour s'en servir

```sql
JOIN CORA_REC.TB_SYNTH_RUM ru ON ru.ID_RSS = s.ID_RSS
JOIN CORA_REC.TB_UNITE_MEDICALE u ON u.ID_UNITE_MED = ru.ID_UNITE_MEDICALE
WHERE TRIM(u.CODE_UNITE_MED) IN ('5701', '5720', '5015', '5010')
```

- Le drapeau UHCD de TB_UNITE ne repère rien : il n'est jamais 'O' (drapeaux-cora-valeurs-propres).
- Un GHS 5xxx ne suffit pas à repérer l'UHCD : des UM d'obstétrique et d'hôpital de jour ont aussi des RSS en 5xxx (tarif-ghs-par-ghm-et-code-ghs).
- Ces codes sont aussi des codes d'UF : dans CORA, chacun est une UF de TB_UNITE liée à l'UM de même code et de même libellé (20261014-structure-uf-urgences-resultat), et un mouvement (TB_MVT.ID_UNITE_M) y porte ce code comme UF. Ce claim lit l'UM du RUM, dans le contexte cora ; hors de ce contexte (EDSaN par exemple), ne pas lire ces codes comme des UM sans le vérifier.

## Ce qui l'appuie

RSS finis en 2025 (20261027-tarif-ghs-5xxx-uhcd-resultat) : 26 218 des 30 371 RSS groupés dans un GHS 5xxx n'ont qu'un RUM. Parmi les quinze UM qui en ont le plus, quatre sont des urgences : 5701 (S.A.U. urgences médicales, 14 934 RSS), 5720 (urgences St Julien, 3 130), 5015 (urgences et UHCD pédiatriques médicales, 1 194) et 5010 (urgences et UHCD pédiatriques chirurgicales, 274). Dans chacune, moins de 10 RSS d'un seul RUM sont dans un autre GHS.

Des sources secondaires décrivent ce GHS depuis la campagne MCO 2021 : un séjour dont toutes les UM relèvent de l'UHCD est payé par un GHS dédié, un par racine de GHM, au même prix quelle que soit sa durée. C'est la ligne 5xxx commune à la racine, sans borne, de PMSI_LIB_GHS_TARIF (tarif-ghs-par-ghm-et-code-ghs).

Points ouverts : le texte officiel (arrêté du 19 février 2015 dit « forfaits », notice technique de financement de l'ATIH) n'est pas lu ; la liste des UM peut être incomplète, car une UM de moins de 100 RSS d'un seul RUM en 5xxx en 2025 n'est pas nommée dans la preuve ; les UM de maternité 6163 et 6167 ont aussi presque tous leurs RSS d'un seul RUM en 5xxx, pour une raison non établie (piste de Francesco : le GHS ordinaire de certains GHM d'obstétrique est numéroté 5xxx, 5500 pour 14Z15Z ; éprouvée par 20261027-tarif-ghs-5xxx-seul-ou-second) ; dans TB_UNITE, ces quatre UF et 5802 (S.A.U. urgences chirurgicales) ont TYPE_AUTORISATION 07A ou 07B, seules parmi les UF lues par 20261014-structure-uf-urgences : si 07 est le type d'autorisation de l'UHCD au PMSI (texte non lu), il repère ces UF sans liste, et 5802, absente des quinze UM de la preuve, manque peut-être ; les RSS de plusieurs RUM passés par ces UM ne sont pas comptés ; seule l'année 2025 est lue.
