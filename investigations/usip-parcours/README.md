# Qui passe par l'USIP (UF 6281), d'où vient-il et où va-t-il, et la DMS et la valorisation GHS des séjours concernés ont-elles changé depuis son ouverture, en particulier pour l'endartériectomie carotidienne et la chirurgie digestive ?

Personne : Francesco
Issue : #103

## Cadrage
- **But :** répondre à une demande d'appui du DIM : typologie et flux des patients de l'USIP ; DMS et valorisation par GHS avant et après l'ouverture ; effet du passage à l'USIP sur la DMS des endartériectomies carotidiennes, qui n'y passaient pas avant ; évolution de la DMS des patients de chirurgie digestive qui y passent.
- **Source :** CORA de production (CWPROD, schéma CORA_REC), requêtes exécutées par Francesco.
- **Passage à l'USIP :** un RUM dans l'unité de l'USIP (Francesco). Le lien entre le mouvement dans l'UF 6281 et le RUM se mesure à l'étape 1 avant de s'en servir.
- **Ouverture :** date lue dans CORA (premier mois d'activité régulière de l'UF 6281), à confirmer par le DIM. Hypothèse de Francesco : début 2026 ; l'UF 6281 manque du fichier structure de 2025.
- **Périodes :** trois ans avant l'ouverture, et tout ce qui suit, par date de sortie ; les deux à trois derniers mois sont écartés, parce que leurs RSS ne sont pas encore codés (rss-mois-recents-non-codes).
- **DMS :** en nuitées et en journées (duree-sejour-journees-ou-nuitees) ; en heures aussi, puisque CORA garde l'heure d'entrée et de sortie (date-et-heure-dans-deux-colonnes), en disant la part des sorties à minuit, plus forte en 2025 et 2026.
- **Valorisation :** MONTANT_GHS (montant-ghs-rss), et le tarif à une année fixe (tarif-ghs-jointure-couverture), pour qu'un changement de tarif ne passe pas pour un changement de casemix ; plus les journées de suppléments de soins intensifs et de surveillance continue.
- **Endartériectomie carotidienne :** les actes EBFA003, EBFA009 et EBFA010 (Francesco).
- **Chirurgie digestive :** les UF rattachées à l'UM CGCD dans le référentiel ref_uf2um.txt du dépôt redsan (2605, 2615, 2642, 2663, 2668, 6300, 6310, 6311, 6320, 6330, 6340, 8840), avec un GHM chirurgical ; pour une DMS, les UF d'hospitalisation complète 6310, 6320 et 6330. Le fichier structure de 2025 range 6300, 6310, 6311, 6320, 6330 et 8840 dans le service de chirurgie digestive.
- **Ajustement :** pas sur le niveau de sévérité du GHM, qui dépend lui-même de la durée (seuil-duree-niveaux-severite).
- **Masquage :** effectifs < 10 masqués dans les requêtes ; codes et libellés d'UF et d'UM en clair, ce ne sont pas des personnes.
- **Branche :** claude/project-thread-hsi2z1, imposée par la session, au lieu de investigation/usip-parcours.

## Choix

## Conclusions
