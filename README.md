# chu-data-knowledge

Ce que nous découvrons sur les données du CHU (CORA, EDSaN, ICCA, OpRoom, PMSI), avec les preuves. Chaque conversation avec un agent part de là, pas de zéro.

Les agents écrivent les fichiers ; les personnes posent les questions, exécutent les requêtes à l'hôpital et décident. Aucune donnée de patient n'entre ici : seulement des résultats agrégés et masqués.

## État

Le squelette est en place ; il n'y a encore aucun claim. La première enquête fixera le format sur le terrain.

## Commencer

```text
pip install -r requirements.txt
python checks/check.py
```

Puis poser une question à son agent : il commence par la cadrer avec vous.

- **Codex** lit AGENTS.md et .agents/skills/.
- **Claude Code** lit CLAUDE.md, qui renvoie à AGENTS.md, et .claude/skills/.
- **App web :** créer un projet avec l'instruction « au début, lis AGENTS.md du dépôt et suis ses instructions ». À vérifier par un essai.

## Une enquête, étape par étape

Chaque étape est une skill. L'agent la suit de lui-même : il suffit de lui poser la question.

| Étape | Skill | Ce que vous faites | Ce que vous obtenez |
|---|---|---|---|
| Cadrer | frame | vous posez la question ; vous confirmez le but, la population, la période, l'unité, la mesure et la comparaison | une question claire, en une phrase |
| Chercher | research | vous indiquez ou fournissez les documents | ce que le dépôt sait déjà ; s'il ne suffit pas, une enquête avec un plan, puis une preuve par passage lu |
| Interroger l'hôpital | relay | vous exécutez la requête à l'hôpital et rapportez le résultat | une requête prête à copier, puis le résultat enregistré comme preuve |
| Conclure | sediment | vous relisez les conclusions et donnez votre accord pour le merge | des claims que d'autres enquêtes réutiliseront |
| Améliorer | retro | (mainteneur) vous lancez la rétro de temps en temps | des propositions de changement de règles, fondées sur les frictions notées |

research et relay peuvent alterner : un résultat de l'hôpital peut demander un nouveau document, sans l'imposer.

## Skills à installer soi-même

Deux skills du paquet supermatt, dérivé des skills de Matt Pocock, sont attendues hors du dépôt : writing-for-agents et domain-modeling. Elles servent à modifier les règles (skills, AGENTS.md, glossaires, ADR) : indispensables au mainteneur, conseillées à tous. Le dépôt n'en garde pas de copie (docs/adr/0000).

## Le dépôt

```text
AGENTS.md          règles pour les agents et pointeurs
GLOSSARY-MAP.md    les contextes (pmsi, cora, edsan…) et leurs glossaires
systems/           ce qu'on sait de chaque logiciel ou base
domains/           concepts et règles sans logiciel précis (PMSI)
investigations/    une enquête par dossier
sources/           une fiche par document
docs/agents/       les conventions
docs/adr/          les décisions et leurs raisons
.agents/skills/    frame, research, relay, sediment, retro
checks/            les contrôles et leurs tests
```

## Commandes

| Commande | Effet |
|---|---|
| `python checks/check.py` | contrôle tout le dépôt : ROUGE bloque, ORANGE signale un travail à faire |
| `python checks/check.py --fingerprint <id>` | l'empreinte d'un claim, à recopier dans une relecture |
| `python checks/sync_skills.py` | recopie .agents/skills dans .claude/skills |
| `python -m unittest discover checks` | les tests des contrôles |

## Historique

Cette version repart de zéro depuis l'architecture v0.4 et ses six révisions (docs/adr/0007). Les branches codex/* gardent la première version, pour référence.
