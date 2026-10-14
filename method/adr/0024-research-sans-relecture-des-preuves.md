# 0024 — research ne relit pas les preuves

Statut : proposé, 2026-10-14 (Pierre). À accepter par le mainteneur.

## Contexte

L'étape 1 de research demandait de parcourir, pour chaque claim trouvé, « leurs prémisses et leurs preuves », puis, depuis 0023, « les requêtes qui lisent ces tables, et leurs preuves ». Un agent lisait donc les preuves de chaque claim à chaque recherche : des tableaux de résultats et des citations, pour des claims qu'il ne faisait qu'utiliser. Ce parcours coûte du temps et du contexte, sans rien apporter : le claim dit déjà ce qu'il établit, et son état de relecture dit s'il a été vérifié.

## Décision

- research lit les claims trouvés et leurs prémisses (en-tête et corps), pas leurs preuves.
- research repère les requêtes déjà exécutées sur les tables de la question, par leur ligne purpose, sans ouvrir leurs résultats. relay les ouvre à l'étape 2, avant d'écrire une requête : c'est là qu'un résultat déjà rapporté évite un aller-retour à l'hôpital (0023).
- review.md, « Quand relire », dit quand on ouvre une preuve : à la relecture au réemploi, quand un claim devient la prémisse d'un nouveau claim (étape 2 de sediment) ; et quand un résultat contredit le claim.

## Raisons

- Une preuve sert à vérifier un claim, pas à l'utiliser. La vérification a lieu à la relecture, au moment où quelqu'un construit dessus (0000, « relecture au réemploi »).
- Les prémisses restent lues : courtes, elles donnent le contexte dont le claim dépend.

## Conséquences

- Une recherche lit moins de fichiers.
- Un agent qui utilise un claim unreviewed s'appuie sur un claim non vérifié : il le dit déjà en citant son état de relecture (claims.md, « Citer un claim »).
