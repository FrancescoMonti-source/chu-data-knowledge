# Où lire l'IPP d'un séjour dans CORA : TB_PATIENT.IPP_PATIENT ou TB_SEJOUR.IPP_PATIENT ?

Personne : Pierre
Issue : #138

## Cadrage
- **But :** retrouver l'IPP des patients d'une extraction (liste individuelle gardée à l'hôpital).
- **Source :** CORA de production (CWPROD, schéma CORA_REC), TB_PATIENT et TB_SEJOUR ; requête exécutée par Pierre.
- **Observation de départ (2026-11-16, Pierre) :** une extraction qui lisait `TB_SEJOUR.IPP_PATIENT` a rendu une colonne IPP vide ; `cora_toolbox` (DIM-code) lit `TB_PATIENT.IPP_PATIENT`. Aucun claim ne dit où lire l'IPP.
- **Population :** séjours sortis de 2023 à 2026 (assez pour voir si le remplissage varie ; périodes à ajuster si CORA les contredit : periode-analyse-cora-2018).
- **Mesure :** par année de sortie, effectifs de séjours selon que l'IPP est renseigné (non vide après TRIM) dans TB_SEJOUR, dans TB_PATIENT, dans les deux (égal ou différent), dans aucun. Aucune valeur d'IPP ne sort.
- **Masquage :** effectifs < 10 masqués dans la requête, aucune ligne de total.
- **Branche :** claude/project-thread-u52yqu, imposée par la session, au lieu de investigation/ipp-patient-vs-sejour.

## Choix

## Conclusions
