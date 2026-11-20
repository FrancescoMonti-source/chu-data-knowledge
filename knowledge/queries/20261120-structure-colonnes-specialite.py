# id: 20261120-structure-colonnes-specialite
# system: structure
# person_data: no-person-data
# purpose: lire les titres de toutes les colonnes du fichier Structure et repérer celle qui donne une spécialité (ou une discipline) : à quel niveau (service ou UF), combien de valeurs, lesquelles (enquête schemas-cora, claim specialite-absente-des-uf)
# Python, avec openpyxl. Le script lit le fichier Structure local (sources/structures/local/Structure-*.xlsx, ou --fichier). Il écrit un seul tableau, en console : une ligne par colonne du fichier avec son titre, son nombre de lignes renseignées, son nombre de valeurs distinctes et, par service, le nombre de services qui ont plusieurs valeurs (la colonne est-elle au niveau du service ou de l'UF ?).
# Les colonnes dont le titre évoque une personne (chef, responsable, nom, prénom, médecin, cadre, contact, mail, téléphone) ne sont lues que pour compter : leurs valeurs ne sortent jamais. Pour les autres colonnes dont le titre évoque une spécialité (spécialité, discipline, activité, type, catégorie, nature, DMT, SAE, discipline), le script liste aussi les valeurs distinctes avec le nombre d'UF qui les portent : ce sont des libellés d'activité, pas des personnes.
# Les valeurs de « Libellé Service » sont toujours listées (Pierre y a repéré la spécialité, 2026-11-20).
# Il ne lit aucune table de l'hôpital. Il affiche le tableau et l'écrit, avec son en-tête de preuve d'exécution, dans retour-structure/ (à pousser, comme celui de 20261026-structure-fichier-vs-cora).
# Usage : python knowledge/queries/20261120-structure-colonnes-specialite.py [--fichier CHEMIN/Structure-AAAAMMJJ.xlsx] [--sortie DOSSIER]
# Chemins : le seul argument à adapter est --fichier ; par défaut, le Structure-*.xlsx le plus récent de sources/structures/local/.

import argparse
import datetime as dt
import sys
from collections import Counter, defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "sources" / "structures"))
from lire_structure import date_du_fichier, normaliser  # noqa: E402

QUERY_ID = "20261120-structure-colonnes-specialite"
LOCAL = Path(__file__).resolve().parents[2] / "sources" / "structures" / "local"
PERSONNE = ("CHEF", "RESPONSABLE", "NOM", "PRENOM", "MEDECIN", "CADRE", "CONTACT", "MAIL", "TEL", "DIRECTEUR", "COORDONN")
SPECIALITE = ("SPECIALITE", "DISCIPLINE", "ACTIVITE", "TYPE", "CATEGORIE", "NATURE", "DMT", "SAE", "FILIERE", "MODE")


def trouver_fichier(arg):
    if arg:
        return Path(arg)
    candidats = sorted(LOCAL.glob("Structure-*.xlsx"), key=date_du_fichier)
    if not candidats:
        sys.exit(f"Aucun Structure-*.xlsx dans {LOCAL} : lancer recuperer_structure.py, ou donner --fichier.")
    return candidats[-1]


def lire(chemin):
    """(titres, lignes) de la première feuille qui a une colonne « Code UF » ; lignes = listes de valeurs."""
    from openpyxl import load_workbook

    wb = load_workbook(chemin, read_only=True, data_only=True)
    try:
        for feuille in wb.worksheets:
            lignes = [list(l) for l in feuille.iter_rows(values_only=True) if any(c not in (None, "") for c in l)]
            debut = next((k for k, l in enumerate(lignes) if any("CODE UF" in normaliser(c) for c in l)), None)
            if debut is not None:
                titres = [str(c or "").strip() for c in lignes[debut]]
                return titres, lignes[debut + 1:]
    finally:
        wb.close()
    sys.exit("Aucune feuille avec une colonne « Code UF ».")


def vide(v):
    return v is None or str(v).strip() == ""


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--fichier")
    p.add_argument("--sortie", type=Path, default=Path("retour-structure"))
    p.add_argument("--par", default="Pierre")
    args = p.parse_args()
    chemin = trouver_fichier(args.fichier)
    titres, lignes = lire(chemin)
    n = [normaliser(t) for t in titres]
    i_uf = next(i for i, t in enumerate(n) if "CODE UF" in t)
    i_srv = next((i for i, t in enumerate(n) if "CODE SERVICE" in t), None)
    run_at = dt.datetime.now().strftime("%Y-%m-%d %H:%M")

    entete = ["QUERY_ID", "DATABASE_NAME", "RUN_AT", "POSITION", "TITRE", "TYPE_DE_TITRE", "N_LIGNES_RENSEIGNEES",
              "N_VALEURS_DISTINCTES", "N_SERVICES_A_PLUSIEURS_VALEURS", "VALEUR", "N_UF_AVEC_CETTE_VALEUR"]
    sortie = [";".join(entete)]

    def ligne(pos, titre, genre, rens, dist, multi, valeur="", nuf=""):
        sortie.append(";".join(str(x) for x in (QUERY_ID, chemin.name, run_at, pos, titre, genre, rens, dist, multi, valeur, nuf)))

    for pos, titre in enumerate(titres):
        if not titre:
            continue
        valeurs = [(l[pos] if pos < len(l) else None) for l in lignes]
        renseignes = [(str(v).strip(), l[i_uf]) for v, l in zip(valeurs, lignes) if not vide(v)]
        distincts = {v for v, _ in renseignes}
        multi = ""
        if i_srv is not None and i_srv != pos:
            par_service = defaultdict(set)
            for v, l in zip(valeurs, lignes):
                if not vide(v) and not vide(l[i_srv]):
                    par_service[str(l[i_srv]).strip()].add(str(v).strip())
            multi = sum(1 for s in par_service.values() if len(s) > 1)
        if any(m in n[pos] for m in PERSONNE):
            ligne(pos, titre, "personne_valeurs_non_lues", len(renseignes), len(distincts), multi)
            continue
        service = "LIBELLE SERVICE" in n[pos]   # Pierre y a lu la spécialité (2026-11-20) : valeurs listées, avec un plafond plus haut
        candidate = service or any(m in n[pos] for m in SPECIALITE)
        ligne(pos, titre, "candidate_specialite" if candidate else "autre", len(renseignes), len(distincts), multi)
        if candidate and len(distincts) <= (400 if service else 80):
            par_valeur = Counter(v for v, _ in renseignes)
            for v, nb in sorted(par_valeur.items(), key=lambda x: -x[1]):
                ligne(pos, titre, "valeur", "", "", "", v, nb)

    table = "\n".join(sortie)
    print(table)
    args.sortie.mkdir(parents=True, exist_ok=True)
    cible = args.sortie / f"{QUERY_ID}-resultat.md"
    cible.write_text(
        f"---\nid: {QUERY_ID}-resultat\ntype: execution\nquery: {QUERY_ID}\nrun_at: {run_at}\ndatabase: {chemin.name}\n"
        f"executed_by: {args.par}\nmodified: no\nperson_data: no-person-data\n---\n```\n{table}\n```\n", encoding="utf-8")
    print(f"Preuve écrite : {cible}")


if __name__ == "__main__":
    main()
