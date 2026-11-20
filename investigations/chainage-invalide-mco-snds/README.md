# Que sont les séjours MCO du SNDS à chaînage invalide, et quand faut-il les exclure ?

Personne : Pierre
Issue : #147

## Cadrage
- But : savoir quand garder ou exclure les séjours dont un code retour du chaînage de T_MCOaaC n'est pas à 0, et l'écrire en claims. Origine : l'étude CHIP de DIM-code (#56), où les comptes sans ce filtre retombent exactement sur ceux de la DGOS.
- Source : PMSI MCO du SNDS, portail de la Cnam, profil 108 (T_MCOaaB, T_MCOaaC, préfixe PROFIL_108.).
- Population : tous les séjours de T_MCOaaB, tous établissements, sans autre filtre (on mesure aussi la part après les filtres GHM 90 et SEJ_TYP B du HDH).
- Période : PMSI 2008 à 2025, comme l'étude CHIP ; COH_NAI_RET et COH_SEX_RET seulement depuis 2013 (fiche HDH).
- Unité : le séjour (ETA_NUM, RSA_NUM).
- Définition opérationnelle : séjour « invalide » = l'un des codes du filtre HDH n'est pas '0', valeur vide comprise, ou pas de ligne dans T_MCOaaC.
- Mesures : part par année ; valeurs et combinaisons des codes ; répartition par type de séjour, âge, forme du NIR_ANO_17, SEJ_TYP ; concentration par établissement ; CHU de Rouen.
- Cadrage confirmé par Pierre le 2026-11-20.

## Choix
- Les FINESS des 20 établissements les plus touchés par année sortent avec leurs comptages masqués : un établissement n'est pas une personne (accord de Pierre, 2026-11-20).

## Conclusions
