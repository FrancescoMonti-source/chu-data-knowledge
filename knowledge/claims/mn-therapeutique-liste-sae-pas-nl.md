---
review: unreviewed
id: mn-therapeutique-liste-sae-pas-nl
kind: documentary
author: Pierre
statement: "Repérer la médecine nucléaire thérapeutique par la liste fermée du bordereau MEDNUC de la SAE (FENL001, KCNL003, KCNL004, PANL001, PBLL001, ZZNL016, et la radioembolisation hépatique EDLL001, EDLL002, comptée à part), jamais par un motif __NL% : la technique L couvre aussi la radiothérapie externe et la curiethérapie."
scope: "CCAM descriptive à usage PMSI 2026, SAE 2025 ; actes des séjours et des consultations externes du PMSI MCO, dont le SNDS"
maturity: documented
lifecycle: active
terms: [pmsi:acte-ccam, pmsi:medecine-nucleaire]
tables: [snds:T_MCOaaA, snds:T_MCOaaFMSTC]
supported_by: [20261117-sae-mednuc-riv, 20261117-sae-mednuc-sirt, 20261117-ccam-nl-radiotherapie-curietherapie, 20261117-ccam-edll-radioembolisation]
depends_on: []
---
## Pour s'en servir

Filtrer sur une liste d'égalités : `IN ('FENL001','KCNL003','KCNL004','PANL001','PBLL001','ZZNL016')` pour la radiothérapie interne vectorisée et l'iode 131 (KCNL003 : hyperthyroïdie, KCNL004 : carcinome thyroïdien) ; ajouter `'EDLL001','EDLL002'` pour la radioembolisation hépatique, et dire si l'étude la compte (la SAE la compte à part). Ne jamais filtrer `LIKE '__NL%'`. Pour la médecine nucléaire diagnostique : mn-diagnostique-ccam-ql-faux-positifs.

## Ce qui l'appuie

Le bordereau MEDNUC de la SAE 2025 sélectionne les séjours de RIV par ces six codes, ceux d'iode 131 par KCNL003 et KCNL004 (20261117-sae-mednuc-riv), et ceux de radioembolisation par EDLL001 et EDLL002 (20261117-sae-mednuc-sirt). La technique L se retrouve dans les séances d'irradiation externe (ZZNL048) et la curiethérapie (JKNL003) (20261117-ccam-nl-radiotherapie-curietherapie) : un motif __NL% compterait la radiothérapie comme de la médecine nucléaire. Il raterait aussi PBLL001 (synoviorthèse) et la radioembolisation, dont la 3e lettre est L (20261117-ccam-edll-radioembolisation).

Points ouverts : codes créés après la CCAM 2026 non vérifiés ; ZZNL016 est un code générique (injection intraveineuse d'un agent radio-isotopique) dont le produit (lutétium 177, iode 131-MIBG…) n'est pas lisible dans le PMSI.
