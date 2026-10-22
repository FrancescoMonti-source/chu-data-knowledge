---
review: unreviewed
id: uf-du-rum-hebergement
kind: empirical
author: Pierre
statement: "Dans CORA, l'UF d'un RUM se lit dans TB_SYNTH_RUM.ID_UNITE_HEBERG (renseignée pour 100 % des RUM de 2022 à 2026, chaque valeur trouvant une ligne de TB_UNITE) : ID_UF_ATTRIB et UF_ATTRIB sont vides pour tous les RUM de la période."
scope: "CORA de production (CWPROD, schéma CORA_REC), TB_SYNTH_RUM, RUM terminés de janvier à septembre de 2022 à 2026, lus le 2026-10-22"
refuted_if: "pour une année de 2022 à 2026, plus de 0,1 % des RUM ont ID_UNITE_HEBERG vide ou sans ligne dans TB_UNITE, ou plus de 10 RUM ont ID_UF_ATTRIB renseigné"
maturity: observed
lifecycle: active
terms: [cora:uf, cora:rum]
tables: [cora:TB_SYNTH_RUM, cora:TB_UNITE]
supported_by: [20261022-rum-uf-colonnes-remplissage-resultat, 20261022-rum-uf-attrib-par-annee-resultat]
depends_on: [joindre-uf-par-code]
---
## Pour s'en servir

Pour rattacher un RUM à une UF, prendre ID_UNITE_HEBERG et le joindre à TB_UNITE par le code (voir joindre-uf-par-code). Ne pas utiliser ID_UF_ATTRIB, vide. ID_UNITE_RESP_MED (UF du responsable médical) n'est pas renseignée partout : 23 % des RUM en 2022, 96 % en 2025 ; elle ne convient pas pour un suivi sur plusieurs années.

Le pôle d'un RUM ne se déduit pas de cette UF : il vient du rattachement de son UM au pôle.

## Ce qui l'appuie

Pour 162 257 RUM en 2022 à 185 035 en 2026, ID_UNITE_HEBERG est renseignée et trouve une ligne de TB_UNITE chaque année ; ID_UF_ATTRIB et UF_ATTRIB ne sont renseignées pour aucun RUM (20261022-rum-uf-colonnes-remplissage-resultat). ID_UNITE_RESP_MED : 37 667 RUM en 2022, 76 309 en 2023, 165 508 en 2024, 175 199 en 2025, 177 400 en 2026.

Points ouverts : non confronté à la définition d'« UF d'hébergement » par l'éditeur du DPI.
