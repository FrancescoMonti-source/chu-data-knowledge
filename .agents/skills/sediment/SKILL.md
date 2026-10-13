---
name: sediment
description: Transformer les preuves d'une enquête en claims et les faire entrer dans le dépôt. Utiliser quand les preuves suffisent pour répondre ; aussi pour réutiliser, contester ou remplacer un claim, et pour suspendre ou fermer une enquête.
---

# sediment

1. **Écrire les claims.** D'abord, pour chaque conclusion : que fera de ce résultat l'agent qui interrogera les données plus tard ? La réponse donne le claim (claims.md, « Entrer ou non ») ; une conclusion qui ne change rien à la façon d'interroger reste dans le README ou dans l'issue. Puis un claim par usage et par test possible (claims.md, « Taille »), dans knowledge/claims/, avec ses termes dans terms, ses preuves dans supported_by et ses prémisses dans depends_on, et la section « Pour s'en servir » (claims.md, « Le corps »). La réponse à la question devient un claim d'enquête qui dépend des claims atomiques.
   Fini quand : chaque conclusion qui change la façon d'interroger les données est un claim ; chaque claim cite ses preuves ou ses prémisses ; et sa section « Pour s'en servir » dit à un agent quoi faire, sans qu'il lise la suite.
2. **Relire ce qu'on réutilise** (review.md). Pour chaque prémisse, selon sa sorte :
   - **claim d'une autre personne, sans relecture à jour :** la relecture au réemploi. La personne lit le travail refait et l'approuve avant que l'agent écrive le bloc review à son nom.
   - **claim de la même personne, venu d'une autre enquête :** author-reread, que la personne fait dans une nouvelle session ; l'agent le lui demande et attend qu'elle revienne.

   Fini quand : chaque prémisse est relue ou déjà à jour, et sa portée (scope) couvre le nouvel usage. Seule exception : un claim provisional peut s'appuyer sur le claim d'une autre personne sans relecture à jour (ORANGE).
3. **Contrôler :** `python checks/check.py`.
   Fini quand : aucun ROUGE ; les ORANGE restants sont listés pour la personne.
4. **Conclure le README.** Dans la section Conclusions du README de l'enquête : les claims, avec leur état de relecture. Relire Choix avec la personne : chaque décision de méthode de l'enquête y est. Enregistrer (investigations/README.md, « La branche »).
   Fini quand : Conclusions liste chaque claim que la branche fait entrer, la personne a confirmé Choix, et le README est enregistré.
5. **Faire entrer.** Supprimer les lectures qu'aucun claim ne cite (investigations/README.md, « L'issue ou le dépôt »). La personne qui mène l'enquête relit et confirme ; l'agent fait le merge de la branche de l'enquête dans la branche principale (investigations/README.md, « La branche »). Sur GitHub, par une PR qui écrit « Refs #N » : l'issue reste ouverte, et l'étape 6 la ferme ou la suspend. Un résultat partiel peut entrer pendant que l'enquête reste ouverte.
   Fini quand : la personne a confirmé et le merge est fait.
6. **Suspendre ou fermer**, au choix de la personne, quand l'enquête s'arrête. Fermer : avant le dernier merge, supprimer les preuves d'exécution qu'aucun claim ne cite, avec leurs requêtes (investigations/README.md, « L'issue ou le dépôt ») ; une fois le dernier merge fait, supprimer la branche de l'enquête (`git push origin --delete investigation/<id>`), puis fermer l'issue à la main, avec un commentaire qui cite la PR. Suspendre : laisser l'issue ouverte, avec un commentaire qui dit où en est l'enquête et ce qui la relancerait.
   Fini quand : la branche est supprimée et l'issue fermée, ou l'issue porte le commentaire de suspension.

**Contester ou remplacer un claim :** review.md, « Contestation », puis les étapes 3 et 5.
