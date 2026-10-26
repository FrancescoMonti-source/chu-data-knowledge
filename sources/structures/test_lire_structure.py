"""Tests de lire_structure.py et des scripts de comparaison du fichier Structure à CORA (données synthétiques)."""

import datetime as dt
import importlib.util
import sys
from pathlib import Path

import pytest
from openpyxl import Workbook

sys.dont_write_bytecode = True  # les scripts de knowledge/queries ne doivent pas y laisser de __pycache__
ICI = Path(__file__).resolve().parent


def charger(chemin: Path, nom: str):
    spec = importlib.util.spec_from_file_location(nom, chemin)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


ls = charger(ICI / "lire_structure.py", "lire_structure")
QUERIES = ICI.parents[1] / "knowledge" / "queries"
comparer = charger(QUERIES / "20261026-structure-fichier-vs-cora.py", "comparer_structure")
mouvements = charger(QUERIES / "20261026-structure-mouvements-hors-fichier.py", "mouvements_structure")

ENTETE = ["Code Pôle", "Libellé Pôle", "Nom chef de pôle", "Code Service", "Libellé Service", "Code UF",
          "Libellé UF (libellé de référence)", "Libellé court UF", "Libellé très long UF", "Date fin UF", "Responsable UF"]


def fichier(tmp_path, lignes, nom="Structure-09102026.xlsx"):
    wb = Workbook()
    ws = wb.active
    ws.title = "Fichier Structure"
    ws.append(["Structure du CHU"])
    ws.append(ENTETE)
    for l in lignes:
        ws.append(l)
    chemin = tmp_path / nom
    wb.save(chemin)
    return chemin


LIGNES = [
    ["P1", "Pôle Femme", "Dr X", "S1", "Pédiatrie", 5618, "PEDIATRIE MED", "PED", "Pédiatrie médicale", None, "Dr Y"],
    ["P1", "Pôle Femme", "Dr X", "S1", "Pédiatrie", "5622", "PEDIATRIE HC", "PED HC", "", dt.datetime(2020, 1, 1), "Dr Z"],
    ["P2", "Pôle Chir", "Dr W", "S2", "Chirurgie", "9999", "AUTRE", "", "", "31/12/2999", ""],
]


def test_lecture_sans_personnes(tmp_path):
    lignes = ls.lire_structure(fichier(tmp_path, LIGNES))
    assert [l["code_uf"] for l in lignes] == ["5618", "5622", "9999"]
    assert lignes[0]["libelle_long"] == "Pédiatrie médicale"
    assert lignes[1]["date_fin"] == dt.date(2020, 1, 1)
    assert lignes[2]["date_fin"] == dt.date(2999, 12, 31)
    assert all("Dr" not in str(v) for l in lignes for v in l.values())


def test_date_du_nom():
    assert ls.date_du_fichier(Path("Structure-09102026.xlsx")) == dt.date(2026, 10, 9)


def cora():
    d = dt.datetime
    return {
        "uf": [(1, "5618", "Pediatrie MED", "O"), (2, "5622", "Autre libellé", "N"), (3, "7777", "Seule", "O")],
        "um": [(10, "5618", "PEDIATRIE MED", "O"), (11, "5619", "Hors fichier", "O")],
        "lien_uf_um": [(1, 10, d(2020, 1, 1), None), (2, 10, d(2020, 1, 1), d(2021, 1, 1))],
        "lien_um_pole": [(10, 100, d(2020, 1, 1), None), (11, 100, d(2010, 1, 1), d(2015, 1, 1))],
        "pole": [(100, "P1", "Pôle Femme")],
    }


def table(res):
    return {(s, m): n for s, m, n in res}


def test_comparaison(tmp_path):
    lignes = ls.lire_structure(fichier(tmp_path, LIGNES))
    t = table(comparer.mesures(lignes, cora(), dt.date(2026, 10, 9)))
    assert t[("CODE_UF_DU_FICHIER_DANS_CORA", "dans_tb_unite")] == 2
    assert t[("CODE_UF_DU_FICHIER_DANS_CORA", "dans_tb_unite_medicale")] == 1
    assert t[("CODE_UF_DU_FICHIER_DANS_CORA", "dans_aucune_des_deux")] == 1
    assert t[("FICHIER", "date_fin_uf_passee")] == 1
    assert t[("CORA_HORS_FICHIER", "tb_unite_hors_fichier_actifs")] == 1
    assert t[("LIBELLE_CODE_PORTE_PAR_LES_DEUX_TABLES", "libelle_du_fichier_egal_aux_deux")] == 1
    assert t[("LIBELLE_TB_UNITE", "libelle_different")] == 1
    # 5618 : TB_UNITE 1 -> UM 10 -> pôle 100 (« Pôle Femme »), identique ; 5622 : lien terminé, sans pôle
    sec = "POLE_SI_LE_CODE_EST_UN_CODE_TB_UNITE"
    assert t[(sec, "meme_code_et_meme_libelle")] == 1
    assert t[(sec, "sans_pole_dans_cora")] == 1
    assert t[("HISTORIQUE_CORA", "tb_unite_avec_lien_um_termine")] == 1
    assert t[("HISTORIQUE_CORA", "tb_unite_medicale_avec_lien_pole_termine")] == 1
    assert t[("HISTORIQUE_FICHIER_ET_ACTIF_CORA", "date_fin_passee_et_tb_unite_inactif")] == 1


def test_ancienne_version(tmp_path):
    recent = ls.lire_structure(fichier(tmp_path, LIGNES))
    ancien_lignes = [LIGNES[0][:3] + ["S9"] + LIGNES[0][4:], LIGNES[1], ["P3", "x", "", "S3", "y", "1234", "Z", "", "", None, ""]]
    ancien = ls.lire_structure(fichier(tmp_path, ancien_lignes, "Structure-01012026.xlsx"))
    t = table(comparer.mesures(recent, cora(), dt.date(2026, 10, 9), ancien, dt.date(2026, 1, 1)))
    sec = "FICHIER_ANCIEN_CONTRE_RECENT"
    assert t[(sec, "codes_dans_les_deux_versions")] == 2
    assert t[(sec, "service_different")] == 1
    assert t[(sec, "fermees_dans_la_version_ancienne_et_encore_dans_la_recente")] == 1
    assert t[(sec, "ouvertes_dans_la_version_ancienne_et_absentes_de_la_recente")] == 1


def test_mouvements_masques():
    res = mouvements.agreger({("5618", 2025): 500, ("5622", 2025): 40, ("0000", 2025): 3,
                              ("5618", 2024): 800, ("5622", 2024): 20}, {"5618", "5622"})
    assert (2025, "oui", "<10", "<10") in res and (2025, "non", "<10", "<10") in res
    assert (2024, "oui", "820", "<10") in res and (2024, "non", "0", "0") in res
