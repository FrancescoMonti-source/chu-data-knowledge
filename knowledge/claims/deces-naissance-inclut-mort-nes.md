---
review: unreviewed
id: deces-naissance-inclut-mort-nes
kind: empirical
author: Francesco
statement: "Dans CORA, les séjours de naissance sortis par décès (TB_SEJOUR.MODE_SORTIE = '9') comptent les enfants mort-nés, qui portent un code P95, et ce sont la grande majorité des décès à J0 : pour les décès d'enfants nés vivants, exclure les séjours qui portent P95."
scope: "CORA de production (CWPROD, schéma CORA_REC), séjours sortis de 2018 à 2025, lus le 2026-11-02"
refuted_if: "pour une période de 2018 à 2025, moins de la moitié des enfants décédés à J0 dans leur séjour de naissance portent un code P95"
maturity: observed
lifecycle: active
terms: [pmsi:mort-ne, pmsi:sejour-naissance, pmsi:mode-entree-sortie, cora:sejour]
tables: [cora:TB_SEJOUR, cora:TB_PATIENT, cora:TB_MVT, cora:TB_DIAG]
supported_by: [20261102-deces-0-28-jours-resultat, 20261102-mortnes-dates-sortie, 20261102-mortnes-p95-extensions]
depends_on: []
---
## Pour s'en servir

Un décès de nouveau-né né vivant : séjour de naissance avec `MODE_SORTIE = '9'` et aucun diagnostic P95 (`CODE_DIAG LIKE 'P95%'`, par TB_DIAG.ID_MVT → TB_MVT.ID_SEJOUR). Un enfant mort-né : les mêmes séjours, avec P95 en DP. Sans ce filtre, un comptage de la mortalité néonatale à J0 compte surtout des mort-nés.

## Ce qui l'appuie

L'instruction de 2021 donne au séjour d'un mort-né des dates d'entrée, de sortie, de naissance et de décès identiques et un mode de sortie 9 (20261102-mortnes-dates-sortie), et un DP P95 (20261102-mortnes-p95-extensions) : rien dans le mode de sortie ne le sépare d'un enfant né vivant décédé le jour même.

Enfants décédés à J0 (20261102-deces-0-28-jours-resultat) : en 2018-2021, 330 dont le séjour sorti par décès commence le jour de la naissance, et 285 qui portent P95 ; en 2022-2025, 347 et 311. De J1 à J27, P95 est presque absent.

Points ouverts : la mesure compte les enfants qui portent P95 sur un mouvement, pas seulement en DP ; un enfant né vivant qui porterait P95 par erreur serait écarté à tort, ce qui n'est pas mesuré.
