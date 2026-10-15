---
id: 20261015-dim-code-chainage-oproom
type: reading
source: dim-code-extraction-cora-oproom
locator: "docstring du module (voie 1), constante _RE_ID_INTERVENTION_EXT, fonctions _parser_id_intervention_ext et charger_oproom_export"
read_by: Pierre
read_at: 2026-10-15
---
> « intervention OpRoom n° N -> `TB_INTERVENTION` dont `NO_INTERVENTION_EXT` vaut "N-<phase>" (phases regroupées) -> actes qui pointent sur ces interventions (`TB_ACTE.NO_INTERVENTION`, qui contient l'`ID_INTERVENTION`) ou qui portent, dans le même séjour, le `NO_INTERVENTION_CCAM` de l'une d'elles. »

> `_RE_ID_INTERVENTION_EXT = re.compile(r"^\s*(\d+)-\d+\s*$")` ; « '237355-0' -> 237355. None si absent ou de format inattendu. »

> `"no_intervention_oproom": brut["I_KEY"].apply(_parser_no_intervention_oproom)` : le n° d'intervention OpRoom est la colonne I_KEY de l'extraction de requete_oproom.py (OR_INTERVENTIONS.I_KEY).
