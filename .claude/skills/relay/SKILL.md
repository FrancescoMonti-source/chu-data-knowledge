---
name: relay
description: Préparer une requête qu'une personne exécutera à l'hôpital, puis enregistrer le résultat comme preuve. Utiliser quand une étape du plan demande des données de CORA, EDSaN, ICCA, OpRoom ou d'un autre système.
---

# relay

Le protocole et ses règles : docs/agents/requests.md. Le filtre : docs/agents/privacy.md.

## Aller

1. **Décider person_data.** La demande touche-t-elle des personnes, patients ou personnel ? Dans le doute, oui : masked.
2. **Écrire la requête** dans `systems/<système>/requests/`, en suivant les claims sur les tables qu'elle touche.
   Fini quand : `python checks/check.py` ne donne aucun ROUGE sur la requête, et chaque règle de requests.md a été vérifiée à la main, suppression secondaire comprise.
3. **Livrer.** Commit et push de la requête sur la branche de l'enquête, puis la donner à la personne, avec les deux lignes pour elle et le rappel de prévenir si elle la modifie (requests.md, « Aller »). Si elle s'arrête là, lui rappeler la retro.
   Fini quand : la requête livrée est poussée, et la personne l'a.

## Retour

4. **Vérifier** l'id, la base et les colonnes attendues. Demander si la requête a été modifiée ; si oui, obtenir la version exécutée. Le fichier .sql ne change pas (requests.md, règle 6).
   Fini quand : ces quatre points sont confirmés.
5. **Filtrer** le résultat (privacy.md). S'il contient une donnée de personne, ne rien écrire, prévenir la personne et suivre la procédure d'incident.
   Fini quand : le résultat ne contient que des agrégats, sans effectif de 1 à 9 en clair.
6. **Enregistrer** la preuve d'exécution (docs/agents/evidence.md). Lancer `python checks/check.py`, puis commit et push sur la branche de l'enquête. Puis la citer dans l'issue de l'enquête, avec l'étape du plan qu'elle couvre.
   Fini quand : aucun ROUGE, le commit est poussé, et la preuve est citée dans l'issue.

Ensuite : l'étape suivante du plan. Un résultat peut demander un document (research) ou une autre requête ; il ne l'impose pas. sediment quand les preuves suffisent pour répondre.
