# 0004 — Deux niveaux : ROUGE et ORANGE

Statut : accepté, 2026-10-10.

## Contexte

La première version avait un seul résultat : tout va bien, ou non. Le travail normal (un résultat partiel, une contestation, une relecture périmée) rendait tout le dépôt rouge, donc impossible à faire entrer.

## Décision

- ROUGE : quelque chose est cassé (format, lien, donnée sensible). Bloque ; le script sort avec le code 1.
- ORANGE : du travail reste à faire (relecture périmée, claim à réexaminer). S'affiche, ne bloque pas.

## Conséquences

Un résultat partiel et une contestation entrent avec des ORANGE, comme le prévoit la v0.4. Si un jour on veut bloquer aussi sur ORANGE, une option --strict suffira.
