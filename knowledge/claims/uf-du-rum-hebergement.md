---
review:
  status: reviewed
  by: Francesco
  at: 2026-11-15
  work: "effectifs et parts recalculés depuis 20261022-rum-uf-colonnes-remplissage-resultat et 20261022-rum-uf-attrib-par-annee-resultat, mêmes chiffres ; jointure corrigée (TB_UNITE.ID_UNITE, comme dans la requête, et non le code) ; ID_UF_ATTRIB : moins de 10 par an, et non aucun ; guide MCO 2026 lu (20261115-guide-mco-um-du-rum) ; Francesco confirme que l'UF d'hébergement de CORA est l'unité où le patient se trouve"
  fingerprint: 235d85ecb542
id: uf-du-rum-hebergement
kind: empirical
author: Pierre
statement: "Dans CORA, l'UF d'un RUM se lit dans TB_SYNTH_RUM.ID_UNITE_HEBERG (renseignée pour 100 % des RUM de 2022 à 2026, chaque valeur trouvant une ligne de TB_UNITE) : UF_ATTRIB est vide pour tous les RUM de la période, et ID_UF_ATTRIB pour tous sauf moins de 10 par an."
scope: "CORA de production (CWPROD, schéma CORA_REC), TB_SYNTH_RUM, RUM terminés de janvier à septembre de 2022 à 2026, lus le 2026-10-22"
refuted_if: "pour une année de 2022 à 2026, plus de 0,1 % des RUM ont ID_UNITE_HEBERG vide ou sans ligne dans TB_UNITE, ou plus de 10 RUM ont ID_UF_ATTRIB renseigné"
maturity: observed
lifecycle: active
terms: [cora:uf, cora:rum]
tables: [cora:TB_SYNTH_RUM, cora:TB_UNITE]
supported_by: [20261022-rum-uf-colonnes-remplissage-resultat, 20261022-rum-uf-attrib-par-annee-resultat, 20261115-guide-mco-um-du-rum]
depends_on: [joindre-uf-par-code]
---
## Pour s'en servir

Pour rattacher un RUM à une UF, prendre ID_UNITE_HEBERG et le joindre à TB_UNITE.ID_UNITE : c'est un identifiant, pas un code. Le code d'UF sert pour les mouvements et les séjours (joindre-uf-par-code), pas ici. Ne pas utiliser ID_UF_ATTRIB, vide. ID_UNITE_RESP_MED (UF du responsable médical) n'est pas renseignée partout : 23 % des RUM en 2022, 96 % en 2025 ; elle ne convient pas pour un suivi sur plusieurs années.

Le pôle d'un RUM ne se déduit pas de cette UF : il vient du rattachement de son UM au pôle.

## Ce qui l'appuie

Pour 162 257 RUM en 2022 à 185 035 en 2026, ID_UNITE_HEBERG est renseignée et trouve une ligne de TB_UNITE chaque année ; la jointure se fait sur TB_UNITE.ID_UNITE, et UF_ATTRIB n'est renseignée pour aucun RUM (20261022-rum-uf-colonnes-remplissage-resultat). ID_UF_ATTRIB l'est pour moins de 10 RUM par an (20261022-rum-uf-attrib-par-annee-resultat). ID_UNITE_RESP_MED : 37 667 RUM en 2022, 76 309 en 2023, 165 508 en 2024, 175 199 en 2025, 177 400 en 2026.

Le guide méthodologique MCO 2026 demande que le RUM porte l'unité où le patient est physiquement hospitalisé, même quand le médecin qui le soigne dépend d'une autre unité (20261115-guide-mco-um-du-rum) : l'unité d'hébergement est celle que la règle désigne, pas celle du responsable médical.

Points ouverts : non confronté à la définition d'« UF d'hébergement » par l'éditeur du DPI.
