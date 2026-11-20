# Combien de séances codées DP Z51.2 avec H35.3 en 2026, et quel écart de valorisation si elles étaient recodées en DP H35.3 + BGLB001 + BZQK001 ?

Personne : Francesco
Issue : #155

## Cadrage
- But : chiffrer le risque sur des prises en charge d'ophtalmologie (injections intravitréennes) codées en séances de « chimiothérapie » non tumorale, dont la justification comme séance est fragile.
- Source : CORA, RSS de TB_SYNTH_RSS ; tarifs de PMSI_LIB_GHS_TARIF (tarif-ghs-par-ghm-et-code-ghs).
- Période : RSS finis de janvier à septembre 2026 (Francesco : seule 2026 compte ; les autres années seulement par curiosité). Les RSS de septembre peuvent être encore en partie non codés (rss-mois-recents-non-codes).
- Population : RSS à DP Z51.2 avec H35.3 ; toutes les UF, comptées par UF (Francesco pense à l'UF 5170 : on vérifie qu'aucune autre UF ne code de même).
- Place de H35.3 : avec un DP Z51.x, la maladie traitée va en DR (guide MCO 2026, chapitre V, catégorie Z51, preuve 20261120-guide-mco-z51-chimiotherapie) ; on compte H35.3 en DR et en DAS.
- Unité : la séance. Un RSS de séances peut en porter plusieurs (NB_SEANCES) ; recodée, chaque date deviendrait un séjour d'hôpital de jour. On compare aux jours d'acte BGLB001.
- Groupage actuel : 28Z17Z (Chimiothérapie pour affection non tumorale, en séances), GHS 9616 (annexe 1 de l'arrêté prestations 2026). À vérifier dans les données.
- Groupage recodé : 02C, en ambulatoire (Francesco l'a testé au groupeur) ; le GHM et le GHS exacts sont à confirmer.
- Mesure : valorisation GHS de base, secteur public, par GHM + CODE_GHS au tarif en vigueur à la date de fin du RSS. Le médicament anti-VEGF n'est pas facturé en sus (Francesco) : il n'entre pas dans l'écart.
- Comparaison : actuel (séances 28Z17Z) contre recodé (un séjour 02C..J par séance) ; et, en borne basse, une facturation en consultation externe (ACE), si un contrôle refusait l'hôpital de jour (instruction « gradation » de 2020).

## Choix
- MONTANT_GHS_EUR masqué dans la preuve 20261120-z512-h353-seances-2026-resultat quand N_RSS ou NB_SEANCES l'est : divisé par le tarif du GHS (411,08 € pour 9616), il redonnait l'effectif masqué.
- Le recodage se compte sur les séances : dans l'UF 5170, un RSS porte une séance (MONTANT_GHS = séances × 411,08 €), et presque toutes ont un jour BGLB001.
- Recodage en hôpital de jour : GHS 398 (Francesco, test au groupeur). La borne ACE se calcule au tarif CCAM de BGLB001 et BZQK001 plus le forfait SE2, la liste 2 de l'annexe 11 étant lue comme celle du SE2 (correspondance non lue dans l'arrêté « forfaits »).

## Conclusions
