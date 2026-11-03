"""Prépare, depuis le fichier Structure, la liste des services à annoter d'une spécialité, puis contrôle l'annotation.

Le fichier Structure n'a pas de colonne de spécialité (claim specialite-absente-des-uf) : la spécialité d'un
service est une table de correspondance que Pierre tient en local, à partir du service du fichier.

    python sources\\structures\\exporter_services.py                 écrit local/services-a-annoter-AAAAMMJJ.csv
    python sources\\structures\\exporter_services.py --annote FICHIER   compte les services annotés et les UF couvertes

Le CSV contient les codes et libellés de service et de pôle (jamais les noms de chefs ni de responsables) et une
colonne « specialite » vide. Il reste dans sources/structures/local/ (ignoré par Git) : ni lui ni le fichier annoté
ne se committent ni ne se collent dans une conversation. La console n'affiche que des comptages.
"""

from __future__ import annotations

import argparse
import csv
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from lire_structure import date_du_fichier, lire_structure  # noqa: E402

LOCAL = Path(__file__).resolve().parent / "local"
COLONNES = ["code_service", "libelle_service", "code_pole", "libelle_pole", "nb_uf", "specialite"]


def dernier_fichier() -> Path:
    candidats = sorted(LOCAL.glob("Structure-*.xlsx"), key=date_du_fichier)
    if not candidats:
        sys.exit(f"Aucun Structure-*.xlsx dans {LOCAL} : lancer recuperer_structure.py, ou donner --fichier.")
    return candidats[-1]


def services(lignes: list[dict]) -> list[dict]:
    """Un service par Code Service : ses libellés, son pôle (le premier vu) et son nombre d'UF."""
    par_service: dict[str, dict] = {}
    ufs = defaultdict(set)
    for l in lignes:
        cle = l["code_service"]
        par_service.setdefault(cle, {
            "code_service": cle, "libelle_service": l["libelle_service"],
            "code_pole": l["code_pole"], "libelle_pole": l["libelle_pole"]})
        ufs[cle].add(l["code_uf"])
    sortie = []
    for cle, s in par_service.items():
        sortie.append({**s, "nb_uf": len(ufs[cle]), "specialite": ""})
    return sorted(sortie, key=lambda s: (s["code_pole"], s["code_service"]))


def ecrire(chemin: Path, liste: list[dict]) -> None:
    chemin.parent.mkdir(parents=True, exist_ok=True)
    with chemin.open("w", encoding="utf-8-sig", newline="") as f:
        w = csv.DictWriter(f, fieldnames=COLONNES, delimiter=";")
        w.writeheader()
        w.writerows(liste)


def controler(annote: Path, lignes: list[dict]) -> dict[str, int]:
    """Comptages seulement : services annotés ou non, UF couvertes, codes inconnus du fichier."""
    with annote.open(encoding="utf-8-sig", newline="") as f:
        lus = list(csv.DictReader(f, delimiter=";"))
    spe = {r["code_service"].strip(): (r.get("specialite") or "").strip() for r in lus}
    codes_fichier = {l["code_service"] for l in lignes}
    ufs = defaultdict(set)
    for l in lignes:
        ufs[l["code_service"]].add(l["code_uf"])
    annotes = {c for c, v in spe.items() if v and c in codes_fichier}
    return {
        "services_du_fichier": len(codes_fichier),
        "services_annotes": len(annotes),
        "services_sans_specialite": len(codes_fichier - annotes),
        "services_du_csv_absents_du_fichier": len(set(spe) - codes_fichier),
        "uf_du_fichier": len({l["code_uf"] for l in lignes}),
        "uf_couvertes": len({u for c in annotes for u in ufs[c]}),
        "specialites_distinctes": len({spe[c] for c in annotes}),
    }


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    p.add_argument("--fichier", type=Path, help="le fichier Structure xlsx (défaut : le plus récent de local/)")
    p.add_argument("--annote", type=Path, help="le CSV annoté, à contrôler (comptages seulement)")
    p.add_argument("--sortie", type=Path, help="dossier du CSV à annoter (défaut : local/)")
    args = p.parse_args(argv)
    fichier = args.fichier or dernier_fichier()
    lignes = lire_structure(fichier)
    if args.annote:
        for k, v in controler(args.annote, lignes).items():
            print(f"{k} : {v}")
        return 0
    cible = (args.sortie or LOCAL) / f"services-a-annoter-{date_du_fichier(fichier):%Y%m%d}.csv"
    liste = services(lignes)
    ecrire(cible, liste)
    print(f"{len(liste)} services, {len({l['code_uf'] for l in lignes})} UF. À annoter (colonne specialite) : {cible}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
