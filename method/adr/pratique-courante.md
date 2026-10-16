# Ce que dit la pratique courante des ADR

Les sources du guide des ADR (README.md), et ce qu'elles disent. Le guide les cite par leur numéro, comme (S1).

Les citations sont exactes, dans la langue de la source. Elles viennent d'une lecture du 16 octobre 2026 ; les numéros reprennent ceux de cette lecture.

## Sources

| # | Source | Date |
|---|---|---|
| S1 | Michael Nygard, [Documenting Architecture Decisions](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions) | 2011-11-15 |
| S6 | Projet MADR, [MADR](https://adr.github.io/madr/) | version 4.0.0, 2024-09-17 |
| S9 | Martin Fowler, [Architecture Decision Record](https://www.martinfowler.com/bliki/ArchitectureDecisionRecord.html) | 2026-03-24 |
| S12 | AWS, [ADR process](https://docs.aws.amazon.com/prescriptive-guidance/latest/architectural-decision-records/adr-process.html) | mars 2022 |
| S15 | Microsoft, [Maintain an architecture decision record (ADR)](https://learn.microsoft.com/en-ca/azure/well-architected/architect-role/architecture-decision-record) | mise à jour 2026-04-13 |
| S16 | Google Cloud, [Architecture decision records overview](https://docs.cloud.google.com/architecture/architecture-decision-records) | mise à jour 2024-08-16 |
| S19 | GDS, [The GDS Way: architecture decisions](https://gds-way.digital.cabinet-office.gov.uk/standards/architecture-decisions.html) | revue 2026-03-05 |
| S20 | Josef Blake, Spotify, [When Should I Write an Architecture Decision Record](https://engineering.atspotify.com/2020/4/when-should-i-write-an-architecture-decision-record) | 2020-04-14 |
| S21 | Olaf Zimmermann, [Architectural Significance Test and Some Core Decisions](https://ozimmer.ch/practices/2020/09/24/ASRTestECSADecisions.html) | 2020-09-24 |
| S22 | Olaf Zimmermann, [A Definition of Done for Architectural Decision Making](https://ozimmer.ch/practices/2020/05/22/ADDefinitionOfDone.html) | 2020-05-22 |
| S23 | Olaf Zimmermann, [Definition of Ready for Architectural Decisions](https://ozimmer.ch/practices/2023/12/01/ADDefinitionOfReady.html) | 2023-12-01 |
| S24 | Olaf Zimmermann, [How to create ADRs — and how not to](https://ozimmer.ch/practices/2023/04/03/ADRCreation.html) | 2023-04-03 |
| S28 | Joel Parker Henderson, [architecture-decision-record](https://github.com/joelparkerhenderson/architecture-decision-record) | dépôt vivant |
| S30 | Python, [PEP 1](https://peps.python.org/1) | modifiée 2026-09-27 |
| S31 | Rust, [RFCs README](https://github.com/rust-lang/rfcs) | non daté |
| S33 | Skill domain-modeling, ADR-FORMAT.md (supermatt) : un outil de praticien, pas une norme | copie du 16/10 |

## Pour qui

- Le lecteur futur, qui sinon ne peut que « Blindly accept the decision » ou « Blindly change it » ; « We will write each ADR as if it is a conversation with a future developer. » (S1)
- « We want to create an ADR when we want future developers to understand the "why" of what we're doing. » (S28)

## Quand en écrire un : la décision compte

- Nygard garde les décisions « architecturally significant » : « those that affect the structure, non-functional characteristics, dependencies, interfaces, or construction techniques ». (S1)
- AWS reprend la liste et y met les manières de travailler : « Construction techniques (libraries, frameworks, tools, and processes) ». (S12)
- Microsoft est plus strict : « Only include choices that affect the system's structure, key quality attributes, or are difficult to reverse. » (S15)
- Zimmermann teste l'importance par sept questions, et prévient : « The ASR Test is not a quantitative tool, a weight calculator. » (S21)

## Quand en écrire un : la décision tranche

- Google : « When there are two or more engineering options and you want to document your thoughts and reasons behind the selection. » (S16)
- Une décision est prête quand « At least two design alternatives (decision options) have been identified ». (S23) Elle est faite quand on a « decided between at least two options, and compared them ». (S22)

## Quand ne pas en écrire

- « We want to skip an ADR when a decision is limited in scope and time and risk and cost, or is already covered elsewhere. » (S28)
- Renommer une classe est l'exemple d'une décision qui ne compte pas : « simple to change in IDEs that support refactoring ». (S21)
- Rust : « Some changes do not require an RFC: Rephrasing, reorganizing, refactoring, or otherwise "changing shape does not change meaning". » (S31) Python : « Most enhancements and bug fixes don't need a PEP ». (S30)
- « If there was no real alternative, there's nothing to record beyond "we did the obvious thing." » (S33)

## Comment l'écrire

- Une décision par ADR : « One ADR describes one significant decision for a specific project. » (S1)
- Une page : « The whole document should be one or two pages long. » (S1) « Keep the ADR short and to the point - typically a single page. » (S9)
- Le contexte, en faits : « These forces are probably in tension, and should be called out as such. The language in this section is value-neutral. It is simply describing facts. » (S1)
- Les conséquences, toutes : « All consequences should be listed here, not just the "positive" ones. » (S1) L'erreur, *Free Lunch Coupon* : « No consequences are documented, or only consequences that seem to be harmless. » (S24)
- Les vraies alternatives seulement. Fowler veut « all the serious alternatives that were considered ». (S9) L'erreur, *Dummy Alternative* : « A solution is made up and presented as an option, but does not work at all in the given context. » (S24)
- Pas de plaidoyer : « The language of marketing has its place, but ADRs are not that place. » (S24)
- La raison dans l'ADR, la règle ailleurs. AWS : l'ADR « focuses on the reason for the decision rather than how the team implemented it ». (S12) Microsoft : « Avoid making decision records design guides. » (S15) L'erreur : « Blueprint or Policy in Disguise », un texte qui ressemble à « a cookbook or law ». (S24) Python : une fois tranchée, une PEP est « a historical document rather than a living specification ». (S30)
- Numéros : « ADRs will be numbered sequentially and monotonically. Numbers will not be reused. » (S1) Fichiers `NNNN-title-with-dashes.md`. (S6)

## Statut

- « A decision may be "proposed" if the project stakeholders haven't agreed with it yet, or "accepted" once it is agreed. » (S1)
- « The status of your ADR's pull request (PR) reflects the status of the decision until it has been accepted. » (S19)
- Accepté, il ne change plus : « When the team accepts an ADR, it becomes immutable. If new insights require a different decision, the team proposes a new ADR. » (S12) « Don't go back and edit accepted records. » (S15)
- L'ancien reste : « If a decision is reversed, we will keep the old one around, but mark it as superseded. » (S1)

## Où les sources divergent

- **Le seuil.** Spotify : « Almost always! », et chaque équipe fixe ce qui compte. (S20) MADR : « any (important) decision ». (S6) Microsoft et domain-modeling placent le seuil plus haut. (S15, S33) Toutes parlent de décisions importantes ; elles diffèrent sur la ligne.
- **L'immuabilité.** Henderson : « In theory, immutability is ideal. In practice, mutability has worked better for our teams. » (S28) Le GDS permet de préciser un ADR existant. (S19) Le guide garde l'immuabilité : après la fusion, seul le Statut change.
- **Les alternatives.** Absentes du format de Nygard (S1), centrales pour Fowler et MADR (S9, S6), facultatives pour domain-modeling (S33).

## Ce que les sources ne disent pas

- Toutes décrivent des équipes humaines. Aucune n'étudie un dépôt écrit par des agents, dont le lecteur principal est un agent : le guide transpose par analogie. L'adaptation du guide (la raison dans la règle quand l'agent qui l'applique en a besoin) vient de là, pas d'une source.
- Aucune ne donne un bon nombre d'ADR, ni ne dit si la pull request suffit pour la raison d'une petite décision.
