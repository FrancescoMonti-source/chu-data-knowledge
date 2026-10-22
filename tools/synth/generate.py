"""Écrit des tables synthétiques : `python tools/synth/generate.py --out DOSSIER [--seed N] [--scale 0.02] [--years 2022-2025]
[--perimeter hospital|fme] [--families rss]`. Le dossier reçoit un CSV par table et manifest.json (graine, réglages, provenance)."""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import synth  # noqa: E402


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--out", type=Path)
    ap.add_argument("--list", action="store_true", help="liste les familles, leurs tables et leurs colonnes, sans rien écrire")
    ap.add_argument("--seed", type=int, default=synth.DEFAULT_SEED)
    ap.add_argument("--scale", type=float, default=0.02, help="part du volume réel : 1 = autant de séjours que l'hôpital")
    ap.add_argument("--years", default="2022-2025")
    ap.add_argument("--perimeter", choices=["hospital", "fme"], default="hospital")
    ap.add_argument("--families", nargs="+", default=["rss"], choices=sorted(synth.GENERATORS))
    a = ap.parse_args()
    if a.list:
        for fam in sorted(synth.GENERATORS):
            print(f"## {fam} : {sys.modules[synth.GENERATORS[fam].__module__].__doc__.splitlines()[0]}")
            seen: dict[str, list[str]] = {}
            for perimeter in (["hospital", "fme"] if fam == "rss" else ["hospital"]):
                tables, _ = synth.generate(1, 0.001 if perimeter == "hospital" else 0.01, range(2025, 2026), perimeter, [fam])
                for name, df in tables.items():
                    if seen.get(name) != list(df.columns):
                        print(f"- {name}{' (--perimeter fme)' if perimeter == 'fme' else ''} : {', '.join(df.columns)}")
                        seen[name] = list(df.columns)
        return 0
    if a.out is None:
        ap.error("--out est requis (ou --list)")
    tables, manifest = synth.generate(a.seed, a.scale, synth.parse_years(a.years), a.perimeter, a.families)
    a.out.mkdir(parents=True, exist_ok=True)
    for name, df in tables.items():
        df.to_csv(a.out / f"{name}.csv", index=False)
    (a.out / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print(json.dumps(manifest["rows"], ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
