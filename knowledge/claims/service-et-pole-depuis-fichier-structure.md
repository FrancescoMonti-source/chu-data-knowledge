---
review: unreviewed
id: service-et-pole-depuis-fichier-structure
kind: documentary
author: Pierre
statement: "Au CHU, le service et le pôle d'une UF viennent du fichier Structure du contrôle de gestion (une ligne par UF : pôle, service, UF), pas de CORA : CORA n'a pas de table de service, une UM n'est pas un service, et le fichier n'a pas de colonne UM."
scope: "CHU de Rouen, fichier Structure mis à jour le 2026-10-09 ; le rattachement à une date passée n'est pas établi"
maturity: documented
lifecycle: active
terms: [structure:service, structure:pole, structure:uf, cora:uf]
tables: [cora:TB_UNITE]
supported_by: [20261026-structure-chu-colonnes]
depends_on: [joindre-uf-par-code]
---
## Pour s'en servir

Quand une question dit « service » ou « pôle » (la part de tel service, un tableau par service), ne jamais prendre l'UM comme service et ne jamais appeler « service » une UM, une UF ou un pôle de CORA. Faire :

1. Rattacher chaque séjour ou mouvement à son UF par son code (joindre-uf-par-code), puis faire correspondre ce code au Code UF du fichier ; tant que l'enquête sur les structures n'a pas établi cette correspondance, la dire comme hypothèse.
2. Lire le service et le pôle de cette UF dans le fichier Structure. Le fichier est confidentiel et reste sur le poste de Pierre : il le récupère avec `python sources\structures\recuperer_structure.py --texte`, qui écrit une copie texte, sans les colonnes de personnes, dans sources/structures/local/texte/ (ignoré par Git). Un agent du cloud ne le lit pas ; la jointure UF → service se prépare donc dans une table de correspondance que Pierre fournit, ou dans un script qu'il exécute.
3. Compter à part, et dire, les UF de CORA absentes du fichier (une UF fermée, par exemple : le fichier a une colonne « Date fin UF »), au lieu de les écarter en silence.
4. Écrire la date du fichier utilisé (« fichier Structure du 2026-10-09 ») dans le rapport : c'est une photo à une date, pas un historique.

Ne rien enregistrer du fichier dans le dépôt ni dans une réponse au-delà d'agrégats par service : les noms des chefs de pôle, de service et des responsables d'UF y figurent et sont déjà écartés de la copie texte.

## Ce qui l'appuie

La fiche de la source liste les colonnes du fichier : pôle, service et UF (codes et libellés), date de fin d'UF, type de prise en charge, établissement, bâtiment ; aucune UM (20261026-structure-chu-colonnes). Le dictionnaire CORA 2020 n'a pas de table de service. Une UM regroupe des UF côté CORA (lien daté UM–UF) et se rattache à un pôle ; ce n'est pas un service.

Points ouverts : à quoi correspond le Code UF du fichier dans CORA, le CODE_UNITE de TB_UNITE (appelé UF dans le glossaire) ou une UM (Pierre : le CODE_UNITE de CORA est l'UM) ? Le pôle du fichier est-il celui de CORA (TB_UNITE_POLE_UM) ? Le service d'une UF a-t-il changé avant la date du fichier, et le fichier garde-t-il l'ancien rattachement d'une UF fermée ? Une enquête qui compare le fichier à CORA, sur le poste de Pierre, répondrait aux trois.
