# Comment les RHS d'hospitalisation de jour SMR de 2025 sont-ils enregistrés dans CORA, avec leurs actes, leur score, leur GME et leur tarif ?

Personne : Pierre
Issue : #96

## Cadrage
- **But :** permettre l'analyse suivie dans DIM-code : qu'aurait changé en 2025, en groupe de réadaptation et en valorisation, un RHS par semaine et par personne (moyenne des pondérations) à la place d'un RHS par venue, en HTP (hospitalisation à temps partiel) SMR. Cette enquête ne répond pas à cette question, elle établit ce que CORA permet d'y répondre.
- **Source :** CORA (TB_MVT_SSR_SEM, TB_ACTE_CSARR, CSARR_PONDERATION, PMSI_LIB_GMT_TARIF, tables de facturation SMR). Pierre exécute les requêtes à l'hôpital.
- **Population :** tous les RHS de HTP SMR de 2025, détail par GN. Pierre confirme qu'en 2025 plusieurs RHS étaient transmis pour une même personne et une même semaine, un par venue.
- **Mesure :** pour un RHS, ses actes et leurs poids, ses jours de présence, son score par jour, son GME et son tarif, tels que CORA les enregistre.
- **Définitions du manuel (lectures, non des claims) :** score par jour = somme des pondérations des actes de la semaine / jours de présence (manuel GME 2025, § 3.3.2.2) ; groupe de réadaptation par seuils du GN (0147 : 60 et 150) ; valorisation = journées de présence × tarif du GMT (notice 162-5-2025).
- **Montants :** Pierre n'a pas les coefficients géographique et de transition ; il pense qu'on peut retrouver les montants dans CORA (étape 5 du plan).
- **Lien avec DIM-code :** les faits sur les données découverts ici passent par sediment ; l'analyse elle-même (simulation, écarts) vit dans DIM-code.

## Choix
- **Identifier la HTP par TYPE_HOSPIT_SSR = 2 :** TYPE_ACTIVITE est vide ; le contrôle est le nombre de patients, 158, attendu par Pierre.
- **Score d'un RHS par SCORE_RR :** il respecte les seuils de l'ATIH pour les GN 0127 et 0406 ; on ne recalcule pas depuis les actes (TB_ACTE_CSARR.POIDS), faute de besoin.
- **RHS hebdomadaire simulé = une personne-semaine :** moyenne des SCORE_RR pondérée par les jours de présence, avec les seuils du GN ; une semaine à GN différents n'est pas simulée (groupe inchangé), un vrai regroupement demandant la fonction de groupage.
- **Valorisation par les tarifs de l'ATIH :** MNT_GMT de CORA les égale à moins de 0,1 %, et aucun coefficient n'est nécessaire pour retrouver les montants.
- **Plan revu :** les étapes 4 et 5 se réduisent à ces contrôles ; l'analyse elle-même est dans DIM-code (étude `2026-10_htp_smr_rhs_hebdo`), qui n'est pas une preuve de CDK.

## Conclusions
Claims (tous unreviewed, auteur Pierre) :
- `htp-smr-type-hospit-ssr` : repérer la HTP par TYPE_HOSPIT_SSR = 2.
- `rhs-htp-une-venue` : un RHS de HTP est une venue ; regrouper par personne et par semaine.
- `score-rr-htp-score-par-jour` : SCORE_RR est le score par jour du groupage.
- `mnt-gmt-htp-tarif-journee` : MNT_GMT est le tarif de la journée ; MNT_GMT_HEBDO et la facturation SMR ne servent pas.
