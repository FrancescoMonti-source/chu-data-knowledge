# Glossaire structure

Les termes du contexte structure : l'organisation du CHU en pôles, services et unités fonctionnelles, telle que le contrôle de gestion la tient dans le fichier Structure (sources/structure-chu-2026-10-09.md). Un titre par terme (## structure:terme), puis la définition en français. Règles : method/layout.md, « Termes et glossaires ».

## structure:pole

Alias : pôle, pôle de gestion, Code Pôle, Libellé Pôle

Le regroupement de services le plus large du fichier Structure : une ligne du fichier donne le pôle de son UF. CORA a aussi des pôles (TB_UNITE_POLE, qui rattache des UM) ; que les deux découpages coïncident n'est pas établi.

## structure:service

Alias : service, Code Service, Libellé Service, service de rattachement

Le regroupement d'UF du fichier Structure, entre l'UF et le pôle. Un service n'est ni une UM (cora:um), ni une UF, ni un pôle : CORA n'a pas de service, et le fichier Structure n'a pas d'UM. Pour le service d'un séjour ou d'un mouvement, on part de son UF et on lit son service dans le fichier ; on ne dit « service » ni pour une UM ni pour un pôle.

## structure:uf

Alias : UF du fichier Structure, Code UF, Libellé UF, Date fin UF

Une ligne du fichier Structure : une UF avec ses libellés, sa date de fin, son type de prise en charge, son service et son pôle. Ce que le Code UF du fichier désigne dans CORA (le CODE_UNITE de TB_UNITE, que le glossaire cora appelle UF, ou une UM) n'est pas encore établi : l'enquête sur les structures le tranche.
