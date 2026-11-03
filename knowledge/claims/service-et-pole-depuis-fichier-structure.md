---
review: unreviewed
id: service-et-pole-depuis-fichier-structure
kind: documentary
author: Pierre
statement: "Au CHU, le service et le pôle d'une UF viennent du fichier Structure du contrôle de gestion (une ligne par UF : pôle, service, UF), pas de CORA : CORA n'a pas de table de service, une UM n'est pas un service, et le fichier n'a pas de colonne UM."
scope: "CHU de Rouen, fichier Structure mis à jour le 2026-10-09 (une seule version lue), comparé à CORA le 2026-10-26 et le 2026-11-03 ; le rattachement à une date passée n'est pas établi"
maturity: documented
lifecycle: active
terms: [structure:service, structure:pole, structure:uf, cora:uf]
tables: [cora:TB_UNITE]
supported_by: [20261026-structure-chu-colonnes, 20261026-structure-fichier-vs-cora-resultat, 20261027-structure-historique-cora-resultat]
depends_on: [joindre-uf-par-code, code-uf-du-fichier-structure, pole-du-fichier-structure-et-cora]
---
## Pour s'en servir

Quand une question dit « service » ou « pôle » (la part de tel service, un tableau par service), ne jamais prendre l'UM comme service et ne jamais appeler « service » une UM, une UF ou un pôle de CORA. Faire :

1. Rattacher chaque séjour ou mouvement à son UF par son code (joindre-uf-par-code), puis joindre ce code au Code UF du fichier (code-uf-du-fichier-structure : 99,9 % des mouvements de 2022 à 2025 y sont).
2. Lire le service et le pôle de cette UF dans le fichier Structure. Le fichier est confidentiel et reste sur le poste de l'utilisateur DIM : il le récupère avec `python sources\structures\recuperer_structure.py --texte`, qui écrit une copie texte, sans les colonnes de personnes, dans sources/structures/local/texte/ (ignoré par Git). Un agent du cloud ne le lit pas ; la jointure UF → service se prépare donc dans une table de correspondance que l'utilisateur DIM fournit, ou dans un script qu'il exécute.
3. Compter à part, et dire, les mouvements dont l'UF est absente du fichier (604 à 1 028 par an), au lieu de les écarter en silence. Le fichier n'est pas un historique : il garde 68 UF inactives dans CORA (leur « Date fin UF » est vide ou à venir, jamais passée) et n'a pas 136 UF inactives de CORA, dont 109 dont la dernière modification enregistrée date de 2021, ni 28 UF actives. Ne pas lire « Date fin UF » comme la date de fermeture, ni l'absence du fichier comme une fermeture : décider « ouverte » par TB_UNITE.ACTIF et dire la règle. L'activité ancienne d'une UF absente du fichier n'a ni service ni pôle : la compter à part.
4. Pour le pôle, ne pas joindre les codes de pôle de CORA (pole-du-fichier-structure-et-cora).
5. Écrire la date du fichier utilisé (« fichier Structure du 2026-10-09 ») dans le rapport : c'est une photo à une date, pas un historique.

Ne rien enregistrer du fichier dans le dépôt ni dans une réponse au-delà d'agrégats par service : les noms des chefs de pôle, de service et des responsables d'UF y figurent et sont déjà écartés de la copie texte.

## Ce qui l'appuie

La fiche de la source liste les colonnes du fichier : pôle, service et UF (codes et libellés), date de fin d'UF, type de prise en charge, établissement, bâtiment ; aucune UM (20261026-structure-chu-colonnes). Le dictionnaire CORA 2020 n'a pas de table de service. Une UM regroupe des UF côté CORA (lien daté UM–UF) et se rattache à un pôle ; ce n'est pas un service.

Les mesures de l'enquête structures (2026-10-26) : le Code UF est un code d'UF de CORA (code-uf-du-fichier-structure) ; le pôle du fichier a d'autres codes que celui de CORA (pole-du-fichier-structure-et-cora) ; le fichier a 1 187 UF, toutes sans date de fin passée ; 163 codes de TB_UNITE n'y sont pas (136 inactifs, 27 actifs).

Mesures du 2026-11-03 (20261027-structure-historique-cora-resultat) : TB_UNITE a 204 UF inactives, dont 68 dans le fichier (aucune avec une date de fin passée) et 136 hors du fichier ; 134 des 136 ont eu un état actif dans TB_HIST_UNITE. 28 UF actives de CORA sont hors du fichier. La dernière modification enregistrée des UF inactives du fichier date de 2021 pour 60 sur 68 ; celle des UF inactives hors du fichier, de 2019 à 2021 pour 134 sur 136. Rien ne sépare donc les deux groupes par une date : le fichier ne retire pas une UF à sa fermeture dans CORA. Pour le service d'une UM, voir service-d-une-um.

Points ouverts : le fichier garde-t-il l'ancien rattachement d'une UF fermée, et le service d'une UF a-t-il changé avant la date du fichier ? Une seule version a été lue : il faut une version plus ancienne (`--ancien` du script 20261026-structure-fichier-vs-cora) pour le dire. La colonne « Date fin UF » est-elle jamais renseignée ? Les mesures ne distinguent pas vide et à venir. La dernière DATE_INFO de TB_HIST_UNITE n'est pas une date de fermeture.
