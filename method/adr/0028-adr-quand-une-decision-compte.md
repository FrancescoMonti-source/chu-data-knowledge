# 0028 — Un ADR pour une décision qui compte et qui tranche

Statut : accepté, 2026-10-16 (Francesco, carte « Adopt the industry test for when the repo writes an ADR? », enquête revalorisation-chir-m8). Modifie 0001 (révision 6) et 0016 (cinquième point du contexte).

## Contexte

La règle 7 donnait un ADR à chaque décision sur une règle. En une semaine, le dépôt en a reçu près de trente. Certains gardent un renommage (0017) ou une reformulation (0011) ; six regroupent plusieurs décisions.

Un agent écrit l'ADR pendant que la pull request est ouverte, et son premier lecteur est le mainteneur qui l'approuve. Pour une décision évidente, l'agent remplit quand même chaque section : il trouve une raison, ajoute une alternative que personne n'a proposée, et plaide pour la solution.

La pratique courante écrit un ADR pour une décision importante, qui a tranché entre de vraies options, et l'écrit pour le lecteur futur. La raison d'une petite décision reste avec le changement.

Ici, le lecteur futur est souvent un agent qui part de zéro et lit les fichiers, pas les pull requests. Il applique aussi les règles, et leur raison l'aide aux cas limites. La pull request fusionnée garde déjà qui a décidé, quoi et quand.

## Décision

Le dépôt suit la pratique courante des ADR : un ADR pour une décision qui compte et qui tranche, écrit pour le lecteur futur. La raison d'une autre décision va dans la pull request, et dans la règle elle-même quand l'agent qui l'applique en a besoin. Le test, la manière d'écrire et le Statut : method/adr/README.md.

## Alternatives écartées

- **Un ADR par décision sur une règle :** pour chaque décision évidente, l'agent fabrique une raison, et les vraies raisons se perdent parmi elles.
- **Le test de domain-modeling, plus strict (difficile à défaire, surprenant et issu d'un vrai compromis) :** une décision sur la manière de travailler, comme la retro en fin de session (0008), resterait sans ADR, alors qu'un agent a besoin de sa raison.

## Conséquences

- L'agent juge si une décision compte et tranche ; dans le doute, il demande au mainteneur dans la pull request.
- La raison d'une petite décision, restée dans la pull request, échappe à l'agent suivant. Quand elle sert à appliquer la règle, elle va dans la règle.
- Les ADR existants gardent leur texte, même ceux qui ne passeraient pas le test.
- Un ADR reste proposé tant que le mainteneur n'a pas tranché.

## Sources

Les sources et leurs citations : pratique-courante.md.
