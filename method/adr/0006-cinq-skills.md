# 0006 — Cinq skills : frame, research, relay, sediment, retro

Statut : accepté, 2026-10-10 (Francesco). La retro est modifiée par 0008 : lancée par tous en fin de session.

## Contexte

La v0.4 prévoit quatre skills pour les utilisateurs, et retro pour les mainteneurs après environ cinq issues fermées. La première version (Codex) les a fusionnées en une seule. Dans la v0.4, frame cherchait aussi ce que le dépôt sait déjà, et research ne lisait que des documents : frame paraissait complète, les autres floues.

## Décision

Une skill par sorte d'activité :

| Skill | Activité |
|---|---|
| frame | parler : cadrer la question avec la personne |
| research | lire ce qui est déjà écrit : les claims du dépôt, puis les documents |
| relay | l'aller-retour à l'hôpital |
| sediment | écrire les claims et les faire entrer |
| retro | améliorer les règles à partir des frictions (mainteneur) |

- research garde la sortie anticipée de la v0.4 : si le dépôt répond déjà, aucune enquête ne s'ouvre.
- research et relay peuvent alterner par tours ; rien ne l'impose.
- retro est écrite dès maintenant, sur le modèle de la skill retro de supermatt, pour être prête à la première rétro. Elle est dans .agents/skills/ comme les autres, seul dossier que Codex et Claude Code lisent, et ne se lance qu'à la demande du mainteneur.

Chaque skill ne contient que des étapes avec leur critère de fin, et renvoie à docs/agents/ pour les règles.

## Raisons

- Le nom de chaque skill dit ce qu'elle fait, et la personne reconnaît les étapes.
- Chaque tâche ne charge que ses étapes ; celles de relay, qui protègent les données, ne sont pas noyées dans le reste.

## Alternative

Une seule skill avec des sections : un fichier de moins, mais toutes les étapes chargées à chaque tâche.
