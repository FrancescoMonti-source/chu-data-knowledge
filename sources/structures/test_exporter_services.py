"""Tests de exporter_services.py (données synthétiques)."""

import importlib.util
import sys
from pathlib import Path

sys.dont_write_bytecode = True
ICI = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("exporter_services", ICI / "exporter_services.py")
es = importlib.util.module_from_spec(spec)
spec.loader.exec_module(es)

LIGNES = [
    {"code_uf": "1", "code_service": "S1", "libelle_service": "Pédiatrie", "code_pole": "P1", "libelle_pole": "Femme"},
    {"code_uf": "2", "code_service": "S1", "libelle_service": "Pédiatrie", "code_pole": "P1", "libelle_pole": "Femme"},
    {"code_uf": "3", "code_service": "S2", "libelle_service": "Chirurgie", "code_pole": "P2", "libelle_pole": "Chir"},
]


def test_un_service_par_code():
    s = es.services(LIGNES)
    assert [(x["code_service"], x["nb_uf"]) for x in s] == [("S1", 2), ("S2", 1)]
    assert all(x["specialite"] == "" for x in s)


def test_ecriture_et_controle(tmp_path):
    csv_ = tmp_path / "s.csv"
    liste = es.services(LIGNES)
    liste[0]["specialite"] = "Pédiatrie"
    liste.append({"code_service": "XX", "libelle_service": "", "code_pole": "", "libelle_pole": "", "nb_uf": 0, "specialite": "Autre"})
    es.ecrire(csv_, liste)
    c = es.controler(csv_, LIGNES)
    assert c["services_annotes"] == 1 and c["services_sans_specialite"] == 1
    assert c["services_du_csv_absents_du_fichier"] == 1
    assert c["uf_couvertes"] == 2 and c["uf_du_fichier"] == 3
