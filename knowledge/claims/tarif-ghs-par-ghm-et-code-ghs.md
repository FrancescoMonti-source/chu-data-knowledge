---
review: unreviewed
id: tarif-ghs-par-ghm-et-code-ghs
kind: empirical
author: Francesco
statement: "Dans CORA, PMSI_LIB_GHS_TARIF porte presque toujours plusieurs lignes valides pour un même GHM, dont un GHS 5xxx commun à la racine et moins cher : pour le tarif d'un RSS, joindre à la fois le GHM complet (TRIM(GHS)) et le CODE_GHS du RSS ; par le GHM seul, chaque RSS trouve deux lignes ou plus, et le plus petit PRIX sous-estime le tarif."
scope: "CORA de production (CWPROD, schéma CORA_REC), lignes de PMSI_LIB_GHS_TARIF valides au 2026-06-30 ; RSS de TB_SYNTH_RSS finis d'octobre 2025 à août 2026, d'au moins une nuit, hors GHS 9999 et CMD 90 et 28, tarif lu à la date de fin du RSS ; lus le 2026-10-23"
refuted_if: "au 2026-06-30, moins de la moitié des GHM ont deux lignes valides ou plus dans PMSI_LIB_GHS_TARIF, ou, joint par le GHM et le CODE_GHS à sa date de fin, le rapport médian entre MONTANT_GHS et PRIX s'écarte de 1 de plus de 5 %"
maturity: observed
lifecycle: active
terms: [cora:rss, pmsi:ghm]
tables: [cora:PMSI_LIB_GHS_TARIF, cora:TB_SYNTH_RSS]
supported_by: [20261023-tarif-ghs-lignes-et-ratio-resultat]
depends_on: []
challenges: [tarif-ghs-jointure-couverture]
---
## Pour s'en servir

Pour le tarif d'un RSS `s` à une date `d`, joindre par les deux clés :

```sql
JOIN CORA_REC.PMSI_LIB_GHS_TARIF t
  ON TRIM(t.GHS) = TRIM(s.CODE_CMD) || TRIM(s.CODE_GHM)
 AND TRIM(t.CODE_GHS) = TRIM(s.CODE_GHS)
 AND t.DATE_DEBUT <= d AND t.DATE_FIN >= d
```

- La colonne GHS porte le GHM sur 6 caractères ; CODE_GHS porte le numéro du GHS sur 4 caractères, comme TB_SYNTH_RSS.CODE_GHS.
- Ne pas prendre, pour un GHM, le plus petit PRIX ni une ligne quelconque : c'est le plus souvent le GHS 5xxx de la racine.
- À tarif constant (des RSS de plusieurs années au tarif d'une même date), garder le GHM et le CODE_GHS de chaque RSS et prendre la ligne valide à cette date. Compter à part les RSS dont le couple n'a pas de ligne à cette date, et les RSS de GHS 9999.

## Ce qui l'appuie

Lignes valides au 2026-06-30 (20261023-tarif-ghs-lignes-et-ratio-resultat) : 2 205 GHM ont deux lignes, 426 trois ou plus, 25 une seule.

Dans les sept racines lues (04C02, 05C02, 05C03, 05C10, 06C03, 06C04, 07C09), chaque GHM a la ligne de son GHS, et une ligne d'un GHS 5xxx commun à toute la racine, de borne basse 0 et de borne haute 999, 1,9 à 5,3 fois moins chère. Par exemple, 04C021 a le GHS 1005 à 8 038,05 € et le GHS 5181 à 4 327,69 €. Les GHM de 05C02 et 05C03 ont en plus deux GHS propres : 05C021 a les GHS 1430 à 17 719,34 € et 1524 à 20 945,39 €. Écarter le GHS 5xxx ne suffit donc pas à trouver la ligne d'un RSS.

RSS finis d'octobre 2025 à août 2026, d'au moins une nuit, hors GHS 9999 : joints par le GHM et le CODE_GHS à leur date de fin, 63 283 RSS sur 63 334 trouvent leur ligne, et le rapport médian entre MONTANT_GHS et PRIX vaut 1. Avec le plus petit PRIX du GHM, ce rapport vaut 3,494.

Ce claim conteste tarif-ghs-jointure-couverture (unreviewed). Sa clé, le GHM complet « pas CODE_GHS », prend la bonne colonne pour le GHM, mais un agent qui la suit obtient deux lignes ou plus par RSS. Sa mesure de couverture, qui dit seulement si un RSS trouve au moins une ligne, n'en dépend pas.

Points ouverts : la médiane dit que le PRIX égale MONTANT_GHS pour le RSS typique, pas pour tous : la part des RSS dont les deux montants diffèrent n'est pas mesurée ; le rôle des GHS 5xxx n'est pas établi (les RSS groupés dans un GHS 5xxx n'ont pas été comptés), ni le sens de GET_LIBELLE ('O' sur une seule ligne par GHM dans les racines lues) ; la mesure ne porte que sur les RSS d'octobre 2025 à août 2026 et les tarifs de 2026, pas sur les années précédentes ; le nombre de lignes valides par couple GHM et CODE_GHS à une même date n'est pas compté (la requête garde le plus petit PRIX du couple, par prudence).
