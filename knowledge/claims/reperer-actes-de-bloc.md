---
review: unreviewed
id: reperer-actes-de-bloc
kind: empirical
author: Pierre
statement: "Dans CORA, on ne peut pas récupérer les actes de bloc avec certitude avant 2022 : jusqu'en septembre 2020 ils viennent de reprises d'historique, et en 2020-2021 ID_SITE est vide pour environ 63 000 et 147 000 actes. Depuis 2022, prendre les actes dont le site de réalisation est un site de bloc (TB_ACTE.ID_SITE → TB_SITE.BLOC = 'O'), quelle que soit leur origine, flux CPage jusqu'en 2024 ou saisie dans CORA depuis 2025."
scope: "CORA de production (CWPROD, schéma CORA_REC), tables TB_ACTE et TB_SITE, actes datés de 2014 à 2025, lus le 2026-10-14"
refuted_if: "plus de 10 000 actes d'une année autre que 2020 et 2021 ont ID_SITE vide, ou la saisie CORA porte moins de la moitié des actes de bloc de 2025"
maturity: observed
lifecycle: active
terms: [cora:acte, cora:intervention]
tables: [cora:TB_ACTE, cora:TB_SITE]
supported_by: [20261014-epoques-actes-resultat]
depends_on: [epoques-codage-actes]
---
## Pour s'en servir

**Période :** partir de 2022. Avant, le résultat est incomplet, et l'écart n'est pas mesurable : le dire, et ne pas comparer ces années aux suivantes.

**Requête :**

```sql
FROM CORA_REC.TB_ACTE a
JOIN CORA_REC.TB_SITE si ON si.ID_SITE = a.ID_SITE
WHERE si.BLOC = 'O'
```

Garder les deux origines : ne pas filtrer sur l'application, car les actes de bloc passent du flux CPage (application 10) à la saisie dans CORA (sans application, ECRAN renseigné) en 2025. Pour regrouper les actes d'une même intervention, grouper par NO_INTERVENTION_CCAM (grouper-actes-par-no-intervention-ccam).

**À ne pas utiliser :**
- **TB_ACTE.NO_INTERVENTION :** il ne couvre que les actes saisis dans l'écran Bloc.
- **TB_INTERVENTION avant 2026 :** elle est incomplète (interventions-cora-flux-oproom).

**Ce qu'il faut dire si une analyse remonte avant 2022 :**
- **2020 et 2021 :** une partie des actes n'a pas de site et sort du périmètre, sans que l'activité baisse.
- **Avant octobre 2020 :** les actes viennent de reprises d'historique (epoques-codage-actes).

**Point ouvert :** la kb de DIM-code signale des sites qui portent des interventions mais ne sont pas paramétrés bloc, et une salle de naissance paramétrée bloc. Ce n'est pas mesuré ici : il faudra le vérifier en croisant avec OpRoom.

## Ce qui l'appuie

Actes par mois et par application (20261014-epoques-actes-resultat) :

- **Actes sur un site de bloc :** environ 14 000 à 17 700 par an en 2014-2016, 10 000 à 12 400 en 2018-2019, puis 56 600 en 2021, 40 900 en 2022, 42 500 en 2023, 43 700 en 2024 et 52 500 en 2025. Part du flux CPage : 71 % en 2021, 97 % en 2022, 96 % en 2023, 88 % en 2024, 38 % en 2025.
- **Site vide :** environ 63 400 actes en 2020 et 147 000 en 2021, presque tous de l'application 10 ; environ 1 800 en 2018 et 2 900 en 2019 ; moins de 10 par mois et par application les autres années.

Les sommes annuelles additionnent des cases mensuelles, dont certaines sont masquées (<10) : elles sont arrondies.
