---
name: relay
description: "Préparer une requête qu'une personne exécutera à l'hôpital, puis enregistrer le résultat comme preuve. Utiliser quand une étape du plan demande des données d'un système de l'hôpital, comme CORA (la liste : knowledge/glossaries/README.md)."
---

# relay

Le protocole et ses règles : method/queries.md. Le filtre : method/privacy.md.

## Aller

1. **Décider person_data.** La demande touche-t-elle des personnes, patients ou personnel ? Dans le doute, oui : masked.
   Fini quand : la valeur est choisie, masked ou no-person-data.
2. **Écrire la requête** dans knowledge/queries/. Avant, chercher les requêtes qui lisent les mêmes tables (method/layout.md, « Retrouver ce qu'on sait ») : si l'une a déjà été exécutée et répond à l'étape, partir de sa preuve plutôt que d'en écrire une nouvelle. Si le résultat d'une routine doit devenir une preuve, la requête en recopie le calcul, sans la charger (queries.md, « Une routine »). Écrire la requête avec le system qu'elle interroge, en suivant les claims sur les tables qu'elle touche. Si ses colonnes ne sont ni dans ces claims ni dans sources/, demander d'abord à la personne le moteur de la base (SQL Server, Oracle…), et commencer par une requête sur le catalogue (queries.md, règle 2).
   Fini quand : `python checks/check.py` ne donne aucun ROUGE sur la requête, et chaque règle de queries.md qui s'applique a sa ligne pour la personne (queries.md, « Aller »).
3. **Livrer.** Enregistrer la requête (investigations/README.md, « La branche »), puis la donner à la personne avec son message (queries.md, « Aller »).
   Fini quand : la requête est enregistrée, et la personne l'a, avec son message.

## Retour

4. **Vérifier** l'id, la base et les colonnes attendues. Demander si la requête a été modifiée ; si oui, obtenir la version exécutée. Le fichier .sql ne change pas (queries.md, règle 6).
   Fini quand : ces quatre points sont confirmés.
5. **Filtrer** le résultat (privacy.md). S'il contient une donnée de personne : ne rien écrire, prévenir la personne, suivre privacy.md, « Incident », puis écrire une nouvelle version de la requête qui masque mieux (étape 2).
   Fini quand : aucune donnée de personne ni aucun effectif de 1 à 9 n'apparaît en clair ; pour masked, le résultat ne contient que des agrégats.
6. **Écrire et enregistrer** la preuve d'exécution (method/evidence.md ; investigations/README.md, « La branche »).
   Fini quand : la preuve est enregistrée.

Ensuite : l'étape suivante du plan. Un résultat peut demander un document (research) ou une autre requête ; il ne l'impose pas. Un plan revu ou une décision de méthode : investigations/README.md, « Le plan » et « Choix ». sediment quand les preuves suffisent pour répondre.
