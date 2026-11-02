---
review: unreviewed
id: joindre-utilisateur-par-v-util
kind: empirical
author: Pierre
statement: "Dans CORA de production, la table des utilisateurs se lit par la vue CORA_REC.V_UTIL (ID_UTIL, CODE_UTIL, NOM_UTIL, PRENOM_UTIL, MATRICULE, NO_RPPS, ACTIF, ID_SPE_MED), qui existe à côté de la table CORA_UTIL.UTIL, plus large : ne pas lire UTIL, et ne jamais sortir nom, prénom, matricule ni RPPS, mais agréger."
scope: "CORA de production (CWPROD), catalogue Oracle des schémas non maintenus par Oracle visibles par le compte de Pierre, lu le 2026-10-19"
refuted_if: "CORA_REC.V_UTIL est absente du catalogue du compte, ou n'a pas de colonne ID_UTIL"
maturity: observed
lifecycle: active
terms: [cora:utilisateur]
tables: [cora:V_UTIL, cora:UTIL]
supported_by: [20261019-catalogue-objets-g3-resultat]
depends_on: []
---
## Pour s'en servir

Pour retrouver l'utilisateur d'une ligne (créateur, dernier modificateur, signataire), joindre `CORA_REC.V_UTIL` par `ID_UTIL`. La clé attendue côté ligne est l'identifiant d'utilisateur que le dictionnaire 2020 décrit pour ID_CREAT et ID_INFO (« identifiant de l'utilisateur ayant créé la ligne ») ; la jointure n'a pas encore été mesurée (points ouverts).

Une analyse n'a pas besoin de l'identité : agréger par `ID_UTIL`, par `ID_SPE_MED` (spécialité médicale) ou par `ACTIF`, et ne rien écrire de NOM_UTIL, PRENOM_UTIL, MATRICULE, NO_RPPS ni CODE_UTIL dans une réponse ou un fichier. Ne pas prendre la table `CORA_UTIL.UTIL` : elle porte en plus des adresses électroniques, des numéros de téléphone et un commentaire libre.

## Ce qui l'appuie

Catalogue de CWPROD (20261019-catalogue-objets-g3-resultat), objets nommés V_UTIL ou UTIL :

- **CORA_REC.V_UTIL :** une vue valide, de 8 colonnes : ACTIF, CODE_UTIL, ID_SPE_MED, ID_UTIL (NUMBER), MATRICULE, NOM_UTIL, NO_RPPS, PRENOM_UTIL.
- **CORA_UTIL.UTIL :** une table valide, d'un autre schéma que CORA_REC, qui compte 31 colonnes et dont les statistiques Oracle du catalogue (NUM_ROWS) donnent 18 424 lignes : c'est une statistique du catalogue, non un comptage, et le nombre réel de lignes n'a pas été compté ; elle reprend celles de la vue et ajoute entre autres (dates d'entrée et de sortie, e-mails, téléphones, répertoire par défaut, commentaire).

Le dictionnaire 2020 n'a pas de fiche pour la table des utilisateurs (il décrit UTIL_MAT_INTERVENANT, UTIL_PASSWORD_HIST, UTIL_TYPE_EXECUTANT). Le catalogue ne montre que les objets visibles par le compte de Pierre : un objet absent est absent ou illisible pour lui.

Points ouverts : la jointure ID_CREAT, ID_INFO ou ID_SIGN vers ID_UTIL (part de lignes qui trouvent un utilisateur, valeurs négatives du dictionnaire pour les applications : TB_MVT.ID_CREAT) ; si V_UTIL est une vue sur UTIL ; si UTIL est lisible par un SELECT (le catalogue ne le dit pas).
