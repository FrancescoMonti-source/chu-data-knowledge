---
name: sediment
description: Transformer les preuves d'une enquête en claims et les faire entrer dans le dépôt. Utiliser quand les preuves suffisent pour répondre ; aussi pour réutiliser, contester ou remplacer un claim, et pour suspendre ou fermer une enquête.
---

# sediment

D'abord, demander à la personne ce que devient l'enquête : elle se ferme, elle est suspendue, ou elle continue après un résultat partiel. Les étapes 5 et 6 en dépendent ; si elle continue, sediment s'arrête à l'étape 5.

1. **Écrire les claims.** Passer chaque conclusion, y compris la réponse à la question de l'enquête, au test de method/claims.md (« Ce qui mérite un claim »). Celles qui le passent deviennent des claims dans knowledge/claims/, un par usage (« Taille »), avec leur section « Pour s'en servir ». Les autres restent dans le README ou l'issue ; la réponse va dans le commentaire qui ferme l'issue (étape 6).
   Une mesure nouvelle sur un sujet déjà couvert par un claim modifie ce claim (statement, « Pour s'en servir » ou « Ce qui l'appuie ») ; elle n'ajoute ni section ni paragraphe de mesures. Si le claim a été relu et doit changer, review.md.
   Fini quand : chaque conclusion qui passe le test est un claim, et aucune autre ; chaque statement passe le test de method/claims.md (champ statement) : il guide l'agent ; chaque « Pour s'en servir » dit à un agent quoi faire sans qu'il lise la suite ; aucune mesure nouvelle n'est ajoutée à un claim existant sous forme de section.
2. **Relire ce qu'on réutilise** (review.md). Pour chaque prémisse, selon sa sorte :
   - **claim d'une autre personne, sans relecture à jour :** la relecture au réemploi. La personne lit le travail refait et l'approuve avant que l'agent écrive le bloc review à son nom.
   - **claim de la même personne, venu d'une autre enquête :** author-reread, que la personne fait dans une nouvelle session ; l'agent le lui demande et attend qu'elle revienne.

   Fini quand : chaque prémisse est relue ou déjà à jour, et sa portée (scope) couvre le nouvel usage. Seule exception : un claim provisional peut s'appuyer sur le claim d'une autre personne sans relecture à jour (ORANGE).
3. **Contrôler :** `python checks/check.py`.
   Fini quand : aucun ROUGE ; les ORANGE restants sont listés pour la personne.
4. **Conclure le README.** Dans la section Conclusions du README de l'enquête : les claims, avec leur état de relecture. Relire Choix avec la personne : chaque décision de méthode prise après le cadrage y est. Enregistrer (investigations/README.md, « La branche »).
   Fini quand : Conclusions liste chaque claim que la branche fait entrer, la personne a confirmé Choix, et le README est enregistré.
5. **Faire entrer.** Supprimer les lectures qu'aucun claim ne cite et, si l'enquête se ferme, les preuves d'exécution qu'aucun claim ne cite, avec leurs requêtes (investigations/README.md, « L'issue ou le dépôt »). La personne qui mène l'enquête relit et confirme ; l'agent ouvre une pull request de la branche de l'enquête vers la branche principale, qui écrit « Refs #N » : l'issue reste ouverte, et l'étape 6 la ferme ou la suspend. Un mainteneur la fusionne (AGENTS.md, règle 8). Un résultat partiel peut entrer pendant que l'enquête reste ouverte. Pas de pull request quand la branche n'a rien à faire entrer ni à retirer de main.
   Fini quand : la personne a confirmé et la pull request est ouverte, ou la branche n'a rien à faire entrer ni à retirer.
6. **Fermer ou suspendre**, selon la réponse du début. Fermer : une fois le dernier merge fait, ou tout de suite s'il n'y a pas de pull request, fermer l'issue à la main, avec un commentaire qui donne la réponse et cite la PR ; sans PR, il donne aussi le cadrage et les choix, que le README emporte avec la branche, et la date de chaque résultat. Puis supprimer la branche de l'enquête (`git push origin --delete investigation/<id>`) ; si GitHub le refuse, demander à la personne de la supprimer (page Branches du dépôt). Suspendre : laisser l'issue ouverte, avec un commentaire qui dit où en est l'enquête et ce qui la relancerait.
   Fini quand : l'issue est fermée et la branche supprimée, ou l'issue porte le commentaire de suspension.

**Contester ou remplacer un claim :** review.md, « Contestation », puis les étapes 3 et 5.
