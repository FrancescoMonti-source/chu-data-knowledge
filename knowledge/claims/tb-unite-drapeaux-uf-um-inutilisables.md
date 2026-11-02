---
review: unreviewed
id: tb-unite-drapeaux-uf-um-inutilisables
kind: empirical
author: Pierre
statement: "Dans CORA, les drapeaux UF et UM de TB_UNITE ne distinguent pas une UF d'une UM : les 838 lignes ont UF = 'O' et 711 ont UM = 'O' alors que TB_UNITE_MEDICALE n'a que 281 UM ; pour lister ou compter les UM, partir de TB_UNITE_MEDICALE."
scope: "CORA de production (CWPROD, schéma CORA_REC), TB_UNITE et TB_UNITE_MEDICALE lus le 2026-10-26"
refuted_if: "UM = 'O' repère exactement les lignes de TB_UNITE dont le code est celui d'une UM de TB_UNITE_MEDICALE (aujourd'hui : 229 sur 281, et 482 lignes sans UM de même code l'ont aussi)"
maturity: observed
lifecycle: active
terms: [cora:uf]
tables: [cora:TB_UNITE, cora:TB_UNITE_MEDICALE]
supported_by: [20261026-tb-unite-drapeaux-uf-um-resultat, 20261026-structure-fichier-vs-cora-resultat]
depends_on: [joindre-uf-par-code]
---
## Pour s'en servir

Ne pas filtrer TB_UNITE sur UM = 'O' pour obtenir les UM, ni sur UF = 'O' pour obtenir les UF : le premier garde 711 lignes pour 281 UM, le second garde tout. La liste des UM est TB_UNITE_MEDICALE (CODE_UNITE_MED, ID_UNITE_MED) ; celle des UF est TB_UNITE, par son code (joindre-uf-par-code). Le dictionnaire CORA 2020 marque ces deux drapeaux obsolètes : les données le confirment.

Ne pas déduire de la présence d'un code dans TB_UNITE que c'est une UF « pure » : les 281 codes d'UM de TB_UNITE_MEDICALE figurent tous dans TB_UNITE, et seuls 229 de ces 281 ont UM = 'O' (les 52 autres ont UM = 'N').

## Ce qui l'appuie

20261026-tb-unite-drapeaux-uf-um-resultat : 838 lignes, UF = 'O' partout ; UM = 'O' pour 711 (dont 229 ont un code d'UM identique et 482 non), UM = 'N' pour 127 (dont 52 ont un code d'UM identique). Les 281 codes d'UM sont tous aussi des codes de TB_UNITE (20261026-structure-fichier-vs-cora-resultat). Donc ni « TB_UNITE ne contient que des UF » ni « TB_UNITE contient aussi les UM » n'est tranché par les drapeaux : au niveau du code, les deux se recouvrent.

Points ouverts : 810 des 838 lignes ont un parent (ID_PERE), mais aucune n'est le parent d'une autre ligne de TB_UNITE : ID_PERE désigne autre chose (une UM, un pôle, une racine commune ?), à tester contre TB_UNITE_MEDICALE et TB_UNITE_POLE.
