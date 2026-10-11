# Requêtes et relay

La protection des données est dans la requête elle-même, pas dans la discipline de la personne qui l'exécute. Le protocole est le même pour tous les systèmes.

## Le fichier

Une requête est un fichier .sql dans `systems/<système>/requests/`, nommé par la date et le sujet. Il commence par trois lignes d'en-tête :

```sql
-- id: 20261007-mvt-rum
-- person_data: masked
-- purpose: compter les mouvements par année (étape 2 du plan)
-- La base et l'heure s'écrivent selon le dialecte du système : voir ses claims.
SELECT '20261007-mvt-rum' AS request_id,
       DB_NAME() AS database_name,
       CURRENT_TIMESTAMP AS run_at,
       ANNEE,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE CAST(COUNT(*) AS VARCHAR(10)) END AS N_MVT
FROM TB_MVT_RUM
GROUP BY ANNEE;
```

- **person_data :** masked si la requête touche des personnes, patients ou personnel ; no-person-data pour des codes, des référentiels ou des schémas. Dans le doute : masked. Les tables du personnel sont masquées.
- **purpose :** ce que la requête cherche, et l'étape du plan qu'elle sert.

## Les règles

1. Seulement des colonnes agrégées, nommées une par une. Jamais SELECT *.
2. Pour connaître les colonnes : WHERE 1=0. La réponse a les en-têtes et aucune ligne. C'est le seul SELECT * admis, et une telle requête n'a pas besoin des règles 3 à 5.
3. Toute statistique calculée sur moins de 10 personnes, séjours ou actes sort comme <10, minimum et maximum compris. Le masquage est écrit dans la requête.
4. On cache aussi les totaux qui permettraient de recalculer une cellule masquée (suppression secondaire) : total 25, cellules visibles 12 et 8, donc la cellule cachée vaut 5.
5. La première colonne affiche l'id de la requête ; les suivantes, la base et l'heure d'exécution.
6. Une requête exécutée ne change plus. Une nouvelle version est un nouveau fichier, avec un nouvel id.

Les règles 1 à 5 valent pour masked ; les règles 2 et 6, pour toutes les requêtes. Le contrôle vérifie SELECT *, et pour masked la présence du seuil (< 10 ou <= 9), d'un agrégat et de l'id. Il ne vérifie pas que le masquage est juste, ni les règles 4 et 6.

## Aller

Le message qui accompagne la requête donne deux lignes à la personne : à quelle étape du plan sert la requête et ce qui change selon le résultat ; où et comment l'exécuter. Il lui rappelle de prévenir si elle modifie la requête.

## Retour

Les étapes : .agents/skills/relay/SKILL.md, « Retour ».

**Risque résiduel :** la personne modifie la requête sans le dire. Seuls un en-tête ou des colonnes qui ne correspondent pas le révèlent.
