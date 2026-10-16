# 0030 — Petits effectifs : masqués dans le dépôt, discutés dans la conversation

Statut : accepté, 2026-10-16 (Francesco, retro du 16 octobre).

## Contexte

privacy.md interdisait tout effectif de 1 à 9 en clair, dans le dépôt comme dans la conversation, et en faisait un incident : arrêter, prévenir le mainteneur, noter l'incident.

Le 15 octobre, la personne a lancé une copie non masquée d'une requête pour son propre usage, puis a cité dans la conversation un effectif sous 10 : des RSS de chirurgie, sur huit mois, pour tout le CHU. L'agent l'a traité comme une ligne de patient et a demandé de corriger le message et de noter un incident. La personne a jugé la réaction disproportionnée : un tel compte ne désigne personne. La question de l'agent avait d'ailleurs provoqué la réponse.

Le dépôt est public : ce qu'on y écrit peut être lu par n'importe qui. La conversation passe chez le fournisseur du modèle, mais elle n'est pas publiée.

Un petit effectif peut pourtant désigner quelqu'un quand la strate est étroite : un GHM rare dans une petite unité, sur un mois, se reconnaît entre collègues.

## Décision

Un effectif de 1 à 9 n'entre jamais dans le dépôt. Dans la conversation, un agrégat sur une strate large peut venir en clair ; l'agent en parle sans l'écrire. L'incident vaut seulement pour une donnée qui désigne une personne, y compris un petit effectif sur une strate qui isole un cas rare. La règle : privacy.md.

## Alternatives écartées

- **Garder l'interdiction partout :** elle traite un compte anonyme comme une ligne de patient, et pousse l'agent à des alertes que la personne finit par ignorer.
- **Lever le masquage pour toute strate :** une strate étroite peut désigner un patient, et l'agent ne verrait plus la différence.

## Conséquences

- La requête masque toujours (queries.md) : la personne seule décide de lancer une copie non masquée.
- L'agent juge si une strate est large ; le contrôle ne le vérifie pas, puisqu'il ne lit pas la conversation.
- Ce qu'on perd : la règle était simple à appliquer ; elle demande maintenant un jugement.
