# 0036 — Chaque skill se déclenche par l'action qu'elle sert, à tout moment

Statut : proposé, 2026-10-19 (Francesco, prototype après la relecture adverse du modèle des skills). Modifie 0006 (une skill par activité) et 0034 (le parcours en trois temps).

## Contexte

Une demande ne suit pas une ligne. Pour comprendre la question, il faut parfois ce que le dépôt sait déjà ; pour choisir la méthode, parfois un chiffre de l'hôpital. Or les descriptions des skills disaient un moment du parcours : research et relay « dans une enquête ouverte, quand une étape du plan le demande », sediment « quand les preuves suffisent pour répondre ». Et chaque skill finissait par « Ensuite : <skill suivante> ». Un agent charge une skill d'après sa description : il lisait ces lignes comme un ordre à suivre, et ne chargeait pas une skill quand l'action arrivait hors de son moment, par exemple un claim utile au milieu d'une enquête.

## Décision

La description de chaque skill nomme l'action qui la charge : répondre à une question (frame), enregistrer ce que dit un document (research), écrire une requête pour l'hôpital (relay), écrire un claim, faire entrer ou fermer (sediment). Aucune skill ne nomme la suivante : l'ordre vient du plan de l'enquête. Les règles : AGENTS.md, « Agent skills ».

## Raisons

- Les barrières restent attachées à l'action qui en a besoin : le filtre de relay part à chaque requête, la relecture et la pull request de sediment à chaque claim qui entre. Seul ce qui ne protège rien disparaît : le moment.
- Lire n'écrit rien dans le dépôt : aucune skill ne le garde.

## Alternatives écartées

- Une seule skill sans étapes séparées : écartée par 0006, toutes les étapes chargées à chaque tâche, et celles de relay noyées.
- Garder les moments et attendre qu'une vraie session montre qu'ils gênent (relecture adverse du 2026-10-19) : moins de texte changé, mais la session où un agent ne charge pas une skill ne se voit pas ; personne ne remarque une skill qui ne s'est pas chargée.

## Conséquences

- Pour savoir quoi faire ensuite, l'agent lit le plan dans l'issue de l'enquête, pas la fin de la skill.
- Reprendre une enquête ne passe plus par frame : investigations/README.md, « Reprendre », via le tableau « Où lire » d'AGENTS.md.
- sediment se charge aussi pour un seul claim en cours d'enquête : ses étapes 1 à 3 seulement.
