# Générateur de données synthétiques

Des lignes fictives, calibrées sur les agrégats masqués du dépôt, pour exécuter et tester du code d'analyse ou de requête quand CORA et OpRoom ne sont pas atteignables (cloud, CI, démonstration). Il remplace les petits générateurs écrits à la main dans chaque étude.

**Ce que c'est :** des tables aux noms et colonnes de CORA et d'OpRoom, tirées au hasard à graine fixe, dont les distributions suivent des agrégats que le dépôt connaît déjà. **Ce que ce n'est pas :** une source de chiffres. Un résultat calculé sur ces lignes teste du code ; il ne dit rien de l'hôpital, il n'entre ni dans un claim, ni dans une preuve, ni dans un rapport sans mention « synthétique ».

## Utiliser

```bash
pip install -r tools/synth/requirements.txt
python tools/synth/generate.py --list                                   # familles, tables, colonnes
python tools/synth/generate.py --out /tmp/synth --years 2022-2025       # hôpital entier, 2 % du volume réel
python tools/synth/generate.py --out /tmp/synth --perimeter fme --scale 1 --years 2022-2026   # pôle FME, volume réel
```

Ou en Python, dans un test :

```python
import sys; sys.path.insert(0, "<CDK>/tools/synth")
import synth
tables, manifest = synth.generate(seed=1, scale=0.02, years=range(2022, 2026), families=("rss",))
```

| Réglage | Sens |
|---|---|
| `--seed` | graine ; même graine et mêmes réglages donnent les mêmes lignes (défaut 20261022) |
| `--scale` | part du volume réel : 1 = autant de séjours que l'hôpital (≈ 170 000 RSS par an ; 0,02 suffit pour un test) |
| `--years` | `2022-2025` ou `2022,2024` |
| `--perimeter` | `hospital` (marginales de l'hôpital) ou `fme` (cellules UF × GHM × GHS × DP du pôle, avec UF d'hébergement) |
| `--families` | `rss` (TB_SYNTH_RSS, TB_SEJOUR, et en `fme` TB_SYNTH_RUM, SYNTH_REF_UF_POLE_FME, PMSI_LIB_GHS_TARIF), `bloc` (INTERVENTIONS, l'extraction OpRoom des requêtes de CDK ; TB_ACTE), `htp` (TB_MVT_SSR_SEM, 2025) |

Les tables préfixées `SYNTH_` n'existent pas dans CORA : ce sont des référentiels de commodité (ici les UF du pôle FME) ; ne pas supposer qu'elles existent à l'hôpital, et lire les vraies tables par leurs claims. `PMSI_LIB_GHS_TARIF` porte le nom de la vraie table mais pas forcément ses colonnes.

La sortie est un CSV par table et `manifest.json` : graine, réglages, effectifs, sources lues et **hypothèses** de chaque famille. Les lignes générées ne se versionnent pas : la graine et les réglages les refont.

## Ce qui est mesuré, ce qui est supposé

Chaque paramètre vient d'un agrégat du dépôt ou est une hypothèse écrite dans `assumptions` (calibration/*.json, manifeste). Mesuré, entre autres : le volume annuel de RSS ; la part des séances, des 0 nuit et des séjours d'au moins une nuit ; la répartition type de GHM × sixième caractère ; la répartition des durées par niveau de sévérité ; les modes de sortie, destinations, provenances ; la version de groupage par semestre ; la forme des codes CIM-10 ; la part de GHS 9999 ; la part de séjours sans RSS et de séjours ouverts ; pour le pôle FME, chaque cellule UF × GHM × GHS × DP à 3 caractères et la durée moyenne de chacune ; pour le bloc, volumes par mois et bloc, spécialités, durées moyennes d'occupation, de TROS et d'incision, délais de saisie des actes.

Supposé, et à ne pas prendre pour une mesure : la forme des durées dans chaque cellule (gamma-Poisson, dispersion `phi` non mesurée), la queue des durées de 5 nuits et plus, la racine de GHM hors pôle FME (tirée au hasard dans le référentiel des GHS), le chapitre CIM-10 du DP hors pôle FME, les montants, les liaisons entre variables que l'agrégat ne donne pas (bloc × spécialité, TB_ACTE × INTERVENTIONS : aucun lien généré). La liste exacte est dans le manifeste.

Un test de fidélité (`python -m synth.fidelity` depuis tools/synth, ou le test unittest) vérifie que les lignes générées retrouvent les agrégats de calibration. Il vérifie la cohérence avec la calibration, pas la vérité de la calibration.

## Cellules masquées

Les agrégats sources contiennent des `<10` et des `masqué`. Une cellule `<10` vaut 5 quand rien ne contraint le groupe ; quand le total du groupe est connu (autre tableau, pourcentages, ou synthèse), les cellules masquées se partagent le reste (aggregates.py, `fill_masked`). Pour le pôle FME, les 95 % de cellules `<10` se partagent ainsi le reliquat des séjours : à volume réel, le jeu contient autant de petites cellules que le réel, ce qui permet de tester un masquage < 10. Les fichiers de calibration ne contiennent jamais l'effectif d'une cellule de 1 à 9 : des parts ou des moyennes, et les `<10` d'origine.

## Ajouter une source

1. Écrire l'agrégat comme d'habitude (requête masquée, preuve ; ou un retour de DIM-code).
2. Dans `synth/extractors.py`, ajouter ou compléter un extracteur (`@extractor("nom")`) : il lit l'agrégat par `Sources.evidence(id)` ou `Sources.dimcode_csv(nom)`, traite les cellules masquées par `fill_masked`, et renvoie des paramètres ; ce qu'il suppose va dans `assumptions`.
3. `python tools/synth/build.py` (avec `--dimcode DOSSIER` pour les extracteurs qui lisent un retour de DIM-code, par exemple le dossier 2026-10-22 de la branche retours-cdk) réécrit `calibration/`.
4. Si une famille nouvelle : un générateur dans `synth/tables/`, inscrit par `@generator("nom")`, qui lit `calib.params("nom")` et ne lit jamais les preuves directement.
5. Un contrôle de fidélité dans `synth/fidelity.py`, un test, et `python -m unittest discover tools/synth/tests`.

`build.py --check` échoue quand `calibration/` n'est plus celle que les sources donnent (la CI le lance, sans DIM-code : les extracteurs qui en dépendent sont alors ignorés). Ne jamais éditer `calibration/` à la main.

## Limites connues

- Pas d'âge, de sexe, de commune : aucun agrégat du dépôt ne les donne.
- Les durées ne sont mesurées que par classes (0, 1, 2, 3, 4, 5+ nuits) ou par moyennes. Une requête qui rendrait des quantiles de durée par CMD améliorerait le plus la fidélité.
- Hors pôle FME, un RSS n'a pas d'UF ni de RUM ; hors 2025, pas de RHS.
- Les séjours ouverts sont supposés sans RSS.
- Les noms de colonnes suivent le catalogue (knowledge/evidence, catalogues de colonnes) quand il les donne ; TB_ACTE générée est indicative ; INTERVENTIONS reprend les colonnes lues par les requêtes oproom de knowledge/queries/.
- Pas de tables de structure de CORA (TB_MVT, TB_UNITE, TB_UNITE_POLE_UM) : un code qui les joint ne s'essaie ici que sur ce que l'agent fabrique à la main ; c'est la première extension utile (un agent de l'évaluation l'a relevé).
- Fichiers de calibration volumineux : ghs_tarif.csv (référentiel des GHS, 1,3 Mo) et fme_cells.csv (0,5 Mo).

## Règles du dépôt

Les agrégats utilisés sont déjà masqués (method/privacy.md). Ce dossier n'a pas de type dans method/layout.md : il y est ajouté comme « outil », hors knowledge/ et investigations/, que le contrôle lit fichier par fichier. Les agents l'emploient par le skill `synth`.
