# Le guide des ADR et la pratique courante

Le guide (README.md) suit la pratique courante des ADR, sauf sur deux points. Ce fichier dit lesquels et pourquoi, pour qu'un agent qui connaît la pratique ne les rouvre pas sans raison nouvelle.

Les citations sont exactes, dans la langue de la source, et viennent d'une lecture du 16 octobre 2026. Ses autres sources et citations sont dans l'historique git de ce fichier.

## Sources

| # | Source | Date |
|---|---|---|
| S1 | Michael Nygard, [Documenting Architecture Decisions](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions) | 2011-11-15 |
| S12 | AWS, [ADR process](https://docs.aws.amazon.com/prescriptive-guidance/latest/architectural-decision-records/adr-process.html) | mars 2022 |
| S15 | Microsoft, [Maintain an architecture decision record (ADR)](https://learn.microsoft.com/en-ca/azure/well-architected/architect-role/architecture-decision-record) | mise à jour 2026-04-13 |
| S20 | Josef Blake, Spotify, [When Should I Write an Architecture Decision Record](https://engineering.atspotify.com/2020/4/when-should-i-write-an-architecture-decision-record) | 2020-04-14 |
| S24 | Olaf Zimmermann, [How to create ADRs — and how not to](https://ozimmer.ch/practices/2023/04/03/ADRCreation.html) | 2023-04-03 |
| S28 | Joel Parker Henderson, [architecture-decision-record](https://github.com/joelparkerhenderson/architecture-decision-record) | dépôt vivant |

## Ce que le guide suit

- Peu d'ADR, pour les choix difficiles à défaire : « Only include choices that affect the system's structure, key quality attributes, or are difficult to reverse. » (S15) « We want to skip an ADR when a decision is limited in scope and time and risk and cost, or is already covered elsewhere. » (S28)
- La raison dans l'ADR, la règle ailleurs : l'ADR « focuses on the reason for the decision rather than how the team implemented it ». (S12) L'erreur est le « Blueprint or Policy in Disguise », un texte qui ressemble à « a cookbook or law ». (S24)
- Une décision par ADR, une page : « One ADR describes one significant decision for a specific project. » « The whole document should be one or two pages long. » (S1)

## Où le guide s'écarte

1. **Un mainteneur demande l'ADR.** Les sources laissent l'équipe juger ce qui compte ; Spotify en écrit « Almost always! ». (S20) Ici, les auteurs sont des agents, qui écrivaient un ADR par réflexe après chaque revue : 32 en une semaine, du 9 au 16 octobre 2026, dont 22 supprimés le 19 octobre parce que leur choix était facile à défaire.
2. **Un ADR change en place, ou disparaît.** Nygard garde l'ancien : « If a decision is reversed, we will keep the old one around, but mark it as superseded. » (S1) AWS : « When the team accepts an ADR, it becomes immutable. » (S12) Henderson, au contraire : « In theory, immutability is ideal. In practice, mutability has worked better for our teams. » (S28) Ici, un agent lit chaque fichier du dossier comme une règle en vigueur, et citait les ADR remplacés comme des interdits. L'historique git garde l'ancien texte : rien n'est perdu.

## Ce que les sources ne disent pas

Toutes décrivent des équipes humaines. Aucune n'étudie un dépôt écrit par des agents, dont le lecteur principal est un agent : les deux écarts viennent de là.
