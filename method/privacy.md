# Données personnelles

Aucune donnée qui permette de reconnaître une personne, patient ou personnel, n'entre dans le dépôt ni dans une conversation avec un agent.

## Trois barrières

1. **La requête** agrège et masque (queries.md). C'est la barrière principale : le résultat passe par la conversation avec l'agent, donc chez OpenAI ou Anthropic, avant tout contrôle local.
2. **Le filtre, avant tout enregistrement.** Avant d'écrire un résultat, une citation ou une note, l'agent vérifie : seulement des agrégats ; aucun effectif de 1 à 9 en clair ; aucun identifiant (NIR, IPP, numéro de séjour), nom, date de naissance, adresse, téléphone ou email d'un patient. S'il en trouve un, il n'écrit rien et prévient la personne.
3. **Le contrôle** cherche la forme des valeurs dans tous les fichiers texte : un NIR dont la clé est valide ; une date complète après « date de naissance », « né le » ou « DDN », ou dans une colonne de naissance d'un tableau ; un effectif de 1 à 9 dans une colonne N_ ou NB_ d'un résultat masqué. Ses messages ne recopient jamais la valeur trouvée.

Décrire une colonne est permis : « NIR : numéro d'inscription au répertoire » est un libellé, pas une donnée. Si le contrôle prend un critère pour une date de naissance (une cohorte, une période), écrire l'année seule, ou le mois et l'année.

## Incident

Si une donnée de personne arrive dans la conversation ou dans un fichier :

1. **Arrêter.** Ne rien écrire ; si c'est écrit, pas de commit ; si le commit est fait, pas de push.
2. **Prévenir le mainteneur** (Francesco), sans recopier la donnée.
3. **Le mainteneur coordonne l'effacement** d'un fichier touché. Si la donnée est dans l'historique de git, il le réécrit : c'est le seul cas où on réécrit l'historique.
4. **Le mainteneur note l'incident :** date, conversation ou fichier, sorte de donnée, cause. Jamais la valeur.

Les relectures ne dépendent pas de l'historique de git : une réécriture ne les casse pas.
