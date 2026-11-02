# id: 20261026-structure-fichier-vs-cora
# system: cora
# person_data: no-person-data
# purpose: comparer le fichier Structure (sources/structure-chu-2026-10-09.md) aux référentiels de CORA : le Code UF du fichier est-il le CODE_UNITE de TB_UNITE ou le CODE_UNITE_MED de TB_UNITE_MEDICALE, le pôle du fichier est-il celui de CORA, que devient une UF fermée, que garde le fichier d'une version à l'autre (étapes 1 à 3 du plan, issue « structures »)
# Python, avec openpyxl et cora_toolbox (la connexion de DIM-code). Référentiels seulement : TB_UNITE, TB_UNITE_MEDICALE, TB_UNITE_M_UNITE, TB_UNITE_POLE_UM, TB_UNITE_POLE ; aucune table de séjour ni de personne. Le script ne lit ni les noms de chefs de pôle, de service ou de responsables d'UF du fichier (sources/structures/lire_structure.py), n'affiche aucune ligne du fichier ni aucun code ou libellé, et n'écrit qu'un tableau de comptages.
# Date de référence : celle du nom du fichier (Structure-09102026.xlsx : 2026-10-09). Un lien UF-UM ou UM-pôle est « en cours » à cette date quand DATE_DEBUT <= elle <= DATE_FIN (ou DATE_FIN vide).
# Libellés comparés après suppression des accents, de la ponctuation et de la casse. Le libellé du fichier est l'un de ses trois libellés d'UF (référence, court, très long).
# Usage : python knowledge/queries/20261026-structure-fichier-vs-cora.py --fichier CHEMIN/Structure-09102026.xlsx [--ancien CHEMIN/Structure-AAAAAAAA.xlsx] [--sortie DOSSIER]
# Chemins et connexion : les seules lignes à adapter (get_connection, ci-dessous, ouvre CWPROD comme le fait executer_requetes_cdk.py de DIM-code).

import argparse
import datetime as dt
import sys
from collections import Counter, defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "sources" / "structures"))
from lire_structure import date_du_fichier, lire_structure, normaliser  # noqa: E402

QUERY_ID = "20261026-structure-fichier-vs-cora"
SCHEMA = "CORA_REC"
LECTURES = {
    "uf": "SELECT ID_UNITE, TRIM(CODE_UNITE), LIBELLE_UNITE, ACTIF FROM {s}.TB_UNITE",
    "um": "SELECT ID_UNITE_MED, TRIM(CODE_UNITE_MED), LIBELLE_UNITE_MED, ACTIF FROM {s}.TB_UNITE_MEDICALE",
    "lien_uf_um": "SELECT ID_UNITE, ID_UNITE_MED, DATE_DEBUT, DATE_FIN FROM {s}.TB_UNITE_M_UNITE",
    "lien_um_pole": "SELECT ID_UNITE_MED, ID_POLE, DATE_DEBUT, DATE_FIN FROM {s}.TB_UNITE_POLE_UM",
    "pole": "SELECT ID_POLE, TRIM(CODE_POLE), LIBELLE_POLE FROM {s}.TB_UNITE_POLE",
}


def lire_cora(conn):
    """Les cinq référentiels, en listes de tuples. Aucune table de personnes."""
    sortie = {}
    with conn.cursor() as cur:
        for nom, sql in LECTURES.items():
            cur.execute(sql.format(s=SCHEMA))
            sortie[nom] = cur.fetchall()
        cur.execute("SELECT SYS_CONTEXT('USERENV', 'DB_NAME') FROM DUAL")
        base = cur.fetchone()[0]
    return base, sortie


def en_cours(debut, fin, ref):
    return (debut is None or debut.date() <= ref) and (fin is None or fin.date() >= ref)


def etiquettes(ligne):
    return {e for e in (normaliser(ligne[k]) for k in ("libelle_uf", "libelle_court", "libelle_long")) if e}


def categorie_pole(ligne, poles):
    """Compare le pôle d'une ligne du fichier à un ensemble de pôles de CORA {(code, libellé)}."""
    code, lib = normaliser(ligne["code_pole"]), normaliser(ligne["libelle_pole"])
    if not code and not lib:
        return "pole_vide_dans_le_fichier"
    if not poles:
        return "sans_pole_dans_cora"
    pc = {(normaliser(c), normaliser(l)) for c, l in poles}
    if (code, lib) in pc:
        return "meme_code_et_meme_libelle"
    if any(code == c for c, _ in pc):
        return "meme_code_libelle_different"
    if any(lib == l for _, l in pc):
        return "meme_libelle_code_different"
    return "code_et_libelle_differents"


def mesures(lignes, cora, ref, anciennes=None, ref_ancien=None):
    """Liste de (section, mesure, n) ; chaque n est un nombre de codes ou de pôles, jamais de personnes."""
    out = []

    def mes(section, mesure, n):
        out.append((section, mesure, n))

    f = {}
    for l in lignes:
        f.setdefault(l["code_uf"], l)
    doubles = Counter(l["code_uf"] for l in lignes)
    mes("FICHIER", "lignes", len(lignes))
    mes("FICHIER", "codes_uf_distincts", len(f))
    mes("FICHIER", "codes_uf_sur_plusieurs_lignes", sum(1 for n in doubles.values() if n > 1))
    fermee = {c for c, l in f.items() if l["date_fin"] is not None and l["date_fin"] < ref}
    mes("FICHIER", "date_fin_uf_passee", len(fermee))
    mes("FICHIER", "date_fin_uf_vide_ou_a_venir", len(f) - len(fermee))

    uf = {c: (i, lib, a) for i, c, lib, a in cora["uf"]}
    um = {c: (i, lib, a) for i, c, lib, a in cora["um"]}
    dans_uf, dans_um = set(f) & set(uf), set(f) & set(um)
    mes("CODE_UF_DU_FICHIER_DANS_CORA", "dans_tb_unite", len(dans_uf))
    mes("CODE_UF_DU_FICHIER_DANS_CORA", "dans_tb_unite_medicale", len(dans_um))
    mes("CODE_UF_DU_FICHIER_DANS_CORA", "dans_les_deux", len(dans_uf & dans_um))
    mes("CODE_UF_DU_FICHIER_DANS_CORA", "dans_aucune_des_deux", len(set(f) - set(uf) - set(um)))

    for nom, table in (("tb_unite", uf), ("tb_unite_medicale", um)):
        hors = [a for c, (_, _, a) in table.items() if c not in f]
        mes("CORA_HORS_FICHIER", f"{nom}_codes", len(table))
        mes("CORA_HORS_FICHIER", f"{nom}_hors_fichier_actifs", sum(1 for a in hors if a == "O"))
        mes("CORA_HORS_FICHIER", f"{nom}_hors_fichier_inactifs", sum(1 for a in hors if a != "O"))
    mes("CORA_HORS_FICHIER", "codes_communs_tb_unite_et_tb_unite_medicale", len(set(uf) & set(um)))

    for nom, table in (("tb_unite", uf), ("tb_unite_medicale", um)):
        communs = set(f) & set(table)
        egal = sum(1 for c in communs if normaliser(table[c][1]) in etiquettes(f[c]))
        mes(f"LIBELLE_{nom.upper()}", "meme_libelle_que_le_fichier", egal)
        mes(f"LIBELLE_{nom.upper()}", "libelle_different", len(communs) - egal)
    trio = set(f) & set(uf) & set(um)
    ega_uf = {c for c in trio if normaliser(uf[c][1]) in etiquettes(f[c])}
    ega_um = {c for c in trio if normaliser(um[c][1]) in etiquettes(f[c])}
    mes("LIBELLE_CODE_PORTE_PAR_LES_DEUX_TABLES", "codes_dans_le_fichier_et_les_deux_tables", len(trio))
    mes("LIBELLE_CODE_PORTE_PAR_LES_DEUX_TABLES", "libelle_du_fichier_egal_a_tb_unite_seulement", len(ega_uf - ega_um))
    mes("LIBELLE_CODE_PORTE_PAR_LES_DEUX_TABLES", "libelle_du_fichier_egal_a_tb_unite_medicale_seulement", len(ega_um - ega_uf))
    mes("LIBELLE_CODE_PORTE_PAR_LES_DEUX_TABLES", "libelle_du_fichier_egal_aux_deux", len(ega_uf & ega_um))
    mes("LIBELLE_CODE_PORTE_PAR_LES_DEUX_TABLES", "libelle_du_fichier_egal_a_aucun", len(trio - ega_uf - ega_um))

    # Liens UF - UM de CORA, à la date de référence
    uf_um, um_uf, uf_um_tous = defaultdict(set), defaultdict(set), defaultdict(set)
    for iu, ium, d, e in cora["lien_uf_um"]:
        uf_um_tous[iu].add((ium, d, e))
        if en_cours(d, e, ref):
            uf_um[iu].add(ium)
            um_uf[ium].add(iu)
    for nom, ids, lien in (("tb_unite", [v[0] for v in uf.values()], uf_um), ("tb_unite_medicale", [v[0] for v in um.values()], um_uf)):
        c = Counter(min(len(lien.get(i, ())), 2) for i in ids)
        mes("LIEN_UF_UM_DE_CORA_EN_COURS", f"{nom}_avec_0_lien", c[0])
        mes("LIEN_UF_UM_DE_CORA_EN_COURS", f"{nom}_avec_1_lien", c[1])
        mes("LIEN_UF_UM_DE_CORA_EN_COURS", f"{nom}_avec_2_liens_ou_plus", c[2])
    id_um_code = {i: c for c, (i, _, _) in um.items()}
    seul = [(c, next(iter(uf_um[i]))) for c, (i, _, _) in uf.items() if len(uf_um.get(i, ())) == 1]
    mes("LIEN_UF_UM_DE_CORA_EN_COURS", "tb_unite_a_une_seule_um_de_meme_code", sum(1 for c, m in seul if id_um_code.get(m) == c))
    mes("LIEN_UF_UM_DE_CORA_EN_COURS", "tb_unite_a_une_seule_um_de_code_different", sum(1 for c, m in seul if id_um_code.get(m) != c))

    # Pôles de CORA, à la date de référence
    pole = {i: (c, lib) for i, c, lib in cora["pole"]}
    um_pole, um_pole_tous = defaultdict(set), defaultdict(set)
    for ium, ip, d, e in cora["lien_um_pole"]:
        um_pole_tous[ium].add((ip, d, e))
        if en_cours(d, e, ref) and ip in pole:
            um_pole[ium].add(ip)
    pole_de = {
        "uf": {c: {p for m in uf_um.get(uf[c][0], ()) for p in um_pole.get(m, ())} for c in dans_uf},
        "um": {c: set(um_pole.get(um[c][0], ())) for c in dans_um},
    }
    for hyp, section in (("uf", "POLE_SI_LE_CODE_EST_UN_CODE_TB_UNITE"), ("um", "POLE_SI_LE_CODE_EST_UN_CODE_TB_UNITE_MEDICALE")):
        cat = Counter(categorie_pole(f[c], {pole[p] for p in ps}) for c, ps in pole_de[hyp].items())
        for k in ("meme_code_et_meme_libelle", "meme_code_libelle_different", "meme_libelle_code_different",
                  "code_et_libelle_differents", "sans_pole_dans_cora", "pole_vide_dans_le_fichier"):
            mes(section, k, cat[k])
        mes(section, "codes_avec_plusieurs_poles_dans_cora", sum(1 for ps in pole_de[hyp].values() if len(ps) > 1))
        paires = {(normaliser(f[c]["code_pole"]), next(iter(ps))) for c, ps in pole_de[hyp].items() if len(ps) == 1 and f[c]["code_pole"]}
        vers, depuis = defaultdict(set), defaultdict(set)
        for pf, pc in paires:
            vers[pf].add(pc)
            depuis[pc].add(pf)
        mes(section, "poles_du_fichier_vus", len(vers))
        mes(section, "poles_du_fichier_vers_un_seul_pole_cora", sum(1 for v in vers.values() if len(v) == 1))
        mes(section, "poles_cora_vus", len(depuis))
        mes(section, "poles_cora_depuis_un_seul_pole_du_fichier", sum(1 for v in depuis.values() if len(v) == 1))

    # Historique dans CORA et dans le fichier
    mes("HISTORIQUE_CORA", "tb_unite_avec_lien_um_termine", sum(1 for liens in uf_um_tous.values() if any(e and e.date() < ref for _, _, e in liens)))
    mes("HISTORIQUE_CORA", "tb_unite_medicale_avec_2_liens_pole_ou_plus", sum(1 for liens in um_pole_tous.values() if len(liens) > 1))
    mes("HISTORIQUE_CORA", "tb_unite_medicale_avec_lien_pole_termine", sum(1 for liens in um_pole_tous.values() if any(e and e.date() < ref for _, _, e in liens)))
    croise = Counter((c in fermee, uf[c][2] == "O") for c in dans_uf)
    mes("HISTORIQUE_FICHIER_ET_ACTIF_CORA", "date_fin_passee_et_tb_unite_actif", croise[(True, True)])
    mes("HISTORIQUE_FICHIER_ET_ACTIF_CORA", "date_fin_passee_et_tb_unite_inactif", croise[(True, False)])
    mes("HISTORIQUE_FICHIER_ET_ACTIF_CORA", "date_fin_vide_ou_a_venir_et_tb_unite_actif", croise[(False, True)])
    mes("HISTORIQUE_FICHIER_ET_ACTIF_CORA", "date_fin_vide_ou_a_venir_et_tb_unite_inactif", croise[(False, False)])

    if anciennes is not None:
        a = {}
        for l in anciennes:
            a.setdefault(l["code_uf"], l)
        sec = "FICHIER_ANCIEN_CONTRE_RECENT"
        communs = set(a) & set(f)
        ferme_a = {c for c, l in a.items() if l["date_fin"] is not None and l["date_fin"] < ref_ancien}
        mes(sec, "codes_dans_les_deux_versions", len(communs))
        mes(sec, "codes_seulement_dans_la_version_recente", len(set(f) - set(a)))
        mes(sec, "codes_seulement_dans_la_version_ancienne", len(set(a) - set(f)))
        mes(sec, "service_identique", sum(1 for c in communs if a[c]["code_service"] == f[c]["code_service"]))
        mes(sec, "service_different", sum(1 for c in communs if a[c]["code_service"] != f[c]["code_service"]))
        mes(sec, "pole_identique", sum(1 for c in communs if a[c]["code_pole"] == f[c]["code_pole"]))
        mes(sec, "pole_different", sum(1 for c in communs if a[c]["code_pole"] != f[c]["code_pole"]))
        mes(sec, "date_fin_uf_modifiee", sum(1 for c in communs if a[c]["date_fin"] != f[c]["date_fin"]))
        mes(sec, "fermees_dans_la_version_ancienne_et_encore_dans_la_recente", len(ferme_a & set(f)))
        mes(sec, "fermees_dans_la_version_ancienne_et_absentes_de_la_recente", len(ferme_a - set(f)))
        mes(sec, "ouvertes_dans_la_version_ancienne_et_absentes_de_la_recente", len(set(a) - ferme_a - set(f)))
    return out


def tableau(base, run_at, nom_fichier, lignes):
    colonnes = ["QUERY_ID", "DATABASE_NAME", "RUN_AT", "FICHIER", "SECTION", "MESURE", "N_CODES"]
    corps = ["| " + " | ".join(colonnes) + " |", "|" + "---|" * len(colonnes)]
    corps += [f"| {QUERY_ID} | {base} | {run_at} | {nom_fichier} | {s} | {m} | {n} |" for s, m, n in lignes]
    return "\n".join(corps) + "\n"


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--fichier", required=True, type=Path, help="le fichier Structure xlsx le plus récent")
    p.add_argument("--ancien", type=Path, help="une version plus ancienne du fichier, pour voir ce qui change")
    p.add_argument("--sortie", type=Path, default=Path("retour-structure"), help="dossier où écrire la preuve")
    p.add_argument("--par", default="Pierre", help="nom écrit dans executed_by")
    args = p.parse_args()
    from cora_toolbox.connexion import get_connection

    ref = date_du_fichier(args.fichier)
    lignes = lire_structure(args.fichier)
    anciennes = lire_structure(args.ancien) if args.ancien else None
    conn = get_connection()
    try:
        base, cora = lire_cora(conn)
    finally:
        conn.close()
    resultat = mesures(lignes, cora, ref, anciennes, date_du_fichier(args.ancien) if args.ancien else None)
    run_at = dt.datetime.now().strftime("%Y-%m-%d %H:%M")
    table = tableau(base, run_at, args.fichier.name + (f" + {args.ancien.name}" if args.ancien else ""), resultat)
    print(table)
    args.sortie.mkdir(parents=True, exist_ok=True)
    cible = args.sortie / f"{QUERY_ID}-resultat.md"
    cible.write_text(
        f"---\nid: {QUERY_ID}-resultat\ntype: execution\nquery: {QUERY_ID}\nrun_at: {run_at}\ndatabase: {base}\n"
        f"executed_by: {args.par}\nmodified: no\nperson_data: no-person-data\n---\n{table}", encoding="utf-8")
    print(f"Preuve écrite : {cible}")


if __name__ == "__main__":
    main()
