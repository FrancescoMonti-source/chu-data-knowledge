# 0000 — Les décisions de l'architecture v0.4

Statut : accepté, 2026-10-09 (architecture v0.4, annexe). Certaines lignes sont modifiées par les ADR suivants.

| Décision | Pourquoi | État |
|---|---|---|
| Relecture au réemploi, pas au merge | à trois, une relecture à chaque merge crée une file d'attente | en vigueur |
| État de relecture dans le premier champ, cité dans les réponses | un agent lit aussi les claims qu'il ne déclare pas | en vigueur |
| depends_on bloquant, retrait motivé | l'agent ne peut pas effacer la ligne pour faire passer le contrôle | en vigueur ; le retrait motivé est une règle de confiance |
| Relecture de l'auteur marquée à part | le champ promet une deuxième personne | en vigueur (author-reread) |
| Preuves dans des fichiers, pas dans l'issue | les contrôles ne lisent que les fichiers ; l'issue finit par être fermée | en vigueur |
| Copier les preuves depuis cora | les contrôles automatiques n'ouvrent pas un autre dépôt privé | en vigueur |
| Protection des données dans la requête, pas de checklist | la personne qui exécute ne suit pas toujours une checklist | en vigueur, plus un filtre avant tout enregistrement (0001) |
| Pas de skill par système | dialectes et pièges sont des faits qui évoluent, pas des procédures | en vigueur |
| Quatre skills au départ | la structure se mérite avec de vraies enquêtes | modifié : cinq skills, retro écrite dès le départ (0006) |
| Debrief par tous, rétro par les mainteneurs en cas de répétition | évite une nouvelle règle pour chaque anecdote | en vigueur, sans arrêt après deux échecs (0001) |
| « Refs #N », jamais « Closes #N » | un résultat partiel ne doit pas fermer l'enquête | en vigueur ; contrôle à venir avec GitHub |
| Étiquette dormant, pas de fermeture automatique | fermer n'est pas résoudre | à venir avec GitHub |
| Quatre liens | ce sont ceux qu'utilisent les contrôles ; le reste, ce sont des champs | en vigueur |
| Pas d'index au départ | la recherche dans les champs des claims suffit ; un index généré met en conflit les PR parallèles | en vigueur |
| Token sans « Administration » ; pas de compte pour les agents | protège les réglages à faible coût | à appliquer à l'arrivée sur GitHub |
| Première enquête, puis import, puis archivage de cora | le format des claims se fixe avec la première enquête | modifié : l'usage peut commencer sans nouveau pilote (0001) |
| CODEOWNERS seulement avec plusieurs mainteneurs | seul, personne ne peut approuver ses propres PR | en vigueur |
| Chaque preuve est un fichier, même une lecture | un seul format : les mêmes liens et les mêmes contrôles pour toutes les preuves | en vigueur |
| Un claim = un test (refuted_if) | si un fait tombe, il tombe seul, et on sait quoi revoir | modifié : refuted_if seulement pour les claims empiriques (0001) ; la taille reste « un test » |
| Ligne de relecture obligatoire, relecteur différent de l'auteur | le contrôle voit l'étiquette, pas le travail : la ligne rend le raccourci visible | modifié : la ligne devient le champ work, l'auteur est déclaré, l'empreinte lie la relecture à une version (0003) |
| Plan dans l'issue, revu par un nouveau commentaire | échafaudage, pas connaissance | en vigueur ; tant que le dépôt est local, le plan vit dans le README de l'enquête |
| Faits, conventions et procédures séparés | une règle qui vaut aussi hors d'une skill ne peut pas vivre dans la skill | en vigueur |
| Debrief : une convention et une étape, pas une skill | une skill de moins ; noter et juger ne cohabitent pas | en vigueur |
| writing-for-agents réutilisée, pas pour les claims | ses leviers servent aux longs documents, pas à un claim de dix lignes | en vigueur |
| Dans le dépôt, seulement ses propres skills | pas de doublon avec les skills que chacun a déjà | en vigueur |
| Autorité dans le claim (champ authority) | — | modifié : l'autorité est dans la source (0001) |
