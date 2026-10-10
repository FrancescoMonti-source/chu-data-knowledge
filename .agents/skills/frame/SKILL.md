---
name: frame
description: Cadrer une question sur les données du CHU et chercher ce que le dépôt sait déjà. Utiliser au début de toute question, et quand une session reprend une enquête.
---

# frame

Cette skill donne les étapes. Les règles sont dans docs/agents/ ; les faits, dans les claims.

1. **Reprendre.** Si l'enquête existe (`investigations/<id>/README.md`), la lire. Si la note de frictions de la session précédente manque, poser une seule question à la personne et noter sa réponse (docs/agents/frictions.md).
   Fini quand : l'état de l'enquête est connu, ou il n'y a pas d'enquête.
2. **Affiner la question** avec la personne : le but, la population, la période, l'unité d'analyse (séjour, patient, acte), la mesure, la comparaison.
   Fini quand : les six points sont écrits et la personne les a confirmés.
3. **Chercher ce qu'on sait** (docs/agents/layout.md, « Retrouver ce qu'on sait ») : pour chaque terme et chaque table de la question, les glossaires, puis les claims qui les citent, puis leurs prémisses et leurs preuves ; enfin, les questions des enquêtes passées.
   Fini quand : chaque terme et chaque table a été cherché, et la personne a reçu ce qui existe, avec l'état de relecture de chaque claim (claims.md, « Citer un claim »), et ce qui manque.
4. **Si ça suffit,** répondre en citant les claims et leur état de relecture. S'arrêter là.
5. **Sinon, ouvrir l'enquête.** Créer la branche `enquete/<id>` et `investigations/<id>/README.md` (modèle : investigations/README.md) avec la question, le cadrage et un plan : quelques étapes dans l'ordre, chacune avec ce à quoi elle sert. Ce qui manque à l'étape 3 devient le plan. Sur GitHub, ouvrir aussi l'issue avec la question et le plan.
   Fini quand : le README existe sur la branche de l'enquête, avec la question, le cadrage et le plan.

Ensuite : research pour les documents, relay pour les données de l'hôpital.
