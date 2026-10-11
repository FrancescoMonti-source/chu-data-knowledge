---
name: relay
description: Préparer une requête qu'une personne exécutera à l'hôpital, puis enregistrer le résultat comme preuve. Utiliser quand une étape du plan demande des données de CORA, EDSaN, ICCA, OpRoom ou d'un autre système.
---

# relay

Le protocole et ses règles : docs/agents/requests.md. Le filtre : docs/agents/privacy.md.

## Aller

1. **Décider person_data.** La demande touche-t-elle des personnes, patients ou personnel ? Dans le doute, oui : masked.
   Fini quand : la valeur est choisie, masked ou no-person-data.
2. **Écrire la requête** dans `systems/<système>/requests/`, en suivant les claims sur les tables qu'elle touche. Sans claim sur ces tables, demander d'abord à la personne le moteur de la base (SQL Server, Oracle…), et commencer par une requête WHERE 1=0 pour connaître les colonnes (requests.md, règle 2).
   Fini quand : `python checks/check.py` ne donne aucun ROUGE sur la requête, et chaque règle de requests.md a été vérifiée à la main, suppression secondaire comprise.
3. **Livrer.** Commit et push de la requête sur la branche de l'enquête, puis la donner à la personne, avec les deux lignes pour elle et le rappel de prévenir si elle la modifie (requests.md, « Aller »).
   Fini quand : la requête livrée est poussée, et la personne l'a.

## Retour

4. **Vérifier** l'id, la base et les colonnes attendues. Demander si la requête a été modifiée ; si oui, obtenir la version exécutée. Le fichier .sql ne change pas (requests.md, règle 6).
   Fini quand : ces quatre points sont confirmés.
5. **Filtrer** le résultat (privacy.md). S'il contient une donnée de personne : ne rien écrire, prévenir la personne, suivre privacy.md, « Incident », puis écrire une nouvelle version de la requête qui masque mieux (étape 2).
   Fini quand : le résultat ne contient que des agrégats, sans effectif de 1 à 9 en clair.
6. **Enregistrer** la preuve d'exécution (docs/agents/evidence.md). Lancer `python checks/check.py`, puis commit et push sur la branche de l'enquête. Puis la citer dans l'issue de l'enquête, avec l'étape du plan qu'elle couvre.
   Fini quand : aucun ROUGE, le commit est poussé, et la preuve est citée dans l'issue.

Ensuite : l'étape suivante du plan. Un résultat peut demander un document (research) ou une autre requête ; il ne l'impose pas. Un plan revu ou une décision de méthode : investigations/README.md, « Le plan » et « Choix ». sediment quand les preuves suffisent pour répondre.
