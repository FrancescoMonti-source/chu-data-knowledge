# 0002 — Markdown avec en-tête YAML

Statut : accepté, 2026-10-10 (Francesco).

## Contexte

La v0.4 prévoyait des fichiers Markdown avec un en-tête YAML : agent-first, mais lisibles par une personne. La première version (Codex) a utilisé du JSON, sans décision écrite.

## Décision

Claims, preuves et sources sont des fichiers Markdown avec un en-tête YAML. Les requêtes sont des fichiers .sql avec un en-tête en commentaires (-- clé: valeur), pour être copiées telles quelles.

Le contrôle lit le YAML comme du texte seulement : no reste « no », une date reste une chaîne. Une clé répétée est ROUGE.

## Conséquences

- Une seule bibliothèque en plus : PyYAML.
- Un en-tête mal écrit est signalé fichier par fichier ; il n'arrête pas le contrôle des autres.
