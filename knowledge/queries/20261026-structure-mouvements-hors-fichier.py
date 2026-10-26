# id: 20261026-structure-mouvements-hors-fichier
# system: cora
# person_data: masked
# purpose: compter, par année, les mouvements commencés dont le code d'UF (TB_MVT.ID_UNITE_M) est, ou n'est pas, un Code UF du fichier Structure : combien de l'activité tombe hors du fichier, donc sans service ni pôle du fichier (étape 4 du plan, issue « structures »)
# Python, avec openpyxl et cora_toolbox (la connexion de DIM-code). Une seule lecture de CORA : TB_MVT, groupée par code d'UF et par année de début, mouvements commencés de 2022 à 2025 (SQL ci-dessous). Les lignes par code restent en mémoire ; le script n'imprime qu'un tableau d'agrégats par année, masqués. Il n'affiche ni code ni libellé du fichier.
# Le code d'UF d'un mouvement est TRIM(ID_UNITE_M) (joindre-uf-par-code) ; il est comparé au Code UF du fichier (sources/structures/lire_structure.py), après suppression des espaces.
# Masquage (règles 3 et 4) : chaque effectif de 1 à 9 sort <10 (0 sort 0 : aucune personne). Les totaux annuels de TB_MVT sont publiés (20261014-mvt-code-uf-resultat) : si une des deux cases d'une année est masquée, l'autre l'est aussi.
# Usage : python knowledge/queries/20261026-structure-mouvements-hors-fichier.py --fichier CHEMIN/Structure-09102026.xlsx [--sortie DOSSIER]
# Chemins et connexion : les seules lignes à adapter (get_connection ouvre CWPROD comme le fait executer_requetes_cdk.py de DIM-code).

import argparse
import datetime as dt
import sys
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "sources" / "structures"))
from lire_structure import lire_structure  # noqa: E402

QUERY_ID = "20261026-structure-mouvements-hors-fichier"
SQL = """SELECT TRIM(ID_UNITE_M) AS CODE_UF, EXTRACT(YEAR FROM DATE_DEBUT_MVT) AS ANNEE, COUNT(*) AS N_MVT
FROM CORA_REC.TB_MVT
WHERE DATE_DEBUT_MVT >= DATE '2022-01-01' AND DATE_DEBUT_MVT < DATE '2026-01-01'
GROUP BY TRIM(ID_UNITE_M), EXTRACT(YEAR FROM DATE_DEBUT_MVT)"""


def masquer(n):
    return "<10" if 0 < n < 10 else str(n)


def agreger(par_code_annee, codes_fichier):
    """[(année, dans_le_fichier, n_mvt, n_uf)] masqués ; une case masquée masque sa jumelle de l'année."""
    mvt, uf = Counter(), Counter()
    for (code, annee), n in par_code_annee.items():
        cle = (annee, "oui" if code in codes_fichier else "non")
        mvt[cle] += n
        uf[cle] += 1
    sortie = []
    for annee in sorted({a for a, _ in mvt}):
        cases = [(oui, mvt[(annee, oui)], uf[(annee, oui)]) for oui in ("oui", "non")]
        cache = any(0 < n < 10 for _, n, _ in cases)
        for oui, n, u in cases:
            sortie.append((annee, oui, "<10" if cache else masquer(n), masquer(u)))
    return sortie


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--fichier", required=True, type=Path, help="le fichier Structure xlsx le plus récent")
    p.add_argument("--sortie", type=Path, default=Path("retour-structure"), help="dossier où écrire la preuve")
    p.add_argument("--par", default="Pierre", help="nom écrit dans executed_by")
    args = p.parse_args()
    from cora_toolbox.connexion import get_connection

    codes = {l["code_uf"] for l in lire_structure(args.fichier)}
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.arraysize = 5000
            cur.execute(SQL)
            par_code_annee = {(c or "", int(a)): int(n) for c, a, n in cur.fetchall()}
            cur.execute("SELECT SYS_CONTEXT('USERENV', 'DB_NAME') FROM DUAL")
            base = cur.fetchone()[0]
    finally:
        conn.close()
    run_at = dt.datetime.now().strftime("%Y-%m-%d %H:%M")
    colonnes = ["QUERY_ID", "DATABASE_NAME", "RUN_AT", "FICHIER", "ANNEE", "CODE_UF_DANS_LE_FICHIER", "N_MVT", "N_UF"]
    corps = ["| " + " | ".join(colonnes) + " |", "|" + "---|" * len(colonnes)]
    corps += [f"| {QUERY_ID} | {base} | {run_at} | {args.fichier.name} | {a} | {o} | {m} | {u} |"
              for a, o, m, u in agreger(par_code_annee, codes)]
    table = "\n".join(corps) + "\n"
    print(table)
    args.sortie.mkdir(parents=True, exist_ok=True)
    cible = args.sortie / f"{QUERY_ID}-resultat.md"
    cible.write_text(
        f"---\nid: {QUERY_ID}-resultat\ntype: execution\nquery: {QUERY_ID}\nrun_at: {run_at}\ndatabase: {base}\n"
        f"executed_by: {args.par}\nmodified: no\nperson_data: masked\n---\n{table}", encoding="utf-8")
    print(f"Preuve écrite : {cible}")


if __name__ == "__main__":
    main()
