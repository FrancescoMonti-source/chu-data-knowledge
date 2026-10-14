---
review: unreviewed
id: reperer-passage-urgences
kind: decision
author: Pierre
statement: "Au CHU, un séjour CORA est un passage aux urgences quand son UF d'entrée (TB_SEJOUR.UF_ENTREE) est l'une de : 5701, 5802, 5709, 5015, 5010, 5720, 5705, 8012, 8013, 8014, 8005, 8000, 5654, 5703 ; ni le drapeau URGENCE de TB_UNITE ni les champs d'urgence du séjour ne servent."
scope: "CORA, séjours entrés de 2014 à 2025"
responsible: Pierre
reconsider_when: "une UF d'urgences est créée, fermée ou recodée ; un champ de CORA repère les passages de façon constante ; une mesure montre des passages enregistrés comme mouvements en cours de séjour"
maturity: documented
lifecycle: active
terms: [cora:sejour, cora:uf, cora:passage-urgences]
tables: [cora:TB_SEJOUR]
supported_by: [20261014-decision-uf-urgences]
depends_on: [drapeau-urgence-uf-non-fiable, sejour-sans-signal-urgences]
---
## Pour s'en servir

Filtrer sur le code de l'UF d'entrée, débarrassé de ses espaces :

```sql
WHERE TRIM(s.UF_ENTREE) IN ('5701', '5802', '5709', '5015', '5010', '5720', '5705',
                            '8012', '8013', '8014', '8005', '8000', '5654', '5703')
```

Ne pas joindre TB_UNITE sur CODE_UNITE pour ce filtre : le code suffit, et un code peut avoir plusieurs lignes dans TB_UNITE.

Pour une série dans le temps, ventiler par UF : la liste mêle des UF qui ferment ou se vident vers 2020 (5802, 5709, 5703) et des UF qui naissent à ce moment (8012, 8013, 8014). Un total qui saute en 2020 vient de cette réorganisation, pas forcément de l'activité.

Pour exclure les urgences gynéco-obstétricales (8005) ou neurologiques (5654) d'une analyse des urgences générales, les retirer de la liste et le dire.

## Ce qui l'appuie

Les signaux de CORA ne repèrent pas les passages : le drapeau URGENCE (drapeau-urgence-uf-non-fiable), ni UF_URGENCE et TYPE_SEJOUR (sejour-sans-signal-urgences). La liste a été arrêtée par Pierre (20261014-decision-uf-urgences) à partir des UF candidates de 20261014-reperer-urgences-resultat : les UF d'urgences générales, adultes et pédiatriques (5701, 5802, 5709, 5015, 5010, 5720), l'UHCD (5705), l'accueil (8012, 8013, 8014), et les urgences spécialisées (8005, 8000, 5654) ou de permanence des soins (5703).

La base de connaissances de dim-code ne retenait que 5701, 5015, 5720, 5010 et 5802.

Points ouverts : le filtre ne voit que l'UF d'entrée ; un passage aux urgences enregistré comme un mouvement plus tard dans le séjour (TB_MVT.ID_UNITE_M) n'est pas mesuré.
