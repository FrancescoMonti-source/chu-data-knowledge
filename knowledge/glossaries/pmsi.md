# Glossaire PMSI

Les termes du contexte pmsi. Un titre par terme (## pmsi:terme), puis la définition en français. Règles : method/layout.md, « Termes et glossaires ».

## pmsi:envoi

Alias : envoi, envois, transmission, M1, M2, M3, M4, M5, M6, M7, M8, M9, M10, M11, M12

La transmission des données PMSI d'un établissement à l'ATIH, sur la plateforme e-PMSI. En MCO, elle se fait chaque mois et cumule l'année : l'envoi M8 porte les RSS sortis de janvier à août.

## pmsi:smr

Alias : SMR, SSR, soins médicaux et de réadaptation, soins de suite et de réadaptation

L'activité de soins médicaux et de réadaptation, nommée soins de suite et de réadaptation (SSR) avant son renommage. Dans CORA, ses séjours gardent la valeur `SSR` de TB_SEJOUR.TYPE_SEJOUR.

## pmsi:groupage

Alias : groupeur, version de groupage, VERSION

L'opération qui range un RSS dans un GHM, puis un GHS, d'après ses diagnostics, ses actes, l'âge, la durée et le mode de sortie, selon une version de la classification et de ses tarifs. Dans CORA, la version utilisée par un RSS est TB_SYNTH_RSS.VERSION.

## pmsi:ghm

Alias : GHM, groupe homogène de malades, CODE_GHM, CODE_CMD

La classe de la classification PMSI dans laquelle le groupage range un RSS : la catégorie majeure de diagnostic (CMD, 2 chiffres), puis une lettre de type (C chirurgical, K acte non opératoire, M médical, Z indifférencié), un numéro de racine et un niveau en dernier caractère (de 1 à 4 pour la sévérité ; J, T, Z et d'autres lettres pour les cas particuliers). Dans CORA, CODE_GHM ne porte que type, numéro et niveau ; la CMD est dans CODE_CMD.

## pmsi:mode-entree-sortie

Alias : mode d'entrée, mode de sortie, MODE_ENTREE, MODE_SORTIE

Le code PMSI qui dit comment un séjour commence ou finit : mutation (6, dans le même établissement), transfert (7, vers ou depuis une autre entité juridique), domicile (8), décès (9, en sortie). Un mode 6 ou 7 se complète d'une provenance ou d'une destination.

## pmsi:provenance-destination

Alias : provenance, destination, CODE_PROVENANCE, CODE_DESTINATION

Le code PMSI qui précise d'où vient un séjour (provenance) ou où va le patient (destination) quand le mode d'entrée ou de sortie est une mutation ou un transfert. Pour la destination, d'après le dictionnaire CORA 2020 : 1 court séjour, 2 SSR (SMR), 3 soins de longue durée, 4 psychiatrie, 6 hospitalisation à domicile, 7 structure d'hébergement médico-social ; pour la provenance, 5 est un service d'urgence.

## pmsi:htp

Alias : HTP, hospitalisation à temps partiel, hospitalisation de jour en SMR, HDJ SMR

L'hospitalisation à temps partiel de jour en SMR. Son groupe de réadaptation (très intense I, intense J, modérée K, indifférenciée L, pédiatrique H) se décide sur le score de réadaptation par jour de la semaine ; elle est valorisée par journée de présence (ATIH, manuel des GME, notice technique de financement SMR).
