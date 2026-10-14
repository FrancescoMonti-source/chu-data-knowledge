---
review: unreviewed
id: specialite-et-etat-intervention
kind: empirical
author: Pierre
statement: "Dans OpRoom, une intervention réalisée est à l'état 4 (clôturée), presque jamais à l'état 2 ; elle n'a pas de spécialité propre : celle de sa procédure est celle de sa demande pour 99,9 % des interventions, comme le type d'hospitalisation (AMBU ou HOSPIT) pour 99,2 %. Sur ces interventions, TYPE_SALLE vaut toujours 2, aucune salle n'est virtuelle et aucune n'est exclue du temps de référence."
scope: "OpRoom de production (QBLOCP), interventions terminées ou clôturées commencées de janvier 2023 au 2026-10-09, par l'extraction de requete_oproom.py"
refuted_if: "pour une année, plus de 1 % des interventions réalisées sont à l'état 2, ou la spécialité de la procédure diffère de celle de la demande pour plus de 1 %"
maturity: observed
lifecycle: active
terms: [oproom:intervention]
tables: [oproom:OR_INTERVENTIONS, oproom:OR_PROCEDURES, oproom:OR_WAITINGLIST, oproom:OR_SPECIALISMS, oproom:OR_ROOMS]
supported_by: [20261014-oproom-attributs-resultat]
depends_on: [developper-sur-qbloct]
---
## Pour s'en servir

- **Interventions réalisées :** `I_STATE IN (2, 4)` ; `I_STATE = 4` donne le même résultat à moins de 10 interventions par an près.
- **Spécialité :** prendre celle de la procédure (`OR_PROCEDURES.P_SPECIALISM_KEY`) ; celle de la demande (`OR_WAITINGLIST.W_SPECIALISM_KEY`) donne la même chose. La pédiatrie est une seule spécialité, PED.
- **Type d'hospitalisation :** celui de l'intervention et celui de la demande concordent ; tous deux sont déclaratifs dans OpRoom. Pour l'ambulatoire au sens du PMSI, passer par CORA.
- **Colonnes qui ne filtrent rien :** TYPE_SALLE, R_VIRTUAL et I_DO_NOT_USE_FOR_SURG_TIME ont la même valeur pour toutes les interventions réalisées.

Environ 12 % des interventions ont plusieurs chirurgiens (rôle chirurgien hors interne) : compter les interventions, pas les lignes de ressources. La date de la demande manque pour 3 à 5 % des interventions, alors que la demande elle-même existe.

## Ce qui l'appuie

Interventions par année de début (20261014-oproom-attributs-resultat, niveau ANNEE) : état 2 pour moins de 10 par an, état 4 pour 28 115 en 2023, 32 503 en 2024, 34 628 en 2025 et 26 789 en 2026 ; spécialité de la procédure égale à celle de la demande pour 28 104, 32 497, 34 616 et 26 785 ; type d'hospitalisation égal pour 27 883, 32 265, 34 392 et 26 589 (99,2 à 99,3 %) ; salle virtuelle et exclusion du temps de référence pour moins de 10 par an ; plusieurs chirurgiens pour 3 374, 3 847, 4 033 et 3 155 ; sans chirurgien pour 23, 36, 19 et 19 ; date de demande vide pour 1 358, 1 307, 1 175 et 777. Niveau VALEURS : TYPE_SALLE vaut 2 pour toutes les interventions de chaque année ; HOSP vaut AMBU ou HOSPIT.
