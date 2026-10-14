---
review: unreviewed
id: joindre-uf-par-code
kind: empirical
author: Pierre
statement: "Dans CORA, chaque code d'UF a une seule ligne dans TB_UNITE, et TB_SEJOUR.UF_ENTREE comme TB_MVT.ID_UNITE_M portent ce code : une jointure sur TRIM(CODE_UNITE) retrouve une ligne et une seule pour tous les séjours et tous les mouvements depuis 2018 (sauf moins de 10 séjours en 2019), alors que TB_MVT.ID_UNITE_M ne correspond à aucun identifiant (TB_UNITE.ID_UNITE, TB_UNITE_MEDICALE.ID_UNITE_MED)."
scope: "CORA de production (CWPROD, schéma CORA_REC), thésaurus TB_UNITE, séjours entrés et mouvements commencés de 2018 à 2025, lus le 2026-10-14"
refuted_if: "un code d'UF a plusieurs lignes dans TB_UNITE, ou plus de 0,1 % des séjours ou des mouvements d'une année ne trouvent aucune ligne de TB_UNITE par TRIM(CODE_UNITE)"
maturity: observed
lifecycle: active
terms: [cora:uf, cora:sejour, cora:mouvement]
tables: [cora:TB_UNITE, cora:TB_UNITE_MEDICALE, cora:TB_SEJOUR, cora:TB_MVT]
supported_by: [20261014-unicite-code-uf-resultat, 20261014-mvt-code-uf-resultat]
depends_on: []
---
## Pour s'en servir

Pour obtenir l'UF d'un séjour ou d'un mouvement et ses attributs (libellé, drapeaux), joindre TB_UNITE par le code, comparé après TRIM :

```sql
JOIN CORA_REC.TB_UNITE u ON TRIM(u.CODE_UNITE) = TRIM(s.UF_ENTREE)     -- séjour
JOIN CORA_REC.TB_UNITE u ON TRIM(u.CODE_UNITE) = TRIM(m.ID_UNITE_M)    -- mouvement
```

La jointure ne duplique aucune ligne : pas besoin de sous-requête MAX(LIBELLE_UNITE) ni de DISTINCT. Malgré son nom, TB_MVT.ID_UNITE_M n'est pas un identifiant : ne pas le joindre à TB_UNITE.ID_UNITE ni à TB_UNITE_MEDICALE.ID_UNITE_MED, qui ne donnent rien. Pour passer de l'UF à l'UM ou au pôle, partir de TB_UNITE.ID_UNITE vers TB_UNITE_M_UNITE.

Un tiers des codes de mouvement sont aussi un code d'UM (TB_UNITE_MEDICALE.CODE_UNITE_MED) : une UF et une UM portent souvent le même code. Ce n'est pas un lien : ne pas joindre l'UM par le code de l'UF.

## Ce qui l'appuie

TB_UNITE (20261014-unicite-code-uf-resultat) : les 838 codes d'UF ont chacun une ligne.

Séjours entrés de 2018 à 2025 (même preuve) : chaque année, tous les séjours trouvent une ligne de TB_UNITE par leur UF_ENTREE, avec ou sans TRIM (859 229 en 2018 à 922 018 en 2025) ; en 2019, moins de 10 séjours n'en trouvent aucune.

Mouvements commencés de 2018 à 2025 : aucun ne trouve de ligne par TB_UNITE.ID_UNITE ni par TB_UNITE_MEDICALE.ID_UNITE_MED (20261014-unicite-code-uf-resultat) ; tous trouvent un code d'UF par TRIM(ID_UNITE_M), un code de 4 caractères, et 33 à 36 % trouvent aussi un code d'UM (20261014-mvt-code-uf-resultat). Les totaux par année sont les mêmes dans les deux preuves (907 674 en 2018, 1 002 818 en 2025).

La kb de DIM-code disait l'inverse (un code d'UF peut avoir plusieurs lignes ; joindre les mouvements par ID_UNITE) sans mesure à l'appui.
