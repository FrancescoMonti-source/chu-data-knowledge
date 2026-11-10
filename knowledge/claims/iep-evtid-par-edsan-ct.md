---
review: unreviewed
id: iep-evtid-par-edsan-ct
kind: empirical
author: Francesco
statement: "Le séjour de CORA (TB_SEJOUR.NO_SEJOUR, l'IEP) se relie à l'EVTID de l'entrepôt EDSaN par redsan::edsan_ct(ids, from = \"IEP\"), un pour un à moins de 10 exceptions près : en 2025, chaque IEP des séjours qui ont un RSS trouve un seul EVTID, moins de 10 EVTID sont partagés par plusieurs IEP, et chaque NO_SEJOUR n'est porté que par un séjour."
scope: "CORA de production (CWPROD, schéma CORA_REC) et service de correspondance EDSaN CT appelé par redsan::edsan_ct ; séjours à RSS groupé fini en 2025 pour l'aller-retour IEP-EVTID, de 2022 à 2025 pour l'unicité de NO_SEJOUR ; lus le 2026-11-10"
refuted_if: "sur une année, plus de 0,1 % des IEP des séjours qui ont un RSS reviennent de edsan_ct en not_found ou multiple_matches, ou plus de 10 EVTID sont rendus pour plusieurs IEP, ou plus de 10 NO_SEJOUR sont portés par plusieurs ID_SEJOUR"
maturity: observed
lifecycle: active
terms: [cora:sejour, edsan:evtid]
tables: [cora:TB_SEJOUR, cora:TB_SYNTH_RSS]
supported_by: [20261110-iep-evtid-correspondance-resultat, 20261110-pie-rss-sejour-resultat, 20261110-requete-editeur-no-sejour-iep]
depends_on: []
---
## Pour s'en servir

Pour passer d'un séjour de CORA à l'entrepôt, prendre TB_SEJOUR.NO_SEJOUR (joint au RSS par ID_SEJOUR) et le convertir :

```r
res <- redsan::edsan_ct(as.character(no_sejour), from = "IEP")  # colonnes IEP, EVTID, status, n_matches
```

Les identifiants doivent être du texte. Garder à part les lignes dont status vaut not_found ou multiple_matches au lieu de les joindre. L'appel inverse (from = "EVTID") rend l'IEP. Une ligne par RSS reste une ligne par RSS après la conversion : un EVTID a autant de lignes que son séjour a de RSS. Avant de sommer par EVTID, vérifier que chaque EVTID n'a qu'un IEP : les rares EVTID partagés réuniraient deux séjours.

Ne pas chercher l'EVTID dans CORA : il n'y est pas. Le pont est le service de l'entrepôt, appelé par edsan_ct() (paquet redsan, par lots de 3 500 identifiants).

## Ce qui l'appuie

Script 20261110-iep-evtid-correspondance (20261110-iep-evtid-correspondance-resultat) : les 176 493 IEP distincts des séjours dont un RSS groupé finit en 2025 reviennent tous en matched (N_IEP_MATCHED = N_IEP) : aucun not_found, aucun multiple_matches. Moins de 10 EVTID sont partagés par plusieurs IEP, et moins de 10 EVTID renvoient, dans l'appel inverse, un autre IEP que celui de départ.

20261110-pie-rss-sejour-resultat (niveau SEJOUR) : de 2022 à 2025, le nombre de NO_SEJOUR distincts égale le nombre de séjours (145 931, 152 947, 162 844, 176 493) ; moins de 10 NO_SEJOUR partagés et moins de 10 séjours sans NO_SEJOUR par an. Les requêtes de l'éditeur de CORA nomment TB_SYNTH_RSS.NO_SEJOUR « IEP » (20261110-requete-editeur-no-sejour-iep).

Points ouverts : l'aller-retour n'est mesuré que sur 2025 ; le code de edsan_ct (paquet redsan) a été lu dans la conversation, il n'est pas une source du dépôt ; un séjour sans RSS (externe, urgences) n'a pas été testé.
