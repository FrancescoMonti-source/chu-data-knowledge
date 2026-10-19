---
review: unreviewed
id: longueur-ligne-rss-groupe
kind: empirical
author: Francesco
statement: "Une ligne de RSS groupé au format 123, dans le fichier groupé d'un envoi comme dans LIGNES_GRP, mesure 205 + 8 nDA + 8 nDAD + 32 nZA caractères, la somme des tailles de la feuille de l'ATIH, et non les 192 + 8 nDA + 8 nDAD + 29 nZA qu'annonce sa formule."
scope: "fichier groupé de l'envoi M8 2026 fabriqué par CORA, et TB_SYNTH_RSS.LIGNES_GRP de CWPROD, RSS MCO sortis de janvier à août 2026 ; feuille « RSS groupé format 123 » de atih-formats-mco-2026"
refuted_if: "plus de 1 % des lignes d'un fichier groupé au format 123 ont une autre longueur que 205 + 8 nDA + 8 nDAD + 32 nZA"
maturity: observed
lifecycle: active
terms: [pmsi:envoi, cora:rss]
tables: [cora:TB_SYNTH_RSS]
supported_by: [20261016-feuille-rss-groupe-format-123, 20261015-grp-m8-themes-resultat, 20261015-forme-lignes-grp-resultat]
depends_on: []
---
## Pour s'en servir

Lire les zones fixes aux positions de la feuille, jusqu'au DA n° 1 en 206-213. Les zones qui suivent se calculent à partir d'une partie fixe de 205 caractères :

- DA n° k : 206 + 8 (k - 1), sur 8 caractères ;
- DAD n° k : 206 + 8 nDA + 8 (k - 1), sur 8 caractères ;
- zone d'acte n° k : 206 + 8 nDA + 8 nDAD + 32 (k - 1), sur 32 caractères.

nDA, nDAD et nZA se lisent en 134-135, 136-137 et 138-140. Pour vérifier qu'une ligne a été lue entière, comparer sa longueur à 205 + 8 nDA + 8 nDAD + 32 nZA, jamais à la formule de la feuille.

## Ce qui l'appuie

La feuille annonce 192 + (8*nDA) + (8*nDAD) + (29*nZA), mais ses propres positions placent un filler en 193-205 et le DA n° 1 en 206, et sa zone d'acte fait 32 caractères (20261016-feuille-rss-groupe-format-123). Son titre dit aussi « format 122 ».

Dans le fichier groupé M8, 163 821 lignes ont la longueur 205 + 8 nDA + 8 nDAD + 32 nZA, et moins de 10 une autre (20261015-grp-m8-themes-resultat). Dans LIGNES_GRP, la première ligne de 106 171 RSS a cette longueur, et celle de moins de 10 RSS la longueur de la formule (20261015-forme-lignes-grp-resultat).

Points ouverts : la position des zones d'actes n'a pas été lue dans les données ; elle se déduit de la longueur.
