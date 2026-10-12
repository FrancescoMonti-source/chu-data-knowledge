# chu-data-knowledge

On travaille de plus en plus avec un agent IA, et ce qu'on apprend ensemble reste dans la conversation, puis se perd. Ce dépôt est un lieu commun : chacun, avec son agent, y sédimente ce qu'il découvre sur les données du CHU, avec les preuves. La conversation suivante, la sienne ou celle d'un collègue, part de là.

Les preuves comptent ici plus qu'ailleurs : l'infrastructure n'est pas documentée, et même la documentation de l'éditeur peut se tromper. Sans preuves, une erreur faite dans une conversation passerait dans toutes les suivantes.

- **Qui :** des personnes du DIM et de l'entrepôt de données. Un projet d'équipe, pas institutionnel.
- **Comment :** les agents écrivent ; les personnes posent les questions et décident. Les agents n'atteignent pas l'hôpital : une personne exécute leurs requêtes à l'intérieur et ne rapporte que des résultats agrégés. Aucune donnée de patient n'entre ici.
- **Ensuite (vers avril 2027) :** des agents qui travaillent directement dans l'hôpital.

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

Deux skills du paquet supermatt, dérivé des skills de Matt Pocock, sont attendues hors du dépôt. writing-for-agents sert à écrire les règles : skills, AGENTS.md, docs/agents/. domain-modeling sert à préciser les termes et à écrire glossaires et ADR, dans les formats du dépôt (docs/adr/0016). Les deux sont indispensables au mainteneur et conseillées à tous. Le dépôt n'en garde pas de copie (docs/adr/0000).

Il faut d'abord Node.js, qui fournit la commande `npx`. Sous Windows : `winget install OpenJS.NodeJS.LTS` dans un terminal, ou l'installateur « LTS » de https://nodejs.org. Fermez puis rouvrez le terminal, et vérifiez avec `node --version`.

Puis, dans un terminal :

```bash
npx skills add svyatov/supermatt -g -a claude-code -a codex -s writing-for-agents -s domain-modeling
```

L'option `-g` les installe dans votre dossier personnel (~/.claude/skills/ et ~/.agents/skills/), pour tous vos projets. Sans elle, la commande les écrirait dans .claude/skills/ et .agents/skills/ du dépôt, à côté de ses propres skills. Pour les mettre à jour : `npx skills update -g writing-for-agents domain-modeling`.

Si PowerShell refuse `npx` (« l'exécution de scripts est désactivée sur ce système »), tapez `npx.cmd` à la place de `npx` : c'est la même commande, sans le script que PowerShell bloque.

Le plugin supermatt complet, pour Claude Code ou Codex, contient aussi ces deux skills. Dans ce dépôt, ne lancez pas sa commande `setup-supermatt-skills` : elle écrit dans AGENTS.md et docs/agents/, qui suivent ici leurs propres règles.

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
