"""Extracteurs : chacun lit des agrégats (preuves, retours) et écrit les paramètres d'un générateur.

Ajouter une source = ajouter ou compléter un extracteur ici, relancer `python tools/synth/build.py`. Un paramètre
qu'aucune source ne mesure est déclaré dans `assumptions` de l'extracteur : il part dans calibration/ et dans le
manifeste de chaque génération, pour que l'agent sache ce qui est mesuré et ce qui est supposé.
"""
from __future__ import annotations

import numpy as np
import pandas as pd

from . import aggregates as agg
from .sources import Sources, text_block_table

EXTRACTORS: dict = {}


def extractor(name: str):
    def register(fn):
        EXTRACTORS[name] = fn
        return fn
    return register


def _p(df: pd.DataFrame, key: str | list[str], n: str = "n_fill") -> dict:
    return agg.to_distribution(df, key, n)


def _joint(df: pd.DataFrame, cols: list[str], n: str = "n_fill") -> dict:
    s = df.groupby(cols)[n].sum()
    s = s[s > 0]
    return {"|".join(map(str, k if isinstance(k, tuple) else (k,))): round(float(v / s.sum()), 6) for k, v in s.items()}


CLASSES = {"1 séance (CMD 28)": "seance", "2 0 nuit": "zero_nuit", "3 au moins une nuit": "nuit", "4 durée vide": "duree_vide"}

RSS_ASSUMPTIONS = [
    "la racine de GHM (CMD, numéro) n'est mesurée qu'à l'échelle du pôle FME : ailleurs elle est tirée parmi les racines du référentiel des GHS, de même lettre de type, à poids égaux",
    "le sixième caractère A-E est ramené à une sévérité 1-4 (A→1 … D→4, E→1) pour tirer la durée ; T → 1 nuit, J → 0 nuit, Z → durées du niveau 1",
    "queue des durées de 5 nuits et plus : 5 + gamma-Poisson d'espérance tail_excess_mean et de dispersion phi (non mesurées ; à remplacer par des quantiles de durée quand une requête les donnera)",
    "chapitre CIM-10 du DP : déduit de la CMD par une table usuelle, hors FME (non mesuré)",
    "GHS : un GHS du référentiel valide à la date de sortie, choisi d'après le niveau de sévérité ; 9999 selon la part mesurée",
    "répartition des sorties dans l'année : uniforme, 2026 arrêtée au 30 septembre",
    "séjours sans RSS (consultations externes, autres champs) : part, champ et part de séjours ouverts mesurés ; leur durée (0 nuit selon la part mesurée, sinon 1 nuit + queue géométrique de moyenne 3) est supposée ; les séjours ouverts sont supposés tous sans RSS",
]


@extractor("rss")
def rss(src: Sources) -> dict:
    m = src.evidence("20261019-montant-ghs-rss-resultat")
    m = m[m["NIVEAU"] == "ANNEE"]
    years = {r["CLE"]: int(float(r["N_RSS"])) for _, r in m.iterrows()}
    p9999 = {r["CLE"]: round(float(r["N_GHS_9999"]) / float(r["N_RSS"]), 5) for _, r in m.iterrows()}
    ref = src.evidence("20261019-tarif-ghs-couverture-4-resultat")
    for _, r in ref.iterrows():  # plus récent que la preuve précédente pour 2025, et seul à donner 2026
        n_rss = agg.parse_number(r["N_RSS"])
        if n_rss == n_rss:
            years[r["ANNEE"]] = int(n_rss)
            n9 = agg.parse_number(r["N_RSS_GHS_9999"])
            if n9 == n9:
                p9999[r["ANNEE"]] = round(n9 / n_rss, 5)

    c = agg.add_counts(src.evidence("20261015-classes-rss-resultat"))
    totals = c[c["VUE"] == "TYPE_PEC"].groupby(["ANNEE", "CLASSE"])["n"].sum()
    classe = {y: {CLASSES[k]: round(float(v / g.sum()), 6) for k, v in g.droplevel(0).items()} for y, g in totals.groupby(level=0)}
    ghm = agg.fill_masked(c[c["VUE"] == "GHM"], ["ANNEE", "CLASSE"], totals=totals)
    mix = {y: {CLASSES[k]: _joint(g2.assign(t=g2["VALEUR_1"] + "|" + g2["VALEUR_2"]), ["t"]) for k, g2 in g.groupby("CLASSE")}
           for y, g in ghm.groupby("ANNEE")}

    sev = agg.add_counts(src.evidence("20261019-severite-nuitees-resultat"))
    sev = sev[sev["MESURE"] == "DUREE_SEJOUR"]
    sev = agg.fill_masked(sev, ["TYPE_GHM", "NIVEAU"], pct_col="PCT_NIVEAU")
    duree = {f"{t}|{lvl}": _p(g, "CLASSE") for (t, lvl), g in sev.groupby(["TYPE_GHM", "NIVEAU"])}

    dest = agg.add_counts(src.evidence("20261019-destination-sortie-mco-resultat"))
    dest = agg.fill_masked(dest[dest["NIVEAU"] == "RSS"], ["ANNEE"], pct_col="PCT_ANNEE")
    destination = {y: _joint(g.assign(k=g["MODE_SORTIE"] + "|" + g["CODE_DESTINATION"]), ["k"]) for y, g in dest.groupby("ANNEE")}
    prov = agg.fill_masked(agg.add_counts(src.evidence("20261019-provenance-mode-entree-rss-resultat")), ["ANNEE"], pct_col="PCT_ANNEE")
    provenance = {y: _joint(g.assign(k=g["CODE_PROVENANCE"] + "|" + g["MODE_ENTREE"]), ["k"]) for y, g in prov.groupby("ANNEE")}

    ver = agg.fill_masked(agg.add_counts(src.evidence("20261019-version-groupage-semestre-resultat")), ["SEMESTRE"], pct_col="PCT_SEMESTRE")
    version = {s: _p(g, "VERSION") for s, g in ver.groupby("SEMESTRE")}

    dp = agg.fill_masked(agg.add_counts(src.evidence("20261019-forme-code-cim10-resultat")).query("NIVEAU == 'DP_RSS'"), ["ANNEE"], pct_col="PCT_ANNEE")
    dp["forme"] = dp["POINT"] + "|" + dp["ESPACE"] + "|" + dp["CASSE"] + "|" + dp["LONGUEUR"]
    forme_dp = {y: _joint(g, ["forme"]) for y, g in dp.groupby("ANNEE")}

    sr = src.evidence("20261013-sejours-sans-rss-resultat")
    prof = agg.fill_masked(agg.add_counts(src.evidence("20261015-sejours-sans-rss-profil-resultat").query("VUE == 'CHAMP' and AVEC_RSS == 'N'")), ["ANNEE"])
    stat = agg.fill_masked(agg.add_counts(src.evidence("20261015-sejours-statut-resultat")), ["ANNEE"])
    sejour = {}
    for _, r in sr.iterrows():
        n, s0, z = (agg.parse_number(r[c]) for c in ("N_SEJ", "N_SEJ_SANS_RSS", "N_SEJ_SANS_RSS_0J"))
        y = r["ANNEE_SORTIE"]
        if y < "2018" or not s0 == s0:
            continue
        ouvert = stat[(stat["ANNEE"] == y) & (stat["ETAT"] == "ouvert")]["n_fill"].sum()
        champ = prof[prof["ANNEE"] == y]
        sejour[y] = {"p_sans_rss": round(s0 / n, 5), "p_zero_nuit_sans_rss": round(z / s0, 5), "p_ouvert_sans_rss": round(float(ouvert) / s0, 6),
                     "champ_sans_rss": _p(champ, "VALEUR")}

    return {
        "sejour": sejour, "years": years, "p_ghs_9999": p9999, "classe": classe, "ghm_mix": mix, "duree_classes": duree,
        "destination": destination, "provenance": provenance, "version_groupage": version, "forme_dp": forme_dp,
        "tail_excess_mean": 4.0, "phi": 0.6, "last_month_2026": 9,
        "assumptions": RSS_ASSUMPTIONS,
    }


@extractor("fme")
def fme(src: Sources) -> dict:
    """Pôle FME : cellules UF × GHM × GHS × DP (3 caractères) × année, avec la queue des cellules < 10 reconstituée par différence."""
    cells = src.dimcode_csv("cellules.csv")
    synth = text_block_table(src.dimcode_text("synthese_dms_fme.md"), "Pôle par année")
    tot = {r["annee"]: (float(r["n_rss"]), float(r["n_rss"]) * float(r["dms"])) for _, r in synth.iterrows()}
    cells["n"] = cells["n_rss"].map(agg.parse_number)
    cells["nu"] = cells["nb_nuitees"].map(agg.parse_number)
    tail, out = {}, []
    for year, g in cells.groupby("annee"):
        vis = g[g["n"].notna()]
        k_tail = int(g["n"].isna().sum())
        n_tail = max(tot[year][0] - vis["n"].sum(), float(k_tail)) if year in tot else float(k_tail) * 1.8
        nu_tail = max(tot[year][1] - vis["nu"].sum(), 0.0) if year in tot else n_tail * 6.0
        tail[year] = {"n_total": tot.get(year, (None,))[0], "cells_lt10": k_tail, "n_per_lt10_cell": round(n_tail / max(k_tail, 1), 3),
                      "mean_nights_lt10": round(nu_tail / max(n_tail, 1.0), 2)}
        g = g.assign(mean_nights=(g["nu"] / g["n"]).round(2))
        out.append(g[["annee", "code_uf", "ghm", "code_ghs", "dp3", "dp_sp", "n_rss", "mean_nights"]])
    w = cells.assign(w=cells["n"].fillna(cells["annee"].map({y: v["n_per_lt10_cell"] for y, v in tail.items()})))
    w["lettre"] = w["dp3"].str[:1].replace("", "(vide)")
    p_letters = {y: {k: round(float(v), 5) for k, v in (g.groupby("lettre")["w"].sum() / g["w"].sum()).items()} for y, g in w.groupby("annee")}
    p_dp_sp = {y: round(float(g.loc[g["dp_sp"] == "1", "w"].sum() / g["w"].sum()), 5) for y, g in w.groupby("annee")}
    hors = src.dimcode_csv("hors_fme.csv")
    hors["n"] = hors["n_sej"].map(agg.parse_number)
    hors["nu"] = hors["nb_nuitees_rum"].map(agg.parse_number)
    p_hors = {y: round(float(g["n"].sum()) / tail[y]["n_total"], 4) for y, g in hors.groupby("annee") if tail.get(y, {}).get("n_total")}
    hors_cols = hors[["annee", "code_uf_hors", "libelle_uf_hors", "pole_hors", "n_sej"]]
    return {
        "tail": tail, "dms_pole": {y: float(synth.loc[synth["annee"] == y, "dms"].iloc[0]) for y in tot}, "p_rum_hors_pole": p_hors, "p_dp_letter": p_letters, "p_dp_sans_precision": p_dp_sp,
        "assumptions": [
            "totaux annuels du pôle (n_rss, DMS) lus dans la synthèse des retours : ils servent à reconstituer, par différence, les séjours des cellules < 10",
            "un séjour des cellules < 10 est réparti à parts égales entre ces cellules (leur effectif réel de 1 à 9 n'est pas connu) ; sa durée suit la moyenne résiduelle",
            "dispersion des durées d'une cellule : celle de l'extracteur rss (phi), non mesurée à l'échelle du pôle",
        ],
        "_files": {"fme_cells.csv": pd.concat(out), "fme_hors_pole.csv": hors_cols,
                   "fme_uf.csv": src.dimcode_csv("liste_uf.csv"),
                   "ghs_tarif.csv": src.dimcode_csv("bornes.csv")},
    }


def _month_years(df: pd.DataFrame, col: str) -> pd.DataFrame:
    return df.assign(ANNEE=df[col].str[:4])


@extractor("bloc")
def bloc(src: Sources) -> dict:
    """Interventions de bloc (OpRoom) et actes CCAM saisis (CORA), par mois."""
    bm = agg.fill_masked(agg.add_counts(src.evidence("20261014-oproom-blocs-mois-resultat")), ["MOIS"])
    # parts et total, jamais l'effectif d'une cellule (une cellule masquée y vaut une valeur imputée, pas un effectif lu)
    bloc_mois = {m: {"n": int(round(g["n_fill"].sum(), -1)), "blocs": _p(g, "BLOC")} for m, g in bm.groupby("MOIS")}

    sp = agg.fill_masked(agg.add_counts(src.evidence("20261014-oproom-specialites-salles-resultat")), ["ANNEE"])
    spec = {y: _p(g, "SPEC") for y, g in sp.groupby("ANNEE")}
    flags = {}
    for s, g in sp.groupby("SPEC"):
        n = g["n_fill"].sum()
        gill = agg.add_counts(g.rename(columns={"N_GILLIES": "n_g"}), "n_g")["n"].sum()
        virt = agg.add_counts(g.rename(columns={"N_SALLE_VIRTUELLE": "n_v"}), "n_v")["n"].sum()
        flags[s] = {"p_gillies": round(float(np.nan_to_num(gill) / n), 4), "p_salle_virtuelle": round(float(np.nan_to_num(virt) / n), 4)}

    at = agg.add_counts(src.evidence("20261014-oproom-attributs-resultat"))
    vals = agg.fill_masked(at[at["NIVEAU"] == "VALEURS"], ["ANNEE", "VARIABLE"])
    attributs = {v: {y: _p(g2, "VALEUR") for y, g2 in g.groupby("ANNEE")} for v, g in vals.groupby("VARIABLE") if v}
    an = agg.fill_masked(agg.add_counts(src.evidence("20261015-oproom-anesthesie-specialite-resultat")), ["SPEC"])
    anesth_par_spec = {s: _p(g, "ANESTHESIE") for s, g in an.groupby("SPEC")}

    du = src.evidence("20261014-oproom-durees-resultat")
    durees = {r["ANNEE"]: {k: agg.parse_number(r[c]) for k, c in (("occupation_min", "MOY_OCCUPATION_MIN"), ("tros_min", "MOY_TROS_MIN"), ("incision_min", "MOY_INCISION_MIN"))}
              for _, r in du.iterrows()}
    ann = agg.add_counts(at[at["NIVEAU"] == "ANNEE"].assign(N=lambda d: d["N"]))
    rates = {}
    for _, r in ann.iterrows():
        n = r["n"] if r["state"] == "ok" else float(bm[bm["MOIS"].str[:4] == r["ANNEE"]]["n_fill"].sum())
        rates[r["ANNEE"]] = {k: round(agg.parse_number(r[c]) / n, 5) for k, c in (("p_sans_chirurgien", "N_SANS_CHIRURGIEN"), ("p_plusieurs_chirurgiens", "N_PLUSIEURS_CHIRURGIENS"),
                             ("p_bloc_non_renseigne", "N_BLOC_NON_RENSEIGNE"), ("p_sans_demande", "N_SANS_DEMANDE"), ("p_proc_suppl", "N_PROC_SUPPL")) if agg.parse_number(r[c]) == agg.parse_number(r[c])}

    ao = agg.fill_masked(agg.add_counts(src.evidence("20261019-actes-origine-saisie-mois-resultat")), ["MOIS"])
    ao["k"] = ao["APPLICATION"] + "|" + ao["ECRAN_RENSEIGNE"] + "|" + ao["TYPE_TRANSFERT"]
    nint = agg.add_counts(ao.rename(columns={"N_NO_INTERVENTION": "n_i"}), "n_i")["n"]
    ao["p_interv"] = (nint.fillna(0) / ao["n_fill"].replace(0, np.nan)).clip(0, 1).fillna(0)
    actes_mix = {m: {k: round(float(v / g["n_fill"].sum()), 6) for k, v in g.groupby("k")["n_fill"].sum().items() if v > 0} for m, g in ao.groupby("MOIS")}
    actes_n = {m: int(g["n_fill"].sum()) for m, g in ao.groupby("MOIS")}
    p_interv = {k: round(float((g["p_interv"] * g["n_fill"]).sum() / g["n_fill"].sum()), 4) for k, g in ao.groupby("k")}

    dl = src.evidence("20261019-delai-saisie-actes-mois-resultat")
    classes = [("N_0_1J", "0-1"), ("N_2_30J", "2-30"), ("N_31_90J", "31-90"), ("N_91_365J", "91-365"), ("N_PLUS_1AN", "366+")]
    delai = {}
    for _, r in dl.iterrows():
        v = {lab: agg.parse_number(r[c]) for c, lab in classes}
        tot = agg.parse_number(r["N"])
        lt = sum(1 for x in v.values() if x != x)
        known = sum(x for x in v.values() if x == x)
        if tot == tot:
            rest = max(tot - known, 0)
        else:
            rest = max(known * 0.0, 0)
        v = {k: (x if x == x else rest / max(lt, 1) if rest > 0 else agg.LT10) for k, x in v.items()}
        s = sum(v.values())
        delai.setdefault(r["MOIS"], {})[r["ORIGINE"]] = {k: round(x / s, 5) for k, x in v.items()}

    ra = src.evidence("20261019-actes-par-intervention-rattachement-resultat")
    ra["m"] = ra["MOY_ACTES_DIRECT"].map(agg.parse_number)
    ra["n"] = ra["N_INTERVENTIONS"].map(agg.parse_number)
    last = ra[ra["MOIS"] >= sorted(ra["MOIS"].unique())[-12]]
    actes_par_interv = {s: round(float(np.nanmean(g["m"])), 3) if g["m"].notna().any() else None for s, g in last.groupby("SAISIE")}
    p_saisie = {s: float(g["n"].fillna(agg.LT10).sum()) for s, g in last.groupby("SAISIE")}
    tot = sum(p_saisie.values())
    p_saisie = {k: round(v / tot, 4) for k, v in p_saisie.items()}

    return {
        "bloc_mois": bloc_mois, "spec_par_annee": spec, "flags_spec": flags, "attributs": attributs, "anesthesie_par_spec": anesth_par_spec,
        "durees_moyennes": durees, "taux_annee": rates, "actes_mix_mois": actes_mix, "actes_n_mois": actes_n, "p_no_intervention": p_interv,
        "delai_saisie": delai, "actes_par_intervention": actes_par_interv, "p_saisie": p_saisie, "sigma_duree": 0.55,
        "assumptions": [
            "forme des durées de bloc : log-normale de moyenne mesurée (OR_INTERVENTIONS durées moyennes) et d'écart-type logarithmique sigma_duree, non mesuré ; incision ≤ TROS ≤ occupation par construction",
            "spécialité, bloc, anesthésie, priorité : tirés séparément (seule l'anesthésie dépend de la spécialité, mesurée) : les liaisons bloc × spécialité ne sont pas reproduites",
            "aucun lien généré entre TB_ACTE et OR_INTERVENTIONS (le chaînage est un sujet de claims, pas simulé) ; NO_INTERVENTION est un entier aléatoire quand il est renseigné",
            "TB_ACTE.ECRAN : valeur fictive « ECR » quand l'écran est renseigné (seule la présence est mesurée)",
            "code CCAM : forme 4 lettres + 3 chiffres tirée au hasard, non mesurée",
            "dans un mois, un jour est tiré uniformément",
        ],
    }


@extractor("htp")
def htp(src: Sources) -> dict:
    """RHS d'hospitalisation à temps partiel de SMR en 2025 : cellules GN × GR, scores et montants de GMT."""
    g = src.evidence("20261020-rhs-htp-gn-gr-montants-2025-resultat")
    s = src.evidence("20261020-rhs-htp-scores-par-gn-gr-2025-resultat").set_index(["GN", "GR"])
    cells = []
    for _, r in g.iterrows():
        n = agg.parse_number(r["N_RHS"])
        key = (r["GN"], r["GR"])
        if not r["GN"]:
            continue  # ligne de total masquée
        nj, mnt = agg.parse_number(r["N_JOURS_PRESENCE"]), agg.parse_number(r["MNT_GMT_SOMME"].replace(" ", ""))
        sc = s.loc[key] if key in s.index else None
        cell = {"gn": r["GN"], "gr": r["GR"], "n_rhs": None if n != n else int(n)}
        if n == n:
            cell.update({"jours_par_rhs": round(nj / n, 3), "mnt_gmt_moyen": round(mnt / n, 2),
                         "score_min": agg.parse_number(sc["SCORE_RR_MIN"]) if sc is not None else None,
                         "score_moy": agg.parse_number(sc["SCORE_RR_MOY"]) if sc is not None else None,
                         "score_max": agg.parse_number(sc["SCORE_RR_MAX"]) if sc is not None else None})
        cells.append(cell)
    visible = [c for c in cells if c["n_rhs"]]
    return {
        "annee": 2025, "cells": visible, "n_cells_lt10": sum(1 for c in cells if not c["n_rhs"]),
        "assumptions": [
            "cellules < 10 RHS omises (leur nombre est dans n_cells_lt10) : le total généré est un peu inférieur au réel",
            "score RR d'un RHS : loi bêta bornée par le min et le max observés, d'espérance égale à la moyenne observée (forme non mesurée)",
            "montant GMT d'un RHS : log-normale de moyenne observée par cellule, sigma 0,25 (non mesuré) ; le montant hebdomadaire est nul (comme mesuré)",
            "une semaine de 2025 tirée uniformément ; un patient par RHS sauf une part de patients à plusieurs RHS (non mesurée à ce niveau)",
        ],
    }
