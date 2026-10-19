---
name: frame
description: Cadrer avec la personne une question sur les données du CHU, et retrouver ce que le dépôt en sait, avant d'écrire une requête, d'ouvrir une enquête ou de compter. Utiliser dès qu'une question nouvelle porte sur ces données (un chiffre, une extraction, une comparaison, une définition, ce que dit un document, dans CORA, OpRoom, le PMSI ou un autre contexte de knowledge/glossaries/README.md), même quand elle paraît rapide ; et quand une session reprend une enquête.
---

# frame

Cadrer coûte moins que refaire. frame s'assure avec la personne qu'on sait quelle question on pose, ce qu'on en sait déjà, et que personne n'y travaille déjà, avant de dépenser quoi que ce soit. Pendant le cadrage, rien ne s'écrit dans le dépôt.

Si la personne reprend une enquête qu'elle nomme : la reprendre (investigations/README.md, « La branche »), puis passer à l'étape en cours de son plan.

1. **Regarder si quelqu'un a déjà posé la question**, dès qu'on en connaît le sujet : les issues, ouvertes et fermées, les pull requests ouvertes et les branches d'enquête (investigations/README.md, « La branche »), les questions des enquêtes passées (method/layout.md, « Retrouver ce qu'on sait »). Si quelque chose y répond ou y travaille, le montrer à la personne, avec son cadrage, et elle choisit : s'arrêter là, et frame est finie ; rejoindre le travail en cours (même section) ; ou poser une autre question. Si rien n'existe, le dire en une ligne.
   Fini quand : ces quatre endroits ont été cherchés ; rien n'y répond, ou la personne a choisi.
2. **Cadrer**, en cherchant ce qu'on sait au fil du cadrage (method/layout.md, « Retrouver ce qu'on sait ») : mener un *grill* avec la personne, par lots de questions, avec une réponse recommandée quand le dépôt ou la demande la fonde (un seul lot pour une demande rapide), jusqu'à ce que la question et la méthode prévue tiennent : le but (ce que la réponse permettra de faire avec les données : retrouver, classer, joindre, compter), la source, la population, la période, l'unité d'analyse, la mesure, la comparaison, les définitions opérationnelles. Un point peut rester « à trancher », ou être « sans objet » (une définition n'a ni mesure ni comparaison). Un document hors du dépôt se lit à l'étape 3.
   Fini quand : la personne a confirmé la question, en une phrase, et le cadrage ; chaque terme et chaque table du cadrage a été cherché, et la personne a reçu ce qui existe, avec l'état de relecture de chaque claim utilisé (method/claims.md, « Citer un claim »), et ce qui manque : un fait que ni un claim, ni sources/, ni un résultat déjà enregistré n'établit ; un chiffre de l'hôpital, même un seul ; un point à trancher.
3. **Conclure :**
   - si rien ne manque, répondre en citant ce qui existe : chaque claim avec son état de relecture, le texte de sources/, la date d'un résultat ;
   - si la question ne demande que ce que dit un document hors du dépôt (une règle du PMSI, sans les données du CHU), le lire et répondre en citant son édition et l'endroit exact, sans rien écrire : ce qu'une source dit déjà n'est pas un claim (method/claims.md, « Ce qui mérite un claim ») ;
   - si rien ne manque et que la personne refera le calcul à l'hôpital avec d'autres réglages, préparer sa routine (method/queries.md, « Une routine »), avec sa pull request ;
   - sinon, ouvrir l'enquête (investigations/README.md, « La branche ») ; les points à trancher deviennent des étapes de son plan.

   Un doute né en chemin ouvre l'enquête.
   Fini quand : la personne dit que la réponse ou la routine lui suffit, et la routine a sa pull request ; ou l'issue a la question et le plan, et le README de l'enquête est enregistré sur sa branche.

Ensuite : pour chaque étape du plan, research pour un document, relay pour des données de l'hôpital ; une définition se tranche avec la personne une fois ses preuves réunies (investigations/README.md, « Choix »).
