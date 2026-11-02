---
review: unreviewed
id: uf-urgences-par-service-structure
kind: decision
author: Pierre
statement: "Au CHU, les UF d'urgences adultes se repèrent par le fichier Structure : ce sont les UF du service « ACCUEIL ET URGENCES » (code service 5700), 15 UF au fichier du 2026-10-09 ; les urgences pédiatriques (5010, 5015, 8000, 8014) forment le service 5730 et les UF d'urgences de spécialité (5654 neurologie, 8005 gynécologie obstétrique) sont rattachées à leur spécialité : les ajouter seulement si la question le demande."
scope: "CHU de Rouen, fichier Structure mis à jour le 2026-10-09 (une seule version lue) ; le service d'une UF à une date passée n'est pas établi"
responsible: Pierre
reconsider_when: "une version plus ancienne du fichier montre que le service des UF d'urgences a changé ; une question porte sur les urgences pédiatriques, neurologiques ou gynécologiques ; le contrôle de gestion renomme ou redécoupe le service 5700"
maturity: documented
lifecycle: active
terms: [structure:service, structure:uf, cora:passage-urgences]
tables: []
supported_by: [20261027-decision-urgences-structure, 20261027-structure-uf-urgences]
depends_on: [service-et-pole-depuis-fichier-structure, drapeau-urgence-uf-non-fiable]
---
## Pour s'en servir

Pour « les urgences », « l'entrée par les urgences » ou « hors urgences » :

1. Rattacher le mouvement à son UF par son code (joindre-uf-par-code), puis lire le code service de cette UF dans le fichier Structure (service-et-pole-depuis-fichier-structure).
2. Prendre comme UF d'urgences celles dont le code service est 5700. Ne plus partir du drapeau URGENCE de TB_UNITE (drapeau-urgence-uf-non-fiable), ni d'une liste d'UF écrite à la main, ni du libellé de l'UF.
3. Dire le service retenu et la date du fichier (« service 5700 du fichier Structure du 2026-10-09 »). Si la question touche les enfants, ajouter le service 5730 ; pour la neurologie ou la gynécologie obstétrique, ajouter 5654 ou 8005 en le disant.

Un passage compte comme urgences par l'UF d'un mouvement du séjour, pas par un champ du séjour (sejour-sans-signal-urgences).

## Ce qui l'appuie

Pierre a retenu le service « ACCUEIL ET URGENCES » comme repère des UF d'urgences dans l'étude DIM-code de la cardiologie, à la place du repérage par libellé (20261027-decision-urgences-structure). Cette règle répond à la question de #30, restée sans méthode (drapeau-urgence-uf-non-fiable).

Le fichier Structure donne, pour le service 5700, 15 UF : 5700, 5701, 5703, 5705, 5709, 5717, 5720, 5802, 5851, 5852, 5853, 8007, 8009, 8012 et 8013. Il couvre les UF qui reçoivent les passages adultes (5701, 5802, 5709, 5720 ; 5705, 8012 et 8013 aussi). L'ancienne liste provisoire de 14 UF (#30) contenait en plus les urgences pédiatriques (5010, 5015, 8000, 8014, service 5730), l'UF d'urgences neurologiques 5654 (service 5650 NEUROLOGIE) et 8005 (service 6160), qui ne sont pas dans le service 5700 (20261027-structure-uf-urgences). Le service 5700 contient aussi des UF qui ne sont pas des lits : consultations (CS : 5703, 8007, 8009, 8012, 8013), unité de crise (5717) et plan blanc (5851 à 5853).

Points ouverts : la décision ne distingue pas les UF d'hospitalisation des UF de consultation du service 5700 ; une seule version du fichier a été lue, donc l'ancienne organisation des urgences (qui a changé vers 2020) n'est pas couverte ; la comparaison avec le repérage par libellé n'est pas enregistrée dans une preuve.
