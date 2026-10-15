---
review: unreviewed
id: chainer-oproom-cora
kind: empirical
author: Pierre
statement: "Pour relier une intervention OpRoom à CORA, prendre dans TB_INTERVENTION.NO_INTERVENTION_EXT le nombre avant le tiret : c'est OR_INTERVENTIONS.I_KEY ; le chiffre après le tiret est la phase, et une intervention OpRoom peut avoir plusieurs lignes dans TB_INTERVENTION. Toutes les interventions du flux OpRoom ont ce numéro, sous la forme « nombre-chiffre »."
scope: "CORA de production (CWPROD, schéma CORA_REC), TB_INTERVENTION depuis novembre 2023, lue le 2026-10-15 ; correspondance avec OpRoom établie par DIM-code"
refuted_if: "une intervention de l'application 16 a un NO_INTERVENTION_EXT d'une autre forme que nombre-chiffre, ou le nombre ne se retrouve pas parmi les OR_INTERVENTIONS.I_KEY"
maturity: observed
lifecycle: active
terms: [cora:intervention, oproom:intervention]
tables: [cora:TB_INTERVENTION, cora:TB_ACTE, oproom:OR_INTERVENTIONS]
supported_by: [20261015-forme-no-intervention-ext-resultat, 20261015-dim-code-chainage-oproom]
depends_on: [interventions-cora-flux-oproom]
---
## Pour s'en servir

Le chaînage se fait en trois temps : extraire la clé côté CORA, la normaliser côté OpRoom, joindre les deux hors des bases (CORA et OpRoom sont deux bases Oracle distinctes). Les tables obtenues sont des données individuelles (séjours, interventions) : elles restent à l'hôpital, et seule une sortie agrégée et masquée en sort.

**1. Côté CORA, en SQL (Oracle) : la clé I_KEY de chaque intervention et ses actes.** Une intervention OpRoom a une ligne de TB_INTERVENTION par phase : le `DISTINCT` final les réunit. Les actes se relient de deux façons, réunies par `UNION` (un `OR` dans la jointure est très lent sur TB_ACTE).

```sql
WITH interv AS (
  SELECT TO_NUMBER(REGEXP_SUBSTR(TRIM(i.NO_INTERVENTION_EXT), '^[0-9]+')) AS I_KEY,
         i.ID_INTERVENTION, i.NO_INTERVENTION_CCAM, m.ID_SEJOUR
  FROM CORA_REC.TB_INTERVENTION i
  JOIN CORA_REC.TB_MVT m ON m.ID_MVT = i.ID_MVT
  WHERE REGEXP_LIKE(TRIM(i.NO_INTERVENTION_EXT), '^[0-9]+-[0-9]+$')
)
SELECT iv.I_KEY, iv.ID_SEJOUR, a.ID_ACTE, 'NO_INTERVENTION' AS LIEN
FROM interv iv
JOIN CORA_REC.TB_ACTE a ON TRIM(TO_CHAR(a.NO_INTERVENTION)) = TRIM(TO_CHAR(iv.ID_INTERVENTION))
UNION
SELECT iv.I_KEY, iv.ID_SEJOUR, a.ID_ACTE, 'NO_INTERVENTION_CCAM'
FROM interv iv
JOIN CORA_REC.TB_ACTE a ON a.NO_INTERVENTION_CCAM = iv.NO_INTERVENTION_CCAM
JOIN CORA_REC.TB_MVT ma ON ma.ID_MVT = a.ID_MVT AND ma.ID_SEJOUR = iv.ID_SEJOUR
```

**2. Côté OpRoom : la même clé.** Dans la base, c'est `OR_INTERVENTIONS.I_KEY`, tel quel. Dans un export Excel d'OpRoom, le « N° d'intervention » est complété par des zéros (`0000237355`) ou lu comme un décimal (`237355.0`) : garder les chiffres de la partie entière.

**3. Joindre, en Python (pandas) :**

```python
import re
import pandas as pd

RE_EXT = re.compile(r"^\s*(\d+)-\d+\s*$")          # '237355-0' -> 237355

def i_key_depuis_ext(v):
    m = RE_EXT.match(str(v)) if pd.notna(v) else None
    return int(m.group(1)) if m else None

def i_key_depuis_export(v):                        # '0000237355', 237355.0 -> 237355
    s = re.sub(r"\D", "", str(v).split(".")[0]) if pd.notna(v) else ""
    return int(s) if s else None

cora["I_KEY"] = cora["NO_INTERVENTION_EXT"].map(i_key_depuis_ext)   # si la clé n'est pas extraite en SQL
oproom["I_KEY"] = oproom["I_KEY"].map(i_key_depuis_export)
cles = cora.dropna(subset=["I_KEY"]).astype({"I_KEY": "int64"})[["I_KEY", "ID_INTERVENTION"]].drop_duplicates()
liens = oproom.merge(cles, on="I_KEY", how="left")  # ID_INTERVENTION vide : intervention non chaînée
```

**3 bis. Ou en R (base R, sans package) :**

```r
motif <- "^\\s*(\\d+)-\\d+\\s*$"
ext <- trimws(as.character(cora$NO_INTERVENTION_EXT))
cora$I_KEY <- ifelse(grepl(motif, ext), as.integer(sub(motif, "\\1", ext)), NA)
oproom$I_KEY <- as.integer(gsub("\\D", "", sub("\\..*$", "", as.character(oproom$I_KEY))))
cles <- unique(cora[!is.na(cora$I_KEY), c("I_KEY", "ID_INTERVENTION")])
liens <- merge(oproom, cles, by = "I_KEY", all.x = TRUE)
```

**Ce qu'il faut dire dans l'analyse :** la part des interventions OpRoom chaînées, et la période. Ce chaînage ne vaut que depuis que TB_INTERVENTION reçoit le flux OpRoom, presque complet depuis 2026 (interventions-cora-flux-oproom) ; avant, rapprocher par séjour et jour (#47).

## Ce qui l'appuie

Forme de NO_INTERVENTION_EXT depuis novembre 2023 (20261015-forme-no-intervention-ext-resultat), chaque chiffre remplacé par 9 : « 999999-9 » pour les 44 162 interventions de l'application 16 et pour 56 interventions sans application ; vide pour 354 interventions sans application ; aucune autre forme.

Que le nombre soit OR_INTERVENTIONS.I_KEY, et le second chiffre la phase, vient du chaînage écrit par Pierre dans DIM-code pour le mapping OpRoom → CCAM (20261015-dim-code-chainage-oproom). La kb de DIM-code parlait d'un numéro « sur 10 chiffres » : c'est la forme de l'export Excel d'OpRoom, pas celle de CORA.
