# 0007 — Repartir de zéro

Statut : accepté, 2026-10-10 (Francesco). Les branches codex/* ont été supprimées le 2026-10-11 (Francesco) : elles ne servaient plus de référence.

## Contexte

La première version, construite avec Codex, était difficile à comprendre : des fiches JSON, des relectures liées à des commits git, environ 14 000 mots de documentation. Une analyse du 10 octobre 2026 a trouvé des faiblesses de fond (relectures fragiles, lenteur, contrôle de confidentialité sur les libellés, relay sans contrôle de la requête).

## Décision

Reconstruire depuis la v0.4, ses six révisions (0001) et les choix du 10 octobre, sur une branche à part. Les branches codex/* restent intactes, pour référence.

Gardé de la première version : les trois sortes de claims, les termes préfixés par leur contexte avec un contrôle d'existence, le réexamen des claims qui dépendent d'un claim contesté.

Pas reconstruit : les fiches correction et resolution (une contestation passe par lifecycle et challenges, comme dans la v0.4), la fiche investigation (le README de l'enquête la remplace), les index.

## Conséquences

Un dépôt plus petit : environ 4 000 mots de conventions et un seul script de contrôle. Aucun contenu à migrer : la première version n'avait pas encore de claim réel.
