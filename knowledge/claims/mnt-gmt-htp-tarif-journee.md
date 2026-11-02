---
review: unreviewed
id: mnt-gmt-htp-tarif-journee
kind: empirical
author: Pierre
statement: "Pour un RHS de HTP, TB_MVT_SSR_SEM.MNT_GMT est le tarif de la journée de son GME ; MNT_GMT_HEBDO vaut 0 et les tables de facturation SMR de CORA (TB_RSF_FACT, TB_RSF_FACT_RHS) sont vides, donc ni l'une ni les autres ne donnent un montant facturé."
scope: "CORA de production (CWPROD, schéma CORA_REC), RHS de HTP (TYPE_HOSPIT_SSR = 2) de TB_MVT_SSR_SEM dont la semaine débute en 2025, lus le 2026-10-20 ; statistiques Oracle pour les tables de facturation"
refuted_if: "en 2025, la somme de MNT_GMT d'au moins 10 RHS d'un même GME de HTP s'écarte de plus de 1 % de leur nombre multiplié par le tarif de la journée de ce GME (ATIH, annexes de l'arrêté tarifaire 2025)"
maturity: observed
lifecycle: active
terms: [cora:rhs, pmsi:htp]
tables: [cora:TB_MVT_SSR_SEM, cora:TB_RSF_FACT, cora:TB_RSF_FACT_RHS]
supported_by: [20261020-rhs-htp-gn-gr-montants-2025-resultat, 20261020-tarifs-gmt-2025-gn0127-gn0406-gn1909-htp, 20261020-catalogue-ssr-htp-resultat]
depends_on: [htp-smr-type-hospit-ssr]
---
## Pour s'en servir

Pour valoriser de la HTP, prendre `MNT_GMT` du RHS, ou le tarif de l'ATIH du GME (annexe de l'arrêté tarifaire de l'année) multiplié par les journées de présence : les deux concordent. Ne pas lire `MNT_GMT_HEBDO` (0 en HTP) ni chercher un montant facturé dans TB_RSF_FACT ou TB_RSF_FACT_RHS (vides). Aucun coefficient géographique n'est à appliquer pour retrouver les montants de CORA.

## Ce qui l'appuie

Le montant moyen par RHS de 2025 est de 310,65 € pour le GME 0127IA0 (112 765,11 € pour 363 RHS) contre un tarif de 310,77 €, de 283,91 € pour 0127JA0 contre 284,14 €, de 220,42 € pour 0406IA0 contre 220,51 € et de 298,72 € pour 1909LA0 contre 298,83 € (20261020-rhs-htp-gn-gr-montants-2025-resultat, 20261020-tarifs-gmt-2025-gn0127-gn0406-gn1909-htp) : moins de 0,1 % d'écart. MNT_GMT_HEBDO_SOMME vaut 0 pour toutes les cellules visibles. Le catalogue donne 0 ligne, d'après les statistiques Oracle, pour TB_RSF_FACT et TB_RSF_FACT_RHS (20261020-catalogue-ssr-htp-resultat).

Points ouverts : l'écart de 0,4 % pour le GME 0409LA0 (163,32 € contre 164,03 €) n'est pas expliqué, peut-être une version de tarif plus ancienne en début d'année ; les comptages des tables de facturation sont des statistiques Oracle, non des comptages exacts.
