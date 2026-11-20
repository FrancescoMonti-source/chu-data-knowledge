---
review: unreviewed
id: nir-ret-1-2-hors-referentiel-beneficiaires
kind: empirical
author: Pierre
statement: "Dans le PMSI MCO du SNDS, le NIR_ANO_17 d'un séjour à NIR_RET = 1 ou 2 ne se retrouve presque jamais dans IR_BEN_R (et celui de NIR_RET = 3 rarement), alors que celui d'un séjour qui n'échoue qu'aux contrôles de cohérence (COH_NAI_RET, COH_SEX_RET) s'y retrouve le plus souvent : ces séjours ne se joignent ni au DCIR ni au référentiel, et seule l'exclusion des échecs de cohérence fait perdre des patients joignables."
scope: "PMSI MCO 2025 du SNDS, échantillon des 2000 premiers NIR_ANO_17 distincts (ordre alphabétique) par classe de code retour, IR_BEN_R, portail de la Cnam, profil 108, exécution du 2026-11-20"
refuted_if: "sur un échantillon de NIR_ANO_17 de séjours à NIR_RET = 2, plus de 10 % sont des BEN_NIR_PSA d'IR_BEN_R"
maturity: observed
lifecycle: active
terms: [snds:chainage-invalide, snds:referentiel-ir, snds:table-pmsi-annuelle]
tables: [snds:T_MCOaaC, snds:IR_BEN_R]
supported_by: [20261120-snds-chainage-invalide-profil-nir-v2-resultat]
depends_on: [joindre-pmsi-mco-referentiel-par-nir, filtre-chainage-snds-patients-pas-activite]
---
## Pour s'en servir

Dans une analyse par patient qui joint IR_BEN_R ou le DCIR (filtre-chainage-snds-patients-pas-activite) :

- exclure NIR_RET ≠ 0 ne fait rien perdre de joignable : ces NIR_ANO_17 n'ont pas de bénéficiaire ; ne pas chercher à les récupérer ;
- les séjours qui n'échouent qu'à COH_NAI_RET ou COH_SEX_RET ont, pour la plupart, un bénéficiaire : s'ils pèsent dans la population étudiée (personnes âgées surtout), compter combien le filtre en retire, et le dire ou faire une analyse de sensibilité qui les garde ;
- les séjours NIR_RET = 9 avec FHO_RET = 1 n'ont presque jamais de NIR_ANO_17 : ils ne se chaînent à rien.

## Ce qui l'appuie

La requête 20261120-snds-chainage-invalide-profil-nir-v2 classe les séjours de 2025 selon leur premier code retour en échec et cherche les 2000 premiers NIR_ANO_17 distincts de chaque classe dans IR_BEN_R (20261120-snds-chainage-invalide-profil-nir-v2-resultat). Retrouvés : 1985 sur 2000 pour les séjours valides (99,3 %, comme le claim joindre-pmsi-mco-referentiel-par-nir) ; 1247 sur 2000 (62,4 %) pour les échecs de cohérence seuls ; 154 sur 2000 (7,7 %) pour NIR_RET = 3 ; moins de 10 sur 2000 pour NIR_RET = 1 et pour NIR_RET = 2. Les séjours NIR_RET = 9 avec FHO_RET = 1 (16 579 en 2025) ont moins de 10 NIR_ANO_17 distincts.

Profil, en 2025 : les séjours NIR_RET = 2 ont pour département de résidence 99 (13 %), 9F (10 %), Paris (8 %) et la Seine-Saint-Denis (5 %), et sont plus jeunes (34 % de 18-44 ans contre 19 % des séjours valides) ; 11 % entrent en mode 0 et 8 % en mode N. Leurs NIR_ANO_17 portent souvent plusieurs séjours (34 % des séjours sur des NIR à 10-99 séjours) : le NIR_ANO_17 regroupe des séjours, mais rien ne dit qu'il s'agit d'une même personne. Les échecs de cohérence seuls touchent surtout les 65 ans et plus (59 %).

Points ouverts : le sens officiel des valeurs de NIR_RET n'est pas lu ; l'échantillon prend les premiers NIR par ordre alphabétique, pas un tirage au hasard ; une seule année (2025) ; 9F est lu comme le code de Mayotte sans vérification dans la nomenclature des codes géographiques du PMSI.
