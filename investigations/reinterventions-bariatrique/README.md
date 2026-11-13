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
- **Actes index : HFFC018, HFFA011, HFCC003 et HFCA001** (sleeve et bypass, par cœlioscopie ou laparotomie) : les autres codes de la subdivision sont rares ou absents depuis 2022 (20261028-actes-bariatriques-par-an-resultat), et l'anneau ou le stimulateur ne sont pas une chirurgie bariatrique au sens de la question.
- **Grade tiré des seuls actes, comme dans l'article** (plan revu du 2026-10-28) : les actes de grade IV de S3 comprennent les forfaits de réanimation ; les jours de supplément et les UM de soins critiques ne sont pas nécessaires pour une première réponse, et l'arrêté « forfaits » n'a pas été lu pour cela.
- **Listes de S3 adaptées à la chirurgie bariatrique**, d'après les libellés de la CCAM 2026 : 20 actes retirés (diagnostiques, ou sans lien probable à 90 jours), 33 actes biliaires gardés à part (lithiase après amaigrissement), 35 actes ajoutés (endoprothèses de l'estomac et du duodénum, gestes par cœlioscopie absents de S3, actes bariatriques en reprise). Les listes sont dans la requête 20261028-retours-j90-grade.
- **STATUT_PROG abandonné** pour « non programmée » : il vaut 'A' presque partout (statut-prog-a-sans-trace-de-preadmission).
- **Non programmée : tout retour qui n'est pas créé avant son jour d'entrée** (Francesco, 2026-10-28) : être créé à l'avance est le seul signal fiable d'un séjour programmé (sejour-cree-avant-entree-programme), et une entrée directe le jour même après une chirurgie est le plus souvent un rappel par l'équipe.
- **Années regroupées (2022-2025) dans le dépôt** : par année, presque toutes les cases seraient sous 10. Le nombre d'une année se calcule à l'hôpital, avec la routine reinterventions-bariatriques : une ligne par année, la réponse dans la colonne N_REINTERVENTIONS.
- **Complications du séjour index comptées à part** (classe « 0 séjour index ») : le questionnaire parle de ré-hospitalisation, mais son titre dit « réinterventions précoces » ; la question est posée au demandeur.

## Conclusions
- reintervention-bariatrique-par-actes-du-retour (unreviewed, provisional) : la réponse à la question. Repérer les réinterventions par les actes de complication du séjour de retour, pas par un second acte bariatrique ; quelques cas par an au CHU.
- sejour-cree-avant-entree-programme (unreviewed, provisional) : un séjour créé avant son jour d'entrée est programmé ; l'inverse ne vaut pas.
- statut-prog-a-sans-trace-de-preadmission (unreviewed, provisional) : STATUT_PROG ne repère pas les séjours programmés, contrairement au dictionnaire.
