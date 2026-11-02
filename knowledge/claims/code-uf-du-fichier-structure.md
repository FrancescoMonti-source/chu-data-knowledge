---
review: unreviewed
id: code-uf-du-fichier-structure
kind: empirical
author: Pierre
statement: "Au CHU, le Code UF du fichier Structure est un code d'UF de CORA, le même que TRIM(TB_MVT.ID_UNITE_M) et TRIM(TB_UNITE.CODE_UNITE) : de 2022 à 2025, 99,9 % des mouvements ont leur code dans le fichier ; mais 512 des 1 187 codes du fichier ne sont ni dans TB_UNITE ni dans TB_UNITE_MEDICALE."
scope: "CORA de production (CWPROD), fichier Structure du 2026-10-09 (une seule version), mouvements commencés de 2022 à 2025, référentiels lus le 2026-10-26"
refuted_if: "plus de 1 % des mouvements commencés une année de 2022 à 2025 ont un code d'UF absent du Code UF du fichier (script 20261026-structure-mouvements-hors-fichier)"
maturity: observed
lifecycle: active
terms: [structure:uf, cora:uf, cora:mouvement]
tables: [cora:TB_MVT, cora:TB_UNITE, cora:TB_UNITE_MEDICALE]
supported_by: [20261026-structure-mouvements-hors-fichier-resultat, 20261026-structure-fichier-vs-cora-resultat]
depends_on: [joindre-uf-par-code]
---
## Pour s'en servir

Pour donner à un séjour ou à un mouvement son service et son pôle du fichier, joindre par le code d'UF : TRIM(TB_MVT.ID_UNITE_M) (ou TRIM(TB_UNITE.CODE_UNITE)) égal au Code UF du fichier, lu comme du texte (« 5618.0 » devient « 5618 »). Ne passer ni par un identifiant (TB_UNITE.ID_UNITE, ID_UNITE_MED) ni par un code d'UM : le code d'UF est celui qui porte les mouvements (joindre-uf-par-code).

Compter à part les mouvements dont l'UF n'est pas dans le fichier et le dire : 1 028 en 2022, 880 en 2023, 714 en 2024 et 604 en 2025, sur plus de 900 000 par an. Ne pas conclure qu'un Code UF du fichier absent de TB_UNITE est une erreur : 512 le sont, sans effet sur les mouvements (377 à 406 UF du fichier ont des mouvements chaque année).

Ne pas écrire « le CODE_UNITE de CORA est l'UM » : c'est un code d'UF, qui est aussi le code d'une UM dans 281 cas (voir tb-unite-drapeaux-uf-um-inutilisables).

## Ce qui l'appuie

Sur les 1 187 UF du fichier (codes tous distincts), 675 sont un CODE_UNITE de TB_UNITE et 235 de ceux-là sont aussi un CODE_UNITE_MED de TB_UNITE_MEDICALE, avec le même libellé que le fichier pour 220 (20261026-structure-fichier-vs-cora-resultat). Chaque année, 99,89 % (2022) à 99,94 % (2025) des mouvements ont leur code dans le fichier (20261026-structure-mouvements-hors-fichier-resultat). Comme tous les mouvements ont un code d'UF dans TB_UNITE (joindre-uf-par-code), le fichier et TB_UNITE décrivent les mêmes UF pour l'activité.

Dans CORA, 241 des 246 UF qui ont un lien en cours avec une UM (TB_UNITE_M_UNITE, au 2026-10-09) l'ont avec une UM de même code : pour elles, le code ne distingue pas l'UF de l'UM. Cela ne dit pas laquelle le fichier décrit ; le fichier a une ligne par UF (pas de colonne UM) et ses codes suivent ceux des mouvements.

Limites : une seule version du fichier, appliquée à des mouvements de 2022 à 2025 ; si un code a changé de sens entre-temps (changements de numéro d'UF ou d'UM), la jointure l'ignore. La baisse des mouvements hors fichier de 2022 à 2025 va dans le sens d'un fichier qui retire les UF fermées, sans le prouver.

Points ouverts : ce que sont les 512 codes du fichier hors CORA (UF créées depuis, UF administratives sans activité, autre codification) ; TB_SEJOUR.UF_ENTREE n'est pas mesuré contre le fichier.
