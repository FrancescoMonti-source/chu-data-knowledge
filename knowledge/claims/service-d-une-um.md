---
review: unreviewed
id: service-d-une-um
kind: empirical
author: Pierre
statement: "Au CHU, une UM de CORA tient dans un seul service du fichier Structure : pour donner un service à un RUM (qui porte une UM, pas une UF de service), passer par les UF liées à son UM dans TB_UNITE_M_UNITE puis lire leur service dans le fichier ; vrai pour les 234 UM qui ont une UF dans le fichier, sur 281 UM."
scope: "CORA de production (CWPROD, schéma CORA_REC), TB_UNITE_M_UNITE sans filtre de dates, fichier Structure du 2026-10-09 (une seule version), lus le 2026-11-03"
refuted_if: "une UM dont les UF liées dans TB_UNITE_M_UNITE et présentes dans le fichier ont deux Code Service différents (mesure UM_ET_SERVICE_DU_FICHIER_LIENS_COURANTS du script 20261027-structure-historique-cora)"
maturity: observed
lifecycle: active
terms: [cora:um, cora:uf, structure:service]
tables: [cora:TB_UNITE_M_UNITE, cora:TB_UNITE_MEDICALE, cora:TB_UNITE]
supported_by: [20261027-structure-historique-cora-resultat]
depends_on: [service-et-pole-depuis-fichier-structure, uf-du-rum-hebergement]
---
## Pour s'en servir

Pour le service d'un RUM, deux chemins :

1. Par l'UF d'hébergement du RUM (uf-du-rum-hebergement), puis son service dans le fichier (service-et-pole-depuis-fichier-structure). C'est le chemin direct.
2. Par l'UM du RUM (TB_SYNTH_RUM.ID_UNITE_MEDICALE), quand on veut un service par UM : prendre les UF liées à l'UM dans TB_UNITE_M_UNITE, garder celles qui sont dans le fichier, lire leur Code Service. Les 234 UM de ce cas n'ont qu'un service ; pas besoin de choisir.

Ne pas filtrer ce lien sur DATE_DEBUT <= date : 77 UF ont un lien sans date de début (historique-rattachement-uf-um-cora), le filtre les perdrait. Compter à part, et dire, les UM sans UF dans le fichier (47 sur 281).

La relation inverse n'est pas une identité : un service regroupe une ou plusieurs UM (sur 72 services du fichier qui ont des UM, 25 en ont une, 13 en ont deux, 34 en ont trois ou plus). Ne pas déduire le service d'une UM par son libellé ni par son code.

## Ce qui l'appuie

Script 20261027-structure-historique-cora, lecture de TB_UNITE_M_UNITE (liens courants) contre le fichier du 2026-10-09 (20261027-structure-historique-cora-resultat) : 234 UM ont au moins une UF dans le fichier ; 5 de ces UM en ont deux ou plus ; les 234 sont dans un seul service, 231 dans un seul pôle (les 3 autres n'ont pas de pôle dans le fichier). Avec les liens de tous les temps (TB_HIST_UNITE_M_UNITE en plus) : 238 UM ; 4 sont sur deux services, 3 sur deux pôles ou plus, ce qui vient des 5 UF qui ont changé d'UM.

Points ouverts : une seule version du fichier, donc rien sur un service qui aurait changé de contenu avant le 2026-10-09 ; 47 UM n'ont aucune UF dans le fichier, leur service n'est pas établi.
