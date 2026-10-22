"""Chargement de calibration/ et de la liste de ce qui est mesuré ou supposé."""
from __future__ import annotations

import json
from functools import lru_cache
from pathlib import Path

import pandas as pd

CAL = Path(__file__).resolve().parents[1] / "calibration"


@lru_cache(maxsize=None)
def params(name: str) -> dict:
    return json.loads((CAL / f"{name}.json").read_text(encoding="utf-8"))


@lru_cache(maxsize=None)
def table(name: str) -> pd.DataFrame:
    return pd.read_csv(CAL / name, dtype=str, keep_default_na=False)


def available(name: str) -> bool:
    return (CAL / name).exists()
