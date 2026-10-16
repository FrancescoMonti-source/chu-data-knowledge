# 0029 — Suivre la pratique courante

Statut : proposé, 2026-10-16 (Claude, d'après ce que Francesco a demandé dans le fil de l'enquête revalorisation-chir-m8).

## Contexte

Le dépôt a été reconstruit en une semaine. Ses règles ont été écrites par des agents, à partir des besoins des premières enquêtes, et relues par le mainteneur, seul à décider.

Un agent propose volontiers une solution neuve et bien argumentée. Le mainteneur ne peut pas vérifier, à chaque règle, qu'elle ne réinvente pas un usage déjà connu. Les ADR en sont un exemple : une pratique courante existait, la règle du dépôt s'en écartait sans raison écrite, et poussait les agents à inventer des raisons (0028).

Une pratique courante a été éprouvée par beaucoup d'équipes ; ses défauts connus sont décrits. Mais elle ne prévoit pas toujours ce qui est propre au dépôt : des agents qui écrivent et lisent ses règles, des données de patients qui restent à l'hôpital.

## Décision

Le dépôt suit la pratique courante quand elle existe. S'en écarter est une décision qui tranche : elle nomme la pratique qu'elle quitte et dit pourquoi. Le principe s'appelle industry-practice, dans AGENTS.md.

## Alternatives écartées

- **Décider chaque règle à partir des seuls besoins du dépôt :** on refait des erreurs que d'autres ont déjà corrigées, et le mainteneur relit chaque règle comme une invention.

## Conséquences

- Avant de proposer une règle, l'agent cherche s'il existe une pratique courante ; l'ADR la cite dans ses sources.
- Une adaptation au dépôt reste possible, avec sa raison, comme celles de method/adr/README.md.
- Chercher prend du temps avant chaque règle nouvelle.
