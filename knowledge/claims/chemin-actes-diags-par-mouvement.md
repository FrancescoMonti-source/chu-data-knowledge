---
review: unreviewed
id: chemin-actes-diags-par-mouvement
kind: empirical
author: Pierre
statement: "Dans CORA, pour récupérer les actes et les diagnostics d'un séjour, passer par le mouvement (TB_ACTE.ID_MVT ou TB_DIAG.ID_MVT → TB_MVT.ID_SEJOUR) : ce chemin les voit presque tous. Le chemin par le RSS (mouvement présent dans TB_MVT_RUM) ne voit que ce qui a été groupé : depuis 2021, il perd plus de la moitié des actes (externes, séances) ; il ne sert que pour le champ PMSI."
scope: "CORA de production (CWPROD, schéma CORA_REC), actes et diagnostics datés de 2014 à 2025, lus le 2026-10-14"
refuted_if: "pour une année depuis 2021, plus de 60 % des actes ont leur mouvement dans TB_MVT_RUM, ou plus de 1 % des actes ou des diagnostics ont un ID_MVT absent de TB_MVT"
maturity: observed
lifecycle: active
terms: [cora:acte, cora:diagnostic, cora:mouvement, cora:rss]
tables: [cora:TB_ACTE, cora:TB_DIAG, cora:TB_MVT, cora:TB_MVT_RUM, cora:TB_SYNTH_RSS]
supported_by: [20261014-chemin-rss-actes-diags-resultat]
depends_on: []
---
## Pour s'en servir

**Chemin à prendre :** du séjour à ses mouvements, puis de chaque mouvement à ses actes et diagnostics, par ID_MVT, le lien principal de TB_ACTE et TB_DIAG.

```sql
FROM CORA_REC.TB_SEJOUR s
JOIN CORA_REC.TB_MVT m  ON m.ID_SEJOUR = s.ID_SEJOUR
JOIN CORA_REC.TB_ACTE a ON a.ID_MVT = m.ID_MVT      -- ou TB_DIAG d ON d.ID_MVT = m.ID_MVT
```

**Seule exception, le champ PMSI :** pour ne garder que ce qui est entré dans un RSS (le DP du RSS, les actes groupés), filtrer les mouvements présents dans TB_MVT_RUM, et le dire.

**À ne pas utiliser :**
- **Le chemin par le RSS pour compter tous les actes ou diagnostics :** il écarte environ 400 000 actes par an depuis 2021, et presque tout en 2016.
- **DATE_DIAG pour dater un diagnostic :** dater par le mouvement (dater-diagnostic-par-mouvement).
- **Mélanger les deux chemins :** une série qui compare des années garde le même chemin d'un bout à l'autre.

Un acte ou un diagnostic dont l'ID_MVT est absent de TB_MVT est rare (moins de 800 par an en 2018-2019, moins de 10 les autres années) : on peut l'ignorer en le disant.

## Ce qui l'appuie

Actes par année de DATE_ACTE (20261014-chemin-rss-actes-diags-resultat) : le chemin par le mouvement les voit tous, sauf 785 en 2018 et 653 en 2019 dont le mouvement manque mais le séjour existe. La part vue par le RSS est de 99,4 % en 2014, 97,7 % en 2015, 3,5 % en 2016 (10 077 sur 284 199), 98,8 % en 2018, 99,0 % en 2019, 62,9 % en 2020, puis de 47,6 % à 49,4 % de 2021 à 2025 (404 320 sur 831 421 en 2025).

Diagnostics par année de DATE_DIAG : vus par le RSS à 76 % et 73 % en 2014-2015, 2,7 % en 2016, 99 % de 2018 à 2020, 96,0 % en 2023 et 95,5 % en 2024 ; presque aucun en 2021, 2022 et 2025, années où presque aucun diagnostic n'a de DATE_DIAG.
