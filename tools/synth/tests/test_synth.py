"""Tests du générateur synthétique (python -m unittest discover tools/synth/tests)."""
from __future__ import annotations

import subprocess
import sys
import unittest
from pathlib import Path

import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

import synth  # noqa: E402
from synth import aggregates as agg  # noqa: E402
from synth import calib, fidelity  # noqa: E402


class Aggregates(unittest.TestCase):
    def test_nombres_et_etats(self):
        self.assertEqual(agg.parse_number("1397"), 1397.0)
        self.assertAlmostEqual(agg.parse_number("1,38"), 1.38)
        self.assertTrue(np.isnan(agg.parse_number("<10")))
        self.assertEqual([agg.cell_state(x) for x in ("12", "<10", "masqué", "(vide)")], ["ok", "lt10", "masked", "other"])

    def test_cellules_masquees_somment_au_total(self):
        df = agg.add_counts(pd.DataFrame({"g": ["a"] * 4, "N": ["100", "<10", "masqué", "50"]}))
        out = agg.fill_masked(df, ["g"], totals=pd.Series({"a": 200.0}))
        self.assertAlmostEqual(out["n_fill"].sum(), 200.0)
        self.assertTrue((out.loc[out["state"] == "lt10", "n_fill"] <= agg.LT10).all())

    def test_total_deduit_des_pourcentages(self):
        df = agg.add_counts(pd.DataFrame({"g": ["a"] * 3, "N": ["100", "masqué", "50"], "P": ["50", "", "25"]}))
        self.assertAlmostEqual(agg.fill_masked(df, ["g"], pct_col="P")["n_fill"].sum(), 200.0)


class Generation(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.t, cls.m = synth.generate(seed=7, scale=0.02, years=range(2022, 2024), families=("rss", "bloc", "htp"))

    def test_meme_graine_memes_lignes(self):
        again, _ = synth.generate(seed=7, scale=0.02, years=range(2022, 2024), families=("rss", "bloc", "htp"))
        for name, df in self.t.items():
            pd.testing.assert_frame_equal(df, again[name])

    def test_autre_graine_autres_lignes(self):
        other, _ = synth.generate(seed=8, scale=0.02, years=range(2022, 2024))
        self.assertFalse(other["TB_SYNTH_RSS"]["DUREE_SEJOUR"].equals(self.t["TB_SYNTH_RSS"]["DUREE_SEJOUR"]))

    def test_rss_coherent(self):
        r = self.t["TB_SYNTH_RSS"]
        self.assertTrue(r["ID_RSS"].is_unique and r["ID_SEJOUR"].is_unique)
        self.assertTrue(((pd.to_datetime(r["DATE_FIN"]) - pd.to_datetime(r["DATE_DEBUT"])).dt.days == r["DUREE_SEJOUR"]).all())
        self.assertTrue((r.loc[r["CODE_CMD"] == "28", "DUREE_SEJOUR"] == 0).all())
        self.assertTrue(r["CODE_GHM"].str.len().eq(4).all())
        self.assertTrue(set(r["ID_SEJOUR"]) <= set(self.t["TB_SEJOUR"]["ID_SEJOUR"]))

    def test_durees_asymetriques(self):
        d = self.t["TB_SYNTH_RSS"].query("DUREE_SEJOUR > 0")["DUREE_SEJOUR"]
        self.assertGreater(d.mean(), d.median())

    def test_petits_effectifs_pour_tester_le_masquage(self):
        r = self.t["TB_SYNTH_RSS"]
        cells = r.groupby([r["DATE_FIN"].str[:4], r["CODE_CMD"] + r["CODE_GHM"].str[:3]]).size()
        self.assertGreater((cells < 10).sum(), 20)
        self.assertGreater((cells >= 10).sum(), 20)

    def test_dp_imprecis_et_formes(self):
        dp = self.t["TB_SYNTH_RSS"]["DP_RETENU"]
        self.assertTrue(dp.str.len().between(0, 6).all())
        self.assertGreater(dp.str.match(r"^[A-Z]\d{2}9").mean(), 0.01)

    def test_sejours_ouverts_sans_date_de_sortie(self):
        s = self.t["TB_SEJOUR"]
        self.assertTrue((s.loc[s["ETAT"] == "ouvert", "DATE_SORTIE"] == "").all())
        self.assertTrue((s.loc[s["AVEC_RSS"] == "O", "ETAT"] == "clos").all())

    def test_manifeste(self):
        self.assertTrue(self.m["synthetic"])
        self.assertIn("assumptions", self.m["provenance"]["rss"])
        self.assertTrue(self.m["provenance"]["rss"]["sources"])

    def test_bloc(self):
        i = self.t["OR_INTERVENTIONS"]
        self.assertTrue((i["DUREE_INCISION_MIN"] <= i["DUREE_TROS_MIN"]).all() and (i["DUREE_TROS_MIN"] <= i["DUREE_OCCUPATION_MIN"]).all())
        self.assertGreater(i["DUREE_OCCUPATION_MIN"].mean(), i["DUREE_OCCUPATION_MIN"].median())

    @unittest.skipUnless(calib.available("fme.json"), "calibration FME absente")
    def test_perimetre_fme(self):
        t, m = synth.generate(seed=3, scale=0.1, years=[2025], perimeter="fme")
        self.assertIn("fme", m["provenance"])
        self.assertTrue({"TB_SYNTH_RUM", "SYNTH_REF_UF_POLE_FME", "PMSI_LIB_GHS_TARIF"} <= set(t))
        self.assertTrue(t["TB_SYNTH_RSS"]["ID_UNITE_HEBERG"].isin(calib.table("fme_uf.csv")["code_uf"]).all())


class Calibration(unittest.TestCase):
    def test_fidelite_aux_agregats(self):
        r = fidelity.report(scale=0.1)
        self.assertTrue(r["ok"].all(), r[~r["ok"]].to_string())

    def test_calibration_a_jour(self):
        out = subprocess.run([sys.executable, str(ROOT / "build.py"), "--check"], capture_output=True, text=True)
        self.assertEqual(out.returncode, 0, out.stderr)

    def test_aucun_effectif_de_1_a_9_dans_les_fichiers(self):
        for name in ("fme_cells.csv", "fme_hors_pole.csv"):
            t = calib.table(name)
            for col in ("n_rss", "n_sej"):
                if col in t:
                    n = pd.to_numeric(t[col], errors="coerce")
                    self.assertFalse(n.between(1, 9).any(), f"{name}.{col}")


if __name__ == "__main__":
    unittest.main()
