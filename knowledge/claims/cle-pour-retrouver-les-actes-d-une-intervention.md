---
review: unreviewed
id: cle-pour-retrouver-les-actes-d-une-intervention
kind: empirical
author: Pierre
statement: "Dans CORA, pour retrouver les actes d'une intervention, joindre d'abord TB_ACTE.NO_INTERVENTION à TB_INTERVENTION.ID_INTERVENTION, puis compléter par les actes du même séjour qui portent le même NO_INTERVENTION_CCAM que l'intervention ; ne pas utiliser TB_INTERVENTION.NO_INTERVENTION_CCAM comme seule clé, car il est vide pour une partie des interventions."
scope: "CORA de production (CWPROD, schéma CORA_REC), TB_ACTE et TB_INTERVENTION, actes rattachés par NO_INTERVENTION, novembre 2023 au 2026-10-19, lu le 2026-10-19"
refuted_if: "plus de 5 % des actes rattachés de mai 2025 à septembre 2026 ont un NO_INTERVENTION_CCAM différent de celui de leur intervention"
maturity: observed
lifecycle: active
terms: [cora:acte, cora:intervention]
tables: [cora:TB_ACTE, cora:TB_INTERVENTION]
supported_by: [20261019-concordance-ccam-acte-intervention-resultat, 20261019-interventions-champs-flux-resultat, 20261019-interventions-par-bloc-resultat]
depends_on: [grouper-actes-par-no-intervention-ccam, interventions-cora-flux-oproom]
---
## Pour s'en servir

Question : quelle clé utiliser pour retrouver les actes d'une intervention de TB_INTERVENTION : NO_INTERVENTION ou NO_INTERVENTION_CCAM ?

Réponse : les deux, dans cet ordre.

1. Clé principale : TB_ACTE.NO_INTERVENTION = TB_INTERVENTION.ID_INTERVENTION. La jointure aboutit toujours (moins de 10 actes sans intervention par mois), mais le numéro n'existe presque que pour les actes saisis dans CORA (voir nombre-actes-par-intervention-selon-saisie-et-chainage).
2. Clé de complément : TB_ACTE.NO_INTERVENTION_CCAM, dans le même séjour. Prendre le numéro CCAM de l'intervention (TB_INTERVENTION.NO_INTERVENTION_CCAM) s'il est renseigné ; sinon celui d'un acte déjà rattaché par NO_INTERVENTION. Ajouter les actes du séjour qui portent ce numéro (grouper-actes-par-no-intervention-ccam).
3. Pour un acte sans aucun de ces numéros : rattacher par séjour, jour et site de bloc (rattacher-actes-bloc-sans-cle).

Ne pas compter sur NO_INTERVENTION_CCAM seul : TB_INTERVENTION.NO_INTERVENTION_CCAM est vide pour une partie des interventions du flux OpRoom, et avant mai 2025 le numéro de l'acte diffère souvent de celui de son intervention (de janvier à août 2024, environ un acte rattaché sur cinq).

## Ce qui l'appuie

Actes rattachés par NO_INTERVENTION, joints à TB_INTERVENTION (20261019-concordance-ccam-acte-intervention-resultat). Chaque mois des 36 mois (novembre 2023 à octobre 2026), moins de 10 actes ont une intervention introuvable, un NO_INTERVENTION_CCAM vide, ou une intervention au numéro vide : les classes utiles sont « identique » et « différent ».

- **Janvier à août 2024 :** 791 identiques et 197 différents (197 sur 988, soit 20 % de différents), de 9 % à 40 % selon le mois.
- **Septembre 2024 à avril 2025 :** moins de 10 différents par mois, sur 78 à 368 actes identiques par mois (le total est masqué pour 6 de ces 8 mois).
- **Mai 2025 à septembre 2026 :** 41 414 identiques et 1 195 différents, soit 2,8 % de différents (1 195 sur 42 609) : 3,2 % de mai à décembre 2025 (448 sur 14 203) et 2,6 % de janvier à septembre 2026 (747 sur 28 406) ; de 1,0 % à 5,5 % selon le mois (5,5 % en janvier 2026, 172 sur 3 117), et 1,0 à 1,3 % de juillet à septembre 2026.

Remplissage de TB_INTERVENTION.NO_INTERVENTION_CCAM pour l'application 16 (20261019-interventions-champs-flux-resultat) : de 31 sur 93 interventions en décembre 2024 (33 %) à 79 sur 89 en juin 2024 (89 %), 100 sur 121 en mars 2024 (83 %), 703 sur 1 311 en mai 2025 (54 %), 2 044 sur 2 977 en septembre 2026 (69 %) ; à partir de mai 2025 le nombre total d'interventions est masqué, la part est calculée sur les interventions à entrée en salle renseignée (égales au total dans les 18 mois où il est visible). Ce remplissage suit de près la part d'interventions qui ont un acte rattaché (54 % contre environ 51 % en mai 2025, 653 sur 1 279 ; 72 % contre environ 70 % en mars 2026, 2 167 sur 3 105, sur des populations voisines mais pas identiques) : le numéro de l'intervention est vide surtout quand aucun acte n'est encore rattaché, et moins de 10 actes rattachés par mois ont une intervention au numéro vide. Les interventions sans application ont leur numéro renseigné de janvier à avril 2025 et en janvier 2026 (16, 14, 99, 45 et 15 interventions, toutes), mais 14 sur 24 seulement en août 2026 ; les autres mois, leur nombre est masqué ou inférieur à 10.

Points ouverts : l'écart d'environ 3 % n'est pas expliqué (une intervention peut avoir plusieurs numéros, ou l'acte a été regroupé autrement) ; la mesure ne porte que sur des actes déjà rattachés, elle ne dit pas si des interventions au numéro renseigné ont des actes de même NO_INTERVENTION_CCAM sans NO_INTERVENTION (requête de suite : actes joints à TB_INTERVENTION par NO_INTERVENTION_CCAM seul, par mois). Les écarts de janvier à août 2024 portent sur 89 à 121 interventions par mois (application 16), d'un seul bloc (2618 : 1 249 interventions sur 1 250 en 2024).

Point ouvert : l'étape 2 (compléter par NO_INTERVENTION_CCAM) s'appuie sur la concordance mesurée ci-dessus et sur grouper-actes-par-no-intervention-ccam, mais le nombre d'actes qu'elle ajoute à ceux rattachés par NO_INTERVENTION n'est pas mesuré ; requête de suite : par mois, actes joints à TB_INTERVENTION par NO_INTERVENTION_CCAM seul.
