---
name: research
description: Chercher ce qui est déjà écrit sur une question cadrée, d'abord dans les claims et les enquêtes du dépôt, puis dans les documents. Utiliser après frame, quand une session reprend une enquête, et quand une étape du plan demande un document.
---

# research

Où chercher : method/layout.md, « Retrouver ce qu'on sait ». Les formats : method/evidence.md. Quand l'enquête a déjà été reprise dans cette session et que l'étape du plan demande un document, passer à l'étape 4.

## Le dépôt

1. **Chercher ce qu'on sait.** D'abord, vérifier les questions des enquêtes ouvertes (investigations/README.md, « La branche ») : si la session reprend une enquête ou qu'une enquête ouverte porte sur la question, la reprendre (même section) et lire son README et son issue (investigations/README.md, « Le plan ») : le dernier plan et les preuves déjà citées. Puis trouver les termes : chercher les mots de la question dans les glossaires, titres et lignes « Alias » (method/layout.md, « Retrouver ce qu'on sait »). Pour chaque terme et chaque table de la question : les glossaires, puis les claims qui les citent, puis leurs prémisses ; puis les requêtes et les routines qui lisent ces tables (leur ligne purpose) ; enfin, les questions des enquêtes passées. D'une routine, lire aussi son README : comparer ce qu'elle compte et ses limites à la question cadrée, et chercher les claims sur lesquels elle s'appuie, comme les autres. D'un claim, lire l'en-tête et le corps : ils disent ce qu'il établit et dans quelle portée. Ne pas ouvrir les preuves (method/review.md, « Quand relire ») : celles d'une requête s'ouvrent quand le plan demande ses données (relay, étape 2).
   Fini quand : la liste des enquêtes ouvertes, chaque terme et chaque table ont été cherchés, toute enquête ouverte correspondante a été reprise avec main à jour, et la personne a reçu ce qui existe, avec l'état de relecture de chaque claim (claims.md, « Citer un claim »), et ce qui manque.
2. **Répondre ou préparer la routine** si les connaissances disponibles suffisent. Citer les claims utilisés et leur état de relecture. Pour une routine, suivre method/queries.md, « Une routine », puis ouvrir une PR pour son code et son README (AGENTS.md, règle 8). Une découverte utile à vérifier pendant ce travail rejoint l'enquête de l'étape 3.
   Fini quand : les réponses et les scripts demandés sont livrés ; toute routine à conserver a son code et sa méthode proposés en PR.
3. **Si une vérification est nécessaire, ouvrir ou poursuivre l'enquête** (investigations/README.md). Pour une enquête reprise : mettre à jour le plan si de nouveaux claims de main changent une étape (investigations/README.md, « Le plan »), puis passer à l'étape en cours du plan. Pour une question nouvelle : ouvrir l'issue avec la question et un plan. Le plan, c'est ce qui manque, en quelques étapes dans l'ordre, chacune avec ce à quoi elle sert : un document à lire, ou une requête à l'hôpital. Une routine qui fait le calcul d'une étape y est nommée avec ses réglages, et l'écart entre ce qu'elle compte et la question, s'il y en a un. Puis créer la branche de l'enquête (investigations/README.md, « La branche ») et `investigations/<id>/README.md`, avec la question, le cadrage de frame et le numéro de l'issue. Enregistrer (même section).
   Fini quand : l'issue existe avec le plan à jour, et le README est enregistré.

## Les documents

Pour chaque étape du plan qui demande un document :

4. **Identifier le document :** titre, éditeur, édition, champ et période d'application (pour le PMSI, l'édition de l'année). Chercher sa fiche dans sources/ ; si elle manque, la créer.
   Fini quand : la fiche existe, avec l'édition dans l'id et l'autorité.
5. **Lire les passages utiles.** Pour chaque passage, un fichier de lecture dans knowledge/evidence/, avec l'endroit exact et une courte citation.
   Fini quand : chaque passage dont l'enquête se sert a son fichier, et aucune citation ne contient de donnée de personne (method/privacy.md).
6. **Enregistrer** (investigations/README.md, « La branche »).
   Fini quand : chaque nouvelle preuve est enregistrée.

Ensuite : relay pour obtenir une preuve à l'hôpital ; sediment pour conserver une connaissance établie ou conclure l'enquête. Un plan revu ou une décision de méthode : investigations/README.md, « Le plan » et « Choix ».
