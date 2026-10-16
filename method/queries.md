# Requêtes et relay

La protection des données est dans la requête elle-même, pas dans la discipline de la personne qui l'exécute. Le protocole est le même pour tous les systèmes.

## Le fichier

Une requête est un fichier .sql dans knowledge/queries/, nommé par la date et le sujet. Il commence par quatre lignes d'en-tête :

```sql
-- id: 20261007-mvt-rum
-- system: cora
-- person_data: masked
-- purpose: compter les mouvements par année (étape 2 du plan)
-- La base et l'heure s'écrivent selon le dialecte du système : voir ses claims, ou demander à la personne.
SELECT '20261007-mvt-rum' AS query_id,
       DB_NAME() AS database_name,
       CURRENT_TIMESTAMP AS run_at,
       ANNEE,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE CAST(COUNT(*) AS VARCHAR(10)) END AS N_MVT
FROM TB_MVT_RUM
GROUP BY ANNEE;
```

- **system :** le système interrogé, écrit comme son contexte dans la carte (knowledge/glossaries/README.md). Un système absent de la carte y entre d'abord (layout.md, « Termes et glossaires »).
- **person_data :** masked si la requête touche des personnes, patients ou personnel ; no-person-data pour des codes, des référentiels ou des schémas. Dans le doute : masked. Les tables du personnel sont masquées.
- **purpose :** ce que la requête cherche, et l'étape du plan qu'elle sert.

## Les règles

1. Seulement des colonnes agrégées. Une colonne d'effectif s'appelle N_… ou NB_… (N_SEJ, NB_PATIENTS) : c'est là que le contrôle cherche les effectifs de 1 à 9 en clair.
2. Les colonnes sont nommées une par une : jamais SELECT *. Pour connaître les tables et les colonnes que ni les claims ni sources/ ne donnent, interroger le catalogue de la base (ALL_TAB_COLUMNS sous Oracle, INFORMATION_SCHEMA.COLUMNS sous SQL Server), en no-person-data : il donne aussi le type et la taille de chaque colonne.
3. Toute statistique calculée sur moins de 10 personnes, séjours ou actes sort comme <10, minimum et maximum compris. Le masquage est écrit dans la requête.
4. On cache aussi les totaux qui permettraient de recalculer une cellule masquée (suppression secondaire) : total 25, cellules visibles 12 et 8, donc la cellule cachée vaut 5.
5. La première colonne affiche l'id de la requête ; les suivantes, la base et l'heure d'exécution.
6. Une requête exécutée ne change plus. Une nouvelle version est un nouveau fichier, avec un nouvel id.

Les règles 1, 3 et 4 valent pour masked ; les règles 2, 5 et 6, pour toutes les requêtes. Le contrôle lit la requête sans ses commentaires. Il vérifie SELECT * et l'id, et pour masked la présence du seuil (< 10 ou <= 9) et d'un agrégat. Il ne vérifie pas que le masquage est juste, ni les règles 4 et 6.

## Un script sur un fichier

Quand la donnée est dans un fichier gardé à l'hôpital, comme le fichier groupé d'un envoi, la requête est un script : un fichier .R ou .py dans knowledge/queries/, nommé comme une requête (method/adr/0026).

- **Langage et paquets :** R ou Python, avec les paquets que la personne a déjà à l'hôpital. Dans le doute, l'agent lui demande.
- **En-tête :** les quatre mêmes lignes, commentées par `#`. system : le système qui a produit le fichier.
- **Règles :** 2 et 5 à 6, plus 1, 3 et 4 pour masked. Le script imprime un seul tableau ; ses premières colonnes sont l'id, le nom du fichier lu et l'heure. Pour masked, il n'imprime que des agrégats, masqués dans le script, sans aucune ligne du fichier.
- **Colonnes du fichier :** ses positions viennent de la fiche de son format, dans sources/.
- **Lire la base :** quand le résultat demande l'état actuel de chaque ligne du fichier, le script lit aussi le système de son en-tête, sur la connexion que la personne a ouverte. La requête SQL nomme ses colonnes ; ses lignes restent en mémoire, et seul le tableau d'agrégats sort.
- **Chemins et connexion :** les seules lignes que la personne adapte. Les changer ne compte pas comme une modification.

```r
# id: 20261016-grp-rum-par-mois
# system: cora
# person_data: masked
# purpose: compter les RUM du fichier groupé d'un envoi par mois de sortie de l'UM (étape 2 du plan)
fichier <- "CHEMIN/VERS/fichier.grp"
l <- readLines(fichier, encoding = "latin1")
n <- table(substr(l, 105, 110))
print(data.frame(QUERY_ID = "20261016-grp-rum-par-mois", DATABASE_NAME = basename(fichier),
                 RUN_AT = format(Sys.time(), "%Y-%m-%d %H:%M"), MOIS = names(n),
                 N_RUM = ifelse(n < 10, "<10", as.character(n))), row.names = FALSE)
```

Le contrôle lit le script sans ses commentaires : il cherche l'id entre guillemets, et pour masked un comptage (sum, length, table, len, Counter…) et le seuil < 10. Il ne vérifie pas que le script n'imprime rien d'autre.

## Une routine

Un calcul qu'on refait à l'hôpital avec d'autres réglages (d'autres codes, d'autres fichiers) devient une routine : un dossier knowledge/routines/<id>/, avec son code `<id>.R` ou `<id>.py` et `README.md` (method/adr/0027). L'id dit ce que la routine calcule, sans date.

- **Le code :** une fonction qui prend les réglages en paramètres. Trois lignes d'en-tête, commentées par `#` : id, system, purpose.
- **README.md :** la méthode, en français : ce que la routine compte, chaque paramètre, ses limites. Ce qu'elle suppose sur les données (les positions d'un fichier, une clé de jointure) s'écrit en claims, que le README cite.
- **Le résultat reste à l'hôpital.** Il n'entre pas dans le dépôt. Non masqué, il ne se colle pas non plus dans une conversation (privacy.md).
- **Un chiffre qui doit devenir une preuve :** une requête de knowledge/queries/ (« Un script sur un fichier »), avec tout son calcul dans le script. Elle ne charge pas la routine : une requête exécutée ne change plus (règle 6), une routine si.

```r
# id: grp-rum-par-mois
# system: cora
# purpose: compter les RUM d'un fichier groupé par mois de sortie de l'UM
grp_rum_par_mois <- function(fichier) {
  l <- readLines(fichier, encoding = "latin1")
  print(table(MOIS = substr(l, 105, 110)))
}
```

Le contrôle vérifie le dossier de la routine, son README.md et son en-tête, et qu'aucune requête ne la charge. Il ne lit pas ce qu'elle imprime.

## Aller

Le message qui accompagne la requête donne deux lignes à la personne : à quelle étape du plan sert la requête et ce qui change selon le résultat ; où et comment l'exécuter. Il lui rappelle de prévenir si elle modifie la requête.

Il donne aussi une ligne par règle qui s'applique à la requête : comment elle la respecte. Par exemple : « Règle 4 : la ligne TOTAL est masquée dès qu'une cellule l'est. » Avec ces lignes, la personne vérifie le masquage avant d'exécuter.
