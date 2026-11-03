---
review: unreviewed
id: historique-rattachement-uf-um-cora
kind: empirical
author: Pierre
statement: "Dans CORA, le rattachement UF-UM est presque fixe (TB_UNITE_M_UNITE suffit : seules 5 UF ont changé d'UM selon TB_HIST_UNITE_M_UNITE), mais 77 UF ont un lien sans DATE_DEBUT et 4 UF pointent vers une UM absente de TB_UNITE_MEDICALE : ne pas filtrer ces liens sur DATE_DEBUT, et compter à part les 4 UF sans UM connue."
scope: "CORA de production (CWPROD, schéma CORA_REC), TB_UNITE_M_UNITE, TB_HIST_UNITE_M_UNITE, TB_HIST_UNITE, UF de TB_UNITE, lus le 2026-11-03"
refuted_if: "plus de 20 UF ont plus d'une UM dans l'historique de TB_HIST_UNITE_M_UNITE, ou aucune UF n'a de lien sans DATE_DEBUT (script 20261027-structure-historique-cora)"
maturity: observed
lifecycle: active
terms: [cora:uf, cora:um]
tables: [cora:TB_UNITE_M_UNITE, cora:TB_HIST_UNITE_M_UNITE, cora:TB_HIST_UNITE, cora:TB_UNITE, cora:TB_UNITE_MEDICALE]
supported_by: [20261027-structure-historique-cora-resultat, 20261026-schemas-candidats-colonnes-resultat, 20261026-structure-fichier-vs-cora-resultat]
depends_on: [joindre-uf-par-code]
---
## Pour s'en servir

- **Passer d'une UF à son UM :** TB_UNITE_M_UNITE (table courante) suffit pour une analyse de 2022 à 2025 : l'historique TB_HIST_UNITE_M_UNITE n'apporte un autre rattachement que pour 5 UF. Garder l'historique pour vérifier une UF qui change d'UM, pas pour tout le monde.
- **Ne pas écrire** `DATE_DEBUT <= date AND (DATE_FIN IS NULL OR DATE_FIN >= date)` sans traiter DATE_DEBUT vide : 77 UF ont un lien sans date de début, elles disparaîtraient de la jointure.
- **Compter à part** les 4 UF dont le lien porte sur une UM absente de TB_UNITE_MEDICALE, et les UF sans lien (592 des 838 UF de TB_UNITE n'avaient aucune UM en cours au 2026-10-09, 20261026-structure-fichier-vs-cora-resultat).
- **Historique des états d'une UF :** TB_HIST_UNITE garde des états successifs (colonnes de TB_UNITE plus DATE_INFO, TYPE_INFO, ID_INFO) : 762 des 839 UF de TB_UNITE ont au moins deux états. La dernière DATE_INFO d'une UF n'est pas une date de fermeture : ne pas la présenter comme telle. La date de fermeture d'une UF n'est pas une colonne de TB_UNITE (seulement ACTIF).

## Ce qui l'appuie

Script 20261027-structure-historique-cora (20261027-structure-historique-cora-resultat) : 282 UF ont un lien courant, 283 un lien dans l'historique ; 276 UF ont tous leurs liens courants retrouvés dans l'historique ; 6 ont un lien courant absent de l'historique et 7 un lien historique sans lien courant. 284 UF n'ont qu'une UM au fil du temps, 5 en ont deux, aucune trois. TB_HIST_UNITE : 839 codes pour 839 UF de TB_UNITE, 1 code absent de TB_UNITE. Les colonnes de TB_HIST_UNITE_M_UNITE (ID_UNITE, ID_UNITE_MED, DATE_DEBUT, DATE_FIN et des champs d'autorisation) viennent du catalogue (20261026-schemas-candidats-colonnes-resultat).

Points ouverts : ce que signifient TYPE_INFO et ID_INFO n'est pas lu ; les 77 liens sans date n'ont pas été comparés à une date de création.
