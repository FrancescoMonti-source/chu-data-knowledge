---
review: unreviewed
id: score-rr-htp-score-par-jour
kind: empirical
author: Pierre
statement: "Dans TB_MVT_SSR_SEM, SCORE_RR d'un RHS de HTP est le score de réadaptation par jour qui décide son groupe (très intense, intense, modérée) ; il vaut 0 quand le RHS n'a aucun acte pondéré, cas où PONDERATION_RR_RHS est vide."
scope: "CORA de production (CWPROD, schéma CORA_REC), RHS de HTP (TYPE_HOSPIT_SSR = 2) de TB_MVT_SSR_SEM dont la semaine débute en 2025, GN 0127 et 0406 pour le contrôle des seuils, lus le 2026-10-20"
refuted_if: "en 2025, au moins 10 RHS de HTP d'un même GN et d'un même groupe de réadaptation ont un SCORE_RR hors des seuils de ce GN et de ce groupe (ATIH, GR_infos 2025)"
maturity: observed
lifecycle: active
terms: [cora:rhs, pmsi:htp]
tables: [cora:TB_MVT_SSR_SEM]
supported_by: [20261020-rhs-htp-scores-par-gn-gr-2025-resultat, 20261020-seuils-htp-gn0127-gn0406]
depends_on: [htp-smr-type-hospit-ssr, rhs-htp-une-venue]
---
## Pour s'en servir

Pour reconstituer ou simuler le groupe de réadaptation d'un RHS de HTP, partir de `SCORE_RR` et des seuils du GN (ATIH, GR_infos de l'année) : très intense à partir du seuil haut, intense à partir du seuil bas, sinon modérée. Comme un RHS de HTP est une venue (rhs-htp-une-venue), le score d'une semaine est la moyenne des SCORE_RR de ses RHS, pondérée par les jours de présence. `PONDERATION_RR_RHS` et `PONDERATION_RR_TOTAL` sont vides pour les RHS sans acte pondéré : ne pas les prendre comme score sans les remplacer par 0.

## Ce qui l'appuie

Pour le GN 0127 (seuils 60 et 150), SCORE_RR des RHS très intenses va de 155 à 360, celui des intenses de 60 à 140, celui des modérés vaut 0. Pour le GN 0406 (seuils 90 et 210), il va de 220 à 540 pour les très intenses, de 110 à 195 pour les intenses, de 0 à 85 pour les modérés (20261020-rhs-htp-scores-par-gn-gr-2025-resultat, seuils lus dans 20261020-seuils-htp-gn0127-gn0406). Aucun RHS ne franchit un seuil du mauvais côté.

Points ouverts : le score n'est pas recalculé à partir des actes (TB_ACTE_CSARR.POIDS) ; les autres GN de HTP (seuils 60 et 150 ou 90 et 210 selon la table de l'ATIH) ne sont pas contrôlés.
