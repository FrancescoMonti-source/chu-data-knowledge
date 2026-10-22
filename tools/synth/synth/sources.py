"""Accès aux sources de calibration, avec la liste de ce qui a été lu (pour la provenance)."""
from __future__ import annotations

import re
from pathlib import Path

import pandas as pd

from . import aggregates as agg

REPO = Path(__file__).resolve().parents[3]


class Sources:
    """Preuves de knowledge/evidence/ et fichiers de retours DIM-code (branche retours-cdk, hors du dépôt)."""

    def __init__(self, evidence_dir: Path | None = None, dimcode_dir: Path | None = None):
        self.evidence_dir = Path(evidence_dir or REPO / "knowledge" / "evidence")
        self.dimcode_dir = Path(dimcode_dir) if dimcode_dir else None
        self.used: list[str] = []

    def evidence(self, evidence_id: str) -> pd.DataFrame:
        self.used.append(f"evidence:{evidence_id}")
        return agg.read_markdown_table(self.evidence_dir / f"{evidence_id}.md")

    def dimcode_csv(self, name: str) -> pd.DataFrame:
        self.used.append(f"dimcode:{name}")
        return agg.read_csv_text(self._dimcode(name))

    def dimcode_text(self, name: str) -> str:
        self.used.append(f"dimcode:{name}")
        return self._dimcode(name).read_text(encoding="utf-8")

    def _dimcode(self, name: str) -> Path:
        if self.dimcode_dir is None:
            raise FileNotFoundError(f"{name} : indiquer --dimcode (copie de la branche retours-cdk de DIM-code, dossier d'un retour)")
        return self.dimcode_dir / name


def text_block_table(text: str, heading: str) -> pd.DataFrame:
    """Tableau « ```text » aligné sous un titre `## heading` d'un fichier de synthèse (colonnes séparées par des blancs)."""
    m = re.search(rf"## {re.escape(heading)}\s+```text\n(.*?)```", text, flags=re.S)
    if not m:
        return pd.DataFrame()
    lines = [l.split() for l in m.group(1).strip().splitlines()]
    return pd.DataFrame(lines[1:], columns=lines[0])
