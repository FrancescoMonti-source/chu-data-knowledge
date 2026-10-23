# Qui passe par l'USIP (UF 6281), d'où vient-il et où va-t-il, et la DMS et la valorisation GHS des séjours concernés ont-elles changé depuis son ouverture, en particulier pour l'endartériectomie carotidienne et la chirurgie digestive ?

Personne : Francesco
Issue : #103

## Cadrage
- **But :** répondre, pour le DIM, à une question de la direction : typologie et flux des patients de l'USIP ; DMS et valorisation par GHS avant et après l'ouverture ; effet du passage à l'USIP sur la DMS des endartériectomies carotidiennes, qui n'y passaient pas avant selon la direction ; évolution de la DMS des patients de chirurgie digestive qui y passent.
- **Source :** CORA de production (CWPROD, schéma CORA_REC), requêtes exécutées par Francesco.
- **Passage à l'USIP :** un RUM dans l'unité de l'USIP (Francesco). Le lien entre le mouvement dans l'UF 6281 et le RUM se mesure à l'étape 1 avant de s'en servir.
- **Ouverture :** date lue dans CORA (premier mois d'activité régulière de l'UF 6281), à confirmer auprès de la direction. Hypothèse de Francesco : début 2026 ; l'UF 6281 manque du fichier structure de 2025.
- **Périodes :** trois ans avant l'ouverture, et tout ce qui suit, par date de sortie ; les deux à trois derniers mois sont écartés, parce que leurs RSS ne sont pas encore codés (rss-mois-recents-non-codes).
- **DMS :** en nuitées et en journées (duree-sejour-journees-ou-nuitees) ; en heures aussi, puisque CORA garde l'heure d'entrée et de sortie (date-et-heure-dans-deux-colonnes), en disant la part des sorties à minuit, plus forte en 2025 et 2026.
- **Valorisation :** MONTANT_GHS (montant-ghs-rss), et le tarif à une année fixe (tarif-ghs-jointure-couverture), pour qu'un changement de tarif ne passe pas pour un changement de casemix ; plus les journées de suppléments de soins intensifs et de surveillance continue.
- **Endartériectomie carotidienne :** les actes EBFA003, EBFA009 et EBFA010 (Francesco).
- **Chirurgie digestive :** les UF rattachées à l'UM CGCD dans le référentiel ref_uf2um.txt du dépôt redsan (2605, 2615, 2642, 2663, 2668, 6300, 6310, 6311, 6320, 6330, 6340, 8840), avec un GHM chirurgical ; pour une DMS, les UF d'hospitalisation complète 6310, 6320 et 6330. Le fichier structure de 2025 range 6300, 6310, 6311, 6320, 6330 et 8840 dans le service de chirurgie digestive.
- **Ajustement :** pas sur le niveau de sévérité du GHM, qui dépend lui-même de la durée (seuil-duree-niveaux-severite).
- **Masquage :** effectifs < 10 masqués dans les requêtes ; codes et libellés d'UF et d'UM en clair, ce ne sont pas des personnes.
- **Branche :** claude/project-thread-hsi2z1, imposée par la session, au lieu de investigation/usip-parcours.

## Choix
- **Ouverture : octobre 2025, et non début 2026.** L'UF 6281 « USIP CHIRURIGICALE » est rattachée à l'UM 6281 depuis le 2025-10-01, avec l'autorisation 24C et 12 lits (20261023-usip-uf-structure) ; ses premiers mouvements datent d'octobre 2025, aucun avant (20261023-usip-mvt-rum-par-mois). Date à confirmer auprès de la direction.
- **Avant l'USIP, l'UF 6284.** L'UF 6284 « REA CHIR U72 SI » (4 lits, autorisation 24C depuis mars 2025, 02B ou 02C en 2024 et début 2025, 03A avant) s'arrête en octobre 2025, quand 6281 commence (20261023-usip-uf-structure, 20261023-usip-mvt-rum-par-mois) : la période « avant » compte ses passages comme ceux d'une unité de même rôle.
- **Passage = RUM de l'UM 6281.** Les mouvements de l'UF 6281 ont un RUM, sauf moins de 10 certains mois et les deux derniers mois, pas encore groupés ; ces RUM portent l'UM 6281 et l'UF d'hébergement 6281 (20261023-usip-mvt-rum-par-mois).
- **Supplément USIP :** TB_SYNTH_RSS a une colonne MNT_JOUR_USIP, en plus de NB_JOUR_SOINS_INT et NB_JOUR_SURV_CONT (20261023-usip-catalogue) ; la valorisation la lit.
- **Actes d'endartériectomie : les neuf actes de thromboendartériectomie carotidienne utilisés** (EBFA002, 003, 006, 008, 009, 010, 012, 015, 016). Les trois actes du cadrage (EBFA003, 009, 010) ont moins de 10 actes par an chacun, EBFA010 aucun depuis 2022, alors que EBFA016 en a 47 à 59 par an (20261023-ccam-endarteriectomie-carotide) ; Francesco a choisi la liste complète (carte du 2026-10-23).
- **Périodes d'octobre à août :** avant = 2022-10 à 2023-08, 2023-10 à 2024-08, 2024-10 à 2025-08 ; après = 2025-10 à 2026-08 ; mêmes mois de part et d'autre, pour écarter la saisonnalité ; septembre et octobre 2026 ne sont pas encore groupés.
- **La DMS est celle du séjour entier, pas du passage dans l'unité** (Francesco, 2026-10-23) : avant l'ouverture, l'USIP n'existait pas, donc seule la durée de tout le RSS se compare ; la durée dans l'unité reste une description (20261023-usip-typologie-flux). Un séjour de SMR qui suit n'est pas compté.
- **Comparaison générale (étape 3) :** les RSS passés par l'UF 6284 avant, contre ceux passés par l'USIP après, restent une catégorie de PASSAGE et une description, pas la réponse : les lits passent de 4 à 12, donc l'USIP reçoit sans doute des patients moins lourds. La réponse vient de groupes définis sans l'unité : endartériectomies, chirurgie digestive, et racines de GHM les plus fréquentes à l'USIP, choisies d'après 20261023-usip-typologie-flux. DMS en hospitalisation complète seulement (au moins une nuit).

## Conclusions
