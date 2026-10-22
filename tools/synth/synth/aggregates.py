"""Lecture des agrégats masqués du dépôt (preuves, CSV de retours) et traitement des cellules masquées."""
from __future__ import annotations

import re
from pathlib import Path

import numpy as np
import pandas as pd

LT10 = 5.0  # valeur imputée à une cellule « <10 » (milieu de 1..9, arrondi)
META_COLUMNS = ("QUERY_ID", "DATABASE_NAME", "RUN_AT")
MASKED_WORDS = {"masqué", "masque"}


def parse_number(text: str) -> float:
    """« 1397 » → 1397.0 ; « 1,38 » → 1.38 ; « <10 » ou « masqué » → NaN ; texte quelconque → NaN."""
    t = str(text).strip().replace(" ", "").replace(" ", "")
    if re.fullmatch(r"-?\d+(?:[.,]\d+)?", t):
        return float(t.replace(",", "."))
    return float("nan")


def cell_state(text: str) -> str:
    """ok, lt10 (« <10 »), masked (suppression secondaire, « masqué ») ou other."""
    t = str(text).strip().lower()
    if t == "<10":
        return "lt10"
    if t in MASKED_WORDS:
        return "masked"
    return "ok" if not np.isnan(parse_number(t)) else "other"


def read_markdown_table(path: Path) -> pd.DataFrame:
    """Premier tableau Markdown d'un fichier, en texte, sans les colonnes d'exécution (QUERY_ID…)."""
    rows = [line.strip() for line in Path(path).read_text(encoding="utf-8").splitlines() if line.startswith("|")]
    if len(rows) < 2:
        return pd.DataFrame()
    split = lambda line: [c.strip() for c in line.strip("|").split("|")]
    header, body = split(rows[0]), [split(r) for r in rows[2:]]
    body = [r + [""] * (len(header) - len(r)) for r in body]
    df = pd.DataFrame(body, columns=header)
    return df.drop(columns=[c for c in META_COLUMNS if c in df.columns])


def add_counts(df: pd.DataFrame, n_col: str = "N") -> pd.DataFrame:
    """Ajoute `n` (float, NaN si masqué) et `state` d'après la colonne d'effectif ; les autres colonnes restent du texte."""
    out = df.copy()
    out["n"] = out[n_col].map(parse_number)
    out["state"] = out[n_col].map(cell_state)
    return out


def fill_masked(df: pd.DataFrame, group: list[str], pct_col: str | None = None, totals: pd.Series | None = None) -> pd.DataFrame:
    """Impute `n_fill` : lt10 → LT10, masked (suppression secondaire) → reste du groupe, réparti entre ses cellules masquées.

    Le total d'un groupe vient de `totals` (Series indexée par les colonnes de `group`) ou, à défaut, de n / pct × 100
    sur ses cellules visibles (médiane). Sans total, une cellule masquée vaut LT10. Le reste est répété à parts égales
    entre les cellules masquées, après les cellules lt10 (au plus LT10 chacune). Documenté : README, « Cellules masquées ».
    """
    out = df.copy()
    out["n_fill"] = out["n"]
    pct = out[pct_col].map(parse_number) if pct_col and pct_col in out else None
    for key, idx in out.groupby(group, dropna=False).groups.items():
        key = key[0] if isinstance(key, tuple) and len(key) == 1 else key  # pandas ≥ 3 : clé en tuple
        g = out.loc[idx]
        lt, masked = g.index[g["state"] == "lt10"], g.index[g["state"] == "masked"]
        if not len(lt) and not len(masked):
            continue
        visible = float(g.loc[g["state"] == "ok", "n"].sum())
        total = None
        if totals is not None and key in totals.index:
            total = float(totals.loc[key])
        elif pct is not None:
            ok = (g["state"] == "ok") & (pct.loc[idx] > 0)
            if ok.any():
                total = float((g.loc[ok, "n"] / pct.loc[idx][ok] * 100).median())
        rest = max(total - visible, 0.0) if total is not None else None
        a = LT10 if rest is None else min(LT10, rest / (len(lt) + 10 * len(masked)))
        out.loc[lt, "n_fill"] = a
        if len(masked):
            out.loc[masked, "n_fill"] = LT10 if rest is None else max(rest - a * len(lt), a) / len(masked)
    out["n_fill"] = out["n_fill"].fillna(0.0)
    return out


def read_csv_text(path: Path) -> pd.DataFrame:
    """CSV de retour (cellules, bornes…) en texte, pour garder « <10 »."""
    return pd.read_csv(path, dtype=str, keep_default_na=False)


def normalize(weights) -> np.ndarray:
    w = np.asarray(weights, dtype=float)
    s = w.sum()
    return w / s if s > 0 else np.full(len(w), 1.0 / max(len(w), 1))


def to_distribution(df: pd.DataFrame, key: str, n: str = "n_fill") -> dict[str, float]:
    """Proportions {valeur: part} d'une colonne, d'après les effectifs imputés."""
    s = df.groupby(key)[n].sum()
    s = s[s > 0]
    return {str(k): round(float(v), 6) for k, v in (s / s.sum()).items()}

