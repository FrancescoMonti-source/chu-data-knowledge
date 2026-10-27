# Par quelles données de CORA repérer, et combien compter, les réhospitalisations MCO non programmées pour une complication de grade Clavien-Dindo III ou IV entre J1 et J90 après une chirurgie bariatrique au CHU ?

Personne : Francesco
Issue : #113

## Cadrage
- **But :** répondre à un questionnaire sur l'obésité, qui demande le « nombre total de réinterventions précoces < 90 jours non programmées après chirurgie bariatrique », précisé ainsi : « toute ré-hospitalisation non programmée pour complication classée DINDO 3-4 dans un délai de 1 à 90 jours post op en MCO ». Aucun champ du PMSI ne porte le grade : la réponse est un proxy, avec ce qu'il perd et ce qu'il compte en trop.
- **Grade :** Clavien-Dindo classe une complication par le traitement reçu (Dindo 2004). Grade III : intervention chirurgicale, endoscopique ou radiologique. Grade IV : complication qui menace la vie et demande une prise en charge en soins intensifs ou en réanimation, défaillance d'organe et dialyse comprises. III et IV sont comptés ensemble, comme dans la question.
- **Proxy de départ :** grade III, un acte CCAM thérapeutique dans le séjour de retour ; grade IV, un acte marqueur de réanimation, un mouvement dans une unité de réanimation ou de soins intensifs, ou une défaillance d'organe codée. Base : l'algorithme de Tzedakis et al. (Ann Surg 2026), validé sur le PMSI en chirurgie hépatobiliaire, à adapter à la chirurgie bariatrique.
- **Source :** CORA de production (CWPROD, schéma CORA_REC), requêtes exécutées par Francesco.
- **Population :** les séjours MCO avec un acte CCAM de chirurgie bariatrique ; J0 est la date de l'acte. Liste des actes à trancher (étape 1 du plan).
- **Retour :** un autre séjour MCO du même patient, relié à un RSS (joindre-rss-par-id-sejour), entré de J1 à J90. Actes et diagnostics par le mouvement (chemin-actes-diags-par-mouvement).
- **Non programmée :** à trancher sur preuves (étape 5). CODE_PROVENANCE '5', TYPE_SEJOUR 'URG', UF_URGENCE et le drapeau URGENCE ne repèrent pas les urgences (provenance-urgences-rupture-2023, sejour-sans-signal-urgences, drapeau-urgence-uf-non-fiable, tous unreviewed). Candidat : l'absence de trace de préadmission (TB_SEJOUR.STATUT_PROG = 'A' d'après le dictionnaire CORA 2020, jamais mesurée), contrôlée par l'entrée par une UF d'urgences (uhcd-reperer-par-um, unreviewed).
- **Période :** actes index depuis 2022, les actes de bloc avant 2022 étant incomplets (reperer-actes-de-bloc, unreviewed) ; l'année retenue est à trancher. Une année N demande les retours jusqu'à fin mars N+1, et les deux derniers mois ne sont pas codés (rss-mois-recents-non-codes, unreviewed).
- **Unité et mesure :** à trancher (séjour de retour, réintervention ou patient).
- **Hors champ :** les réhospitalisations dans un autre établissement, que CORA ne voit pas ; les décès (grade V).
- **Masquage :** effectifs < 10 masqués dans les requêtes ; les codes d'actes et de diagnostics ne sont pas des personnes.
- **Branche :** claude/project-thread-pgynof, imposée par la session, au lieu de investigation/reinterventions-bariatrique.

## Choix
- **Tzedakis et al. 2026 cité par son DOI, sans fiche dans sources/** (10.1097/SLA.0000000000007105 ; table S3 du matériel supplémentaire, lue le 2026-10-27) : method/evidence.md n'a pas d'autorité pour un article publié, et une valeur nouvelle demanderait une décision de mainteneur. Ses listes d'actes servent à écrire les requêtes ; elles ne soutiennent aucun claim.

## Conclusions
