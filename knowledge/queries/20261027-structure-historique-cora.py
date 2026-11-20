# id: 20261027-structure-historique-cora
# system: cora
# person_data: no-person-data
# purpose: mesurer ce que l'historique de CORA (TB_HIST_UNITE, TB_HIST_UNITE_M_UNITE) dit des UF fermées, des UF absentes du fichier Structure et du rattachement UF-UM, et si une UM tient dans un service du fichier (étapes 5 à 7 du plan, enquête #108, issue « structures »)
# Python, avec openpyxl et cora_toolbox (la connexion de DIM-code). Référentiels seulement : TB_UNITE, TB_UNITE_MEDICALE, TB_UNITE_M_UNITE, TB_HIST_UNITE, TB_HIST_UNITE_M_UNITE ; aucune table de séjour ni de personne. Le script ne lit ni les noms de chefs de pôle, de service ou de responsables d'UF du fichier (sources/structures/lire_structure.py), n'affiche aucune ligne du fichier ni aucun code ou libellé, et n'écrit qu'un tableau de comptages de codes.
# Date de référence : celle du nom du fichier. TB_HIST_UNITE garde des états successifs d'une UF (DATE_INFO, TYPE_INFO) ; on n'en tire que des comptages : on ne suppose pas que la dernière DATE_INFO soit une date de fermeture, la mesure la présente comme « dernière modification enregistrée ».
# Usage : python knowledge/queries/20261027-structure-historique-cora.py [--fichier CHEMIN/Structure-AAAAMMJJ.xlsx] [--sortie DOSSIER]
# Sans --fichier, le plus récent Structure-*.xlsx de sources/structures/local/. Chemins et connexion : les seules lignes à adapter (get_connection ouvre CWPROD comme le fait executer_requetes_cdk.py de DIM-code).

import argparse
import datetime as dt
import sys
from collections import Counter, defaultdict
from pathlib import Path

RACINE = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(RACINE / "sources" / "structures"))
from lire_structure import date_du_fichier, lire_structure  # noqa: E402

QUERY_ID = "20261027-structure-historique-cora"
SCHEMA = "CORA_REC"
LECTURES = {
    "uf": "SELECT ID_UNITE, TRIM(CODE_UNITE), ACTIF FROM {s}.TB_UNITE",
    "um": "SELECT ID_UNITE_MED, TRIM(CODE_UNITE_MED), ACTIF FROM {s}.TB_UNITE_MEDICALE",
    "lien": "SELECT ID_UNITE, ID_UNITE_MED, DATE_DEBUT, DATE_FIN FROM {s}.TB_UNITE_M_UNITE",
    "hist_uf": "SELECT ID_UNITE, TRIM(CODE_UNITE), ACTIF, DATE_INFO FROM {s}.TB_HIST_UNITE",
    "hist_lien": "SELECT ID_UNITE, ID_UNITE_MED, DATE_DEBUT, DATE_FIN FROM {s}.TB_HIST_UNITE_M_UNITE",
}


def dernier_fichier():
    candidats = sorted((RACINE / "sources" / "structures" / "local").glob("Structure-*.xlsx"), key=date_du_fichier)
    if not candidats:
        sys.exit("Aucun Structure-*.xlsx dans sources/structures/local/ : donner --fichier.")
    return candidats[-1]


def lire_cora(conn):
    """Les cinq tables, en listes de tuples. Aucune table de personnes."""
    sortie = {}
    with conn.cursor() as cur:
        for nom, sql in LECTURES.items():
            cur.execute(sql.format(s=SCHEMA))
            sortie[nom] = cur.fetchall()
        cur.execute("SELECT SYS_CONTEXT('USERENV', 'DB_NAME') FROM DUAL")
        base = cur.fetchone()[0]
    return base, sortie


def annee(d):
    return str(d.year) if d is not None else "sans_date"


def mesures(lignes, cora, ref):
    """Liste de (section, mesure, n) ; chaque n est un nombre de codes, jamais de personnes."""
    out = []

    def mes(section, mesure, n):
        out.append((section, mesure, n))

    f = {}
    for l in lignes:
        f.setdefault(l["code_uf"], l)
    uf = {i: (c, a) for i, c, a in cora["uf"]}
    code_de = {i: c for i, (c, _) in uf.items()}
    um_code = {i: c for i, c, _ in cora["um"]}

    # Historique des états d'une UF
    etats = defaultdict(list)  # ID_UNITE -> [(DATE_INFO, ACTIF)]
    for iu, c, a, d in cora["hist_uf"]:
        etats[iu].append((d, a))
    codes_hist = {c for _, c, _, _ in cora["hist_uf"]}
    mes("HISTORIQUE_ETATS_UF", "tb_unite_codes", len(uf))
    mes("HISTORIQUE_ETATS_UF", "tb_unite_avec_au_moins_1_etat_dans_tb_hist_unite", sum(1 for i in uf if i in etats))
    mes("HISTORIQUE_ETATS_UF", "tb_unite_avec_2_etats_ou_plus", sum(1 for i in uf if len(etats.get(i, ())) > 1))
    mes("HISTORIQUE_ETATS_UF", "codes_de_tb_hist_unite_absents_de_tb_unite", len(codes_hist - {c for c, _ in uf.values()}))
    mes("HISTORIQUE_ETATS_UF", "codes_de_tb_hist_unite_absents_de_tb_unite_et_dans_le_fichier", len((codes_hist - {c for c, _ in uf.values()}) & set(f)))

    # UF fermées (ACTIF <> 'O') : dans le fichier ou non, et depuis quand
    for lib, cond in (("inactives", lambda a: a != "O"), ("actives", lambda a: a == "O")):
        ids = [i for i, (c, a) in uf.items() if cond(a)]
        dans = [i for i in ids if uf[i][0] in f]
        hors = [i for i in ids if uf[i][0] not in f]
        mes(f"TB_UNITE_{lib.upper()}", "codes", len(ids))
        mes(f"TB_UNITE_{lib.upper()}", "dans_le_fichier", len(dans))
        mes(f"TB_UNITE_{lib.upper()}", "hors_du_fichier", len(hors))
        mes(f"TB_UNITE_{lib.upper()}", "hors_du_fichier_avec_historique", sum(1 for i in hors if i in etats))
        mes(f"TB_UNITE_{lib.upper()}", "hors_du_fichier_sans_historique", sum(1 for i in hors if i not in etats))
        if lib == "inactives":
            ouvert_avant = lambda i: any(a == "O" for _, a in etats.get(i, ()))  # noqa: E731
            mes("TB_UNITE_INACTIVES", "hors_du_fichier_avec_un_etat_actif_dans_l_historique", sum(1 for i in hors if ouvert_avant(i)))
            mes("TB_UNITE_INACTIVES", "dans_le_fichier_date_fin_passee", sum(1 for i in dans if f[uf[i][0]]["date_fin"] and f[uf[i][0]]["date_fin"] < ref))
            mes("TB_UNITE_INACTIVES", "dans_le_fichier_date_fin_vide_ou_a_venir", sum(1 for i in dans if not (f[uf[i][0]]["date_fin"] and f[uf[i][0]]["date_fin"] < ref)))
            for groupe, ids_g in (("dans_le_fichier", dans), ("hors_du_fichier", hors)):
                derniere = Counter(annee(max((d for d, _ in etats[i] if d is not None), default=None)) if i in etats else "sans_historique"
                                   for i in ids_g)
                for a in sorted(derniere):
                    mes("TB_UNITE_INACTIVES_DERNIERE_MODIFICATION_ENREGISTREE", f"{groupe}_{a}", derniere[a])
    # UF du fichier inconnues de TB_UNITE
    mes("FICHIER", "codes_uf_absents_de_tb_unite", len(set(f) - {c for c, _ in uf.values()}))
    mes("FICHIER", "codes_uf_absents_de_tb_unite_mais_dans_tb_hist_unite", len((set(f) - {c for c, _ in uf.values()}) & codes_hist))

    # Rattachement UF-UM : courant contre historique
    courant = defaultdict(set)
    for iu, ium, d, e in cora["lien"]:
        courant[iu].add((ium, d, e))
    hist = defaultdict(set)
    for iu, ium, d, e in cora["hist_lien"]:
        hist[iu].add((ium, d, e))
    mes("RATTACHEMENT_UF_UM", "uf_avec_lien_courant", len(courant))
    mes("RATTACHEMENT_UF_UM", "uf_avec_lien_dans_l_historique", len(hist))
    mes("RATTACHEMENT_UF_UM", "uf_avec_lien_courant_et_sans_lien_dans_l_historique", sum(1 for i in courant if i not in hist))
    mes("RATTACHEMENT_UF_UM", "uf_avec_lien_courant_tous_retrouves_dans_l_historique", sum(1 for i, l in courant.items() if l <= hist.get(i, set())))
    mes("RATTACHEMENT_UF_UM", "uf_avec_lien_dans_l_historique_et_sans_lien_courant", sum(1 for i in hist if i not in courant))
    um_ever = {i: {m for m, _, _ in (courant.get(i, set()) | hist.get(i, set()))} for i in set(courant) | set(hist)}
    c = Counter(min(len(v), 3) for v in um_ever.values())
    mes("RATTACHEMENT_UF_UM", "uf_avec_1_um_au_fil_du_temps", c[1])
    mes("RATTACHEMENT_UF_UM", "uf_avec_2_um_au_fil_du_temps", c[2])
    mes("RATTACHEMENT_UF_UM", "uf_avec_3_um_ou_plus_au_fil_du_temps", c[3])
    changent = [i for i, v in um_ever.items() if len(v) > 1]
    mes("RATTACHEMENT_UF_UM", "uf_qui_changent_d_um_et_sont_dans_le_fichier", sum(1 for i in changent if code_de.get(i) in f))
    mes("RATTACHEMENT_UF_UM", "uf_qui_changent_d_um_et_sont_hors_du_fichier", sum(1 for i in changent if code_de.get(i) not in f))
    mes("RATTACHEMENT_UF_UM", "uf_avec_lien_sans_date_debut", sum(1 for i in um_ever if any(d is None for _, d, _ in (courant.get(i, set()) | hist.get(i, set())))))
    mes("RATTACHEMENT_UF_UM", "uf_avec_lien_qui_porte_sur_une_um_inconnue_de_tb_unite_medicale", sum(1 for v in um_ever.values() if any(m not in um_code for m in v)))

    # Une UM tient-elle dans un service du fichier ? (liens courants, puis liens de tous les temps)
    for nom, source in (("LIENS_COURANTS", courant), ("LIENS_DE_TOUS_LES_TEMPS", um_ever)):
        par_um = defaultdict(set)
        for iu, v in source.items():
            ums = {m for m, _, _ in v} if nom == "LIENS_COURANTS" else v
            code = code_de.get(iu)
            if code in f:
                for m in ums:
                    par_um[m].add(code)
        services = {m: {f[c]["code_service"] for c in codes if f[c]["code_service"]} for m, codes in par_um.items()}
        poles = {m: {f[c]["code_pole"] for c in codes if f[c]["code_pole"]} for m, codes in par_um.items()}
        sec = f"UM_ET_SERVICE_DU_FICHIER_{nom}"
        mes(sec, "um_avec_au_moins_1_uf_dans_le_fichier", len(par_um))
        mes(sec, "um_avec_2_uf_du_fichier_ou_plus", sum(1 for codes in par_um.values() if len(codes) > 1))
        s = Counter(min(len(v), 3) for v in services.values())
        mes(sec, "um_dans_1_seul_service", s[1])
        mes(sec, "um_sur_2_services", s[2])
        mes(sec, "um_sur_3_services_ou_plus", s[3])
        p = Counter(min(len(v), 3) for v in poles.values())
        mes(sec, "um_dans_1_seul_pole", p[1])
        mes(sec, "um_sur_2_poles_ou_plus", p[2] + p[3])
        # sens inverse : un service du fichier contient-il plusieurs UM ?
        um_par_service = defaultdict(set)
        for m, v in services.items():
            for sv in v:
                um_par_service[sv].add(m)
        k = Counter(min(len(v), 3) for v in um_par_service.values())
        mes(sec, "services_du_fichier_avec_des_um", len(um_par_service))
        mes(sec, "services_avec_1_um", k[1])
        mes(sec, "services_avec_2_um", k[2])
        mes(sec, "services_avec_3_um_ou_plus", k[3])
    return out


def tableau(base, run_at, nom_fichier, lignes):
    colonnes = ["QUERY_ID", "DATABASE_NAME", "RUN_AT", "FICHIER", "SECTION", "MESURE", "N_CODES"]
    corps = ["| " + " | ".join(colonnes) + " |", "|" + "---|" * len(colonnes)]
    corps += [f"| {QUERY_ID} | {base} | {run_at} | {nom_fichier} | {s} | {m} | {n} |" for s, m, n in lignes]
    return "\n".join(corps) + "\n"


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--fichier", type=Path, help="le fichier Structure xlsx (défaut : le plus récent de sources/structures/local/)")
    p.add_argument("--sortie", type=Path, default=Path("retour-structure"), help="dossier où écrire la preuve")
    p.add_argument("--par", default="Pierre", help="nom écrit dans executed_by")
    args = p.parse_args()
    from cora_toolbox.connexion import get_connection

    fichier = args.fichier or dernier_fichier()
    ref = date_du_fichier(fichier)
    lignes = lire_structure(fichier)
    conn = get_connection()
    try:
        base, cora = lire_cora(conn)
    finally:
        conn.close()
    run_at = dt.datetime.now().strftime("%Y-%m-%d %H:%M")
    table = tableau(base, run_at, fichier.name, mesures(lignes, cora, ref))
    print(table)
    args.sortie.mkdir(parents=True, exist_ok=True)
    cible = args.sortie / f"{QUERY_ID}-resultat.md"
    cible.write_text(
        f"---\nid: {QUERY_ID}-resultat\ntype: execution\nquery: {QUERY_ID}\nrun_at: {run_at}\ndatabase: {base}\n"
        f"executed_by: {args.par}\nmodified: no\nperson_data: no-person-data\n---\n{table}", encoding="utf-8")
    print(f"Preuve écrite : {cible}")


if __name__ == "__main__":
    main()
