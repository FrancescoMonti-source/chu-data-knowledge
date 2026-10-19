# 0023 — L'issue garde le travail à faire, le dépôt garde ce qu'on a observé

Statut : accepté, 2026-10-14 (Francesco, dans le fil du projet, après la relecture de Pierre sur la PR #28). Modifié par 0034 : c'est frame qui cherche dans le dépôt. Modifié par 0035 : sediment fait les deux tris à l'étape 5, et une enquête qui n'a rien à faire entrer se ferme sans pull request.

## Contexte

investigations/README.md disait ce qui va dans l'issue d'une enquête : le plan, et un commentaire par nouvelle preuve, avec son id. Il ne disait pas ce qui va ailleurs.

L'issue #25 (les séjours CORA sans RSS) contient trois sortes de choses :

- un plan, des hypothèses et des tests à faire ;
- le résultat d'une requête exécutée à l'hôpital, avec la requête ;
- une affirmation de dim-code, non éprouvée.

La requête et sa preuve ne sont plus dans le dépôt : aucun claim ne les citait, et l'enquête les a retirées de sa branche. Le résultat est maintenant seulement dans l'issue.

Une issue n'est pas un fichier du dépôt. Trois conséquences :

- check.py ne lit pas l'issue. Le contrôle des effectifs de 1 à 9 (method/privacy.md) ne s'applique pas au résultat.
- research cherche dans le dépôt. L'agent suivant ne trouve pas le résultat, et peut demander le même relay une deuxième fois.
- L'issue finit fermée.

## Décision

investigations/README.md reçoit la section « L'issue ou le dépôt ». Avant d'écrire une chose, l'agent la classe :

- une requête, une preuve ou un claim : dans le dépôt. L'issue donne seulement l'id de la preuve.
- un plan, une hypothèse ou un test à faire : dans l'issue.

Une preuve qu'aucun claim ne cite :

- le résultat d'une requête reste dans le dépôt tant que l'issue ouverte d'une enquête le cite. Si l'enquête se ferme sans claim qui le cite, sediment le supprime avec sa requête, avant le dernier merge.
- une lecture est supprimée avant le merge.

Un claim jugé inutile avant le merge part avec ce qui ne servait qu'à lui. Après le merge, il passe en withdrawn.

Une affirmation non éprouvée est une hypothèse, même quand un document la dit.

sediment fait ce tri : les lectures à l'étape 5 (faire entrer), les exécutions à l'étape 6 (fermer).

Dans AGENTS.md, « Où lire » envoie à investigations/README.md avant d'écrire dans une issue.

research trouvait une preuve seulement par les claims qui la citent. method/layout.md (« Retrouver ce qu'on sait ») et research cherchent aussi les requêtes qui lisent les tables de la question, puis leurs preuves.

## Raisons

- Tout ce qui vient de l'hôpital passe par le contrôle et reste trouvable : privacy-by-design, single-source-of-truth.
- Le contrôle accepte déjà une preuve qu'aucun claim ne cite : checks/ ne change pas.
- Compromis avec Pierre, à la relecture : les agents créent des preuves sans raison, et une preuve sans usage encombre le dépôt. Mais un résultat de requête a coûté un relay : il reste tant qu'une question ouverte prévoit de s'en servir. Une lecture se refait vite.

## Conséquences

- Les issues friction suivent déjà cette règle : aucun extrait de résultat (retro, étape 4).
- Si 0022 est accepté, une phrase de claims.md change. Elle dit qu'une mesure sans usage « reste dans l'issue de la question, avec sa requête et son résultat ». Avec 0023, la mesure n'est pas un claim, mais sa requête et sa preuve restent dans le dépôt.
- Pour #25 : la requête 20261013-sejours-sans-rss et sa preuve sont revenues sur investigation/fondations-cora (f7d414c), et l'issue les cite.
- La règle reste une règle de confiance : le contrôle ne lit pas les issues.
- Plus tard, peut-être : check.py signale en ORANGE une preuve qu'aucun claim ne cite, pour garder le tri visible.
