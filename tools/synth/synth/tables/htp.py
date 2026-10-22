"""RHS d'HTP en SMR (2025) synthétiques : GN × GR, durées de présence, scores RR et montants de GMT."""
from __future__ import annotations

import numpy as np
import pandas as pd

from .. import calib
from . import generator


@generator("htp")
def htp(rng: np.random.Generator, scale: float, years: list[int]) -> dict[str, pd.DataFrame]:
    p = calib.params("htp")
    if p["annee"] not in years:
        return {"TB_MVT_SSR_SEM": pd.DataFrame(columns=["ID_RHS", "ID_PATIENT", "ANNEE", "SEMAINE", "GN", "GR", "NBJ_PRES", "SCORE_RR", "MNT_GMT", "MNT_GMT_HEBDO", "MNT_TOTAL"])}
    parts = []
    for c in p["cells"]:
        n = int(round(c["n_rhs"] * scale))
        if not n:
            continue
        lo, mo, hi = c["score_min"] or 0, c["score_moy"] or 0, c["score_max"] or 0
        if hi > lo and lo < mo < hi:
            k = 4.0
            mu = (mo - lo) / (hi - lo)
            score = lo + rng.beta(mu * k, (1 - mu) * k, size=n) * (hi - lo)
        else:
            score = np.full(n, mo)
        mnt = rng.lognormal(np.log(c["mnt_gmt_moyen"]) - 0.25**2 / 2, 0.25, size=n)
        parts.append(pd.DataFrame({"GN": c["gn"], "GR": c["gr"], "NBJ_PRES": np.maximum(1, rng.poisson(c["jours_par_rhs"], size=n)),
                                   "SCORE_RR": score.round().astype(int), "MNT_GMT": mnt.round(2)}))
    df = pd.concat(parts, ignore_index=True)
    n = len(df)
    df.insert(0, "ID_RHS", np.arange(1, n + 1) + 60_000_000)
    df.insert(1, "ID_PATIENT", rng.integers(1, max(int(n * 0.45), 2), size=n) + 800_000)
    df.insert(2, "ANNEE", p["annee"])
    df.insert(3, "SEMAINE", rng.integers(1, 53, size=n))
    df["MNT_GMT_HEBDO"] = 0.0
    df["MNT_TOTAL"] = df["MNT_GMT"]
    return {"TB_MVT_SSR_SEM": df}
