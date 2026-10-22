"""INTERVENTIONS (extraction OpRoom) et TB_ACTE (CORA) synthétiques : volumes par mois et bloc, durées, saisie des actes."""
from __future__ import annotations

import string

import numpy as np
import pandas as pd

from .. import calib
from . import generator
from .rss import _choice


def _lognormal(rng, mean: float, sigma: float, n: int) -> np.ndarray:
    return rng.lognormal(np.log(mean) - sigma**2 / 2, sigma, size=n)


def _unit_mean_beta(rng, a: float, b: float, n: int) -> np.ndarray:
    """Bruit multiplicatif de moyenne 1 (forme supposée : une phase est une fraction de la précédente)."""
    return rng.beta(a, b, size=n) * (a + b) / a


def _day_in_month(rng, month: str, n: int) -> pd.Series:
    start = pd.Timestamp(month + "-01")
    days = start.days_in_month
    return pd.Series(start + pd.to_timedelta(rng.integers(0, days, size=n), unit="D"))


def _interventions(rng, p: dict, scale: float, years: list[int]) -> pd.DataFrame:
    parts = []
    for month, m in sorted(p["bloc_mois"].items()):
        if int(month[:4]) not in years:
            continue
        for bloc, share in m["blocs"].items():
            n = int(round(m["n"] * share * scale))
            if n:
                parts.append(pd.DataFrame({"mois": month, "BLOC": bloc, "n": n}, index=[0]))
    plan = pd.concat(parts, ignore_index=True)
    plan = plan.loc[plan.index.repeat(plan["n"])].reset_index(drop=True)
    n = len(plan)
    year = plan["mois"].str[:4].to_numpy()
    spec = np.empty(n, dtype=object)
    anesth = np.empty(n, dtype=object)
    for y in np.unique(year):
        idx = np.where(year == y)[0]
        spec[idx] = _choice(rng, p["spec_par_annee"][y], len(idx))
    for s in np.unique(spec):
        idx = np.where(spec == s)[0]
        an = p["anesthesie_par_spec"].get(s) or p["attributs"]["ANESTHESIE"][max(p["attributs"]["ANESTHESIE"])]
        anesth[idx] = _choice(rng, an, len(idx))
    out = pd.DataFrame({"ID_INTERVENTION": np.arange(1, n + 1) + 70_000_000, "BLOC": plan["BLOC"], "SPEC": spec, "ANESTHESIE": anesth})
    dates = np.empty(n, dtype="datetime64[ns]")
    for m, idx in plan.groupby("mois").groups.items():
        dates[idx] = _day_in_month(rng, m, len(idx)).to_numpy()
    out["DATE_INTERVENTION"] = pd.to_datetime(dates).strftime("%Y-%m-%d")
    for var in ("PRIORITE", "HOSP", "TYPE_SALLE"):
        col = np.empty(n, dtype=object)
        for y in np.unique(year):
            idx = np.where(year == y)[0]
            d = p["attributs"][var].get(y) or p["attributs"][var][max(p["attributs"][var])]
            col[idx] = _choice(rng, d, len(idx))
        out[var] = col
    fl = pd.DataFrame([p["flags_spec"].get(s, {"p_gillies": 0.0, "p_salle_virtuelle": 0.0}) for s in spec])
    out["SITE_GILLIES"] = rng.random(n) < fl["p_gillies"].to_numpy()
    out["SALLE_VIRTUELLE"] = rng.random(n) < fl["p_salle_virtuelle"].to_numpy()
    occ = np.empty(n)
    for y in np.unique(year):
        idx = np.where(year == y)[0]
        d = p["durees_moyennes"].get(y) or p["durees_moyennes"][max(p["durees_moyennes"])]
        occ[idx] = _lognormal(rng, d["occupation_min"], p["sigma_duree"], len(idx))
        out.loc[idx, "_f_tros"] = d["tros_min"] / d["occupation_min"]
        out.loc[idx, "_f_inc"] = d["incision_min"] / d["tros_min"]
    occupation = pd.Series(occ).round().clip(1).astype(int)
    tros = (occ * out["_f_tros"] * _unit_mean_beta(rng, 8, 1.2, n)).round().clip(1).astype(int).clip(upper=occupation)
    incision = (tros * out["_f_inc"] * _unit_mean_beta(rng, 4, 3, n)).round().clip(1).astype(int).clip(upper=tros)
    start = pd.to_datetime(out["DATE_INTERVENTION"]) + pd.to_timedelta(rng.integers(8 * 60, 18 * 60, size=n), unit="min")
    offset = (rng.random(n) * (tros - incision)).astype(int)
    fmt = "%Y-%m-%d %H:%M:%S"
    # noms de l'extraction INTERVENTIONS d'OpRoom (requêtes knowledge/queries/*oproom*) ; valeurs en texte, vide = NULL
    out["DEBUT"] = start.dt.strftime(fmt)
    out["FIN"] = (start + pd.to_timedelta(occupation, unit="min")).dt.strftime(fmt)
    out["DEBUT_BIONET"] = (start + pd.to_timedelta(tros, unit="min")).dt.strftime(fmt)
    out["DEBUT_INCISION"] = (start + pd.to_timedelta(offset, unit="min")).dt.strftime(fmt)
    out["FIN_INCISION"] = (start + pd.to_timedelta(offset + incision, unit="min")).dt.strftime(fmt)
    out["SALLE_CODE"] = np.where(out.pop("SITE_GILLIES"), "SALLE GILLIES", "SALLE " + pd.Series(rng.integers(1, 15, size=n)).astype(str))
    out["SALLE"] = out["SALLE_CODE"]
    out["SALLE_VIRTUELLE"] = np.where(out["SALLE_VIRTUELLE"], "1", "0")
    out["ETAT"] = "4"
    out = out.drop(columns=["_f_tros", "_f_inc", "DATE_INTERVENTION"])
    rates = np.array([p["taux_annee"].get(y, p["taux_annee"][max(p["taux_annee"])]).get("p_plusieurs_chirurgiens", 0.12) for y in year])
    out["NB_CHIRURGIENS"] = 1 + (rng.random(n) < rates).astype(int)
    out.loc[rng.random(n) < np.array([p["taux_annee"].get(y, p["taux_annee"][max(p["taux_annee"])]).get("p_sans_chirurgien", 0.001) for y in year]), "NB_CHIRURGIENS"] = 0
    return out


def _ccam(rng, n: int) -> np.ndarray:
    letters = np.array(list(string.ascii_uppercase))
    a = ["".join(r) for r in rng.choice(letters, size=(n, 4))]
    d = rng.integers(0, 1000, size=n)
    return np.array([f"{x}{y:03d}" for x, y in zip(a, d)], dtype=object)


def _actes(rng, p: dict, scale: float, years: list[int]) -> pd.DataFrame:
    rows = []
    bounds = {"0-1": (0, 1), "2-30": (2, 30), "31-90": (31, 90), "91-365": (91, 365), "366+": (366, 900)}
    for month, mix in sorted(p["actes_mix_mois"].items()):
        if int(month[:4]) not in years:
            continue
        n = int(round(p["actes_n_mois"][month] * scale))
        if not n:
            continue
        k = _choice(rng, mix, n)
        app, ecran_renseigne, transfert = (np.array([s.split("|")[i] for s in k]) for i in range(3))
        d = _day_in_month(rng, month, n)
        origin = np.where(ecran_renseigne == "O", "ECRAN renseigné", "ECRAN vide")
        delay = np.zeros(n, dtype=int)
        for o in np.unique(origin):
            idx = np.where(origin == o)[0]
            cls = _choice(rng, p["delai_saisie"].get(month, next(iter(p["delai_saisie"].values())))[o], len(idx))
            lo = np.array([bounds[c][0] for c in cls])
            hi = np.array([bounds[c][1] for c in cls])
            delay[idx] = lo + (rng.beta(0.6, 1.6, size=len(idx)) * (hi - lo + 1)).astype(int)
        has_i = rng.random(n) < np.array([p["p_no_intervention"].get(x, 0.0) for x in k])
        rows.append(pd.DataFrame({"mois": month, "APPLICATION": app, "ECRAN": np.where(ecran_renseigne == "O", "ECR", ""), "TYPE_TRANSFERT": np.where(transfert == "(vide)", "", transfert),
                                  "DATE_ACTE": d.dt.strftime("%Y-%m-%d").to_numpy(), "DATE_CREAT": (d + pd.to_timedelta(delay, unit="D")).dt.strftime("%Y-%m-%d").to_numpy(),
                                  "NO_INTERVENTION": np.where(has_i, rng.integers(1, 10**7, size=n).astype(str), "")}))
    out = pd.concat(rows, ignore_index=True)
    out.insert(0, "ID_ACTE", np.arange(1, len(out) + 1) + 80_000_000)
    out["CODE_ACTE"] = _ccam(rng, len(out))
    return out.drop(columns=["mois"])


@generator("bloc")
def bloc(rng: np.random.Generator, scale: float, years: list[int]) -> dict[str, pd.DataFrame]:
    p = calib.params("bloc")
    return {"INTERVENTIONS": _interventions(rng, p, scale, years), "TB_ACTE": _actes(rng, p, scale, years)}
