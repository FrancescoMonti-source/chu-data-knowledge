---
review: unreviewed
id: joindre-fichier-groupe-par-no-rss
kind: empirical
author: Francesco
statement: "Le n° de RSS du fichier groupé d'un envoi (positions 28-47) et le NO_RSS de sa valorisation (VisualValoSejours.csv) sont TB_SYNTH_RSS.NO_RSS : joindre ces fichiers à CORA par cette colonne."
scope: "CORA de production (CWPROD, schéma CORA_REC), fichier groupé et VisualValoSejours.csv de l'envoi M8 2026, RSS MCO sortis de janvier à août 2026, lus le 2026-10-15"
refuted_if: "pour un envoi, moins de 99 % des RSS de CORA de la période se retrouvent par NO_RSS dans son fichier groupé, ou plus de 10 NO_RSS de la période désignent chacun plusieurs RSS de CORA"
maturity: observed
lifecycle: active
terms: [pmsi:envoi, cora:rss]
tables: [cora:TB_SYNTH_RSS]
supported_by: [20261015-classes-m8-fichier-resultat, 20261015-forme-lignes-grp-resultat, 20261015-colonnes-hist-diag-synth-rss-resultat]
depends_on: []
---
## Pour s'en servir

Joindre sur les valeurs sans espaces : `trimws(substr(ligne, 28, 47))` pour le fichier groupé, `TRIM(s.NO_RSS)` pour CORA, la colonne NO_RSS pour VisualValoSejours.csv. Une ligne du fichier groupé est un RUM : réunir d'abord les lignes par n° de RSS. Compter les NO_RSS en double dans CORA avant de joindre ; il y en a moins de 10 sur janvier-août 2026.

Ne pas prendre NO_RSS_EXT, le « N° RSS application source » du dictionnaire.

## Ce qui l'appuie

Fichier groupé M8, valorisation du même envoi et CORA, joints par NO_RSS (20261015-classes-m8-fichier-resultat) : 128 604 des 128 636 RSS de CORA sortis de janvier à août 2026 et groupés hors CMD 90 se retrouvent dans le fichier, et autant dans la valorisation. Dans LIGNES_GRP, que CORA écrit au même format, les positions 28-47 valent NO_RSS pour tous les RSS sauf moins de 10 (20261015-forme-lignes-grp-resultat).

NO_RSS existe dans TB_SYNTH_RSS et TB_HIST_SYNTH_RSS, en VARCHAR2 de 8 (20261015-colonnes-hist-diag-synth-rss-resultat). Le dictionnaire de 2020 ne la décrit pas dans TB_SYNTH_RSS, seulement NO_RSS_EXT ; il la décrit dans TB_SYNTH_RSS_VERSION (« Numéro du RSS »).

Points ouverts : les 32 RSS de CORA absents du fichier.
