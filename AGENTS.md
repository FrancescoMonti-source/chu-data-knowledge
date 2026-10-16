# Règles pour les agents

## Pourquoi ce dépôt

Ce dépôt sédimente ce que nous apprenons en analysant les données de l'hôpital, pour donner à l'agent de la prochaine analyse un contexte précis et vérifié. Ce contexte le guide pour interroger les données et interpréter les résultats, et pour produire à son tour des claims utiles, vrais et vérifiés, en suivant le format, la validation par une personne et les contraintes du dépôt. Plusieurs personnes et leurs agents y contribuent, et chaque conversation, de n'importe qui, part de là.

Un claim est donc écrit pour cet agent. Il doit être :

- **utile :** il change ce que l'agent écrit dans une requête ou conclut d'un résultat (method/claims.md, « Ce qui mérite un claim ») ;
- **vrai et vérifié :** appuyé sur ses preuves, réfutable, relu quand on le réutilise. Sans preuves, une erreur faite dans une conversation passerait dans toutes les suivantes ;
- **conforme :** le format de method/, le relay pour les données, la validation par une personne, les contrôles de check.py.

## Règles obligatoires

1. Aucune donnée de personne dans un fichier ni dans une réponse : le filtre passe avant tout enregistrement (method/privacy.md).
2. Une requête pour l'hôpital suit method/queries.md : agrégats seulement, masquage <10 dans la requête elle-même.
3. Avant d'écrire un fichier, lire la convention de son type (tableau ci-dessous).
4. Lancer `python checks/check.py` avant chaque commit. Corriger le contenu, jamais le contrôle.
5. Toute réponse qui utilise un claim cite son état de relecture.
6. Clés et valeurs en anglais ; texte libre en français.
7. Une règle (ce fichier, method/, les skills, checks/) ne change que par le mainteneur, quand il fusionne la pull request. Une décision qui compte et qui tranche reçoit un ADR (method/adr/README.md).
8. Les agents travaillent sur une branche autre que `main` et ouvrent une pull request vers `main`. Aucun push direct sur `main`, même si leurs droits GitHub le permettent.

## Où lire

| Avant de… | Lire |
|---|---|
| ranger un fichier, choisir un id, définir un terme ou un contexte, chercher ce qu'on sait | method/layout.md |
| écrire un claim | method/claims.md |
| écrire une preuve (lecture ou résultat) ou une fiche de source | method/evidence.md |
| préparer une requête ou une routine | method/queries.md |
| réutiliser, relire ou contester un claim | method/review.md |
| ouvrir, retrouver ou reprendre une enquête, écrire dans son issue | investigations/README.md |
| corriger une friction | method/maintenance.md |
| comprendre un message ROUGE ou ORANGE | method/checks.md |
| comprendre un mot de la méthode | method/GLOSSARY.md |
| changer une règle, écrire un ADR, savoir pourquoi une règle existe | method/adr/README.md |

## Agent skills

Les skills du dépôt (frame, research, relay, sediment, retro) sont dans .agents/skills/. Claude Code lit une copie dans .claude/skills/, générée par `python checks/sync_skills.py` : on ne modifie que .agents/skills/.

Attendues hors du dépôt, installées par chacun : writing-for-agents (à chaque modification d'une skill, de ce fichier ou de method/ ; jamais pour un claim) et domain-modeling (pour éprouver un terme avec la personne et le confronter aux claims). Ce que domain-modeling fait écrire suit les formats du dépôt plutôt que les siens : un terme selon method/layout.md (« Termes et glossaires »), la carte des contextes dans knowledge/glossaries/README.md, un lien entre deux contextes comme un claim, un ADR dans method/adr/, selon son README.md.
