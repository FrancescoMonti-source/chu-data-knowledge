"""Télécharge la dernière version du fichier « Structure » (UM, UF, services…) de l'intranet du CHU.

Le nom du fichier porte sa date (`Structure-JJMMAAAA.xlsx`, dossier `files/AAAA/MM/`). Le script sonde les
jours récents du plus récent au plus ancien jusqu'à trouver un fichier : aucune URL exacte à fournir. Il ne
lui faut que le site (`--site`, ou `--url` d'une version quelconque), donné une seule fois puis mémorisé dans
`config/local_structure.yaml` (ignoré par Git) : le code ne contient aucun nom de serveur.

Le fichier est une donnée interne : il va dans `data/external/structure/` (ignoré par Git), jamais dans un commit.

Avec `--texte`, une copie texte (une par feuille, sans les colonnes de personnes) est écrite à côté, aussi en local.
Rien de `local/` n'est versionné (.gitignore) ; la fiche de la source est `sources/structure-chu-AAAA-MM-JJ.md`.

Usage :  python sources\\structures\\recuperer_structure.py --site http://<intranet>/<site> [--texte]  (ensuite sans argument)
"""

from __future__ import annotations

import argparse
import datetime as dt
import logging
import os
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path

import yaml

logger = logging.getLogger("structure")

LOCAL = Path(__file__).resolve().parent / "local"  # ignoré par Git
CONFIG_LOCALE = LOCAL / "site.yaml"
DESTINATION = LOCAL
MOTIF_URL = re.compile(r"^(?P<base>.+)/files/\d{4}/\d{2}/(?P<prefixe>[^/]*?)\d{8}(?P<suffixe>\.[A-Za-z0-9]+)$")
MOTIF_NOM = re.compile(r"\d{8}")


def modele(url: str) -> tuple[str, str, str]:
    """Décompose l'URL d'un fichier daté en (base du site, préfixe du nom, extension)."""
    m = MOTIF_URL.match(url)
    if not m:
        raise ValueError(f"URL inattendue (attendu .../files/AAAA/MM/Nom-JJMMAAAA.ext) : {url}")
    return m["base"], m["prefixe"], m["suffixe"]


def adresses(base: str, prefixe: str, suffixe: str, jour: dt.date) -> list[str]:
    """Adresses possibles d'un fichier daté de `jour` : dossier du mois du jour ou du mois suivant."""
    suivant = (jour.replace(day=1) + dt.timedelta(days=32)).replace(day=1)
    nom = f"{prefixe}{jour:%d%m%Y}{suffixe}"
    return [f"{base}/files/{d:%Y/%m}/{nom}" for d in (jour, suivant)]


def existe(url: str, delai: float = 10) -> bool:
    """Vrai si l'URL répond 200 ; faux sur 404. Toute autre erreur (réseau, droits) est levée."""
    for methode in ("HEAD", "GET"):
        req = urllib.request.Request(url, method=methode)
        try:
            with urllib.request.urlopen(req, timeout=delai):
                return True
        except urllib.error.HTTPError as e:
            if e.code == 404:
                return False
            if e.code == 405 and methode == "HEAD":
                continue
            raise
    return False


def chercher_derniere(base: str, prefixe: str, suffixe: str, aujourdhui: dt.date, jours: int, sonde=existe) -> str | None:
    """Adresse du fichier le plus récent des `jours` derniers jours, ou None."""
    for retour in range(jours + 1):
        for url in adresses(base, prefixe, suffixe, aujourdhui - dt.timedelta(days=retour)):
            if sonde(url):
                return url
    return None


def site_connu(site: str | None, url: str | None, config: Path = CONFIG_LOCALE) -> str | None:
    """Site de l'intranet : argument, URL d'un fichier, variable STRUCTURE_SITE, puis config locale (mémorisée)."""
    if site:
        return site.rstrip("/")
    if url:
        return modele(url)[0]
    if os.environ.get("STRUCTURE_SITE"):
        return os.environ["STRUCTURE_SITE"].rstrip("/")
    if config.exists():
        return (yaml.safe_load(config.read_text(encoding="utf-8")) or {}).get("site")
    return None


def telecharger(url: str, dossier: Path) -> Path:
    """Télécharge `url` dans `dossier` (atomique) ; ne retélécharge pas un fichier déjà présent."""
    cible = dossier / url.rsplit("/", 1)[1]
    if cible.exists():
        logger.info("Déjà présent : %s", cible)
        return cible
    dossier.mkdir(parents=True, exist_ok=True)
    partiel = cible.with_suffix(cible.suffix + ".part")
    with urllib.request.urlopen(url, timeout=60) as r, open(partiel, "wb") as f:
        f.write(r.read())
    partiel.replace(cible)
    logger.info("Téléchargé : %s (%d octets)", cible, cible.stat().st_size)
    return cible


# En-têtes de colonnes qui désignent des personnes : écartées de la copie texte.
MOTIF_PERSONNE = re.compile(r"^nom\b|\bresp\b|responsable|chef|cadre|m[ée]decin|praticien|pr[ée]nom|mail|courriel|t[ée]l|matricule", re.I)


def vers_texte(xlsx: Path, dossier: Path) -> tuple[list[Path], list[str]]:
    """Écrit une feuille par fichier texte (tableau Markdown) sans les colonnes de personnes.

    Renvoie les fichiers écrits et les colonnes écartées (« feuille : colonne »). L'en-tête est la première
    ligne d'au moins trois cellules remplies (les lignes de titre au-dessus sont ignorées) ; les colonnes
    sans titre sont ignorées.
    """
    from openpyxl import load_workbook

    date = MOTIF_NOM.search(xlsx.stem)[0]
    id_source = f"structure-chu-{date[4:]}-{date[2:4]}-{date[:2]}"
    dossier.mkdir(parents=True, exist_ok=True)
    ecartees, fichiers = [], []
    wb = load_workbook(xlsx, read_only=True, data_only=True)
    for i, feuille in enumerate(wb.worksheets, 1):
        lignes = [l for l in feuille.iter_rows(values_only=True) if any(c not in (None, "") for c in l)]
        if not lignes:
            continue
        debut = next((k for k, l in enumerate(lignes) if sum(c not in (None, "") for c in l) >= 3), None)
        if debut is None:
            continue
        lignes = lignes[debut:]
        entete = [" ".join(str(c or "").split()) for c in lignes[0]]
        gardees = [j for j, h in enumerate(entete) if h and not MOTIF_PERSONNE.search(h)]
        ecartees += [f"{feuille.title} : {h}" for j, h in enumerate(entete) if h and j not in gardees]

        def cellule(l, j):
            return str(l[j] if j < len(l) and l[j] is not None else "").replace("|", "/").replace("\n", " ").strip()

        corps = ["| " + " | ".join(entete[j] for j in gardees) + " |", "|" + "---|" * len(gardees)]
        corps += ["| " + " | ".join(cellule(l, j) for j in gardees) + " |" for l in lignes[1:]]
        nom = re.sub(r"[^a-z0-9]+", "-", feuille.title.lower()).strip("-") or f"feuille{i}"
        f = dossier / f"{id_source}__{nom}.txt"
        f.write_text("\n".join(corps) + "\n", encoding="utf-8")
        fichiers.append(f)
    wb.close()
    return fichiers, ecartees


def ecrire_texte(xlsx: Path) -> int:
    """Copie texte du fichier, dans local/texte/."""
    fichiers, ecartees = vers_texte(xlsx, LOCAL / "texte")
    logger.info("Feuilles converties : %d, dans %s. Colonnes écartées (personnes) : %s",
                len(fichiers), LOCAL / "texte", ecartees or "aucune")
    return 0


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    p.add_argument("--site", help="racine du site de l'intranet (mémorisée dans config/local_structure.yaml)")
    p.add_argument("--url", help="ou l'URL d'une version connue, dont on déduit le site")
    p.add_argument("--prefixe", default="Structure-", help="début du nom de fichier (défaut Structure-)")
    p.add_argument("--extension", default=".xlsx", help="extension (défaut .xlsx)")
    p.add_argument("--jours", type=int, default=180, help="nombre de jours récents à sonder (défaut 180)")
    p.add_argument("--dest", type=Path, default=DESTINATION, help="dossier de destination")
    p.add_argument("--texte", action="store_true", help="écrire aussi une copie texte, sans les colonnes de personnes")
    args = p.parse_args(argv)
    logging.basicConfig(level=logging.INFO, format="%(message)s")
    site = site_connu(args.site, args.url)
    if not site:
        p.error("site inconnu : donner --site (ou --url) une première fois")
    if site != site_connu(None, None):
        CONFIG_LOCALE.parent.mkdir(parents=True, exist_ok=True)
        CONFIG_LOCALE.write_text(yaml.safe_dump({"site": site}), encoding="utf-8")
        logger.info("Site mémorisé dans %s", CONFIG_LOCALE)
    try:
        trouvee = chercher_derniere(site, args.prefixe, args.extension, dt.date.today(), args.jours)
    except (urllib.error.URLError, OSError) as e:
        logger.error("Intranet injoignable : %s", e)
        return 1
    if trouvee is None:
        logger.error("Aucune version trouvée sur %d jours (--jours pour élargir).", args.jours)
        return 1
    logger.info("Dernière version : %s", trouvee.rsplit("/", 1)[1])
    try:
        fichier = telecharger(trouvee, args.dest)
    except (urllib.error.URLError, OSError) as e:
        logger.error("Téléchargement impossible : %s", e)
        return 1
    return ecrire_texte(fichier) if args.texte else 0


if __name__ == "__main__":
    sys.exit(main())
