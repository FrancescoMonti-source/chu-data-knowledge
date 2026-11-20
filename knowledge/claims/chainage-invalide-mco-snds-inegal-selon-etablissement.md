---
review: unreviewed
id: chainage-invalide-mco-snds-inegal-selon-etablissement
kind: empirical
author: Pierre
statement: "Dans le PMSI MCO du SNDS, le filtre de chaînage retire environ 1 % des séjours depuis 2020 (1,3 à 2,2 % de 2009 à 2019, 10,8 % en 2008), surtout pour NIR_RET = 2, mais très inégalement selon l'établissement et le patient (plus de 50 % des séjours dans une vingtaine d'établissements, davantage chez les 18-64 ans et les nouveau-nés) : une comparaison entre établissements, territoires ou classes d'âge faite sur les seuls chaînages valides est biaisée."
scope: "PMSI MCO du SNDS, tables T_MCOaaB et T_MCOaaC de 2008 à 2025, tous établissements, portail de la Cnam, profil 108, exécution du 2026-11-20"
refuted_if: "sur une année depuis 2020, la part de séjours invalides dépasse 3 %, ou aucun établissement de plus de 1000 séjours n'a plus de 20 % de séjours invalides"
maturity: observed
lifecycle: active
terms: [snds:chainage-invalide, snds:table-pmsi-annuelle, snds:profil-108]
tables: [snds:T_MCOaaB, snds:T_MCOaaC]
supported_by: [20261120-snds-chainage-invalide-mco-resultat, 20261120-spf-taux-codes-retour-mco, 20261120-snds-chainage-invalide-profil-nir-v2-resultat]
depends_on: [filtre-chainage-snds-patients-pas-activite]
---
## Pour s'en servir

Quand une analyse par patient impose le filtre de chaînage (filtre-chainage-snds-patients-pas-activite) et qu'elle compare des établissements, des territoires ou des classes d'âge :

- donner, par groupe comparé, la part de séjours retirés par le filtre ; au-delà de quelques pour cent dans un groupe, le signaler ;
- ne pas classer un établissement ou un territoire sur ses seuls chaînages valides sans ce contrôle : certains perdent plus de la moitié de leurs séjours ;
- en 2008, ne pas appliquer DAT_RET sans regarder ce qu'il retire : 1,75 million de séjours ont DAT_RET = 1, surtout en GHM 90.

## Ce qui l'appuie

La requête 20261120-snds-chainage-invalide-mco compte tous les séjours de T_MCOaaB de 2008 à 2025 avec leur ligne de T_MCOaaC (20261120-snds-chainage-invalide-mco-resultat). Part des séjours invalides : 10,8 % en 2008, 2,2 % en 2009, puis une baisse lente jusqu'à 1,3 % en 2019, et de 0,9 à 1,2 % de 2020 à 2025 (0,94 % en 2025, 341 316 séjours). Sur NIR_RET, la part concorde avec le guide de Santé publique France (1,15 % en 2019 des deux côtés, 20261120-spf-taux-codes-retour-mco).

En 2025, parmi les séjours invalides : NIR_RET = 2 seul 61 %, NIR_RET = 1 seul 15 %, NIR_RET = 3 seul 11 %, COH_NAI_RET = 1 seul 6 %, et 5 % ont NIR_RET à SEJ_RET à 9 avec FHO_RET = 1 et PMS_RET = 1. En 2008, DAT_RET = 1 seul fait 64 % des invalides, et 97 % des séjours en GHM 90 sont invalides.

Établissements : en 2025, 1215 des 1890 ETA_NUM ont au moins un séjour invalide, 26 en ont plus de 10 % et 22 plus de 50 % ; l'établissement médian (au moins 100 séjours) en a 0,14 %. Les 10 premiers portent 30 % des séjours invalides, et il en faut 196 pour atteindre 80 %. Le FINESS 980500003 a 59,5 % de séjours invalides (NIR_RET = 2) ; 750712184 (AP-HP) en a 37 446, soit 2,5 % de son activité. Au CHU de Rouen (760780239), la part va de 0,3 à 1,4 % selon l'année, presque toujours NIR_RET = 2.

Patients : en 2025, 1,2 % chez les 18-64 ans contre 0,5 % chez les 65 ans et plus ; 3,9 % chez les nouveau-nés (CMD 15) et quand l'âge est inconnu ; 51 % des prestations inter-établissements (SEJ_TYP = B). Les séjours NIR_RET = 2 résident plus souvent hors de France (département 99, 13 %), en 9F (10 %), à Paris et en Seine-Saint-Denis (20261120-snds-chainage-invalide-profil-nir-v2-resultat) : exclure les chaînages invalides retire surtout ces territoires.

Points ouverts : le sens de chaque valeur de NIR_RET n'est pas lu ; que NIR_RET = 2 corresponde à l'AME ou aux NIR provisoires vient de la fiche AME du HDH (20261120-hdh-ame-codes-retour) et n'est pas testé dans les données ; l'identité de 980500003 n'est pas vérifiée dans le référentiel FINESS.
