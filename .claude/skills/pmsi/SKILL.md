---
name: "pmsi"
description: "Répondre à une question sur une règle du PMSI ou sur la facturation hospitalière (groupage, DP et DAS, GHM et GHS, actes CCAM, ACE, NGAP, forfaits, définitions d'activité comme hospitalisation complète, partielle ou séance), en citant la source de la bonne campagne. Utiliser quand la demande ou une étape du plan porte sur ce que dit un texte ou un référentiel, sans donnée du CHU. Une question sur les données du CHU commence par frame."
---

# pmsi

Le PMSI change chaque année : une règle vaut pour une campagne. Les documents ont leur fiche dans sources/ (formats : method/evidence.md).

1. **Cadrer la règle.** Écrire en une ligne la date du séjour ou de l'acte, la campagne qui s'applique, le champ (MCO ; HAD, SMR et psychiatrie seulement si la personne le demande) et le type de question : codage et groupage, facturation (ACE, NGAP, CCAM, forfaits), ou définition d'activité pour un comptage (hospitalisation complète, partielle, de semaine, séance). Une question mixte donne deux réponses, aux conclusions séparées. Un cas se décrit sans donnée de personne (method/privacy.md) : son profil, jamais un dossier.
   Fini quand : cette ligne est dans la réponse.
2. **Chercher la source,** par rang : (1) les textes en vigueur à la date (Légifrance : lois, décrets, arrêtés, décisions de l'UNCAM publiées au Journal officiel) ; (2) les référentiels officiels de l'année (ATIH : guide méthodologique, manuel des GHM, CIM-10-FR, CCAM, notice technique ; Assurance Maladie : NGAP, CCAM, NABM ; DREES : aide au remplissage de la SAE, pour compter des séjours, des journées ou des séances par mode d'hospitalisation à partir du PMSI) ; (3) les guides et circulaires, utiles mais non opposables ; (4) les relais et tutoriels, pour repérer seulement. Prendre la fiche dans sources/ ; si elle manque, research la crée.
   Fini quand : chaque règle citée vient d'une source de rang 1 ou 2, ou porte la mention « guide, non opposable » ou « non vérifiée ».
3. **Lire le passage** dans l'édition de la campagne, puis citer l'édition, l'endroit exact et la date d'application. Une règle trouvée seulement dans une édition plus ancienne est « non confirmée pour la campagne ». Un site qui refuse la lecture est « non vérifié ».
   Fini quand : chaque citation a son édition et son endroit exact.
4. **Facturation : conclure par étage.** Séparer : l'acte est codable ; l'acte est facturable dans ce cas ; le tarif ; la transmission dans le circuit local de l'établissement. Pour « facturable », vérifier ensemble le champ de la prise en charge, le professionnel qui a réalisé l'acte, la prescription, la trace dans le dossier, le cumul avec les autres actes de la séance et le circuit local : un code présent dans la nomenclature ne prouve pas qu'on peut le facturer. Étiquettes : *facturable* (toutes les conditions tiennent, source à l'appui), *facturable sous conditions* (les lister), *non facturable* (citer la disposition), *indéterminé* (dire le fait ou la règle qui manque). Un cas « plausible » reste indéterminé.
   Fini quand : chaque étage a sa conclusion ou « indéterminé », et aucun montant n'est donné sans version et date vérifiées.
5. **Répondre.** La conclusion d'abord, en deux à quatre phrases ; puis les conditions qui la décident, la source, ce qui reste à confirmer. Ce qu'une source dit déjà ne devient pas un claim (method/claims.md, « Ce qui mérite un claim ») ; une règle dont un claim sur les données a besoin devient une preuve (research).

Ensuite : research pour enregistrer la règle comme preuve, quand une enquête s'en sert.