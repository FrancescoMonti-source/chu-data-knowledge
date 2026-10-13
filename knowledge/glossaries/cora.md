# Glossaire CORA

Les termes du contexte cora. Un titre par terme (## cora:terme), puis la définition en français. Règles : method/layout.md, « Termes et glossaires ».

Aucun terme pour l'instant.

## cora:sejour

Alias : TB_SEJOUR, venue, NO_SEJOUR

Un enregistrement de TB_SEJOUR : un passage d'un patient au CHU, d'une date d'entrée à une date de sortie, hospitalisation ou consultation externe. Il porte ses mouvements dans les unités (TB_MVT).

## cora:rss

Alias : RSS, TB_SYNTH_RSS, résumé de sortie standardisé

Un enregistrement de TB_SYNTH_RSS : le résultat du groupage MCO d'un séjour dans CORA, fait d'un ou plusieurs RUM. Un séjour s'y relie par ses mouvements : TB_MVT, puis TB_MVT_RUM, qui porte l'ID_RSS.

## cora:type-sejour

Alias : TYPE_SEJOUR, type de séjour

La colonne TYPE_SEJOUR de TB_SEJOUR, sur trois caractères : MCO, HDJ, EXT, URG, PSY, REA, SSR, LSJ… Le dictionnaire CORA 2020 la présente comme un moyen de distinguer, par exemple, l'externe de l'hospitalisation dans une même unité.
