"""Lit le fichier Structure (xlsx) en mémoire : une ligne par UF, sans les colonnes de personnes.

Les noms des chefs de pôle, de service et des responsables d'UF ne sont jamais lus. Rien n'est écrit sur
le disque. Colonnes repérées par leur titre (accents, casse et espaces ignorés) : « Code UF », « Libellé UF »
(et court, très long), « Date fin UF », « Code Pôle », « Libellé Pôle », « Code Service », « Libellé Service ».
"""

from __future__ import annotations

import datetime as dt
import re
import unicodedata
from pathlib import Path


def normaliser(texte) -> str:
    """Majuscules sans accents ni ponctuation, espaces réduits : « Néonatalogie  3ème » → « NEONATALOGIE 3EME »."""
    sans = unicodedata.normalize("NFD", str(texte or "")).encode("ascii", "ignore").decode()
    return " ".join(re.sub(r"[^A-Z0-9]+", " ", sans.upper()).split())


def code(valeur) -> str:
    """Un code lu dans une cellule : 5618.0 devient « 5618 »."""
    if isinstance(valeur, float) and valeur.is_integer():
        valeur = int(valeur)
    return str(valeur if valeur is not None else "").strip()


def date(valeur) -> dt.date | None:
    """Une date de cellule (date Excel ou texte JJ/MM/AAAA, AAAA-MM-JJ) ; None si vide ou illisible."""
    if isinstance(valeur, dt.datetime):
        return valeur.date()
    if isinstance(valeur, dt.date):
        return valeur
    texte = str(valeur or "").strip()
    for forme in ("%d/%m/%Y", "%Y-%m-%d", "%d/%m/%y"):
        try:
            return dt.datetime.strptime(texte[:10], forme).date()
        except ValueError:
            pass
    return None


def colonnes(entete: list[str]) -> dict[str, int]:
    """Position de chaque colonne utile, d'après son titre normalisé ; absente si le titre manque."""
    n = [normaliser(h) for h in entete]

    def cherche(*motifs, sauf=()):
        for i, h in enumerate(n):
            if all(m in h for m in motifs) and not any(s in h for s in sauf):
                return i
        return None

    trouvees = {
        "code_uf": cherche("CODE UF"), "libelle_uf": cherche("LIBELLE UF", sauf=("COURT", "LONG")),
        "libelle_court": cherche("LIBELLE", "COURT", "UF"), "libelle_long": cherche("LIBELLE", "LONG", "UF"),
        "date_fin": cherche("DATE FIN UF"), "code_pole": cherche("CODE POLE"), "libelle_pole": cherche("LIBELLE POLE"),
        "code_service": cherche("CODE SERVICE"), "libelle_service": cherche("LIBELLE SERVICE"),
    }
    return {k: v for k, v in trouvees.items() if v is not None}


def lire_structure(chemin: Path) -> list[dict]:
    """Les lignes du fichier : {code_uf, libelle_uf, libelle_court, libelle_long, date_fin, code_pole, ...}."""
    from openpyxl import load_workbook

    wb = load_workbook(chemin, read_only=True, data_only=True)
    try:
        for feuille in wb.worksheets:
            lignes = [l for l in feuille.iter_rows(values_only=True) if any(c not in (None, "") for c in l)]
            debut = next((k for k, l in enumerate(lignes) if "code_uf" in colonnes([str(c or "") for c in l])), None)
            if debut is None:
                continue
            pos = colonnes([str(c or "") for c in lignes[debut]])
            sortie = []
            for l in lignes[debut + 1:]:
                ligne = {k: (l[i] if i < len(l) else None) for k, i in pos.items()}
                if not code(ligne.get("code_uf")):
                    continue
                ligne["code_uf"] = code(ligne["code_uf"])
                ligne["date_fin"] = date(ligne.get("date_fin"))
                for k in ("code_pole", "code_service"):
                    ligne[k] = code(ligne.get(k))
                for k in ("libelle_uf", "libelle_court", "libelle_long", "libelle_pole", "libelle_service"):
                    ligne[k] = " ".join(str(ligne.get(k) or "").split())
                sortie.append(ligne)
            return sortie
    finally:
        wb.close()
    raise ValueError(f"{chemin} : aucune feuille n'a de colonne « Code UF »")


def date_du_fichier(chemin: Path) -> dt.date:
    """La date portée par le nom du fichier : Structure-09102026.xlsx → 2026-10-09."""
    m = re.search(r"(\d{2})(\d{2})(\d{4})", Path(chemin).stem)
    if not m:
        raise ValueError(f"{chemin} : pas de date JJMMAAAA dans le nom")
    return dt.date(int(m[3]), int(m[2]), int(m[1]))
