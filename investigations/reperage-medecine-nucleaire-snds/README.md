# Avec quels codes CCAM repérer la médecine nucléaire dans le PMSI du SNDS, et le CHU de Rouen en fait-il ?

Personne : Pierre
Issue : #143

## Cadrage
But : qu'une étude SNDS repère la médecine nucléaire (MN) sans faux positif ni oubli, et sache où chercher celle des patients du CHU.
Source : le PMSI MCO du SNDS sur le portail de la Cnam (profil 108), actes des séjours (T_MCOaaA) et des consultations externes (T_MCOaaFMSTC) ; la CCAM descriptive à usage PMSI 2026 ; le bordereau MEDNUC de la SAE 2025.
Population : les actes, pas les patients.
Période : 2024 pour l'observation.
Unité d'analyse : l'acte CCAM, par établissement et par code.
Mesure : nombre d'actes par code ; libellé et chapitre de chaque code.
Comparaison : le CHU de Rouen contre un établissement qui fait de la MN (le Centre Henri Becquerel).

## Choix
- Enquête ouverte après coup (2026-11-17), pour faire entrer ce qu'a appris l'étude DIM-code 2026-11_radiotherapie_becquerel (DIM-code PR #49) sur la MN seulement : Pierre a écarté les faits sur Becquerel et la radiothérapie.
- La requête a été exécutée depuis l'étude DIM-code (chercher_mn(), commit a7deba5) ; 20261116-snds-mn-codes en reprend le calcul et la preuve garde la version exécutée.
- La relecture des codes a été faite par un agent indépendant (2026-11-17), à la demande de Pierre, puis chaque libellé cité a été relu dans la CCAM descriptive 2026.
- Dans l'étude DIM-code, Pierre a gardé ZZQL010 et ZZQL013 en MN diagnostique et n'a pas ajouté EDLL001, EDLL002 ni HPML001 (2026-11-17) : choix propre à l'étude, pas une règle du dépôt ; les claims disent de trancher et de le dire.

## Conclusions
- mn-diagnostique-ccam-ql-faux-positifs (unreviewed)
- mn-therapeutique-liste-sae-pas-nl (unreviewed)
- chu-rouen-sans-medecine-nucleaire (unreviewed)
