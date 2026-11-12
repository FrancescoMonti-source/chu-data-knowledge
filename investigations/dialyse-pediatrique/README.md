# Combien de séances de dialyse le CHU a-t-il réalisées en 2025 pour des patients de moins de 18 ans le jour de la séance ?

Personne : Francesco
Issue : #135

## Cadrage
- **But :** compter. Le chiffre de 2025, avec 2022 à 2024 pour le comparer.
- **Source :** CORA de production (CWPROD, schéma CORA_REC), TB_SYNTH_RSS ; requêtes exécutées par Francesco.
- **Règle officielle :** une séance est une venue d'un jour, une seule par jour ; un RSS peut réunir plusieurs séances identiques, dont le nombre est dans « nombre de séances » ; un patient hospitalisé en MCO n'a pas de RSS de séance, sa dialyse entre en actes et en suppléments dans le RSS du séjour ; la dialyse à domicile ou en autodialyse est hors de ces règles (guide méthodologique MCO 2026, chap. VII, § 1 et 2, p. 142-144 ; même texte dans l'édition 2024 : l'édition 2025 n'a pas été lue). Le fichier IUM connaît un type d'unité 22, « hémodialyse en centre pour enfant » (même guide, chap. I, § 2.4, p. 27).
- **Séance de dialyse :** RSS de GHM 28Z01Z, 28Z02Z, 28Z03Z ou 28Z04Z (entraînements à la dialyse péritonéale, à l'hémodialyse, hémodialyse ; manuel des GHM 2026, vol. 2, CMD 28, liste D-113). Choisi par Francesco.
- **Mesure :** la somme de NB_SEANCES, pas le nombre de RSS ; par GHM. Les dialyses pendant une hospitalisation (NB_DIALYSE, NB_DIP des RSS hors CMD 28) sont comptées à part, hors du chiffre principal. Choisi par Francesco.
- **Pédiatrique :** moins de 18 ans le jour du début du RSS, âge recalculé (age-entree-a-recalculer, unreviewed). La requête croise avec l'UF 5624 (PED.MED.HEMODIALYSE, uf-du-rum-hebergement, unreviewed), pour voir où l'âge et l'unité diffèrent. Choisi par Francesco.
- **Période :** RSS finis de 2022 à 2025 (DATE_FIN). Choisi par Francesco.
- **Unité d'analyse :** la séance ; le RSS et le patient en appui.
- **Masquage :** effectifs < 10 masqués dans la requête, aucune ligne de total.
- **Branche :** claude/project-thread-ltp11c, imposée par la session, au lieu de investigation/dialyse-pediatrique (#123).

## Choix
- **Plan revu, étape 2 :** un collègue cible les séances par le GHS 9617 et trouve plusieurs séances par NO_SEJOUR ; l'arrêté « forfaits » réserve le GHS 9617 au GHM 28Z04Z pris en charge « en centre pour enfants », sans condition d'âge (20261112-arrete-forfaits-hemodialyse-ghs). La requête 20261112-dialyse-ghs-sejour compare GHS, âge et UF, et compte les NO_SEJOUR à côté des RSS.

## Conclusions

Réponse : en 2025, 802 séances de dialyse pour des patients de moins de 18 ans le jour de la séance, toutes en hémodialyse (28Z04Z), pour 12 patients, toutes dans l'UF 5624 : les deux lectures de « pédiatrique » donnent le même chiffre. 1 078 en 2024 (11 patients), également tout en 28Z04Z. En 2023, 1 154 séances d'hémodialyse (10 patients), plus une ligne 28Z01Z masquée : le total de 2023 est inconnu, et au moins 1 154. 2022 masqué (moins de 10 patients). À part, chaque année, moins de 10 enfants dialysés pendant un séjour d'hospitalisation, par groupe d'UF (suppléments, pas des séances) ; leur nombre de RSS est masqué, donc inconnu (20261112-dialyse-pediatrique-resultat).

Comparaison avec un ciblage par GHS 9617 : ces 802 séances sont toutes en GHS 9617, réparties sur 60 NO_SEJOUR ; le GHS 9617 compte aussi moins de 10 patients de 18 ans ou plus de l'UF 5624. Compter les NO_SEJOUR donne 60, pas 802 (20261112-dialyse-ghs-sejour-resultat).

Claims :
- seances-dialyse-un-rss-par-seance (unreviewed)

Prémisses de la requête, non relues : age-entree-a-recalculer, uf-du-rum-hebergement, joindre-rss-par-id-sejour (unreviewed).
