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

Puis demander à son agent de cadrer une question : la skill frame s'en charge.

- **Codex** lit AGENTS.md et .agents/skills/.
- **Claude Code** lit CLAUDE.md, qui renvoie à AGENTS.md, et .claude/skills/.
- **App web :** créer un projet avec l'instruction « au début, lis AGENTS.md du dépôt et suis ses instructions ». À vérifier par un essai.

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
.agents/skills/    frame, research, relay, sediment
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
