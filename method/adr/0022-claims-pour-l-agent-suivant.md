# 0022 — Un claim s'écrit pour l'agent qui interrogera les données

Statut : proposé, 2026-10-13 (Pierre, pendant la migration de la base de connaissances de dim-code, #24). À accepter par le mainteneur.

## Contexte

Les premiers claims de la migration (#24) ont été écrits comme des comptes rendus de mesure : « 80 à 83 % des séjours sortis n'ont pas de RSS », « 76 à 85 % des séjours d'un jour sont en 'HDJ' depuis 2021 », puis un second claim pour les séjours d'au moins une nuit. Vrais, réfutables, bien prouvés, mais peu utiles à l'agent suivant : il ne cherche pas un pourcentage, il cherche quelle variable prendre et comment classer un séjour. Un autre claim recopiait le titre d'une table du dictionnaire CORA, déjà dans sources/.

La méthode y poussait sans le vouloir :

- claims.md définit un claim comme « une affirmation sur les données », sans dire à qui il sert ;
- refuted_if et la règle « Taille » (un claim par test) récompensent l'énoncé le plus facile à tester : un chiffre, découpé par sous-population ;
- le corps ne contient que « raisonnement et limites » : aucune place pour ce qu'un agent doit faire ;
- decision cite « une façon de compter », pas une méthode : la règle d'usage n'avait pas de sorte évidente ;
- sediment contrôle les liens vers les preuves, pas l'utilité du claim ;
- frame demande une mesure et une comparaison, ce qui oriente vers le chiffre.

La base de connaissances de dim-code avait une section « Comment l'appliquer » dans chaque fiche ; elle s'est perdue dans la traduction.

## Décision

- claims.md dit qu'un claim s'écrit pour l'agent suivant, et ajoute « Ce qui mérite un claim » : un claim entre s'il contredit une source, s'il dit ce qu'aucune source ne dit et qui change la façon d'interroger, ou s'il pose une décision. Pas de claim qui recopie une source ; pas de claim pour une mesure qui n'oriente aucun usage (elle reste dans l'issue).
- statement est dit pour qui interroge les données ; les chiffres vont dans le corps.
- « Taille » : un claim par usage, pas un claim par chiffre. Une méthode adoptée à la suite d'un constat est un claim decision qui dépend du constat empirical.
- decision couvre aussi une méthode pour reconstruire ce qu'une variable ne donne pas.
- Le corps a deux sections : « Pour s'en servir », puis « Ce qui l'appuie » (raisonnement, chiffres, limites, points ouverts).
- sediment demande, avant d'écrire, ce que l'agent suivant fera du résultat ; frame fait dire au but ce que la réponse permettra de faire avec les données.

## Raisons

- Le dépôt sert d'abord à l'agent suivant (AGENTS.md, « Pourquoi ce dépôt ») : un claim qui ne lui dit pas quoi faire l'oblige à refaire l'interprétation.
- Le statement reste réfutable : « TYPE_SEJOUR ne permet pas de classer les séjours » se réfute par une valeur constante dans le temps.
- Séparer constat et méthode garde la falsifiabilité du constat et rend la méthode révisable par reconsider_when.

## Alternatives

- **Un champ use dans l'en-tête :** visible par grep, mais une méthode en plusieurs étapes ne tient pas dans une ligne d'en-tête ; la section du corps suffit, et l'empreinte la couvre déjà.
- **Un contrôle qui exige la section « Pour s'en servir » :** possible plus tard ; pour l'instant, règle de confiance.

## Conséquences

- Les claims d'avant ce choix (aucun sur main) n'ont pas à être repris.
- Le contrôle ne vérifie pas la présence ni la qualité de « Pour s'en servir » : règle de confiance.
