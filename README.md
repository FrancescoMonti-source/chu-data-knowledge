# chu-data-knowledge

Un petit groupe, fatigué d'avancer à l'aveugle dans une infrastructure non documentée, met en commun ce qu'il découvre sur le système de données du CHU, avec les preuves. Des agents IA conservent ce savoir ici : chaque conversation part de là, pas de zéro.

- **Systèmes :** CORA, EDSaN, ICCA, OpRoom pour commencer, puis d'autres bases du système hospitalier.
- **Personnes :** le DIM et l'entrepôt de données. Un projet d'équipe, pas institutionnel.
- **Phase 1 (maintenant) :** chacun travaille avec son propre agent, over-the-air. Une personne fait le relais : elle exécute les requêtes à l'intérieur de l'hôpital et ne rapporte que des résultats agrégés. Aucune donnée de patient n'entre ici.
- **Phase 2 (vers avril 2027) :** des agents hands-on dans l'hôpital.

Les agents écrivent ; les personnes posent les questions et décident.

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

Chaque étape est une skill. L'agent les suit de lui-même : il suffit de lui poser la question.

| Étape | Skill | Ce que vous faites | Ce que vous obtenez |
|---|---|---|---|
| Cadrer | frame | vous posez la question ; vous confirmez le but, la population, la période, l'unité, la mesure et la comparaison | une question claire, en une phrase |
| Chercher | research | vous indiquez ou fournissez les documents | ce que le dépôt sait déjà ; s'il ne suffit pas, une enquête avec un plan, puis une preuve par passage lu |
| Interroger l'hôpital | relay | vous exécutez la requête à l'hôpital et rapportez le résultat | une requête prête à copier, puis le résultat enregistré comme preuve |
| Conclure | sediment | vous relisez les conclusions et donnez votre accord pour le merge | des claims que d'autres enquêtes réutiliseront |

research et relay peuvent alterner : un résultat de l'hôpital peut demander un nouveau document, sans l'imposer.

## Finir une session

Quand vous vous arrêtez, à n'importe quelle étape, lancez la retro : `/retro` dans Claude Code ; avec Codex, demandez-la. C'est la seule skill que l'agent ne lance pas de lui-même. Vous parlez avec lui de ce qui a gêné et de sa cause ; il ouvre ou complète une issue friction sur GitHub. Le mainteneur corrige une friction quand elle revient.

## Skills à installer soi-même

Deux skills du paquet supermatt, dérivé des skills de Matt Pocock, sont attendues hors du dépôt : writing-for-agents et domain-modeling. Elles servent à modifier les règles (skills, AGENTS.md, glossaires, ADR) : indispensables au mainteneur, conseillées à tous. Le dépôt n'en garde pas de copie (docs/adr/0000).

## Le dépôt

Deux sortes de fichiers : ce qu'on apprend sur l'hôpital, qui vaut par ses preuves, et la façon de travailler, qui vaut parce que le mainteneur l'a décidée. Pourquoi chaque dossier existe et où va chaque fichier : docs/agents/layout.md.

Ce qu'on apprend :

```text
systems/           connaissance relative à un logiciel ou à une base : tables, comportements (CORA, EDSaN…)
domains/           connaissance appartenant à un domaine précis et qui resterait vraie si le CHU changeait de logiciel : concepts et règles métier (PMSI par ex.)
investigations/    la réponse à une question, construite sur les claims de systems/ et/ou domains/
sources/           une fiche par document, citée par chacune de ses lectures
GLOSSARY-MAP.md    les contextes (pmsi, cora, edsan…) et leurs glossaires
```

Comment on travaille :

```text
AGENTS.md          règles pour les agents et pointeurs
docs/agents/       les conventions : écrire un claim, une preuve, une requête
docs/adr/          les décisions et leurs raisons (ADR : Architecture Decision Record)
.agents/skills/    les étapes : frame, research, relay, sediment, retro
checks/            les contrôles et leurs tests
```

## Commandes

| Commande | Effet |
|---|---|
| `python checks/check.py` | contrôle tout le dépôt : ROUGE bloque, ORANGE signale un travail à faire |
| `python checks/check.py --fingerprint <id>` | l'empreinte d'un claim, à recopier dans une relecture |
| `python checks/sync_skills.py` | recopie .agents/skills dans .claude/skills |
| `python -m unittest discover checks` | les tests des contrôles |
