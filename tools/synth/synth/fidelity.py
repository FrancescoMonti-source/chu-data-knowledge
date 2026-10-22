"""Écart entre une génération et les agrégats de calibration : `python tools/synth/fidelity.py [--scale 0.1] [--seed N]`."""
from __future__ import annotations

import numpy as np
import pandas as pd

from . import DEFAULT_SEED, calib
from . import generate as _generate


def _tol(p: float, n: int) -> float:
    return 4 * float(np.sqrt(max(p * (1 - p), 1e-4) / max(n, 1))) + 0.01


def rss_hospital(rss: pd.DataFrame, years) -> list[dict]:
    p = calib.params("rss")
    rows, year = [], rss["DATE_FIN"].str[:4]
    for y in map(str, years):
        g = rss[year == y]
        n = len(g)
        if not n:
            continue
        ghm6 = g["CODE_CMD"] + g["CODE_GHM"]
        is_seance = (g["CODE_CMD"] == "28")
        got = {"seance": is_seance.mean(), "zero_nuit": ((g["DUREE_SEJOUR"] == 0) & ~is_seance).mean(), "nuit": (g["DUREE_SEJOUR"] > 0).mean()}
        for k, v in got.items():
            t = p["classe"][y].get(k, 0)
            rows.append({"mesure": f"classe {k}", "cle": y, "cible": t, "obtenu": v, "tolerance": _tol(t, n)})
        rows.append({"mesure": "GHS 9999", "cle": y, "cible": p["p_ghs_9999"][y], "obtenu": (g["CODE_GHS"] == "9999").mean(), "tolerance": _tol(p["p_ghs_9999"][y], n)})
        night = g[g["DUREE_SEJOUR"] > 0]
        for t in ("C", "M"):
            sel = night[night["CODE_GHM"].str[0].isin(["C", "K"] if t == "C" else ["M", "Z"]) & night["CODE_GHM"].str[-1].eq("1")]
            if len(sel) < 200:
                continue
            tgt = {k: v for k, v in p["duree_classes"][f"{t}|1"].items() if k != "0"}
            s = sum(tgt.values())
            d = sel["DUREE_SEJOUR"]
            obs = {"1": (d == 1).mean(), "2": (d == 2).mean(), "3": (d == 3).mean(), "4": (d == 4).mean(), "5+": (d >= 5).mean()}
            for k, v in obs.items():
                rows.append({"mesure": f"durée niveau 1 type {t}", "cle": f"{y} {k}", "cible": tgt[k] / s, "obtenu": v, "tolerance": _tol(tgt[k] / s, len(sel)) + 0.02})
    return rows


def rss_fme(rss: pd.DataFrame, years) -> list[dict]:
    f = calib.params("fme")
    rows, year = [], rss["DATE_FIN"].str[:4]
    for y in map(str, years):
        g = rss[year == y]
        if y not in f["tail"] or not len(g):
            continue
        rows.append({"mesure": "FME n_rss", "cle": y, "cible": f["tail"][y]["n_total"], "obtenu": float(len(g)), "tolerance": 0.02 * f["tail"][y]["n_total"]})
        rows.append({"mesure": "FME DMS (nuitées)", "cle": y, "cible": f["dms_pole"][y], "obtenu": float(g["DUREE_SEJOUR"].mean()), "tolerance": 0.2})
    return rows


def sejour(tables: dict, years) -> list[dict]:
    p = calib.params("rss")["sejour"]
    s, rows = tables["TB_SEJOUR"], []
    for y in map(str, years):
        g = s[(s["DATE_SORTIE"].str[:4] == y) | ((s["DATE_SORTIE"] == "") & (s["DATE_ENTREE"].str[:4] == y))]
        if y not in p or not len(g):
            continue
        rows.append({"mesure": "séjours sans RSS", "cle": y, "cible": p[y]["p_sans_rss"], "obtenu": float((g["AVEC_RSS"] == "N").mean()), "tolerance": _tol(p[y]["p_sans_rss"], len(g))})
    return rows


def bloc(tables: dict, years) -> list[dict]:
    p = calib.params("bloc")["durees_moyennes"]
    i, rows = tables["INTERVENTIONS"], []
    mins = lambda a, b: (pd.to_datetime(i[a]) - pd.to_datetime(i[b])).dt.total_seconds() / 60
    cols = {"occupation_min": mins("FIN", "DEBUT"), "tros_min": mins("DEBUT_BIONET", "DEBUT"), "incision_min": mins("FIN_INCISION", "DEBUT_INCISION")}
    for y in map(str, years):
        sel = i["DEBUT"].str[:4] == y
        if y not in p or not sel.any():
            continue
        for k, s in cols.items():
            rows.append({"mesure": f"bloc {k} moyenne", "cle": y, "cible": p[y][k], "obtenu": float(s[sel].mean()), "tolerance": 0.06 * p[y][k]})
    return rows


def htp(tables: dict) -> list[dict]:
    p = calib.params("htp")
    t = tables["TB_MVT_SSR_SEM"]
    gmt = {(c["gn"], c["gr"]): c["mnt_gmt_moyen"] for c in p["cells"] if c["n_rhs"] >= 100}
    return [{"mesure": "HTP montant GMT moyen", "cle": f"{gn}-{gr}", "cible": m, "obtenu": float(t[(t["GN"] == gn) & (t["GR"] == gr)]["MNT_GMT"].mean()), "tolerance": 0.08 * m}
            for (gn, gr), m in gmt.items()]


def report(scale: float = 0.1, seed: int = DEFAULT_SEED, fme: bool = True) -> pd.DataFrame:
    rows = []
    t, _ = _generate(seed, scale, range(2022, 2026), "hospital")
    rows += rss_hospital(t["TB_SYNTH_RSS"], range(2022, 2026))
    rows += sejour(t, range(2022, 2026))
    t, _ = _generate(seed, 0.3, range(2023, 2026), "hospital", ("bloc",))
    rows += bloc(t, range(2023, 2026))
    t, _ = _generate(seed, 1.0, [2025], "hospital", ("htp",))
    rows += htp(t)
    if fme and calib.available("fme.json"):
        t, _ = _generate(seed, 1.0, range(2022, 2027), "fme")
        rows += rss_fme(t["TB_SYNTH_RSS"], range(2022, 2027))
    df = pd.DataFrame(rows)
    df["ecart"] = df["obtenu"] - df["cible"]
    df["ok"] = df["ecart"].abs() <= df["tolerance"]
    return df


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--scale", type=float, default=0.1)
    ap.add_argument("--seed", type=int, default=DEFAULT_SEED)
    a = ap.parse_args()
    r = report(a.scale, a.seed)
    print(r.round(4).to_string(index=False))
    print(f"\n{int(r['ok'].sum())}/{len(r)} dans la tolérance")
    raise SystemExit(0 if r["ok"].all() else 1)
