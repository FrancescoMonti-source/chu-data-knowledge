---
review: unreviewed
id: etat-envoi-dans-fichier-groupe
kind: empirical
author: Francesco
statement: "L'état d'un envoi MCO (ses RSS, leur GHM, leurs DAS) se lit dans son fichier groupé (.grp) : les versions groupées que CORA garde (TB_SYNTH_RSS, TB_HIST_SYNTH_RSS et leur LIGNES_GRP) ont moins de RSS et moins de DAS que le fichier, et font passer pour récents des DAS saisis avant l'envoi."
scope: "CORA de production (CWPROD, schéma CORA_REC) et fichier groupé de l'envoi M8 2026 (20261002_074740_RSS_Final), RSS MCO sortis de janvier à août 2026, lus le 2026-10-15"
refuted_if: "pour un envoi, les versions de CORA groupées avant l'heure de son fichier donnent, chaque mois, les RSS et les DAS du fichier à 1 % près"
maturity: observed
lifecycle: active
terms: [pmsi:envoi, cora:rss, cora:diagnostic]
tables: [cora:TB_SYNTH_RSS, cora:TB_HIST_SYNTH_RSS, cora:TB_DIAG, cora:TB_HIST_DIAG]
supported_by: [20261015-grp-m8-themes-resultat, 20261015-m8-cora-par-mois-resultat, 20261015-das-m8-lignes-grp-vs-tb-diag-resultat, 20261015-forme-lignes-grp-resultat, 20261015-separateur-lignes-grp-resultat, 20261015-classes-m8-regroupes-resultat, 20261015-groupage-m8-hist-synth-rss-resultat]
depends_on: [longueur-ligne-rss-groupe]
---
## Pour s'en servir

Pour l'état d'un envoi, lire son fichier groupé à l'hôpital, par un script sur le fichier (method/queries.md, « Un script sur un fichier ») ; pour comparer deux états, prendre la routine revalorisation-entre-deux-etats. Le fichier se lit aux positions de la feuille de l'ATIH (longueur-ligne-rss-groupe) et se joint à CORA par NO_RSS (joindre-fichier-groupe-par-no-rss).

Ne pas prendre pour l'état d'un envoi la version de TB_SYNTH_RSS ou de TB_HIST_SYNTH_RSS groupée avant l'heure du fichier (jour de DATE_FABRICATION, heure de HEURE_FABRICATION), ni sa LIGNES_GRP : un gain mesuré depuis l'envoi compterait des DAS saisis avant lui. DATE_ENVOI_TUTELLE (« date de blocage ») ne marque pas non plus l'envoi : presque aucun RSS n'en a une.

Sans le fichier, CORA donne une approximation des DAS de l'envoi : ceux de TB_DIAG créés avant l'heure du fichier (DATE_CREAT), plus ceux de TB_HIST_DIAG créés avant et supprimés après. Le GHM de l'envoi, donc son niveau de sévérité, ne se lit que dans le fichier.

## Ce qui l'appuie

Fichier de l'envoi M8, horodaté le 2 octobre 2026 à 07:47:40 (20261015-grp-m8-themes-resultat), contre la version de chaque RSS que CORA avait groupée avant cette heure : la version actuelle, ou sa dernière copie dans TB_HIST_SYNTH_RSS (20261015-m8-cora-par-mois-resultat). Sur les RSS sortis de janvier à août 2026 :

- **RSS :** 130 737 dans le fichier, 128 373 dans CORA. Le fichier en a plus chaque mois, de 39 en janvier à 774 en août.
- **DAS** (couples RSS-code) : 286 555 dans le fichier, sur ses 130 737 RSS. Sur les 128 373 RSS de CORA : 268 670 dans LIGNES_GRP (6,2 % de moins), et 284 486 parmi les DAS de TB_DIAG créés avant la coupure, plus ceux de TB_HIST_DIAG supprimés après (0,7 % de moins).

Le fichier suit donc le codage du moment, pas le dernier groupage gardé par CORA : il a sans doute été regroupé à sa fabrication (inféré, non vérifié dans CORA).

La lecture de LIGNES_GRP n'est pas en cause. LIGNES_GRP garde le RSS groupé au format 123 (RUM 023), avec la CMD, le GHM et le n° de RSS aux positions du fichier (20261015-forme-lignes-grp-resultat), un RUM par ligne, les lignes séparées par CHR(13) (20261015-separateur-lignes-grp-resultat). Lus ainsi, ses DAS d'aujourd'hui sont ceux de TB_DIAG : 126 062 couples RSS-code des deux côtés, 22 dans TB_DIAG seulement, sur les RSS à un seul RUM. À M8, sur les mêmes RSS, 2 499 DAS créés avant la coupure manquent à LIGNES_GRP (20261015-das-m8-lignes-grp-vs-tb-diag-resultat).

L'effet sur une mesure : en comparant la LIGNES_GRP de la version à M8 à celle d'aujourd'hui, au moins 330 RSS de chirurgie auraient gagné un DAS de l'un de six thèmes (E40-E46, L89, R33, R52.1, R52.2, U82-U85, Z29.0), dont 37 montés de niveau, pour 176 943 € ; mais 325 d'entre eux avaient leur DAS du thème saisi avant la coupure (20261015-classes-m8-regroupes-resultat).

DATE_ENVOI_TUTELLE est renseignée pour moins de 10 RSS de chirurgie par mois ; de 156 à 422 RSS de chirurgie par mois ont été regroupés après M8 (20261015-groupage-m8-hist-synth-rss-resultat).

Points ouverts : un seul envoi observé ; pourquoi CORA ne garde pas le groupage fait pour le fichier.
