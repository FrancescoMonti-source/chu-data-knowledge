# 0006 — Quatre skills : frame, research, relay, sediment

Statut : proposé, à confirmer par Francesco.

## Contexte

La v0.4 prévoit quatre skills. La première version (Codex) les a fusionnées en une seule, qui renvoie aux conventions. Francesco n'est pas sûr de cette fusion (2026-10-10).

## Décision proposée

Quatre skills courtes, qui ne contiennent que des étapes avec leur critère de fin, et renvoient à docs/agents/ pour les règles.

## Raisons

- Chaque tâche ne charge que ses étapes.
- Les étapes de relay, celles qui protègent les données, ne sont pas noyées dans le reste.
- Le debrief suit les moments prévus par la v0.4 : relay à la livraison d'une requête, sediment à la fermeture, frame à la reprise.

## Alternative

Une seule skill avec quatre sections : un fichier de moins, mais toutes les étapes chargées à chaque tâche.
