# 0003 — Relecture liée à une empreinte du contenu

Statut : accepté, 2026-10-10 (Francesco, option « 1b » de l'analyse).

## Contexte

La première version liait chaque relecture à un commit SHA, l'identifiant d'une version dans git, et cherchait l'auteur dans l'historique. Ça cassait avec un squash merge (la PR devient un commit nouveau), avec un clone superficiel (sans historique, le cas par défaut de GitHub Actions), et avec une réécriture de l'historique après un incident. C'était aussi lent : des milliers d'appels à git.

## Décision

Une relecture recopie une empreinte : les 12 premiers caractères du SHA-256 de l'en-tête du claim (sans review ni lifecycle), de son corps, du texte de ses preuves avec leur requête ou leur source, et de l'empreinte de ses prémisses. Les fins de ligne sont normalisées. `python checks/check.py --fingerprint <id>` l'affiche. L'auteur est déclaré dans le champ author.

lifecycle reste hors de l'empreinte : une contestation ne doit pas bloquer les claims des autres, seulement leur signaler un réexamen (0004).

La v0.4 donnait aussi à chaque exécution un champ request_commit. Il est remplacé par une règle : une requête exécutée ne change plus, une nouvelle version prend un nouvel id (docs/agents/requests.md).

## Conséquences

- Aucun appel à git : le contrôle marche avec un squash, un clone superficiel, une réécriture, et reste rapide.
- Tout changement dans la chaîne périme la relecture (ORANGE), même la correction d'une faute.
- L'auteur et le relecteur sont déclarés, pas prouvés : règle de confiance.
