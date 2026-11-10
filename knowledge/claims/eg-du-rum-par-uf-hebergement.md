---
review: unreviewed
id: eg-du-rum-par-uf-hebergement
kind: empirical
author: Francesco
statement: "Dans CORA, l'entité géographique (le site) d'un RUM se lit par son UF d'hébergement : TB_SYNTH_RUM.ID_UNITE_HEBERG = TB_EG_UNITE.ID_UNITE, puis TB_EG ; chaque UF y a une seule EG, et presque tous les RUM en trouvent une. TB_SYNTH_RSS.ID_ETABLIS, vide, ne donne pas le site."
scope: "CORA de production (CWPROD, schéma CORA_REC), TB_EG, TB_EG_UNITE, RUM des RSS groupés à deux RUM ou plus finis de 2022 à 2025, lus le 2026-11-10"
refuted_if: "une UF a plusieurs EG dans TB_EG_UNITE, ou plus de 0,1 % des RSS à deux RUM ou plus d'une année ont un RUM dont ID_UNITE_HEBERG ne trouve pas d'EG, ou TB_SYNTH_RSS.ID_ETABLIS est renseigné"
maturity: observed
lifecycle: active
terms: [cora:eg, cora:rum, cora:uf, cora:rss]
tables: [cora:TB_SYNTH_RUM, cora:TB_EG_UNITE, cora:TB_EG, cora:TB_SYNTH_RSS]
supported_by: [20261110-rss-plusieurs-eg-resultat, 20261110-sejour-plusieurs-rss-etab-resultat, 20261110-sejour-plusieurs-rss-eg-resultat]
depends_on: []
---
## Pour s'en servir

Pour situer un RUM sur un site du CHU :

```sql
JOIN CORA_REC.TB_EG_UNITE eu ON eu.ID_UNITE = u.ID_UNITE_HEBERG
JOIN CORA_REC.TB_EG e ON e.ID_EG = eu.ID_EG   -- CODE_EG, LIBELLE_EG, NO_FINESS (FINESS géographique)
```

La jointure se fait par l'identifiant (ID_UNITE), pas par le code de l'UF. Aucune UF n'a deux EG, mais l'absence de doublon exact dans TB_EG_UNITE n'est pas mesurée : par prudence, passer par une sous-requête groupée par ID_UNITE, comme 20261110-rss-plusieurs-eg. Le site d'un RSS est celui de ses RUM ; un RSS peut en avoir deux (sejour-plusieurs-rss-changement-eg).

Ne pas utiliser TB_SYNTH_RSS.ID_ETABLIS : d'après le dictionnaire CORA 2020, il désigne un établissement d'une base « siège » qui consolide plusieurs établissements, et il est vide au CHU. TB_UNITE.FINESS_GEO est réservé au paramétrage de la psychiatrie.

C'est le site de l'UF d'hébergement, qui peut différer de celui de l'UM du RUM quand le patient est hébergé ailleurs. Une UM n'a pas de colonne de site : son site se déduit de ses UF (TB_UNITE_M_UNITE).

## Ce qui l'appuie

20261110-rss-plusieurs-eg-resultat : TB_EG a 6 lignes ; aucune UF de TB_EG_UNITE n'a deux EG ; 3 UF de TB_UNITE n'ont pas d'EG. Sur 38 451 à 39 358 RSS à deux RUM ou plus par an de 2022 à 2025, moins de 10 par an ont un RUM sans EG, et moins de 10 un RUM dont l'UF a plusieurs EG.

20261110-sejour-plusieurs-rss-etab-resultat : ID_ETABLIS n'a aucune valeur distincte sur les RSS testés (ETABLIS_DISTINCTS = 0, de 2022 à 2025).

Les RUM lus se répartissent sur trois sites : Charles Nicolle (HCN), Bois-Guillaume (BG) et Saint-Julien (STJ) (20261110-sejour-plusieurs-rss-eg-resultat).

Points ouverts : TB_EG_UNITE n'a pas de dates, et une UF qui aurait changé de site serait mal placée avant son déménagement ; les RSS à un seul RUM n'ont pas été testés.
