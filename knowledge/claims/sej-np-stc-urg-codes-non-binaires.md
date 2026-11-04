---
review: unreviewed
id: sej-np-stc-urg-codes-non-binaires
kind: empirical
author: Pierre
statement: "Dans T_MCOaaB, SEJ_NP (non programmé, depuis 2022) et STC_URG (passage par une structure d'urgence, depuis 2023) ne sont pas des 0/1 : au CHU en 2025, SEJ_NP vaut 1, 2 ou reste vide (92 % vide) et STC_URG vaut 5, U, V ou reste vide (75 % vide) : ne pas filtrer sur la valeur 1 avant d'avoir établi le sens des codes."
scope: "PMSI MCO du CHU de Rouen (FINESS juridique 760780239), séjours sortis en 2025, portail SNDS, profil 108"
refuted_if: "la documentation du format ATIH du MCO donne à SEJ_NP et STC_URG des modalités 0/1 ou oui/non, ou un décompte des valeurs de T_MCO25B du CHU montre une autre répartition"
maturity: observed
lifecycle: active
terms: [snds:portail, snds:profil-108, snds:table-pmsi-annuelle]
tables: [snds:T_MCOaaB]
supported_by: [20261104-snds-valeurs-codes-mco-chu-v2-resultat]
depends_on: [tables-snds-vues-profil-108]
---
## Pour s'en servir

Avant de compter les séjours non programmés ou passés par les urgences, chercher le sens des codes dans le format ATIH du MCO de l'année, ou demander la nomenclature. Le schéma du HDH ne donne pas de nomenclature pour ces deux variables et ne les crée qu'en 2022 et 2023 : avant, elles sont absentes. En attendant, sortir les effectifs par valeur brute, sans les interpréter.

## Ce qui l'appuie

Séjours du CHU sortis en 2025 (20261104-snds-valeurs-codes-mco-chu-v2-resultat) : SEJ_NP vaut vide pour 175306 séjours, 2 pour 14010 et 1 pour 1788 ; STC_URG vaut vide pour 143913, 5 pour 44124, U pour 2441 et V pour 626. Si 1 voulait dire « non programmé », il n'y aurait que 0,9 % de séjours non programmés dans un CHU qui a des urgences : le sens n'est donc pas celui qu'on supposerait.

Points ouverts : le sens de 1, 2, U, V, 5 et du vide ; si le vide veut dire « programmé » ou « non renseigné ». Une seule année et un seul établissement.
