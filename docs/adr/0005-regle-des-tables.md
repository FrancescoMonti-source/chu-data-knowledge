# 0005 — Un claim qui nomme des tables va dans systems/

Statut : accepté, 2026-10-10 (Francesco).

## Contexte

La v0.4 donne une règle pratique : un claim qui doit nommer des tables va dans systems/. SPEC.md dit l'inverse (citer une table n'impose pas systems/), sans qu'une révision l'explique.

## Décision

Garder la règle de la v0.4, contrôlée : un claim de domains/ avec tables non vide est ROUGE.

## Raisons

- Simple à appliquer pour un agent, simple à contrôler.
- Un claim de domaine reste vrai sans logiciel précis ; s'il nomme des tables, il décrit un système.

## Alternative

Le sujet décide seul, sans contrôle. Pour y passer : retirer ce contrôle de checks/check.py et son test, et mettre à jour docs/agents/layout.md.
