"""TB_SYNTH_RSS, TB_SYNTH_RUM et TB_SEJOUR synthétiques (séjours MCO groupés), à l'échelle de l'hôpital ou du pôle FME."""
from __future__ import annotations

import numpy as np
import pandas as pd

from .. import calib
from ..durations import sample_from_classes, sample_nb
from . import generator

# chapitre(s) CIM-10 du DP par CMD : table usuelle, non mesurée (hors FME)
CMD_LETTERS = {
    "01": "GI", "02": "H", "03": "JKH", "04": "J", "05": "I", "06": "K", "07": "K", "08": "MS", "09": "LC", "10": "E",
    "11": "N", "12": "NC", "13": "NCO", "14": "O", "15": "P", "16": "D", "17": "CD", "18": "AB", "19": "F", "20": "FT",
    "21": "ST", "22": "T", "23": "Z", "25": "B", "26": "ST", "27": "Z", "28": "Z",
}
SIXTH_TO_LEVEL = {"1": "1", "2": "2", "3": "3", "4": "4", "A": "1", "B": "2", "C": "3", "D": "4", "E": "1", "Z": "1"}


def _choice(rng, dist: dict[str, float], n: int) -> np.ndarray:
    keys = list(dist)
    p = np.array([dist[k] for k in keys], dtype=float)
    return np.array(keys, dtype=object)[rng.choice(len(keys), size=n, p=p / p.sum())]


def _dates(rng, year: int, n: int, last_month: int) -> pd.Series:
    start = pd.Timestamp(year=year, month=1, day=1)
    days = (pd.Timestamp(year=year, month=last_month, day=1) + pd.offsets.MonthEnd(0) - start).days + 1
    return pd.Series(start + pd.to_timedelta(rng.integers(0, days, size=n), unit="D"))


def _ghs_index(ref_year: int) -> dict[str, list[str]]:
    t = calib.table("ghs_tarif.csv")
    at = f"{ref_year}-07-01"
    v = t[(t["date_debut"] <= at) & (t["date_fin"] >= at) & (t["code_ghs"] != "9999")].sort_values(["code_ghm_racine", "code_ghs"])
    return v.groupby("code_ghm_racine")["code_ghs"].apply(list).to_dict()


def _dp_code(rng, dp3: np.ndarray, imprecise: np.ndarray, forme: dict[str, float]) -> np.ndarray:
    """Écrit un DP dans les formes mesurées (longueur 3 à 6, point, espace, casse) ; « sans précision » = 4e caractère 9."""
    n = len(dp3)
    forms = _choice(rng, forme, n)
    out = np.empty(n, dtype=object)
    digits = rng.integers(0, 9, size=(n, 3))
    for i in range(n):
        point, space, case, length = forms[i].split("|")
        if length == "<3":
            out[i] = ""
            continue
        length = int(length)
        s = dp3[i]
        if length >= 4:
            s += "9" if imprecise[i] else str(digits[i, 0])
        if length >= 5:
            s += str(digits[i, 1])
        if length >= 6:
            s += str(digits[i, 2])
        if point == "avec point" and len(s) > 3:
            s = s[:3] + "." + s[3:]
        if space not in ("aucun", "(vide)"):
            s = s + " "
        if case == "minuscule":
            s = s.lower()
        out[i] = s
    return out


def _finish(rng, df: pd.DataFrame, p: dict) -> pd.DataFrame:
    """Colonnes communes aux deux périmètres : identifiants, dates, entrée, sortie, groupage, montants."""
    n = len(df)
    year = df["annee"].to_numpy()
    df["ID_RSS"] = np.arange(1, n + 1) + 10_000_000
    df["ID_SEJOUR"] = rng.permutation(np.arange(1, n + 1)) + 50_000_000
    df["ID_PATIENT"] = rng.integers(1, max(n // 2, 2), size=n) + 900_000
    df["NO_SEJOUR"] = df["ID_SEJOUR"].map(lambda v: f"S{v:09d}")
    df["NO_RSS"] = df["ID_RSS"].map(lambda v: f"{v % 10**8:08d}")
    pe, pd_ = np.empty(n, dtype=object), np.empty(n, dtype=object)
    me, ms, ds = np.empty(n, dtype=object), np.empty(n, dtype=object), np.empty(n, dtype=object)
    for y in np.unique(year):
        idx = np.where(year == y)[0]
        d = p["destination"][str(y)] if str(y) in p["destination"] else p["destination"][max(p["destination"])]
        pr = p["provenance"][str(y)] if str(y) in p["provenance"] else p["provenance"][max(p["provenance"])]
        k = _choice(rng, d, len(idx))
        ms[idx], ds[idx] = [a.split("|")[0] for a in k], [a.split("|")[1] for a in k]
        k = _choice(rng, pr, len(idx))
        pe[idx], me[idx] = [a.split("|")[0] for a in k], [a.split("|")[1] for a in k]
    for col, v in (("CODE_PROVENANCE", pe), ("MODE_ENTREE", me), ("MODE_SORTIE", ms), ("CODE_DESTINATION", ds)):
        df[col] = pd.Series(v).replace("(vide)", "").to_numpy()
    sortie = pd.to_datetime(df["DATE_FIN"])
    sem = sortie.dt.year.astype(str) + "-S" + ((sortie.dt.month > 6) + 1).astype(str)
    df["VERSION"] = [int(_choice(rng, p["version_groupage"].get(s, p["version_groupage"][max(p["version_groupage"])]), 1)[0]) for s in sem]
    nights = df["DUREE_SEJOUR"].to_numpy(dtype=float)
    mnt = (1100.0 + 330.0 * np.sqrt(np.maximum(nights, 0)) * 3) * rng.lognormal(0.0, 0.25, size=n)
    df["MONTANT_GHS"] = np.where(df["CODE_GHS"] == "9999", 0.0, mnt.round(2))
    df["NB_RUM"] = 1
    df["STATUT"] = "T"
    return df


@generator("rss")
def rss(rng: np.random.Generator, scale: float, years: list[int], perimeter: str = "hospital") -> dict[str, pd.DataFrame]:
    if perimeter == "fme":
        return _fme(rng, scale, years)
    p = calib.params("rss")
    parts = []
    for y in years:
        ys = str(y)
        n = max(int(round(p["years"].get(ys, 0) * scale)), 0)
        if n == 0:
            continue
        ref = _ghs_index(min(y, 2026))
        by_type: dict[str, list[str]] = {}
        for r in ref:
            by_type.setdefault(r[2], []).append(r)
        classe = _choice(rng, {k: v for k, v in p["classe"][ys].items() if k != "duree_vide"}, n)
        type6 = np.empty(n, dtype=object)
        for c in np.unique(classe):
            idx = np.where(classe == c)[0]
            type6[idx] = _choice(rng, p["ghm_mix"][ys][c], len(idx))
        typ, six = np.array([t.split("|")[0] for t in type6]), np.array([t.split("|")[1] for t in type6])
        racine = np.empty(n, dtype=object)
        for t in np.unique(typ):
            idx = np.where(typ == t)[0]
            pool = [r for r in by_type.get(t, []) if r[:2] not in ("28", "90")] or by_type.get(t, ["99Z99"])
            seance_pool = [r for r in ref if r[:2] == "28"] or ["28Z04"]
            for c in ("seance", "other"):
                sub = idx[(classe[idx] == "seance")] if c == "seance" else idx[(classe[idx] != "seance")]
                racine[sub] = rng.choice(seance_pool if c == "seance" else pool, size=len(sub))
        level = np.array([SIXTH_TO_LEVEL.get(s, "1") for s in six])
        dur = np.zeros(n, dtype=int)
        night = classe == "nuit"
        for t in ("C", "M"):
            for lv in "1234":
                m = night & (np.where(np.isin(typ, ["C", "K"]), "C", "M") == t) & (level == lv)
                if m.any():
                    shares = {k: v for k, v in p["duree_classes"][f"{t}|{lv}"].items() if k != "0"}
                    dur[m] = sample_from_classes(rng, shares, int(m.sum()), p["tail_excess_mean"], p["phi"])
        dur[night & (six == "T")] = 1
        dur[night & (six == "J")] = 0
        dur[night & (dur == 0) & (six != "J")] = 1
        ghs = np.empty(n, dtype=object)
        for i, r in enumerate(racine):
            lst = ref.get(r) or ["9999"]
            ghs[i] = lst[min(int(level[i]) - 1, len(lst) - 1)]
        ghs[rng.random(n) < p["p_ghs_9999"].get(ys, 0.003)] = "9999"
        last = p["last_month_2026"] if y == 2026 else 12
        fin = _dates(rng, y, n, last)
        cmd = np.array([r[:2] for r in racine])
        letters = np.array([CMD_LETTERS.get(c, "R") for c in cmd], dtype=object)
        dp_letter = np.array([rng.choice(list(s)) for s in letters])
        fme_p = calib.params("fme") if calib.available("fme.json") else None
        r_share = fme_p["p_dp_letter"].get(ys, {}) if fme_p else {}
        extra = rng.random(n) < (r_share.get("R", 0.0) + r_share.get("Z", 0.0) * 0.5)
        dp_letter[extra] = rng.choice(["R", "Z"], size=int(extra.sum()))
        dp3 = np.array([l + f"{rng.integers(0, 100):02d}" for l in dp_letter], dtype=object)
        imprecise = rng.random(n) < (fme_p["p_dp_sans_precision"].get(ys, 0.045) if fme_p else 0.045)
        df = pd.DataFrame({
            "annee": y, "CODE_CMD": cmd, "CODE_GHM": [r[2:] + s for r, s in zip(racine, six)], "CODE_GHS": ghs,
            "DUREE_SEJOUR": dur, "DATE_FIN": fin.dt.strftime("%Y-%m-%d"),
            "DATE_DEBUT": (fin - pd.to_timedelta(dur, unit="D")).dt.strftime("%Y-%m-%d"),
            "DP_RETENU": _dp_code(rng, dp3, imprecise, p["forme_dp"].get(ys) or p["forme_dp"][max(p["forme_dp"])]),
            "perimetre": "hospital",
        })
        parts.append(df)
    df = _finish(rng, pd.concat(parts, ignore_index=True), p)
    return {"TB_SYNTH_RSS": _rss_columns(df), "TB_SEJOUR": _sejour(df, rng, p)}


def _rss_columns(df: pd.DataFrame) -> pd.DataFrame:
    cols = ["ID_RSS", "ID_SEJOUR", "ID_PATIENT", "NO_SEJOUR", "NO_RSS", "CODE_CMD", "CODE_GHM", "CODE_GHS", "DUREE_SEJOUR", "MONTANT_GHS",
            "DATE_DEBUT", "DATE_FIN", "DP_RETENU", "MODE_ENTREE", "CODE_PROVENANCE", "MODE_SORTIE", "CODE_DESTINATION", "VERSION", "NB_RUM", "STATUT"]
    return df[cols + [c for c in ("ID_UNITE_HEBERG",) if c in df]].reset_index(drop=True)


def _sejour(df: pd.DataFrame, rng: np.random.Generator, p: dict, extras: bool = True) -> pd.DataFrame:
    """Séjours des RSS, plus (hôpital entier) les séjours sans RSS, dont une part ouverte, sans date de sortie."""
    base = df[["ID_SEJOUR", "ID_PATIENT", "NO_SEJOUR", "DATE_DEBUT", "DATE_FIN"]].rename(columns={"DATE_DEBUT": "DATE_ENTREE", "DATE_FIN": "DATE_SORTIE"})
    base = base.assign(ETAT="clos", CHAMP="MCO PMSI", AVEC_RSS="O")
    if not extras:
        return base.reset_index(drop=True)
    parts, year = [base], df["DATE_FIN"].str[:4]
    nxt = int(base["ID_SEJOUR"].max()) + 1
    for y, s in p["sejour"].items():
        n_rss = int((year == y).sum())
        n = int(round(n_rss * s["p_sans_rss"] / (1 - s["p_sans_rss"]))) if n_rss else 0
        if not n:
            continue
        last = p["last_month_2026"] if y == "2026" else 12
        sortie = _dates(rng, int(y), n, last)
        nights = np.where(rng.random(n) < s["p_zero_nuit_sans_rss"], 0, rng.geometric(1 / 3.0, size=n))
        ouvert = rng.random(n) < s["p_ouvert_sans_rss"]
        ids = np.arange(nxt, nxt + n)
        nxt += n
        parts.append(pd.DataFrame({
            "ID_SEJOUR": ids, "ID_PATIENT": rng.integers(1, max(n_rss, 2), size=n) + 900_000, "NO_SEJOUR": [f"S{v:09d}" for v in ids],
            "DATE_ENTREE": (sortie - pd.to_timedelta(nights, unit="D")).dt.strftime("%Y-%m-%d"),
            "DATE_SORTIE": np.where(ouvert, "", sortie.dt.strftime("%Y-%m-%d")),
            "ETAT": np.where(ouvert, "ouvert", "clos"), "CHAMP": _choice(rng, s["champ_sans_rss"], n), "AVEC_RSS": "N"}))
    return pd.concat(parts, ignore_index=True)


def _fme(rng, scale: float, years: list[int]) -> dict[str, pd.DataFrame]:
    p, f = calib.params("rss"), calib.params("fme")
    cells = calib.table("fme_cells.csv")
    uf = calib.table("fme_uf.csv")
    hors = calib.table("fme_hors_pole.csv")
    parts = []
    for y in years:
        ys = str(y)
        if ys not in f["tail"]:
            continue
        c = cells[cells["annee"] == ys]
        t = f["tail"][ys]
        lt = c["n_rss"] == "<10"
        w = np.where(lt, t["n_per_lt10_cell"], pd.to_numeric(c["n_rss"], errors="coerce").fillna(0))
        mean = np.where(lt, t["mean_nights_lt10"], pd.to_numeric(c["mean_nights"], errors="coerce").fillna(0))
        n = max(int(round(t["n_total"] * scale)), 0)
        pick = rng.choice(len(c), size=n, p=w / w.sum())
        sel = c.iloc[pick].reset_index(drop=True)
        dur = sample_nb(rng, mean[pick], p["phi"])
        last = p["last_month_2026"] if y == 2026 else 12
        fin = _dates(rng, y, n, last)
        racine = sel["ghm"].str[:5]
        df = pd.DataFrame({
            "annee": y, "CODE_CMD": sel["ghm"].str[:2], "CODE_GHM": sel["ghm"].str[2:], "CODE_GHS": sel["code_ghs"],
            "DUREE_SEJOUR": dur, "DATE_FIN": fin.dt.strftime("%Y-%m-%d"),
            "DATE_DEBUT": (fin - pd.to_timedelta(dur, unit="D")).dt.strftime("%Y-%m-%d"),
            "ID_UNITE_HEBERG": sel["code_uf"], "perimetre": "fme",
        })
        imprecise = (sel["dp_sp"] == "1").to_numpy()
        df["DP_RETENU"] = _dp_code(rng, sel["dp3"].to_numpy(dtype=object), imprecise, p["forme_dp"].get(ys) or p["forme_dp"][max(p["forme_dp"])])
        parts.append(df)
    df = _finish(rng, pd.concat(parts, ignore_index=True), p)
    rum = pd.DataFrame({"ID_RSS": df["ID_RSS"], "ID_SEJOUR": df["ID_SEJOUR"], "ID_UNITE_HEBERG": df["ID_UNITE_HEBERG"], "DATE_DEBUT": df["DATE_DEBUT"], "DATE_FIN": df["DATE_FIN"]})
    extra = []
    for y in years:
        if str(y) not in f["p_rum_hors_pole"]:
            continue
        idx = np.where(df["annee"].to_numpy() == y)[0]
        pick = idx[rng.random(len(idx)) < f["p_rum_hors_pole"][str(y)]]
        h = hors[hors["annee"] == str(y)]
        hw = pd.to_numeric(h["n_sej"], errors="coerce").fillna(5).to_numpy()
        e = rum.iloc[pick].copy()
        e["ID_UNITE_HEBERG"] = h["code_uf_hors"].to_numpy()[rng.choice(len(h), size=len(e), p=hw / hw.sum())]
        extra.append(e)
    rum = pd.concat([rum] + extra, ignore_index=True)
    df["NB_RUM"] = df["ID_RSS"].map(rum["ID_RSS"].value_counts())
    out = _rss_columns(df)
    return {"TB_SYNTH_RSS": out, "TB_SYNTH_RUM": rum, "TB_SEJOUR": _sejour(df, rng, p, extras=False), "REF_UF_POLE_FME": calib.table("fme_uf.csv"),
            "PMSI_LIB_GHS_TARIF": calib.table("ghs_tarif.csv").rename(columns={"code_ghm_racine": "CODE_GHM_RACINE"})}
