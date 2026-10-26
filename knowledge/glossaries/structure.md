# Glossaire structure

Les termes du contexte structure : l'organisation du CHU en pôles, services et unités fonctionnelles, telle que le contrôle de gestion la tient dans le fichier Structure (sources/structure-chu-2026-10-09.md). Un titre par terme (## structure:terme), puis la définition en français. Règles : method/layout.md, « Termes et glossaires ».

## structure:pole

Alias : pôle, pôle de gestion, Code Pôle, Libellé Pôle

Le regroupement de services le plus large du fichier Structure : une ligne du fichier donne le pôle de son UF. CORA a aussi des pôles (TB_UNITE_POLE, qui rattache des UM) ; les deux découpages se superposent presque, mais sous d'autres codes de pôle, et CORA n'a pas de pôle pour la plupart des UF du fichier (pole-du-fichier-structure-et-cora).

## structure:service

Alias : service, Code Service, Libellé Service, service de rattachement

Le regroupement d'UF du fichier Structure, entre l'UF et le pôle. Un service n'est ni une UM (cora:um), ni une UF, ni un pôle : CORA n'a pas de service, et le fichier Structure n'a pas d'UM. Pour le service d'un séjour ou d'un mouvement, on part de son UF et on lit son service dans le fichier ; on ne dit « service » ni pour une UM ni pour un pôle.

## structure:uf

Alias : UF du fichier Structure, Code UF, Libellé UF, Date fin UF

Une ligne du fichier Structure : une UF avec ses libellés, sa date de fin, son type de prise en charge, son service et son pôle. Son Code UF est un code d'UF de CORA, celui de TB_UNITE.CODE_UNITE et des mouvements (code-uf-du-fichier-structure) ; il est aussi le code d'une UM pour 235 UF du fichier, sans que cela en fasse une UM.
