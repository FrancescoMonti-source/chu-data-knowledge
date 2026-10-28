# reinterventions-bariatriques

Compte, par année de l'intervention, les réhospitalisations MCO non programmées de J1 à J90 avec un acte de complication de grade Clavien-Dindo III ou IV, après une sleeve ou un bypass. C'est le nombre que demande le questionnaire sur l'obésité : « toute ré-hospitalisation non programmée pour complication classée DINDO 3-4 dans un délai de 1 à 90 jours post op en MCO ».

Née dans l'enquête reinterventions-bariatrique (issue #113), de la requête 20261028-retours-j90-grade : même calcul, avec l'année de l'intervention en ligne et une colonne par compte. La réponse et ses limites : reintervention-bariatrique-par-actes-du-retour (unreviewed, provisional).

## Appel

On la lance à l'hôpital. Son résultat y reste : il n'entre pas dans le dépôt, et non masqué, il ne se colle pas dans une conversation (method/queries.md, « Une routine »). Un chiffre qui doit devenir une preuve passe par une requête qui recopie le calcul.

```text
source("CHEMIN/VERS/knowledge/routines/reinterventions-bariatriques/reinterventions-bariatriques.R")
reinterventions_bariatriques(connexion = function() redsan:::.cora_connect(), annees = 2025, masquer = FALSE)
```

La routine imprime une ligne par année, puis une ligne d'explication par colonne. La réponse au questionnaire est la colonne N_REINTERVENTIONS.

## Paramètres

| Paramètre | Défaut | Rôle |
|---|---|---|
| connexion | obligatoire | une fonction qui ouvre la connexion à CORA, par exemple `function() redsan:::.cora_connect()` |
| annees | 2022:2025 | les années de l'intervention (le jour du premier acte index du séjour) |
| actes_index | HFFC018, HFFA011, HFCC003, HFCA001 | les actes qui font une intervention : sleeve et bypass, par cœlioscopie ou laparotomie |
| masquer | TRUE | FALSE donne les vrais effectifs, pour la personne seule à l'hôpital : la première ligne dit alors « masque : non » (method/privacy.md) |

## Ce que la routine lit

- **CORA :** TB_ACTE (ID_SEJOUR, DATE_ACTE, CODE_ACTE), TB_SEJOUR (ID_SEJOUR, ID_PATIENT, DATE_ENTREE, DATE_SORTIE, UF_ENTREE, DATE_CREAT), TB_SYNTH_RSS (ID_SEJOUR). Un séjour compte s'il est sorti et relié à un RSS par TB_SYNTH_RSS.ID_SEJOUR (joindre-rss-par-id-sejour, unreviewed). Le calcul se fait dans CORA : seuls les comptes par année reviennent dans R.
- **UF d'urgences :** 5701, 5802, 5709, 5015, 5010 et 5720 (drapeau-urgence-uf-non-fiable, uhcd-reperer-par-um, unreviewed).
- **Actes de grade III ou IV :** les listes de la requête 20261028-retours-j90-grade, recopiées dans la routine. Grade IV : les actes de grade IV de la table S3 de Tzedakis et al. 2026 (DOI 10.1097/SLA.0000000000007105), forfaits de réanimation compris. Grade III : les actes de grade III gardés de S3, plus les 35 actes ajoutés pour la chirurgie bariatrique (endoprothèses de l'estomac et du duodénum, gestes par cœlioscopie, actes bariatriques en reprise). Les actes biliaires et les actes retirés de S3 ne comptent pas. Le choix de ces listes : investigations/reinterventions-bariatrique/README.md, « Choix ».

## Ce que la routine compte

Une intervention : un séjour avec un acte index. J0 est le jour du premier acte index du séjour ; son année fait la ligne. Un retour : un autre séjour du même patient, entré de J0 + 1 à J0 + 90, et au plus tôt le jour de sortie de l'intervention.

Un retour est non programmé s'il n'a pas été créé dans CORA avant son jour d'entrée (sejour-cree-avant-entree-programme, unreviewed, provisional) : il est entré par une UF d'urgences, ou il suit un séjour d'urgences de la veille ou du jour même, ou il a été créé le jour de son entrée ou après.

| Colonne | Ce qu'elle compte |
|---|---|
| N_INTERVENTIONS | les interventions de l'année |
| N_RETOURS | les retours de J1 à J90 |
| N_RETOURS_NON_PROGRAMMES | les retours non programmés |
| N_REINTERVENTIONS | les retours non programmés avec au moins un acte de grade III ou IV : la réponse au questionnaire |
| N_INTERVENTIONS_REPRISES | les interventions suivies d'au moins une réintervention, si l'unité retenue est l'intervention ou le patient |
| N_COMPLICATIONS_SEJOUR_INDEX | les interventions avec un acte de grade III dès J0 + 1, ou de grade IV dès J0 + 4, dans leur propre séjour, comme l'article ; hors de la réponse, qui parle de ré-hospitalisation |
| COMPLETE | « non » avant le 1er juillet de l'année suivante : les retours vont jusqu'à fin mars, et les deux derniers mois ne sont pas encore codés (rss-mois-recents-non-codes, unreviewed) |

Un retour peut suivre deux interventions : il compte alors dans chacune de leurs années.

## Masquage

Avec masquer = TRUE, le résultat suit les règles 3 et 4 de method/queries.md :

- Règle 3 : chaque effectif sous 10 sort <10.
- Règle 4 : un compte sort « masqué » quand le compte dont il est une partie, moins lui, vaut de 1 à 9 : N_RETOURS_NON_PROGRAMMES face à N_RETOURS, N_REINTERVENTIONS face à N_RETOURS_NON_PROGRAMMES, N_INTERVENTIONS_REPRISES face à N_REINTERVENTIONS, N_COMPLICATIONS_SEJOUR_INDEX face à N_INTERVENTIONS.

Pas de ligne qui somme les années : elle permettrait de recalculer une cellule masquée.

## Limites

- Les retours dans un autre établissement manquent : CORA ne les voit pas.
- Le grade vient des seuls actes. Aucun dossier n'a été relu par un chirurgien, et les listes de Tzedakis et al. sont validées en chirurgie hépatobiliaire, pas bariatrique.
- Un retour créé avant son jour d'entrée est compté programmé, même s'il soigne une complication.
- L'unité du questionnaire (séjour de retour, intervention ou patient) n'est pas tranchée : N_REINTERVENTIONS compte des séjours, N_INTERVENTIONS_REPRISES des interventions.
