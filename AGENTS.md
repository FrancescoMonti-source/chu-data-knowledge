# Règles pour les agents

Ce dépôt garde, avec leurs preuves, ce que nous découvrons sur les données du CHU. Les agents écrivent ; les personnes décident.

## Règles obligatoires

1. Aucune donnée de personne dans un fichier ni dans une réponse : le filtre passe avant tout enregistrement (docs/agents/privacy.md).
2. Une requête pour l'hôpital suit docs/agents/requests.md : agrégats seulement, masquage <10 dans la requête elle-même.
3. Avant d'écrire un fichier, lire la convention de son type (tableau ci-dessous).
4. Lancer `python checks/check.py` avant chaque commit. Corriger le contenu, jamais le contrôle.
5. Toute réponse qui utilise un claim cite son état de relecture.
6. Clés et valeurs en anglais ; texte libre en français.
7. Une règle (ce fichier, docs/agents/, les skills, checks/) ne change que par le mainteneur ; une décision reçoit un ADR dans docs/adr/.

## Où lire

| Avant de… | Lire |
|---|---|
| ranger un fichier, choisir un id, chercher ce qu'on sait | docs/agents/layout.md |
| écrire un claim | docs/agents/claims.md |
| écrire une preuve ou une fiche de source | docs/agents/evidence.md |
| préparer une requête, enregistrer un résultat | docs/agents/requests.md |
| réutiliser, relire ou contester un claim | docs/agents/review.md |
| ouvrir, retrouver ou reprendre une enquête | investigations/README.md |
| corriger une friction | .agents/skills/retro/SKILL.md, « Corriger » |
| comprendre un message ROUGE ou ORANGE | docs/agents/checks.md |
| comprendre un mot de la méthode | docs/agents/GLOSSARY.md |
| savoir pourquoi une règle existe | docs/adr/ |

## Agent skills

Les skills du dépôt sont dans .agents/skills/. Claude Code lit une copie dans .claude/skills/, générée par `python checks/sync_skills.py` : on ne modifie que .agents/skills/.

- **frame :** cadrer la question avec la personne.
- **research :** chercher ce qui est déjà écrit, dans les claims du dépôt puis dans les documents.
- **relay :** l'aller-retour à l'hôpital.
- **sediment :** écrire les claims, relire, contester, faire entrer, fermer.
- **retro :** en fin de session, quand la personne la lance : relever les accrocs avec elle, puis ouvrir ou compléter une issue friction. Quand la personne dit qu'elle s'arrête, lui proposer la retro.

Attendues hors du dépôt, installées par chacun : writing-for-agents (à chaque modification d'une skill, de ce fichier ou de docs/agents/ ; jamais pour un claim) et domain-modeling.
