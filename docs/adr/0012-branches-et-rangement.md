# 0012 — Branches d'enquête, place des claims atomiques, cadrage

Statut : accepté, 2026-10-11 (Francesco, choix « All five » après une troisième relecture de docs/agents et des skills).

## Contexte

Une troisième relecture a cherché tout ce qui pouvait être mieux, en laissant de côté ce que les deux précédentes avaient corrigé (docs/adr/0009, 0011). Elle a suivi une enquête sur plusieurs semaines, avec d'autres enquêtes qui entrent dans main pendant ce temps. Une branche d'enquête reprise ne voyait pas les claims entrés dans main depuis son ouverture : une prémisse qui les cite donnait ROUGE « n'existe pas » (essayé sur une copie). layout.md rangeait un claim neuf dans investigations/ dès qu'il ne servait qu'à une enquête, contre « Position », le glossaire et l'architecture v0.4.

## Décision

- **Reprendre** une enquête fait entrer la branche principale à jour dans sa branche (`git merge origin/main`), avant tout travail.
- **Rangement :** seule la réponse à la question d'une enquête va dans investigations/<enquête>/claims/. Les claims atomiques vont dans systems/ ou domains/, à côté de leur preuve, comme dans la v0.4.
- **Cadrage :** il s'écrit seulement dans le README de l'enquête. L'issue garde la question et le plan, et renvoie au README.
- **Fermer** une enquête supprime sa branche, après le dernier merge. La liste des branches `enquete/*` est donc celle des enquêtes ouvertes ou suspendues.
- **CI :** elle se lance aussi à chaque push sur une branche d'enquête.

## Conséquences

- Reprendre peut demander de résoudre un conflit, par exemple quand deux enquêtes ont ajouté un terme au même GLOSSARY.md.
- Sur GitHub, l'option qui supprime la branche après chaque merge reste désactivée : un résultat partiel entre pendant que l'enquête continue.
- Retrouver lance `git fetch --prune`, pour ne pas lister les branches déjà supprimées.
