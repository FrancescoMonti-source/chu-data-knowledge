---
name: sediment
description: Transformer les preuves d'une enquête en claims et les faire entrer dans le dépôt. Utiliser quand les preuves suffisent pour répondre ; aussi pour réutiliser, contester ou remplacer un claim, et pour suspendre ou fermer une enquête.
---

# sediment

Pour suspendre ou fermer une enquête sans nouveau claim : aller à l'étape 3. Pour contester ou remplacer un claim hors enquête : sur une branche dédiée, suivre method/review.md, « Contestation », puis les étapes 1, 2, 4 et 5.

1. **Écrire les claims.** D'abord, pour chaque conclusion : que fera de ce résultat l'agent qui interrogera les données plus tard ? La réponse donne le claim (claims.md, « Ce qui mérite un claim ») ; une conclusion qui ne change rien à la façon d'interroger reste dans le README ou dans l'issue. Puis un claim par usage et par test possible (claims.md, « Taille »), dans knowledge/claims/, avec ses termes dans terms, ses preuves dans supported_by et ses prémisses dans depends_on, et la section « Pour s'en servir » (claims.md, « Le corps »). La réponse à la question devient un claim d'enquête qui dépend des claims atomiques.
   Fini quand : chaque conclusion qui change la façon d'interroger les données est un claim ; chaque claim cite ses preuves ou ses prémisses ; et sa section « Pour s'en servir » dit à un agent quoi faire, sans qu'il lise la suite.
2. **Relire ce qu'on réutilise** (review.md). Pour chaque prémisse, selon sa sorte :
   - **claim d'une autre personne, sans relecture à jour :** la relecture au réemploi. La personne lit le travail refait et l'approuve avant que l'agent écrive le bloc review à son nom.
   - **claim de la même personne, venu d'une autre enquête, sans relecture à jour :** author-reread, que la personne fait dans une nouvelle session ; l'agent le lui demande et attend qu'elle revienne.

   Fini quand : chaque prémisse venue d'une autre personne ou d'une autre enquête est relue ou déjà à jour, et sa portée (scope) couvre le nouvel usage. Seule exception : un claim provisional peut s'appuyer sur le claim d'une autre personne sans relecture à jour (ORANGE).
3. **Conclure le README.** Dans la section Conclusions du README de l'enquête : les claims, avec leur état de relecture. Relire Choix avec la personne : chaque décision de méthode de l'enquête y est.
   Fini quand : Conclusions liste chaque claim que la branche fait entrer, et la personne a confirmé Choix.
4. **Contrôler et enregistrer.** Supprimer les lectures qu'aucun claim ne cite, et, si l'enquête se ferme, les preuves d'exécution qu'aucun claim ne cite avec leurs requêtes (investigations/README.md, « L'issue ou le dépôt »). Lancer `python checks/check.py`, puis enregistrer (investigations/README.md, « La branche »).
   Fini quand : aucun ROUGE, les ORANGE restants sont listés pour la personne, et la branche est enregistrée.
5. **Faire entrer.** La personne relit et confirme ; l'agent ouvre ou met à jour la pull request vers main (investigations/README.md, « La branche »), avec « Refs #N » pour une enquête : l'issue reste ouverte, et l'étape 6 la ferme ou la suspend. Un résultat partiel peut entrer pendant que l'enquête reste ouverte.
   Fini quand : la personne a confirmé et la pull request est ouverte (ou son texte remis à la personne sans `gh`).
6. **Suspendre ou fermer**, au choix de la personne, quand l'enquête s'arrête. Fermer : une fois la dernière PR fusionnée dans main, supprimer la branche de l'enquête (`git push origin --delete investigation/<id>`), puis fermer l'issue à la main, avec un commentaire qui cite la PR. Suspendre : laisser l'issue ouverte, avec un commentaire qui dit où en est l'enquête et ce qui la relancerait.
   Fini quand : l'issue porte le commentaire de suspension, ou, après fusion de la PR, la branche est supprimée et l'issue fermée.
