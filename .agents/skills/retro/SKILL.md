---
name: retro
description: Rétrospective du mainteneur sur les frictions notées dans les enquêtes, pour proposer des changements de règles. Seulement quand le mainteneur la demande.
disable-model-invocation: true
---

# retro

Debrief note, rétro change : cette skill propose, le mainteneur décide. Elle s'inspire de la skill retro de supermatt, appliquée aux frictions des enquêtes plutôt qu'à une session de code.

1. **Charger writing-for-agents** (installée hors du dépôt) : toute modification d'une skill, d'AGENTS.md ou de docs/agents/ suit ses règles.
2. **Rassembler les frictions :** les lignes des sections Frictions de chaque `investigations/*/README.md` (et des issues friction, sur GitHub). Une ligne déjà examinée par une rétro porte « → rétro <date> ».
   Fini quand : chaque README d'enquête a été lu, et chaque friction non examinée est listée avec son enquête et sa date.
3. **Regrouper** les frictions qui décrivent le même accroc, et compter les répétitions, lignes déjà examinées comprises : un accroc qui revient après un changement montre que le changement n'a pas suffi.
   Fini quand : chaque friction non examinée appartient à un groupe.
4. **Chercher la cause** de chaque groupe, dans cet ordre :
   - **Contrôle :** un contrôle aurait-il attrapé l'erreur ? Une règle qu'on peut contrôler devient un contrôle, avec son test, plutôt qu'une phrase de plus.
   - **Pointeur :** l'agent a-t-il manqué une règle qui existe ? Il manque alors un pointeur dans AGENTS.md, une skill ou docs/agents/.
   - **Dérive :** deux règles se contredisent-elles, ou une règle cite-t-elle un chemin, un champ ou une commande qui n'existe plus ? Une contradiction passe avant le reste.
   - **Étape floue :** une étape de skill dit-elle mal quoi faire, ou son critère de fin est-il trop vague ?
   - **Poids mort :** une règle ne change-t-elle rien, ou est-elle écrite deux fois ?
5. **Filtrer.** Garder un groupe seulement s'il s'est répété au moins deux fois, ou s'il touche la sécurité des données ; s'il cite les lignes de friction qui le montrent ; et si la leçon n'est pas déjà écrite dans les règles. Corriger la règle existante plutôt qu'en ajouter une. Proposer aussi de retirer : si les skills et docs/agents/ ne font que grandir d'une rétro à l'autre, la rétro ajoute sans retirer.
   Fini quand : chaque groupe est gardé ou écarté, avec sa raison.
6. **Présenter** au mainteneur les propositions gardées, de la plus grave à la moins grave : les frictions citées, la cause, le changement (fichier et texte). Si aucune ne reste, le dire, avec la raison de chaque écart.
7. **Appliquer ce que le mainteneur accepte :** un commit par changement, un ADR si c'est une décision (docs/adr/). Puis marquer chaque friction examinée : « → rétro <date> : <changement> », ou « → rétro <date> : écartée ».
   Fini quand : chaque friction examinée porte sa marque, et `python checks/check.py` ne donne aucun ROUGE.
