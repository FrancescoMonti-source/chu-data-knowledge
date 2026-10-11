---
name: research
description: Chercher ce qui est déjà écrit sur une question cadrée, d'abord dans les claims du dépôt, puis dans les documents (textes réglementaires, guides de l'ATIH, documentation d'un éditeur, documents du CHU). Utiliser après frame, et quand une étape du plan demande un document.
---

# research

Cette skill donne les étapes. Où chercher : docs/agents/layout.md, « Retrouver ce qu'on sait ». Les formats : docs/agents/evidence.md. Si l'enquête est déjà ouverte, passer directement aux documents.

## Le dépôt

1. **Chercher ce qu'on sait.** Pour chaque terme et chaque table de la question : les glossaires, puis les claims qui les citent, puis leurs prémisses et leurs preuves ; enfin, les questions des enquêtes passées.
   Fini quand : chaque terme et chaque table a été cherché, et la personne a reçu ce qui existe, avec l'état de relecture de chaque claim (claims.md, « Citer un claim »), et ce qui manque.
2. **Si ça suffit,** répondre en citant les claims et leur état de relecture. S'arrêter là : aucune enquête ne s'ouvre.
3. **Sinon, ouvrir l'enquête** (investigations/README.md). Ouvrir l'issue avec la question, le cadrage de frame et un plan. Le plan, c'est ce qui manque, en quelques étapes dans l'ordre, chacune avec ce à quoi elle sert : un document à lire, ou une requête à l'hôpital. Puis créer la branche `enquete/<id>` et `investigations/<id>/README.md`, avec la question, le cadrage et le numéro de l'issue.
   Fini quand : l'issue existe avec le plan, et le README existe sur la branche de l'enquête.

## Les documents

Pour chaque étape du plan qui demande un document :

4. **Identifier le document :** titre, éditeur, édition, champ et période d'application (pour le PMSI, l'édition de l'année). Chercher sa fiche dans sources/ ; si elle manque, la créer.
   Fini quand : la fiche existe, avec l'édition dans l'id et l'autorité.
5. **Lire les passages utiles.** Pour chaque passage, un fichier de lecture dans le dossier evidence/ du sujet du passage (docs/agents/layout.md), avec l'endroit exact et une courte citation.
   Fini quand : chaque passage dont l'enquête se sert a son fichier, et aucune citation ne contient de donnée de personne (docs/agents/privacy.md).
6. **Contrôler et enregistrer :** `python checks/check.py`, puis commit sur la branche de l'enquête.
   Fini quand : aucun ROUGE, et le commit est fait.
7. **Relier au plan.** Dans l'issue de l'enquête, un commentaire qui donne, pour chaque nouvelle preuve, son id et l'étape qu'elle couvre.
   Fini quand : chaque nouvelle preuve est citée dans l'issue.

Ensuite : relay pour une étape qui demande des données de l'hôpital ; sediment quand les preuves suffisent pour répondre.
