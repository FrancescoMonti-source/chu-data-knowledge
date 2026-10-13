# Glossaire CORA

Les termes du contexte cora. Un titre par terme (## cora:terme), puis la définition en français. Règles : method/layout.md, « Termes et glossaires ».

## cora:sejour

Alias : TB_SEJOUR, venue, NO_SEJOUR

Un enregistrement de TB_SEJOUR : un passage d'un patient au CHU, d'une date d'entrée à une date de sortie, qu'il s'agisse d'une hospitalisation ou d'une consultation externe. Il porte ses mouvements dans les unités (TB_MVT).

## cora:consultation-externe

Alias : venue externe, externe, ACE, actes et consultations externes

Un séjour CORA qui n'est pas une hospitalisation : le patient vient pour une consultation ou un acte et repart sans être hospitalisé.

## cora:rss

Alias : RSS, TB_SYNTH_RSS, résumé de sortie standardisé

Un enregistrement de TB_SYNTH_RSS : le résultat du groupage d'un séjour dans CORA, fait d'un ou plusieurs RUM. Un séjour peut en porter plusieurs, rarement (passage dans une unité hors PMSI). Un séjour s'y relie par ses mouvements : TB_MVT, puis TB_MVT_RUM, qui porte l'ID_RSS.
