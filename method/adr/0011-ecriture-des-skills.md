# 0011 — L'écriture des skills, et la branche main

Statut : accepté, 2026-10-11 (Francesco, après la relecture des skills selon writing-for-agents). Modifié par 0031 : suppression d'agents/openai.yaml sur retro et relecture dans sediment limitée aux prémisses d'une autre personne ou d'une autre enquête.

## Contexte

Une deuxième relecture a jugé l'écriture des cinq skills, pas leurs règles : quand une skill se lance, si chaque critère de fin dit ce qui prouve que l'étape est faite, si un même sens est écrit à plusieurs endroits. Six messages réalistes ont été donnés à des agents neufs : un résultat collé lance relay, une demande de document lance frame, comme prévu. Les défauts sont dans la formulation de quelques lignes. Le même jour, la branche claude/v2 a été renommée main sur GitHub.

## Décision

- **relay :** la requête arrive avec une ligne par règle de requests.md qui s'applique, qui dit comment elle la respecte (requests.md, « Aller »). La vérification « à la main » devient visible ; c'est la seule barrière de la suppression secondaire.
- **frame :** un point du cadrage peut être « sans objet » (une définition n'a ni mesure ni comparaison). L'étape 1 n'est finie qu'après lecture de la liste des enquêtes ouvertes.
- **Enregistrer** est défini une fois (investigations/README.md, « La branche ») : contrôle sans ROUGE, commit sur la branche de l'enquête, push, chaque nouvelle preuve citée dans l'issue. research, relay et sediment disent « Enregistrer » au lieu de le réécrire.
- **sediment, étape 2 :** un cas par sorte de prémisse. L'exception provisional porte sur le claim qui s'appuie sur la prémisse, comme dans le contrôle.
- **retro :** agents/openai.yaml empêche Codex de la lancer seul. La section « Corriger » passe dans docs/agents/maintenance.md : pendant la retro, l'agent n'a plus sous les yeux la façon de corriger.
- La branche principale s'appelle main.

## Conséquences

- La personne lit quelques lignes de plus avec chaque requête.
- Un fichier de plus pour le mainteneur : docs/agents/maintenance.md.
- La CI, qui écoutait déjà main, se lance à chaque push sur la branche principale.
