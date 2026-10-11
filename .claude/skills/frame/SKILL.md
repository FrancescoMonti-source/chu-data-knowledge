---
name: frame
description: Cadrer une question sur les données du CHU avec la personne, avant toute recherche. Utiliser au début de toute question, et quand une session reprend une enquête.
---

# frame

Cette skill donne les étapes. Les règles sont dans docs/agents/ ; les faits, dans les claims. frame est une conversation : rien ne s'écrit dans le dépôt.

1. **Reprendre.** Si la question appartient à une enquête ouverte (`investigations/<id>/README.md`), lire son README et son issue : le dernier plan et les preuves déjà citées.
   Fini quand : l'état de l'enquête est connu, ou la question est nouvelle.
2. **Affiner la question** avec la personne : le but, la population, la période, l'unité d'analyse (séjour, patient, acte), la mesure, la comparaison. Proposer une formulation, la faire corriger.
   Fini quand : la question tient en une phrase, les six points sont écrits, et la personne les a confirmés.

Ensuite : research pour une question nouvelle ; pour une enquête reprise, l'étape en cours de son plan.
