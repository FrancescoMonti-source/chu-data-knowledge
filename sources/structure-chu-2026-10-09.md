---
id: structure-chu-2026-10-09
title: "Fichier Structure du CHU : pôles, services et UF"
publisher: "contrôle de gestion du CHU de Rouen"
edition: "mise à jour du 09/10/2026"
location: "http://intranet4/controle-de-gestion/files/2026/10/Structure-09102026.xlsx (intranet du CHU, dossiers files/AAAA/MM/ ; non joignable depuis le cloud). Il n'est pas dans le dépôt : on récupère la dernière version avec sources/structures/recuperer_structure.py, dans sources/structures/local/ (ignoré par Git) sur le poste de Pierre"
authority: local
---

Le fichier est confidentiel et reste sur le poste de Pierre. Une feuille, « Fichier Structure », une ligne par UF (environ 1 190), sous une ligne de titre. Colonnes, telles qu'elles sont nommées :

- Code Pôle, Libellé Pôle
- Code Service, Libellé Service
- Code UF, Libellé UF (libellé de référence), Libellé court UF, Libellé très long UF
- Libellé établissement, Libellé établissement abréviation
- Lettre budg. UF, Date fin UF
- Type prise en charge, type prise en charge abréviation
- bâtiment abréviation, bâtiment, numéro étage Cpage

Il contient en plus les nom et prénom du chef de pôle, du chef de service et du responsable de l'UF : aucun agent ne les lit. Le script les écarte avant tout envoi.

Il relie donc un pôle, un service et une UF. Il n'a pas de colonne UM : la correspondance UM et UF ou service n'y est pas.
