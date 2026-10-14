# Glossaire CORA

Les termes du contexte cora. Un titre par terme (## cora:terme), puis la définition en français. Règles : method/layout.md, « Termes et glossaires ».

## cora:sejour

Alias : TB_SEJOUR, venue, NO_SEJOUR

Un enregistrement de TB_SEJOUR : un passage d'un patient au CHU, d'une date d'entrée à une date de sortie, hospitalisation ou consultation externe. Il porte ses mouvements dans les unités (TB_MVT).

## cora:rss

Alias : RSS, TB_SYNTH_RSS, résumé de sortie standardisé

Un enregistrement de TB_SYNTH_RSS : le résultat du groupage MCO d'un séjour dans CORA, fait d'un ou plusieurs RUM. Un séjour s'y relie par ses mouvements : TB_MVT, puis TB_MVT_RUM, qui porte l'ID_RSS.

## cora:type-sejour

Alias : TYPE_SEJOUR, type de séjour

La colonne TYPE_SEJOUR de TB_SEJOUR, sur trois caractères : MCO, HDJ, EXT, URG, PSY, REA, SSR, LSJ… Le dictionnaire CORA 2020 la présente comme un moyen de distinguer, par exemple, l'externe de l'hospitalisation dans une même unité.

## cora:uf

Alias : UF, unité fonctionnelle, unité, TB_UNITE, CODE_UNITE, UF d'entrée, UF_ENTREE

Une unité du thésaurus TB_UNITE, désignée par son code (CODE_UNITE). Un séjour porte son UF d'entrée (TB_SEJOUR.UF_ENTREE), chaque mouvement l'UF où il a lieu (TB_MVT.ID_UNITE_M). Un même code peut avoir plusieurs lignes dans TB_UNITE.

## cora:passage-urgences

Alias : urgences, passage aux urgences, SAU, UF d'urgences, URGENCE, UF_URGENCE, TYPE_SEJOUR URG

Le passage d'un patient dans une unité d'urgences du CHU, enregistré dans CORA comme un séjour ou un mouvement dans l'une de ces unités.

## cora:mouvement

Alias : TB_MVT, mouvement, mouvement d'unité, passage dans une unité, ID_MVT

Un enregistrement de TB_MVT : le séjour d'un patient dans une unité (UF), d'une date et heure de début (DATE_DEBUT_MVT, HEURE_DEBUT_MVT) à une date et heure de fin (DATE_FIN_MVT, HEURE_FIN_MVT). Un séjour (cora:sejour) en compte un ou plusieurs.

## cora:preadmission

Alias : préadmission, préadmissions, STATUT_PROG P, séjour programmé, venue programmée

Un séjour de TB_SEJOUR créé à l'avance pour une venue programmée, reconnaissable à TB_SEJOUR.STATUT_PROG = 'P'.
