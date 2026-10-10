# 0008 — La retro en fin de session

Statut : accepté, 2026-10-10 (Francesco). Modifie 0006 (retro), 0001 (révision 5) et deux lignes de 0000.

## Contexte

La v0.4 sépare le debrief, où chacun note ses frictions pendant l'enquête, et la rétro, où le mainteneur les juge de temps en temps. Noter pendant la session ne marche pas : quand relay livre une requête, la session vient de commencer ou elle est à mi-chemin. Et une ligne notée par l'agent seul dit ce qui s'est passé, rarement pourquoi.

## Décision

- Une seule étape, la retro, que la personne lance quand elle s'arrête. Elle relève les accrocs de la session, en cherche la cause avec la personne, puis ouvre une issue GitHub avec l'étiquette friction, ou commente celle qui existe déjà.
- Le mainteneur corrige une friction quand elle revient au moins deux fois, ou tout de suite si elle touche la sécurité des données.
- Disparaissent : docs/agents/frictions.md, les sections Frictions des enquêtes, et les étapes de debrief de frame, relay et sediment.

## Raisons

- La personne sait ce qui l'a gênée. En parler trouve la vraie cause : une erreur de l'agent, ou une règle peu claire.
- La session est encore fraîche : rien à noter en cours de route.
- Une friction qui revient s'ajoute à la même issue : les répétitions se comptent d'elles-mêmes.

## Coût

Quelques minutes à la fin de chaque session. Une session fermée sans retro perd ses accrocs. Les issues sont hors des fichiers : le contrôle des données de personne ne les lit pas, la règle le remplace.

## Alternative

Garder le debrief, avec une skill qui relit la transcription de la session : deux étapes au lieu d'une, et la transcription reste privée, sur l'ordinateur de chacun.
