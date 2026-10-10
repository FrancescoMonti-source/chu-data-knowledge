# Frictions : debrief et rétro

Tout le monde note ; seul le mainteneur change les règles, et seulement quand un problème se répète.

Une friction, c'est tout accroc pendant une enquête : un contrôle qui échoue, une correction de la personne, une étape qui ralentit, une règle peu claire.

## Debrief

- **Où :** dans la section Frictions du README.md de l'enquête (et dans l'issue, quand le dépôt sera sur GitHub).
- **Quand :** relay, quand il livre une requête ; sediment, à une pause ou à la fermeture ; frame, quand une session reprend et que la note de la précédente manque : une seule question à la personne.
- **Format :** une ligne par friction, qui décrit sans juger. Une correction peut venir d'une erreur de l'agent ou d'une explication peu claire.

  `- 2026-10-12, relay : la personne a ajouté un filtre sur l'année ; version exécutée relue, preuve en modified: yes.`

- À la fermeture, la section existe, même avec « aucune ».

## Après un contrôle qui échoue

L'agent corrige le contenu, jamais le contrôle, et réessaie : changer un contrôle, c'est changer les règles. Il n'y a pas d'arrêt obligé après plusieurs échecs (docs/adr/0001). Si l'agent ne sait pas corriger, il le dit à la personne et note la friction.

## Rétro

Le mainteneur la lance de temps en temps, avec la skill retro. Elle propose un changement seulement pour une friction répétée au moins deux fois, ou liée à la sécurité des données ; elle peut aussi proposer de retirer une règle. Chaque friction examinée reçoit une marque à la fin de sa ligne :

  `- 2026-10-12, relay : … → rétro 2026-12-01 : contrôle ajouté.`

Une erreur évidente dans une skill se corrige tout de suite, sans attendre la rétro. Une décision reçoit un ADR dans docs/adr/.
