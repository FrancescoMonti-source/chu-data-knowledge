# 0029 — Deux mainteneurs à égalité

Statut : accepté, 2026-10-16 (Francesco, dans le fil du projet : « Pierre is on equal foot, oligarchy not monarchy », puis « both of us should be able to merge », avec de l'aide pour voir où ils divergent ; CODEOWNERS sans relecture obligatoire : « un buon compromesso »). Modifie 0000 (ligne CODEOWNERS).

## Contexte

La v0.4 prévoyait des mainteneurs, au pluriel (0000). Le texte du dépôt n'en nommait qu'un, Francesco, et la règle 7 lui réservait les changements de règle. Pierre en a pourtant fusionné lui-même (#26, #29), et Francesco ne s'y oppose pas tant qu'ils ne divergent pas. Sur GitHub, Francesco est administrateur et Pierre a le droit d'écriture, qui suffit pour fusionner.

À deux, un vote à la majorité ne départage personne : il faut l'accord des deux. La pratique courante, celle de la fondation Apache par exemple, en a deux formes : la relecture avant la fusion (review-then-commit), ou la fusion libre, que l'autre peut contester après coup (commit-then-review).

## Décision

Francesco et Pierre sont mainteneurs à égalité (method/GLOSSARY.md). Chacun fusionne seul un changement de règle ; si l'autre s'y oppose, avec une raison, la règle reste ou redevient ce qu'elle était jusqu'à leur accord (AGENTS.md, règle 7). Un claim contesté sans accord reste challenged (method/review.md).

Pour que l'autre voie chaque changement de règle, .github/CODEOWNERS nomme les deux sur les fichiers de règle : GitHub lui demande sa relecture, sans bloquer la fusion.

## Alternatives écartées

- **Un seul mainteneur qui tranche :** c'est ce que disait le texte ; Francesco l'a refusé, et la PR #54, un CODEOWNERS à son seul nom, a été fermée.
- **Relecture obligatoire par l'autre avant la fusion** (le réglage « require review from code owners » sur main) : 0000 la prévoyait dès qu'il y aurait plusieurs mainteneurs. Francesco veut que chacun puisse fusionner ; elle ralentirait chaque changement de règle, alors qu'ils n'ont pas encore divergé. À reprendre au premier désaccord qui arrive trop tard.
- **Un fichier MAINTAINERS.md, comme le modèle de la CNCF :** pour deux noms, la définition du glossaire suffit.

## Conséquences

- L'autre est prévenu, mais rien ne l'oblige à lire avant la fusion : un désaccord peut se découvrir tard, et défaire coûte alors plus cher.
- Une pull request en brouillon ne prévient personne : GitHub demande la relecture quand elle passe en « ready for review ».
- Un désaccord sans issue garde l'état d'avant : la règle d'avant, ou le claim challenged.
- Seul Francesco peut changer les réglages du dépôt sur GitHub.
