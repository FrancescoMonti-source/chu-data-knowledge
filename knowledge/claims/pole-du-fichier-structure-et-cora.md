---
review: unreviewed
id: pole-du-fichier-structure-et-cora
kind: empirical
author: Pierre
statement: "Au CHU, le code de pôle du fichier Structure n'est pas celui de CORA (6 codes identiques sur 225 UF comparables) et CORA ne donne un pôle qu'à 225 des 1 187 UF du fichier : lire le pôle d'une UF dans le fichier, et ne comparer à CORA que par le libellé du pôle."
scope: "CORA de production (CWPROD), pôle d'une UF lu par TB_UNITE_M_UNITE puis TB_UNITE_POLE_UM, liens en cours au 2026-10-09 ; fichier Structure du 2026-10-09, UF dont le code est un CODE_UNITE de TB_UNITE"
refuted_if: "le même script, sur un fichier plus récent, trouve le même code de pôle que CORA pour plus de la moitié des UF comparables"
maturity: observed
lifecycle: active
terms: [structure:pole, structure:uf, cora:uf]
tables: [cora:TB_UNITE, cora:TB_UNITE_M_UNITE, cora:TB_UNITE_POLE_UM, cora:TB_UNITE_POLE]
supported_by: [20261026-structure-fichier-vs-cora-resultat]
depends_on: [code-uf-du-fichier-structure]
---
## Pour s'en servir

Pour le pôle d'une UF, prendre celui du fichier (service-et-pole-depuis-fichier-structure). Ne pas joindre le code de pôle du fichier à celui de TB_UNITE_POLE : les deux codifications diffèrent. Pour rapprocher les deux découpages, comparer les libellés de pôle après normalisation (majuscules, sans accents ni ponctuation), et dire que la comparaison ne porte que sur les UF liées à une UM dans CORA.

Quand un rapport donne un pôle par UF ou par UM de CORA, dire d'où il vient (fichier ou CORA) : pour 64 des 225 UF comparables, le libellé de pôle diffère.

## Ce qui l'appuie

Parmi les 675 UF du fichier dont le code est un CODE_UNITE de TB_UNITE (20261026-structure-fichier-vs-cora-resultat) : 446 n'ont aucun pôle dans CORA (leur UF n'a pas de lien en cours avec une UM, 592 des 838 lignes de TB_UNITE dans ce cas), 4 ont un pôle vide dans le fichier, 225 ont un pôle dans CORA. Sur ces 225 : 6 ont le même code et le même libellé, 155 le même libellé avec un autre code, 64 ni l'un ni l'autre. Un pôle du fichier mène à un seul pôle CORA pour 10 des 12 pôles vus, et un pôle CORA vient d'un seul pôle du fichier pour 11 des 12 : les deux découpages se superposent presque, sous d'autres codes. Aucune UF n'a plusieurs pôles dans CORA. Lire le Code UF comme un code d'UM (235 codes) donne les mêmes proportions : 6 identiques, 158 de même libellé, 64 différents.

Limites : « libellé différent » veut dire différent après normalisation ; renommage, abréviation ou vraie réorganisation ne sont pas distingués. Le pôle de CORA est celui de l'UM liée à l'UF, pas une colonne de l'UF. Les 446 UF sans pôle et les 512 codes hors TB_UNITE ne sont pas comparables : 962 des 1 187 UF du fichier (81 %) n'ont aucun pôle côté CORA.

Points ouverts : la cause des 64 écarts (à voir avec Pierre, UF par UF, hors dépôt) ; combien de pôles compte le fichier au total (non enregistré dans une preuve) ; le pôle d'une UM a changé pour 5 UM (liens datés) : le pôle d'avant n'est pas comparé.
