---
review: unreviewed
id: chu-rouen-sans-medecine-nucleaire
kind: empirical
author: Pierre
statement: "Le CHU de Rouen (ETA_NUM 760780239) ne fait pas de médecine nucléaire dans le PMSI du SNDS : en 2024, aucun acte de médecine nucléaire en consultation externe, et en séjour seulement ZZQL008, qui n'en est pas, et des détections isotopiques au bloc (ZZQL010, ZZQL013) ; la médecine nucléaire de ses patients se cherche dans les autres établissements."
scope: "PMSI MCO du SNDS, portail de la Cnam, profil 108, année 2024 (T_MCO24A, T_MCO24FMSTC), ETA_NUM 760780239"
refuted_if: "pour une année du PMSI, le CHU (760780239) a au moins 10 actes de scintigraphie ou de TEP (__QL% hors ZZQL008, ZZQL010, ZZQL013, ZZQL021) ou de la liste de médecine nucléaire thérapeutique, en séjour ou en consultation externe"
maturity: observed
lifecycle: active
terms: [pmsi:medecine-nucleaire, pmsi:acte-ccam, snds:table-pmsi-annuelle]
tables: [snds:T_MCOaaA, snds:T_MCOaaFMSTC]
supported_by: [20261116-snds-mn-codes-resultat]
depends_on: [mn-diagnostique-ccam-ql-faux-positifs]
---
## Pour s'en servir

Pour une question sur la médecine nucléaire des patients du CHU, ne pas la chercher dans ses séjours ou ses consultations externes : lire les actes des autres établissements (codes : mn-diagnostique-ccam-ql-faux-positifs, mn-therapeutique-liste-sae-pas-nl) pour les patients du CHU. Un acte ZZQL008, ZZQL010 ou ZZQL013 au CHU n'est pas une prise en charge en médecine nucléaire au CHU.

## Ce qui l'appuie

En 2024, le motif __QL% et la liste de RIV ne trouvent au CHU que trois codes, tous en séjour : ZZQL008 (142 actes), ZZQL010 (56) et ZZQL013 (<10) ; aucun en consultation externe (20261116-snds-mn-codes-resultat). La même requête trouve des dizaines de codes de scintigraphie, de TEP et de RIV dans un autre établissement de la région, en séjour et en consultation externe (ZZQL016, TEP du corps entier : 15331 actes externes), ce qui montre que les tables et le motif fonctionnent. ZZQL008 n'est pas de la médecine nucléaire, et ZZQL010 est un geste complémentaire du chirurgien (mn-diagnostique-ccam-ql-faux-positifs) ; ZZQL013 comprend une injection radio-isotopique, qui peut être faite par une équipe de médecine nucléaire extérieure.

Points ouverts : une seule année (2024) lue ; les comptes portent sur des actes, sans filtre sur l'activité (ZZQL010 en activité 4 compte en double).
