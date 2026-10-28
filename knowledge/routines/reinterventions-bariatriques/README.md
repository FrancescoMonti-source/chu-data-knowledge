# reinterventions-bariatriques

Compte, par année de l'intervention, les réhospitalisations MCO non programmées de J1 à J90 avec un acte de complication de grade Clavien-Dindo III ou IV, après une sleeve ou un bypass ; sur demande, elle liste ces séjours, pour les vérifier en dossier. Le compte est le nombre que demande le questionnaire sur l'obésité : « toute ré-hospitalisation non programmée pour complication classée DINDO 3-4 dans un délai de 1 à 90 jours post op en MCO ».

Née dans l'enquête reinterventions-bariatrique (issue #113), de la requête 20261028-retours-j90-grade : même calcul, avec l'année de l'intervention en ligne et une colonne par compte. La réponse et ses limites : reintervention-bariatrique-par-actes-du-retour (unreviewed, provisional).

## Appel

On la lance à l'hôpital. Son résultat y reste : il n'entre pas dans le dépôt, et non masqué, il ne se colle pas dans une conversation (method/queries.md, « Une routine »). Un chiffre qui doit devenir une preuve passe par une requête qui recopie le calcul.

```text
source("CHEMIN/VERS/knowledge/routines/reinterventions-bariatriques/reinterventions-bariatriques.R")
r <- reinterventions_bariatriques(connexion = function() redsan:::.cora_connect(), annees = 2025, masquer = FALSE, sejours = TRUE)
```

La routine imprime une ligne par année, puis une ligne d'explication par colonne, puis, avec sejours = TRUE, la liste des séjours. La réponse au questionnaire est la colonne N_REINTERVENTIONS. Elle rend aussi, sans les imprimer une seconde fois, `r$comptes` et `r$sejours` (NULL sans sejours = TRUE).

## Paramètres

| Paramètre | Défaut | Rôle |
|---|---|---|
| connexion | obligatoire | une fonction qui ouvre la connexion à CORA, par exemple `function() redsan:::.cora_connect()` |
| annees | 2022:2025 | les années de l'intervention (le jour du premier acte index du séjour) |
| actes_index | HFFC018, HFFA011, HFCC003, HFCA001 | les actes qui font une intervention : sleeve et bypass, par cœlioscopie ou laparotomie |
| masquer | TRUE | FALSE donne les vrais effectifs, pour la personne seule à l'hôpital : la première ligne dit alors « masque : non » (method/privacy.md) |
| sejours | FALSE | TRUE ajoute la liste des séjours concernés ; elle demande masquer = FALSE, car une liste de séjours ne se masque pas |

## Ce que la routine lit

- **CORA :** TB_ACTE (ID_SEJOUR, DATE_ACTE, CODE_ACTE), TB_SEJOUR (ID_SEJOUR, ID_PATIENT, NO_SEJOUR, DATE_ENTREE, DATE_SORTIE, UF_ENTREE, DATE_CREAT), TB_SYNTH_RSS (ID_SEJOUR) ; pour la liste des séjours, V_CCAM_NV (CODE, TYPE, LIBELLE_LONG), jointe sur le code de l'acte avec TYPE = 'A', qui n'ajoute aucune ligne (ccam-nv-une-ligne-par-code, unreviewed). Un séjour compte s'il est sorti et relié à un RSS par TB_SYNTH_RSS.ID_SEJOUR (joindre-rss-par-id-sejour, unreviewed). Le calcul se fait dans CORA : seuls les comptes par année reviennent dans R, et, avec sejours = TRUE, une ligne par retour et par acte de grade III ou IV.
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
| N_REINTERVENTIONS_URGENCES | parmi elles, celles entrées par une UF d'urgences ou après un séjour d'urgences de la veille ou du jour même : le minimum sûr. L'écart avec N_REINTERVENTIONS, ce sont les retours créés le jour de leur entrée sans urgence, programmés ou non |
| N_INTERVENTIONS_REPRISES | les interventions suivies d'au moins une réintervention, si l'unité retenue est l'intervention ou le patient |
| N_COMPLICATIONS_SEJOUR_INDEX | les interventions avec un acte de grade III dès J0 + 1, ou de grade IV dès J0 + 4, dans leur propre séjour, comme l'article ; hors de la réponse, qui parle de ré-hospitalisation |
| COMPLETE | « non » avant le 1er juillet de l'année suivante : les retours vont jusqu'à fin mars, et les deux derniers mois ne sont pas encore codés (rss-mois-recents-non-codes, unreviewed) |

Un retour peut suivre deux interventions : il compte alors dans chacune de leurs années.

## La liste des séjours

Avec sejours = TRUE, une ligne par retour de J1 à J90 avec un acte de grade III ou IV, programmé ou non : ANNEE, NO_SEJOUR_INDEX et DATE_INTERVENTION, NO_SEJOUR_RETOUR (TB_SEJOUR.NO_SEJOUR, le n° de séjour officiel, d'après le dictionnaire CORA 2020) et DATE_ENTREE_RETOUR, JOUR (J + n), GRADE (le plus haut), ACTES (les actes des listes trouvés dans le retour, chacun avec son libellé : « code : libellé », séparés par « ; »), ENTREE (la classe de programmation), DANS_LA_REPONSE (oui pour les retours comptés dans N_REINTERVENTIONS) et A_VERIFIER (oui pour un retour créé le jour de son entrée sans urgence : un séjour programmé dont la préadmission manque y tombe aussi). Une liste de séjours est une donnée de personne : elle ne s'enregistre pas hors de l'hôpital et ne se colle pas dans une conversation (method/privacy.md).

## Masquage

Avec masquer = TRUE, le résultat suit les règles 3 et 4 de method/queries.md :

- Règle 3 : chaque effectif sous 10 sort <10.
- Règle 4 : un compte sort « masqué » quand le compte dont il est une partie, moins lui, vaut de 1 à 9 : N_RETOURS_NON_PROGRAMMES face à N_RETOURS, N_REINTERVENTIONS face à N_RETOURS_NON_PROGRAMMES, N_REINTERVENTIONS_URGENCES et N_INTERVENTIONS_REPRISES face à N_REINTERVENTIONS, N_COMPLICATIONS_SEJOUR_INDEX face à N_INTERVENTIONS.

Pas de ligne qui somme les années : elle permettrait de recalculer une cellule masquée.

## Limites

- Les retours dans un autre établissement manquent : CORA ne les voit pas.
- Le grade vient des seuls actes. Aucun dossier n'a été relu par un chirurgien, et les listes de Tzedakis et al. sont validées en chirurgie hépatobiliaire, pas bariatrique.
- Créé avant son jour d'entrée, un retour est compté programmé, même s'il soigne une complication. Créé le jour même sans urgence, il est compté non programmé, même si la préadmission a seulement été oubliée : la colonne N_REINTERVENTIONS_URGENCES et la liste (A_VERIFIER) servent à le vérifier.
- L'unité du questionnaire (séjour de retour, intervention ou patient) n'est pas tranchée : N_REINTERVENTIONS compte des séjours, N_INTERVENTIONS_REPRISES des interventions.
