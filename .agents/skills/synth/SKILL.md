---
name: synth
description: "Générer des lignes synthétiques (RSS, séjours, bloc, actes, RHS) pour exécuter et tester du code d'analyse ou de requête quand CORA ou OpRoom ne sont pas accessibles. Utiliser dès qu'un code a besoin de données pour tourner, avant d'écrire un jeu de données à la main. Jamais pour répondre à une question sur l'hôpital."
---

# synth

Le générateur : tools/synth/ (README.md : réglages, ce qui est mesuré ou supposé, ajout d'une source). Il sert à faire tourner du code. Ses lignes ne disent rien de l'hôpital.

1. **Décider.** Le code a-t-il besoin de lignes pour s'exécuter ou se tester (une requête Python, un calcul, un rapport, un test) ? Alors continuer. Si la question demande un chiffre de l'hôpital, il vient d'une requête que la personne exécute (relay), jamais d'ici.
   Fini quand : l'usage est « tester du code ».
2. **Lister puis générer.** `python tools/synth/generate.py --list` donne les tables et leurs colonnes (les noms de CORA ou d'OpRoom, sauf les tables préfixées SYNTH_, qui n'existent pas à l'hôpital : ne pas les lire dans le code livré ; un nom ou une colonne que ni CDK ni la liste ne donne reste à vérifier). Puis, avec la graine par défaut et un volume qui suffit (`--scale 0.02` ; `--perimeter fme` pour des UF d'un pôle) :
   `python tools/synth/generate.py --out <dossier hors dépôt> --years 2022-2025 --families rss`
   Dans un test Python : `synth.generate(...)` (README.md, « Utiliser »). Ne pas écrire de générateur à côté : s'il manque une table ou une colonne, le dire à la personne et proposer l'ajout (README.md, « Ajouter une source »).
   Fini quand : les CSV et manifest.json existent hors du dépôt, avec une graine écrite dans le code ou le README de l'étude.
3. **Lire le manifeste** avant de s'appuyer sur une propriété des données. Ce qui est dans `assumptions` n'est pas mesuré : ne pas en conclure ce que fait l'hôpital, et ne pas régler un seuil dessus.
   Fini quand : chaque propriété dont le code dépend est mesurée, ou notée comme supposée.
4. **Écrire et tester le code sur ces lignes.** Pour un code qui sort des agrégats : le masquage < 10 se teste ici (le jeu contient des petits effectifs exprès) ; la sortie du code ne contient aucun effectif de 1 à 9 (method/queries.md, règles 1, 3 et 4).
   Fini quand : le code tourne sur les lignes générées et son test passe.
5. **Étiqueter.** Tout résultat calculé sur ces lignes porte « synthétique » : dans la réponse à la personne, dans le README de l'étude, sur une figure. Ne jamais les mettre dans un claim, une preuve, un résultat d'enquête ou un rapport livré. Ne pas committer les lignes générées.
   Fini quand : la réponse dit que les chiffres sont synthétiques et ce que le test a vérifié (le code, pas l'hôpital).

Ensuite : le code attend la vraie exécution par la personne (relay pour une requête de CDK ; la commande d'exécution de DIM-code).
