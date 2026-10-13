# 0020 — Les agents passent par une pull request

Statut : accepté, 2026-10-13 (Francesco, dans la conversation Codex sur les droits des collaborateurs).

## Contexte

Les collaborateurs doivent pouvoir pousser directement sur `main`, tandis que leurs agents passent par une pull request. Quand un agent utilise les identifiants GitHub d'un collaborateur, GitHub ne distingue pas ces deux usages.

## Décision

À court terme, porter cette obligation dans AGENTS.md, règle 8. Les droits GitHub des collaborateurs restent inchangés.

## Conséquences

- La règle repose sur le respect des instructions par les agents ; GitHub ne l'impose pas.
- CLAUDE.md renvoie déjà à AGENTS.md : la même règle s'applique à Codex et à Claude Code.
