---
review: unreviewed
id: salle-gillies-hors-bloc
kind: empirical
author: Pierre
statement: "Dans OpRoom, exclure la salle GILLIES des volumes de bloc et du TVO : elle est hors bloc, mais porte depuis 2024 une part notable de l'ORL et de la chirurgie maxillo-faciale, et depuis 2025 toute la dermatologie."
scope: "OpRoom de production (QBLOCP), interventions terminées ou clôturées commencées de janvier 2023 au 2026-10-09, par l'extraction de requete_oproom.py"
refuted_if: "la salle GILLIES porte plus de 10 interventions par an d'autres spécialités que l'ORL, la CMF et la dermatologie"
maturity: observed
lifecycle: active
terms: [oproom:intervention, oproom:bloc, oproom:tvo]
tables: [oproom:OR_INTERVENTIONS, oproom:OR_ROOMS, oproom:OR_PROCEDURES, oproom:OR_SPECIALISMS]
supported_by: [20261014-oproom-specialites-salles-resultat, 20261014-kb-gillies]
depends_on: [developper-sur-qbloct]
---
## Pour s'en servir

Pour compter l'activité des blocs ou calculer un TVO, exclure les interventions de la salle GILLIES (`R_CODE` ou `R_NAME` contenant GILLIES), et le dire. Sans cette exclusion, l'ORL et la CMF sont gonflés d'un quart à un tiers depuis 2024, et la dermatologie n'a, depuis 2025, aucune intervention dans un bloc.

Le périmètre de salles retenu par le tableau de bord des blocs est dans `analysis/2026-10_temps_bloc/config_temps_bloc.FEDERATIONS` de DIM-code.

## Ce qui l'appuie

Interventions par année, spécialité et salle (20261014-oproom-specialites-salles-resultat) : en salle GILLIES, moins de 10 par spécialité en 2023 ; 406 sur 1 610 en ORL et 205 sur 781 en CMF en 2024 ; 509 sur 1 676 en ORL, 352 sur 1 002 en CMF et 90 sur 90 en dermatologie en 2025 ; 396 sur 1 317 en ORL, 336 sur 906 en CMF et 105 sur 105 en dermatologie jusqu'au 2026-10-09 ; moins de 10 pour chaque autre spécialité.

Que la salle soit hors bloc vient de Pierre, qui l'a établi en reproduisant le tableau de bord officiel des blocs (20261014-kb-gillies).
