# À quelle UF est attribué un RUM, et comment suivre les changements de numéro d'UF et d'UM ?

Personne : Pierre
Issue : #100

## Cadrage
- **Question :** dans CORA, l'UF d'un RUM (TB_SYNTH_RUM.ID_UF_ATTRIB), le rattachement UM-UF (TB_UNITE_M_UNITE), et le suivi d'un même service quand les numéros d'UM et d'UF changent.
- **Pourquoi :** l'étude DIM-code dms_fme (DIM-code#37) veut raisonner par UF et non par UM, en tenant compte des changements de numéros. Cette enquête comprend les données ; l'étude y répondra ensuite avec les claims qui en sortent (séparation des dépôts : compréhension ici, analyse dans DIM-code).
- **Ce qu'on sait déjà :** une UF se retrouve par son code dans TB_UNITE (joindre-uf-par-code) ; la liste UM-UF du pôle femme-mère-enfant (retours-cdk de DIM-code, 2026-10-21) montre l'UM 5618 rattachée aux UF 5618 et 5622, et l'UM 5619 aux UF 5619 et 5623. Aucune preuve ici : c'est une piste.
- **Hypothèses à tester (dans l'issue, pas des claims) :** ID_UF_ATTRIB est renseignée pour la plupart des RUM ; l'UF attribuée est l'une des UF de l'UM du RUM ; au niveau UF, la pédiatrie médicale d'hospitalisation du pôle reste continue en 2025.
- **Périmètre des requêtes :** RUM terminés de janvier à septembre de 2022 à 2026 (règle M9 de l'étude), pôle menf pour l'étape 4.
- **Masquage :** effectifs < 10 masqués dans les requêtes ; structures (codes et libellés d'UM et d'UF) en clair, ce ne sont pas des personnes.
- **Branche :** claude/project-thread-mgw97o, imposée par la session, au lieu de investigation/uf-um-rum.

## Choix
- **Colonnes à tester :** ID_UF_ATTRIB est vide pour pratiquement tous les RUM de 2022 à 2026 (20261022-rum-uf-attrib-par-annee : moins de 10 renseignés par année). Le catalogue (20261022-uf-um-catalogue) montre trois autres colonnes d'unité dans TB_SYNTH_RUM : UF_ATTRIB (code, VARCHAR2), ID_UNITE_HEBERG et ID_UNITE_RESP_MED. On les mesure avant de choisir (plan revu).
- **Référentiel figé en attendant :** Pierre indique ref_uf2umpmsi.txt (dépôt redsan, FrancescoMonti-source, inst/extdata/reference), qui donne pour chaque UF (SEJUF) son regroupement d'UM de séjour (SEJUM, ex. PEDE) et l'UM PMSI (UM_PMSI). Il rattache UF 5622 à l'UM 5618 et UF 5623 à l'UM 5619. C'est une piste à lire et à confronter à CORA, pas une preuve.

- **Binômes GHM × DP manquants (plan revu, 2026-10-22) :** Pierre voit dans l'étude dms_fme des binômes GHM × DP fréquents en 2025 et absents en 2026. Le regroupement des UF liées (5622 + 5618, 5623 + 5619, 5627 + 5616, justifié par 20261022-um-pole-fme-uf-trois-sources) ne les fait pas tous revenir. Deux requêtes testent d'autres causes, sans UF : le binôme disparaît-il du pôle (20261022-fme-binomes-ghm-dp-pole-par-annee), et le codage ou la durée de 2026 sont-ils incomplets ou changés mois par mois (20261022-fme-sejours-par-mois-sortie). Hypothèses dans l'issue.

## Conclusions
Aucune pour l'instant.
