# Les actes des UF 5508, 6510 et 6196 se filtrent-ils sur l'UF du mouvement ou sur le site de l'acte ?

Personne : Pierre
Issue : #131 (question 1)

## Cadrage
- **Question :** dans reperer-actes-de-bloc, la requête prend les actes des UF 5508, 6510 et 6196 par l'UF du mouvement (`TB_MVT.ID_UNITE_M`) ; la preuve 20261015-sites-bloc-resultat les a comptés comme des sites de l'acte (`TB_ACTE.ID_SITE`, `TB_SITE.CODE_SITE`). Personne n'a exécuté le filtre de la requête. Les deux filtres prennent-ils les mêmes actes ?
- **Ce que l'étude applique :** la décision « UF_BLOC » de Pierre (DIM-code, `analysis/2026-10_chainage_oproom_ccam`) filtre sur l'UF du mouvement : `TB_SITE.BLOC = 'O'` ou `TRIM(M.ID_UNITE_M) IN (UF_BLOC)`. C'est le filtre de la requête du claim.
- **Population et unité :** actes de CORA datés de 2025 (CWPROD, `CORA_REC`) ; aucune personne.
- **Masquage :** masked, effectifs < 10 en `<10` dans la requête.
- **Branche :** `claude/project-thread-u0z3vd`, imposée par la session, au lieu de `investigation/uf-bloc-mouvement-ou-site` ; suite sur `claude/project-thread-l5tduy`, partie de la première.
- **Critère pour trancher (2026-11-20, Pierre demande une enquête dédiée) :** le bon filtre retrouve les actes des interventions OpRoom sans prendre d'actes faits hors intervention. Le compte d'actes ne suffit pas à trancher. Mesure sur les interventions du flux OpRoom dans CORA (TB_INTERVENTION, mai 2025 à aujourd'hui, presque complet en 2026 : interventions-cora-flux-oproom), par deux liens : TB_ACTE.NO_INTERVENTION, et le même séjour le même jour.

## Choix
- Comparer les deux filtres, pour chaque UF, en trois groupes : pris par les deux, par le mouvement seul, par le site seul (requête 20261120-uf-bloc-filtre-mouvement-site).

- Troisième filtre candidat (2026-11-20) : le site de l'acte est un site non paramétré bloc qui sert de bloc à des interventions OpRoom (TB_INTERVENTION.ID_BLOC). 20261019-interventions-par-bloc-resultat montre H.G.E.ENDOSCOPIE AG (2250, BLOC = 'N') comme bloc de 1 035 interventions en 2025 et 2 261 en 2026, et le filtre mouvement prend 924 actes de 2025 de ce site pour 5508 et 2 208 pour 6510. Les requêtes des étapes 3 et 4 du plan comparent donc trois filtres, pas deux.

- Hypothèse de Pierre (2026-11-20) : on passe par le mouvement parce que, avant 2026, les actes ne sont pas saisis dans CORA et n'ont pas de site. Réfutée le 2026-11-20 : le site est renseigné pour les actes de ces UF de 2022 à 2026, flux CPage compris. Vérifiée par année et par application d'origine (requête 20261120-uf-bloc-site-par-annee-application) ; reperer-actes-de-bloc dit déjà que ID_SITE est vide pour moins de 10 actes par mois et par application hors 2020 et 2021.

## Conclusions
- reperer-actes-de-bloc (mis à jour, unreviewed) : les deux filtres prennent des actes différents ; le mouvement prend beaucoup plus que le site (20261120-uf-bloc-filtre-mouvement-site-resultat). Reste à Pierre de dire lequel il veut.
