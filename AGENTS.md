# Règles pour les agents

## Pourquoi ce dépôt

Ce dépôt sédimente ce que nous apprenons en analysant les données de l'hôpital, pour donner à l'agent de la prochaine analyse un contexte précis et vérifié. Ce contexte le guide pour interroger les données et interpréter les résultats, et pour produire à son tour des claims utiles, vrais et vérifiés, en suivant le format, la validation par une personne et les contraintes du dépôt. Plusieurs personnes et leurs agents y contribuent, et chaque conversation, de n'importe qui, part de là.

Un claim est donc écrit pour cet agent : il doit changer ce que l'agent écrit dans une requête ou conclut d'un résultat (method/claims.md, « Ce qui mérite un claim »). Il doit aussi être vrai : sans preuves, une erreur faite dans une conversation passerait dans toutes les suivantes.

Les principes, un mot chacun :

| Principe | En pratique |
|---|---|
| agent-first | les agents écrivent, les personnes décident |
| over-the-air | l'hôpital, on l'atteint par une personne |
| bounded-context | chaque terme vaut dans son contexte |
| evidence-based | chaque claim renvoie à ses preuves |
| falsifiable | chaque claim empirique dit quelle observation le contredirait |
| review-on-reuse | on relit un claim quand on construit dessus |
| privacy-by-design | sur des personnes, des agrégats seulement, masqués dans la requête |
| single-source-of-truth | chaque information à un seul endroit |
| CI-enforced | les contrôles imposent ce qui peut l'être ; le reste est une règle de confiance |
| human-in-the-loop | aucune règle ne change sans une personne |
| YAGNI | la structure naît quand une vraie enquête la demande |

## Règles obligatoires

1. Aucune donnée de personne dans un fichier ni dans une réponse : le filtre passe avant tout enregistrement (method/privacy.md).
2. Une requête pour l'hôpital suit method/queries.md : sur des personnes, agrégats seulement, masquage <10 dans la requête elle-même.
3. Avant d'écrire un fichier, lire la convention de son type (tableau ci-dessous).
4. Lancer `python checks/check.py` avant chaque commit. Corriger le contenu, jamais le contrôle.
5. Toute réponse qui utilise un claim cite son état de relecture.
6. Clés et valeurs en anglais ; texte libre en français.
7. Une règle (ce fichier, method/, les skills, checks/) ne change que quand un mainteneur fusionne la pull request. Si l'autre s'y oppose, avec une raison, elle reste ou redevient ce qu'elle était jusqu'à leur accord. Un ADR ne s'écrit que quand un mainteneur le demande (method/adr/README.md).
8. Les agents travaillent sur une branche autre que `main` et ouvrent une pull request vers `main`. Aucun push direct sur `main`, même si leurs droits GitHub le permettent. Un agent ne fusionne une pull request que si la personne le lui demande.

## Où lire

| Avant de… | Lire |
|---|---|
| ranger un fichier, choisir un id, définir un terme ou un contexte, chercher ce qu'on sait | method/layout.md |
| écrire un claim | method/claims.md |
| écrire une preuve ou une fiche de source | method/evidence.md |
| préparer une requête ou une routine, enregistrer un résultat | method/queries.md |
| réutiliser, relire ou contester un claim | method/review.md |
| ouvrir, retrouver ou reprendre une enquête, revoir son plan, noter un choix, écrire dans son issue | investigations/README.md |
| corriger une friction | method/maintenance.md |
| comprendre un message ROUGE ou ORANGE | method/checks.md |
| comprendre un mot de la méthode | method/GLOSSARY.md |
| écrire ou lire un ADR, savoir pourquoi un choix difficile à défaire a été fait | method/adr/README.md |

## Agent skills

Les skills du dépôt sont dans .agents/skills/. Claude Code lit une copie dans .claude/skills/, générée par `python checks/sync_skills.py` : on ne modifie que .agents/skills/.

- **frame :** toute question nouvelle sur les données du CHU commence par frame : la cadrer avec la personne, et retrouver ce que le dépôt en sait ; puis répondre, préparer une routine, ou ouvrir une enquête si quelque chose manque.
- Pour chaque étape du plan d'une enquête : **research** pour lire un document, **relay** pour l'aller-retour à l'hôpital.
- **sediment :** écrire les claims, relire, contester, faire entrer, fermer.
- **retro :** en fin de session, quand la personne la lance : relever les accrocs avec elle, puis ouvrir ou compléter une issue friction. Quand la personne dit qu'elle s'arrête, lui proposer la retro.

Attendues hors du dépôt, installées par chacun : writing-for-agents (à chaque modification d'une skill, de ce fichier ou de method/ ; jamais pour un claim) et domain-modeling (pour éprouver un terme avec la personne et le confronter aux claims). Ce que domain-modeling fait écrire suit les formats du dépôt plutôt que les siens : un terme selon method/layout.md (« Termes et glossaires »), un lien entre deux contextes comme un claim, un ADR dans method/adr/, selon son README.md.
