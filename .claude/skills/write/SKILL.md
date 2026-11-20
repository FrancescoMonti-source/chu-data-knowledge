---
name: write
description: Écrire ou reprendre un document qu'une personne lira (note de méthode, rapport, courriel, résumé pour un collègue, un demandeur ou la direction). Utiliser avant le premier jet et à chaque reprise. Un claim, une skill ou une règle du dépôt s'écrit pour un agent, hors de cette skill.
---

# write

Le lecteur n'a pas vu le travail. On écrit à partir de ce qu'il doit pouvoir faire après lecture, dans l'ordre où il s'en sert, et non dans l'ordre où les choses ont été décidées.

1. **Cerner le lecteur.** Écrire en une ligne chacun, et le montrer à la personne qui demande le document :
   - **lecteur :** qui, et ce qu'il sait déjà ;
   - **tâche :** ce qu'il doit pouvoir faire après lecture (refaire un calcul, décider, répondre à un questionnaire, défendre un chiffre) ;
   - **ses questions :** les cinq questions qu'il posera. Pour un comptage, par exemple : « qu'est-ce qui est compté exactement ? », « dans quelles tables et quels champs ? », « ne compte-t-on que les retours par les urgences ? », « que le nombre ne voit-il pas ? », « comment le refaire ? ».

   Fini quand : la personne a confirmé les trois lignes.
2. **Proposer un plan :** les titres, avec une ligne chacun, selon « La forme ».
   Fini quand : la personne a accepté le plan.
3. **Écrire**, selon « La forme » et « Rendre la lecture facile ».
   Fini quand : chaque question du lecteur a sa réponse dans le document.
4. **Tester avec un lecteur neuf.** Donner à un agent neuf le document seul, sans rien de la conversation, avec les questions du lecteur. Lui demander de répondre à chacune, puis de dire ce qui est ambigu et ce que le document suppose déjà connu. Chaque réponse fausse, absente ou hésitante est un trou : corriger le document, puis relancer le test. Sans sous-agent, la personne fait le test dans une nouvelle conversation.
   Fini quand : l'agent neuf répond juste à chaque question.

À chaque remarque de la personne : corriger la partie visée, puis refaire l'étape 4 sur tout le document. Le reste garde ce que le test a validé.

## La forme

D'abord la réponse, en deux phrases. Puis le contenu dans l'ordre où le lecteur s'en sert. Pour une méthode ou un comptage : les étapes de ce qui est compté, numérotées, chacune avec ses détails concrets (tables, champs, codes, fenêtres de temps, taille des listes, règle exacte) et son pourquoi en une proposition ; puis ce que le nombre ne voit pas ; comment le refaire ; les questions ouvertes et les pièces jointes.

Un choix s'explique dans l'étape où il s'applique. Une table des choix à part justifie des décisions dont le lecteur ignore encore l'existence.

## Rendre la lecture facile

Le lecteur survole : il saute à la partie qui répond à son problème. D'après « What makes documentation good » (OpenAI) :

- **Un titre dit ce que montre sa section,** en phrase (« Seuls les retours non créés à l'avance comptent »), plutôt qu'un thème (« Non programmé »).
- **Chaque paragraphe s'ouvre sur une phrase qui tient seule** et donne son idée, mot clé en tête.
- **Les résultats avant la méthode.**
- **Des paragraphes courts.** Une idée clé peut faire un paragraphe d'une phrase. Des puces et des tableaux pour les éléments parallèles ; du gras seulement sur les mots qu'un lecteur pressé doit voir.
- **Des phrases simples :** couper les longues, sujet et verbe tôt, sans adverbes ni remplissage.
- **Des mots précis et simples :** écrire les sigles en entier, définir un terme avant qu'une phrase s'appuie dessus, garder un seul nom pour une chose.
- **Nommer la chose** plutôt que renvoyer à la phrase d'avant par « ce » ou « cela ».
- **Expliquer plus simplement qu'on ne le croit nécessaire,** sans simplifier à l'excès. Dans le doute, garder l'explication : l'expert saute une ligne, le débutant bute sur celle qui manque. Une explication aide à comprendre ; une justification défend un choix que le lecteur n'a pas mis en cause : garder la première, couper la seconde.
- **Dire la chose** plutôt que ce que le lecteur pense ou veut (« vous voudrez sans doute… »).
- **Ordonner par utilité pour le lecteur :** le cas courant d'abord, les cas rares à la fin ou dehors.

Enfreindre une de ces règles seulement quand la suivre gênerait le lecteur.

## Couper

Avant de retirer une phrase, se demander : « si je la coupe, qu'est-ce qui casse pour le lecteur ? » La couper seulement si rien ne casse. Un détail qu'il faut pour refaire ou vérifier un résultat reste. Rendre compte d'une coupe par ce qu'elle a retiré, et non par la longueur gagnée.

## Sources

- Anthropic, skill doc-coauthoring : le test avec un lecteur neuf et les questions prévues du lecteur. https://github.com/anthropics/skills/tree/main/skills/doc-coauthoring
- Matt Pocock, skills writing-shape et writing-beats : établir ce que le lecteur sait déjà ; « If I cut this, what breaks? ». https://github.com/mattpocock/skills/tree/main/skills/in-progress
- OpenAI Cookbook, « What makes documentation good ». https://github.com/openai/openai-cookbook/blob/main/articles/what_makes_documentation_good.md
