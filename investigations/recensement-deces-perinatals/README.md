# Comment retrouver dans CORA, chaque semestre, tous les décès que l'instruction RMM de 2026 demande de recenser ?

Personne : Francesco
Issue : #42

## Cadrage
But : savoir si le DIM peut retrouver dans CORA, chaque semestre, les décès à recenser pour les RMM en périnatalité, et comment les classer (IMG, mort fœtale spontanée, né vivant décédé).
Population : les décès à partir de 36+0 SA, grossesse unique : enfants nés sans vie après IMG, morts fœtales spontanées, enfants nés vivants décédés de J0 à J27, « consentis » compris (instruction-rmm-perinatalite-2026). L'exploration regarde plus large (à partir de 22 SA, toutes grossesses) pour voir ce que retire chaque filtre.
Période : 2018-2025 pour l'exploration (periode-analyse-cora-2018) ; ensuite, un semestre.
Unité d'analyse : le décès, c'est-à-dire l'enfant, né vivant ou né sans vie ; ni le séjour, ni la mère.
Mesure : effectifs par signal (code CIM-10, mode de sortie, écran périnatalité) et remplissage des variables du recensement.
Comparaison : entre signaux, pour voir lesquels se recoupent.

## Choix
- Le recensement est plus large que les cas examinés en RMM : l'extraction ne retire ni les IMG, ni les morts fœtales spontanées avant le travail, ni les décès « consentis » (Francesco, 15/10, d'après § 1.b et § 1.c de l'instruction).
- Hors périmètre pour l'instant : organisation des RMM, vérification des dossiers et certificats, corrections du codage, relevé annuel (Francesco, 15/10). Le classement avant ou pendant le travail et le repérage des cas « consentis » ne servent qu'à la priorité des RMM (§ 1.d) : on les note quand le codage les donne (extensions de P95 depuis 2019, 20261102-mortnes-p95-extensions), sans en faire une condition du recensement ; les cas « consentis » n'ont pas de code (instruction-mort-nes-pmsi-2021, annexe I, § III.3.1), l'équipe les complète depuis le dossier.
- On recense les décès survenus dans l'établissement, enfants transférés ici compris. Un enfant né ici et décédé ailleurs après un transfert reste un angle mort connu : l'instruction ne dit pas quel établissement le compte (Francesco, 02/11).
- Convention de temps : J0 est le jour de naissance, donc le « 28e jour de vie » (§ 1.b, annexe 1.2) est J27, comme « de J0 à J27 » (§ 1.c) ; l'âge au décès se compte en jours de calendrier (date du décès moins date de naissance, sans l'heure), de 0 à 27 (Francesco, 02/11 ; même découpage dans note-definitions-perinatalite-2023, annexe). Le choix entre date de sortie et TB_PATIENT.DATE_DECES ne change rien : les deux tombent le même jour pour tous les décès vus (20261102-deces-0-28-jours-resultat).
- La fiche de la source entre seule, par la PR #41, avant l'enquête.

## Conclusions
Réponse : oui, CORA retrouve les décès du recensement par le séjour de l'enfant, avec deux angles morts. Enfants mort-nés : DP P95, dont l'extension sépare IMG (P95+0) et MFS (P95+1, +2, +8), à 22 SA ou plus, ou 500 g ou plus. Enfants nés vivants décédés de J0 à J27 : séjour sorti par décès, sans P95, séjour de naissance ou non (transferts ici, réhospitalisations). Grossesse unique : côté mère, par le lien de séjour. Angles morts : les cas « consentis », sans code, et les enfants nés ici et décédés ailleurs après un transfert.

Claims, tous unreviewed :
- deces-naissance-inclut-mort-nes (unreviewed)
- mort-nes-sous-22-sa-avant-2025 (unreviewed)
- p964-encore-sur-mort-nes (unreviewed)
- lien-enfant-mere-par-no-sejour (unreviewed)
- naissance-par-date-pas-mode-n (unreviewed)

Pas de claim : TB_PERINAT vide, POID_NAISSANCE partiel, RANG_NAISSANCE vide (Francesco, 03/11) ; la forme P95+1 des codes, que donnent ensemble le texte (P95.+1, 20261102-mortnes-p95-extensions) et code-cim10-sans-point (unreviewed).
