---
review: unreviewed
id: date-et-heure-dans-deux-colonnes
kind: empirical
author: Pierre
statement: "Dans CORA, DATE_ENTREE, DATE_SORTIE, DATE_DEBUT_MVT, DATE_FIN_MVT et DATE_ACTE sont à minuit : l'heure est dans la colonne HEURE_* associée, qui est un horodatage complet du même jour ; pour un instant ou une durée en heures, prendre HEURE_*, et la différence de deux DATE_* ne donne que des jours entiers."
scope: "CORA de production (CWPROD, schéma CORA_REC), TB_SEJOUR, TB_MVT et TB_ACTE, lignes datées de 2018 à octobre 2026, lu le 2026-10-19"
refuted_if: "plus de 1 % des DATE_SORTIE d'une année ont une heure différente de 00:00:00, ou plus de 1 % des HEURE_* renseignées d'une année portent un autre jour que la DATE_* associée"
maturity: observed
lifecycle: active
terms: [cora:sejour, cora:mouvement, cora:acte]
tables: [cora:TB_SEJOUR, cora:TB_MVT, cora:TB_ACTE]
supported_by: [20261019-date-heure-colonnes-resultat, 20261019-catalogue-types-colonnes-g3-resultat]
depends_on: []
---
## Pour s'en servir

- **Instant :** prendre `HEURE_ENTREE`, `HEURE_SORTIE`, `HEURE_DEBUT_MVT`, `HEURE_FIN_MVT` ou `HEURE_ACTE` tel quel : c'est un DATE Oracle qui porte le jour de la DATE_* associée et l'heure. Ne pas y chercher une date fictive (1899, 1900) : il n'y en a pas. Si on préfère partir de la DATE_*, `TRUNC(DATE_x) + (HEURE_x - TRUNC(HEURE_x))` donne le même instant.
- **Durée en heures (DMS fine, délai) :** soustraire deux HEURE_*, pas deux DATE_*.
- **Durée en jours :** soustraire les DATE_* donne des jours entiers ; le TRUNC est neutre.
- **Heure à 00:00:00 :** une HEURE_* peut valoir minuit exactement sans que l'événement ait eu lieu à minuit. La part est faible pour les entrées et les débuts de mouvement et les actes, plus forte pour les sorties récentes (voir ci-dessous) : la dire quand une durée en heures dépend des sorties.

## Ce qui l'appuie

Types (20261019-catalogue-types-colonnes-g3-resultat) : toutes les colonnes DATE_* et HEURE_* de TB_SEJOUR, TB_MVT et TB_ACTE sont de type DATE (7 octets).

Lignes par année de la date (20261019-date-heure-colonnes-resultat), pour DATE_ENTREE et DATE_SORTIE de TB_SEJOUR, DATE_DEBUT_MVT et DATE_FIN_MVT de TB_MVT, DATE_ACTE de TB_ACTE, de 2018 à 2026 :

- moins de 10 DATE_* par année portent une heure non nulle, pour chaque colonne (plusieurs centaines de milliers de lignes par année et par colonne) ;
- quand l'effectif est visible, 100 % des HEURE_* renseignées portent le même jour que la DATE_* ; moins de 10 portent une date avant 1950 ;
- HEURE_* à une heure autre que minuit : plus de 99,6 % pour les entrées, et plus de 99,6 % pour les débuts de mouvement ; plus de 99,9 % pour les actes ; pour les sorties 98,5 % en 2023 (832 918 sur 845 368), 97,6 % en 2025 (869 325 sur 891 061) et 95,9 % en 2026 (716 290 sur 747 011), soit 1,5 %, 2,4 % et 4,1 % de sorties à minuit (99,9 % ou plus de 2018 à 2022 et en 2024, soit moins de 0,1 % à minuit) ; pour la fin de mouvement 99,1 % en 2023 (907 633 sur 916 078), 97,8 % en 2025 (949 698 sur 971 500) et 96,3 % en 2026 (809 203 sur 839 968). Les autres pourcentages sont calculés sur les lignes de l'année, au plus bas pour les entrées 99,65 % en 2023 (855 696 sur 858 680) et pour les débuts de mouvement 99,68 % en 2023 (930 431 sur 933 448).

Le dictionnaire 2020 donne déjà DATE_ACTE « sans les heures » et HEURE_ACTE « date et heure de réalisation » ; les mesures l'étendent aux séjours et aux mouvements et lèvent le doute sur une date fictive.

Points ouverts : les interventions (TB_INTERVENTION) et OpRoom, non mesurés ici ; la cause des sorties à minuit en 2023, 2025 et 2026 ; les lignes dont HEURE_* est vide ou d'un autre jour que la DATE_* : aucune là où les effectifs visibles sont égaux, moins de 10 (effectif masqué) pour DATE_ACTE en 2018, 2021, 2023 et 2025 et pour DATE_FIN_MVT en 2019 et 2020, dont le nombre de lignes est lui-même masqué.
