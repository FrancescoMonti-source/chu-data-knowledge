---
name: research
description: Chercher ce qui est déjà écrit sur une question cadrée, d'abord dans les claims du dépôt, puis dans les documents. Utiliser après frame, et quand une étape du plan demande un document.
---

# research

Où chercher : docs/agents/layout.md, « Retrouver ce qu'on sait ». Les formats : docs/agents/evidence.md. Si l'enquête est déjà ouverte, passer directement aux documents.

## Le dépôt

1. **Chercher ce qu'on sait.** Pour chaque terme et chaque table de la question : les glossaires, puis les claims qui les citent, puis leurs prémisses et leurs preuves ; enfin, les questions des enquêtes passées.
   Fini quand : chaque terme et chaque table a été cherché, et la personne a reçu ce qui existe, avec l'état de relecture de chaque claim (claims.md, « Citer un claim »), et ce qui manque.
2. **Si ça suffit,** répondre en citant les claims et leur état de relecture. S'arrêter là : aucune enquête ne s'ouvre.
   Fini quand : la personne a sa réponse, et elle dit qu'elle lui suffit.
3. **Sinon, ouvrir l'enquête** (investigations/README.md). Ouvrir l'issue avec la question et un plan. Le plan, c'est ce qui manque, en quelques étapes dans l'ordre, chacune avec ce à quoi elle sert : un document à lire, ou une requête à l'hôpital. Puis créer la branche de l'enquête (investigations/README.md, « La branche ») et `investigations/<id>/README.md`, avec la question, le cadrage de frame et le numéro de l'issue. Enregistrer (même section).
   Fini quand : l'issue existe avec le plan, et le README est enregistré.

## Les documents

Pour chaque étape du plan qui demande un document :

4. **Identifier le document :** titre, éditeur, édition, champ et période d'application (pour le PMSI, l'édition de l'année). Chercher sa fiche dans sources/ ; si elle manque, la créer.
   Fini quand : la fiche existe, avec l'édition dans l'id et l'autorité.
5. **Lire les passages utiles.** Pour chaque passage, un fichier de lecture dans le dossier evidence/ du sujet du passage (docs/agents/layout.md), avec l'endroit exact et une courte citation.
   Fini quand : chaque passage dont l'enquête se sert a son fichier, et aucune citation ne contient de donnée de personne (docs/agents/privacy.md).
6. **Enregistrer** (investigations/README.md, « La branche »).
   Fini quand : chaque nouvelle preuve est enregistrée.

Ensuite : relay pour une étape qui demande des données de l'hôpital ; sediment quand les preuves suffisent pour répondre. Un plan revu ou une décision de méthode : investigations/README.md, « Le plan » et « Choix ».
