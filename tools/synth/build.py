"""Construit calibration/ à partir des agrégats : `python tools/synth/build.py [--dimcode DOSSIER] [--check]`.

--dimcode : dossier d'un retour de la branche retours-cdk de DIM-code (cellules.csv, bornes.csv…), si on veut
(re)calculer les extracteurs qui en dépendent. Sans lui, ils sont ignorés et leurs fichiers gardés.
--check : ne réécrit rien, échoue si calibration/ n'est plus celle que les sources donnent (utilisé par la CI).
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from synth import extractors  # noqa: E402
from synth.sources import Sources  # noqa: E402

CAL = Path(__file__).resolve().parent / "calibration"


def build(dimcode: Path | None) -> dict[str, bytes]:
    """Retourne {nom de fichier: contenu} pour chaque extracteur calculable."""
    files: dict[str, bytes] = {}
    for name, fn in extractors.EXTRACTORS.items():
        src = Sources(dimcode_dir=dimcode)
        try:
            params = fn(src)
        except FileNotFoundError as e:
            print(f"ignoré : {name} ({e})", file=sys.stderr)
            continue
        for fname, df in params.pop("_files", {}).items():
            files[fname] = df.to_csv(index=False, lineterminator="\n").encode("utf-8")
        params["sources"] = sorted(set(src.used))
        files[f"{name}.json"] = (json.dumps(params, ensure_ascii=False, indent=1, sort_keys=True) + "\n").encode("utf-8")
    return files


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dimcode", type=Path)
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args()
    files = build(a.dimcode)
    if a.check:
        stale = [n for n, b in files.items() if not (CAL / n).exists() or (CAL / n).read_bytes() != b]
        if stale:
            print("calibration/ périmée :", ", ".join(stale), "\nrelancer : python tools/synth/build.py", file=sys.stderr)
            return 1
        print(f"calibration/ à jour ({len(files)} fichiers)")
        return 0
    CAL.mkdir(exist_ok=True)
    for n, b in files.items():
        (CAL / n).write_bytes(b)
    print(f"{len(files)} fichiers écrits dans {CAL}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
