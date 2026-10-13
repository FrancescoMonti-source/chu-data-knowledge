# 0023 — L'issue porte le travail en cours, le dépôt ce qu'on a observé

Statut : proposé, 2026-10-13 (Francesco, après la discussion de la PR de 0022). À accepter par le mainteneur.

## Contexte

investigations/README.md mettait deux choses dans l'issue d'une enquête : le plan, et un commentaire par nouvelle preuve qui donne son id. Rien ne disait ce qui n'y va pas.

L'issue #25 (les séjours CORA sans RSS) mêle trois sortes de choses : le plan et des hypothèses ; le tableau d'un résultat rapporté de l'hôpital, avec sa requête ; une affirmation reprise de dim-code, non éprouvée. La requête et la preuve de ce résultat ont été retirées de la branche de l'enquête, faute de claim pour les citer. Le résultat ne vit plus que dans l'issue.

Une issue est hors des fichiers du dépôt. check.py ne la lit pas : le contrôle des effectifs de 1 à 9 (method/privacy.md) n'y passe pas. research cherche dans le dépôt : l'agent suivant ne trouve pas le résultat et risque de redemander le même relay. Et l'issue finit fermée.

## Décision

investigations/README.md reçoit la section « L'issue ou le dépôt », avec une seule question : d'où vient ce qu'on écrit ?

- De l'hôpital ou d'un document : dans le dépôt (requête, preuve, claim s'il y en a un). L'issue cite l'id de la preuve, sans recopier le résultat. Une preuve qu'aucun claim ne cite encore reste dans le dépôt.
- De ce qu'on prévoit ou suppose : dans l'issue (plan, hypothèses, tests à faire, affirmation pas encore éprouvée).

AGENTS.md, « Où lire », renvoie à cette section avant d'écrire dans une issue.

## Raisons

- Tout ce qui vient de l'hôpital passe par le contrôle et reste trouvable : privacy-by-design, single-source-of-truth.
- Le contrôle permet déjà une preuve qu'aucun claim ne cite : rien à changer dans checks/.

## Conséquences

- Les issues friction suivent déjà cette ligne : aucun extrait de résultat (retro, étape 4).
- Si 0022 est accepté, sa phrase « elle reste dans l'issue de la question, avec sa requête et son résultat » est à remplacer : la mesure n'est pas un claim, mais sa preuve reste dans le dépôt.
- Pour #25 : remettre la requête 20261013-sejours-sans-rss et sa preuve sur la branche investigation/fondations-cora, et remplacer le tableau de l'issue par l'id de la preuve.
- La règle reste une règle de confiance : le contrôle ne lit pas les issues.
