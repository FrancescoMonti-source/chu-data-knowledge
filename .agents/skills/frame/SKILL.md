---
name: frame
description: Cadrer avec la personne une question sur les données du CHU, et retrouver ce que le dépôt en sait, avant d'écrire une requête, de lire un document ou de compter. Utiliser dès qu'une demande porte sur ces données (un chiffre, un comptage, une extraction, une comparaison, une définition, dans CORA, OpRoom, le PMSI ou un autre contexte de knowledge/glossaries/README.md), même quand elle paraît rapide ; et quand une session reprend une enquête.
---

# frame

Cadrer coûte moins que refaire. frame s'assure avec la personne qu'on sait quelle question on pose, ce qu'on en sait déjà, et que personne n'y travaille déjà, avant de dépenser quoi que ce soit. Pendant le cadrage, rien ne s'écrit dans le dépôt.

1. **Regarder si quelqu'un a déjà posé la question**, dès qu'on en connaît le sujet : les enquêtes ouvertes (investigations/README.md, « La branche »), les issues et les pull requests ouvertes (`gh issue list`, `gh pr list` ; sans `gh`, demander à la personne), les questions des enquêtes passées (method/layout.md, « Retrouver ce qu'on sait »). Si quelque chose y répond ou y travaille, le montrer à la personne, qui choisit : s'arrêter là, rejoindre le travail en cours avec la personne qui le mène, ou poser une autre question. Rejoindre une enquête : la reprendre (investigations/README.md, « La branche »), lire son README et le dernier plan de son issue (même fichier, « Le plan »), puis passer à l'étape en cours ; son cadrage tient lieu de l'étape 2.
   Fini quand : la liste des enquêtes ouvertes a été lue, la personne sait ce qui existe, et a choisi.
2. **Cadrer**, en cherchant ce qu'on sait quand il le faut (method/layout.md, « Retrouver ce qu'on sait ») : mener un *grill* avec la personne, par lots de questions chacune avec une réponse recommandée (un seul lot pour une demande rapide), jusqu'à la méthode prévue, provisoire : le but (ce que la réponse permettra de faire avec les données : retrouver, classer, joindre, compter), la source, la population, la période, l'unité d'analyse, la mesure, la comparaison, les définitions opérationnelles. Un point peut rester « à trancher », ou être « sans objet » (une définition n'a ni mesure ni comparaison).
   Fini quand : la personne a confirmé la question, en une phrase, et le cadrage ; chaque terme et chaque table du cadrage a été cherché ; la personne a reçu ce qui existe, avec l'état de relecture de chaque claim (method/claims.md, « Citer un claim »), et ce qui manque : un fait qu'aucun claim n'établit, ou des données de l'hôpital, même un seul chiffre.

Ensuite :
- si rien ne manque, répondre en citant les claims et leur état de relecture, ou préparer la routine d'un calcul à refaire (method/queries.md, « Une routine »), avec sa pull request, jusqu'à ce que la personne dise que cela lui suffit. Ce qui reste à vérifier en chemin ouvre l'enquête ;
- si quelque chose manque, ouvrir l'enquête (investigations/README.md, « La branche ») ; puis, pour chaque étape de son plan, research pour un document, relay pour des données de l'hôpital.
