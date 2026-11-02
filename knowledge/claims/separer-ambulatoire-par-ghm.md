---
review: unreviewed
id: separer-ambulatoire-par-ghm
kind: empirical
author: Pierre
statement: "Dans CORA, TB_SYNTH_RSS.TYPE_PEC est toujours vide et ne sépare rien ; parmi les RSS de 0 nuit, la chirurgie et les actes interventionnels ambulatoires se reconnaissent au GHM, de type C ou K et de niveau J, l'hôpital de jour de médecine aux GHM de type M."
scope: "CORA de production (CWPROD, schéma CORA_REC), RSS de TB_SYNTH_RSS finis de 2018 à 2025, lus le 2026-10-15"
refuted_if: "TYPE_PEC est renseigné pour plus de 1 % des RSS d'une année, ou plus de 10 % des RSS de 0 nuit de type C ont un autre niveau que J"
maturity: observed
lifecycle: active
terms: [cora:rss]
tables: [cora:TB_SYNTH_RSS]
supported_by: [20261015-classes-rss-resultat, 20261019-ghm-sixieme-duree-rss-resultat]
depends_on: [type-prise-en-charge-mco]
---
## Pour s'en servir

Pour séparer les séjours de 0 nuit que type-prise-en-charge-mco classe en ambulatoire :

- **Chirurgie ambulatoire et actes interventionnels :** lettre de type C (chirurgical) ou K (actes non opératoires), et niveau J (ambulatoire) : `SUBSTR(TRIM(CODE_GHM), 1, 1) IN ('C', 'K') AND SUBSTR(TRIM(CODE_GHM), -1) = 'J'`.
- **Hôpital de jour de médecine :** lettre de type M, quel que soit le niveau (Z, T, 1…).
- **Le reste :** types Z (CMD 28 mise à part) et les RSS de type C ou K sans niveau J. Ils sont peu nombreux ; les garder à part et les compter.

CODE_GHM a toujours 4 caractères, sans la CMD (le GHM complet est `TRIM(CODE_CMD) || TRIM(CODE_GHM)`) : la lettre de type est le premier caractère, le niveau le dernier. Seuls 1 à 4 sont des niveaux de sévérité ordonnés ; J, T, Z, E et A à D n'en sont pas. Ne pas se servir de TYPE_PEC.

## Ce qui l'appuie

RSS par année de fin, classe de type-prise-en-charge-mco et GHM (20261015-classes-rss-resultat) : TYPE_PEC est vide pour tous les RSS de chaque année de 2018 à 2025. Parmi les RSS de 0 nuit, de type C : 6 919 de niveau J en 2018, 6 288 en 2021, 9 280 en 2025, et de 160 à 380 par an d'un autre niveau (2 à 4 %) ; de type K et de niveau J : 4 883 en 2018, 4 169 en 2021, 6 224 en 2025 ; de type M : surtout de niveau T (environ 29 000 par an en 2018 et 2021) et Z (8 368 en 2018, 18 313 en 2025). Les séances (CMD 28) sont toutes de type et de niveau Z.
