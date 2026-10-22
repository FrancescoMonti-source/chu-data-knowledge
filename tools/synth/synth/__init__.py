"""Générateur de données synthétiques du CHU, calibré sur des agrégats masqués. Voir tools/synth/README.md."""
from __future__ import annotations

import numpy as np
import pandas as pd

from . import calib
from .tables import GENERATORS
from .tables import bloc as _bloc  # noqa: F401  (inscrit les générateurs)
from .tables import htp as _htp  # noqa: F401
from .tables import rss as _rss  # noqa: F401  (inscrit le générateur)

DEFAULT_SEED = 20261022


def parse_years(spec: str) -> list[int]:
    """« 2022-2025 » ou « 2022,2024 »."""
    out: list[int] = []
    for part in spec.split(","):
        a, _, b = part.partition("-")
        out += list(range(int(a), int(b or a) + 1))
    return out


def generate(seed: int = DEFAULT_SEED, scale: float = 0.02, years=range(2022, 2026), perimeter: str = "hospital", families=("rss",)) -> tuple[dict[str, pd.DataFrame], dict]:
    """Retourne ({table: DataFrame}, manifeste). Même graine et mêmes réglages : mêmes lignes."""
    tables: dict[str, pd.DataFrame] = {}
    prov: dict = {}
    for i, fam in enumerate(families):
        rng = np.random.default_rng([seed, i])
        kwargs = {"perimeter": perimeter} if fam == "rss" else {}
        tables.update(GENERATORS[fam](rng, scale, list(years), **kwargs))
        prov[fam] = {"sources": calib.params(fam)["sources"] if calib.available(f"{fam}.json") else [],
                     "assumptions": calib.params(fam).get("assumptions", [])}
        if fam == "rss" and perimeter == "fme":
            prov["fme"] = {"sources": calib.params("fme")["sources"], "assumptions": calib.params("fme")["assumptions"]}
    manifest = {
        "synthetic": True, "seed": seed, "scale": scale, "years": list(years), "perimeter": perimeter, "families": list(families),
        "rows": {k: int(len(v)) for k, v in tables.items()}, "provenance": prov,
        "note": "données synthétiques, calibrées sur des agrégats masqués ; aucune ligne ne correspond à une personne",
    }
    return tables, manifest
