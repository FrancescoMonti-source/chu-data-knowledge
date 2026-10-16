# 0031 — Relecture à froid d'octobre : PR pour faire entrer, catalogue sans WHERE 1=0, reprise dans research et retro invocable

Statut : accepté, 2026-10-16 (Francesco, relecture à froid d'octobre). Modifie 0008 (retro invocable par l'agent), 0009 (suppression de WHERE 1=0, reprise dans research) et 0011 (suppression d'openai.yaml, relecture des seules prémisses externes).

## Contexte

Une nouvelle relecture à froid d'AGENTS.md, de method/, des skills et de checks/check.py a relevé cinq contradictions entre les règles et leur contrôle :

1. **Faire entrer :** `sediment` demandait un `git merge --no-ff` direct sur `main`, alors que la règle 8 d'AGENTS.md interdit tout push direct sur `main` et exige une pull request.
2. **Découverte des colonnes :** l'exception `SELECT * … WHERE 1=0` (0009) échouait dans le contrôle dès que l'en-tête portait `person_data: no-person-data` (seul `SELECT *` restait vu par l'expression régulière) et contredisait `method/queries.md`.
3. **Reprise d'enquête :** `frame` reprenait une enquête déjà cadrée, sans fusionner `origin/main` ni vérifier si de nouveaux claims changeaient le plan.
4. **Relecture des prémisses :** `sediment` demandait de relire toute prémisse `unreviewed`, y compris les claims atomiques créés dans la même enquête par la même personne.
5. **Déclenchement de la retro :** `disable-model-invocation: true` et `agents/openai.yaml` (0011) empêchaient l'agent de proposer `retro` quand la personne annonçait la fin de la session.

## Décision

Faire entrer une enquête passe par une pull request vers `main` après les Conclusions du README (investigations/README.md, sediment/SKILL.md) ; `SELECT *` est interdit sans exception et les colonnes absentes de `sources/` se découvrent par le catalogue en `person_data: no-person-data` avec les règles 2, 5 et 6 sur toutes les requêtes (method/queries.md, checks/check.py) ; `research` reprend les enquêtes ouvertes, `sediment` ne fait relire que les prémisses d'une autre personne ou d'une autre enquête, et `retro` est invocable par l'agent (research/SKILL.md, sediment/SKILL.md, retro/SKILL.md).

## Alternatives écartées

- **Autoriser `git merge` direct sur `main` pour les enquêtes :** affaiblit la protection de la branche principale et prive la clôture du contrôle CI sur la pull request.
- **Réparer l'exception `SELECT * … WHERE 1=0` dans `check.py` :** interroger le catalogue en `person_data: no-person-data` donne directement les noms et types des colonnes dans un tableau Markdown normal, sans exception syntaxique dans le parseur SQL.
- **Garder `disable-model-invocation: true` sur `retro` :** oblige la personne à taper `/retro` après avoir déjà dit qu'elle s'arrêtait.

## Conséquences

- Toute clôture ou suspension d'enquête ouvre ou met à jour une pull request vers `main`.
- Un agent qui découvre une table écrit une requête sur le catalogue plutôt qu'un `SELECT * WHERE 1=0`.
- Ce qu'on perd : un agent pourrait déclencher `retro` trop tôt si un message ressemble à une fin de session ; la première phrase de `retro` demande l'accord de la personne avant de commencer.
