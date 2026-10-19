# revalorisation-entre-deux-etats

Compare deux états du codage MCO et dit, pour des thèmes de diagnostics, ce qui a été « récupéré » entre les deux : les RSS qui ont gagné un code du thème et dont le niveau de GHM est monté.

- **Avant :** le fichier groupé d'un envoi (.grp, format 123).
- **Après :** un second fichier groupé (M7 puis M8, par exemple), ou CORA aujourd'hui.

Née dans l'enquête revalorisation-chir-m8 (issue #50), de la requête 20261015-classes-m8-fichier.

## Appel

On la lance à l'hôpital. Son résultat y reste : il n'entre pas dans le dépôt, et non masqué, il ne se colle pas dans une conversation (method/queries.md, « Une routine »). Un chiffre qui doit devenir une preuve passe par une requête qui recopie le calcul.

```text
source("CHEMIN/VERS/knowledge/routines/revalorisation-entre-deux-etats/revalorisation-entre-deux-etats.R")
revalorisation_entre_deux_etats(avant_grp = ..., themes = ...)
```

## Paramètres

| Paramètre | Défaut | Rôle |
|---|---|---|
| avant_grp | obligatoire | chemin du fichier groupé de l'état avant |
| avant_valo | NULL | VisualValoSejours.csv du même envoi ; NULL : pas d'euros |
| apres | "cora" | "cora", ou le chemin d'un second fichier groupé |
| apres_valo | NULL | avec un second fichier : sa valorisation ; avec CORA : MONTANT_GHS est lu |
| connexion | NULL | une fonction qui ouvre la connexion à CORA, par exemple `function() redsan:::.cora_connect()` ; obligatoire si apres = "cora" |
| periode | NULL | deux dates de sortie du RSS, bornes comprises. NULL : du 1er janvier à la fin du dernier mois de sortie de l'état avant (janvier-août pour l'envoi M8). Elle écarte de l'état après les RSS que l'état avant ne pouvait pas contenir, comme ceux sortis en septembre quand l'après est CORA |
| themes | obligatoire | une liste nommée : thème = débuts de codes CIM-10, sans point (`escarres = "L89"`) |
| types_diag | "DAS" | parmi "DAS", "DP", "DR" |
| garder | NULL | les RSS gardés, selon le GHM de l'état après : une liste nommée par cmd (06), type (C), racine (06C04, le GHM sans son niveau) ou ghm (06C042). `list(type = c("C", "K"))` garde les GHM chirurgicaux et ceux des actes non opératoires ; plusieurs entrées se cumulent. NULL : tous les RSS hors CMD 90 |
| par | NULL | le découpage des lignes : un ou plusieurs de "cmd", "type", "racine", "ghm", lus sur l'état après. `c("cmd", "type")` donne une ligne par CMD et type. NULL : un seul groupe, ensemble. Un découpage fin donne surtout des <10 : il sert aux thèmes fréquents |
| masquer | TRUE | FALSE donne les vrais effectifs, pour la personne seule à l'hôpital : MASQUE dit alors « non » (method/privacy.md) |

## Ce que la routine lit

- **Fichier groupé :** une ligne par RUM, réunies par n° de RSS (positions 28-47), d'après la feuille « RSS groupé format 123 » (source atih-formats-mco-2026), dont la formule de longueur est fausse (longueur-ligne-rss-groupe). Version 10-12, CMD 3-4, GHM 5-8 du 1er RUM, date de sortie de l'UM 103-110 (la plus grande donne la sortie du RSS), nDA 134-135, DP 141-148, DR 149-156, DA n° k à 206 + 8 (k - 1). La routine s'arrête si une ligne n'est pas au format 123.
- **Valorisation :** MNT_GHS par NO_RSS, 1re ligne d'un NO_RSS ; séparateur ; , ou tabulation, lu dans l'en-tête.
- **CORA :** TB_SYNTH_RSS (NO_RSS, CODE_CMD, CODE_GHM, MONTANT_GHS, DATE_FIN) et TB_DIAG par TB_MVT_RUM. TYPE_DIAG : P pour le DP, R pour le DR, S pour les DAS (dictionnaire-cora-2020, TB_DIAG ; requetes-cora-par-defaut-v1). Les lignes lues restent en mémoire.
- **Jointure :** NO_RSS de CORA = n° de RSS du fichier = NO_RSS de la valorisation (joindre-fichier-groupe-par-no-rss). Le GHM sans sa CMD (GHM 5-8 du fichier, CODE_GHM de CORA) a le type en 1er caractère et le niveau en 4e (separer-ambulatoire-par-ghm).

## Ce que la routine compte

La population : les RSS de l'état après sortis dans la période, hors CMD 90, réduits par garder. Un RSS « gagne » un thème s'il a un code du thème après et aucun avant ; il le « perd » dans l'autre sens. THEME = tous : les RSS qui ont gagné (ou perdu) au moins un thème, comptés une fois.

Chaque RSS tombe dans une seule classe :

| Colonne | Le RSS… |
|---|---|
| N_RSS_A_CMD90_AVANT | était en CMD 90 avant |
| N_RSS_A_ABSENT_AVANT | était absent de l'état avant |
| N_RSS_B_NIVEAU_MONTE | même type de GHM, niveau 1-4 monté : c'est le « récupéré » |
| N_RSS_C_MEME_NIVEAU | même type, même niveau |
| N_RSS_NIVEAU_BAISSE | même type, niveau descendu |
| N_RSS_C_SANS_NIVEAU | même type, un niveau hors 1-4 (J, T, lettre) à un des deux états |
| N_RSS_TYPE_CHANGE | type de GHM différent avant ; hors des classes |

EUROS_B : montant après moins montant avant, sommé sur la classe B ; « sans_valo » quand une valorisation manque. N_RSS_B_SANS_MNT : RSS de la classe B sans l'un des deux montants, hors de cette somme.

PERIODE : la période utilisée, donnée ou calculée.

Lignes SENS = controle (colonne N_CONTROLE) : rss_apres (la population, après garder), rss_apres_dans_avant, rss_apres_avec_mnt_avant, no_rss_double_apres, rss_avant, rss_avant_hors_periode (RSS de l'état avant sortis hors de la période, ou sans date lisible).

## Masquage

Avec masquer = TRUE, le résultat suit les règles 3 et 4 de method/queries.md :

- Règle 3 : chaque effectif sous 10 sort <10 ; EUROS_B sort <10 quand moins de 10 RSS de la classe B ont leurs deux montants.
- Règle 4 : une partie sort « masqué » quand son tout moins elle vaut de 1 à 9 : rss_apres_dans_avant et rss_apres_avec_mnt_avant face à rss_apres, rss_avant_hors_periode face à rss_avant, N_RSS_B_SANS_MNT face à N_RSS_B_NIVEAU_MONTE.

## Limites

- La classe B ne prouve pas que le diagnostic gagné a fait monter le niveau : un autre code a pu changer en même temps.
- Le niveau compare le 1er RUM de l'état avant au GHM de l'état après ; un RSS dont le type de GHM change est mis à part.
- L'état d'un envoi n'est que dans son fichier groupé : les versions groupées de CORA et leur LIGNES_GRP ne le remplacent pas (etat-envoi-dans-fichier-groupe).
- Quand l'état après est CORA, EUROS_B soustrait le MNT_GHS de la valorisation de l'envoi au MONTANT_GHS de CORA : que les deux comptent la même chose n'a pas été vérifié.
- Pas de ligne qui somme les groupes : elle permettrait de recalculer une cellule masquée.
- garder et par lisent l'état après. Un RSS dont le GHM change de racine entre les deux états est classé selon son GHM d'après.
