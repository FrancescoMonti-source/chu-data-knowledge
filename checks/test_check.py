"""Tests des contrôles. Lancer : python -m unittest discover checks"""

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from check import ORANGE, RED, Repository  # noqa: E402
from sync_skills import sync  # noqa: E402

REQUEST = """\
-- id: 20261007-mvt-rum
-- person_data: masked
-- purpose: compter les mouvements par année
SELECT '20261007-mvt-rum' AS request_id,
       ANNEE,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE CAST(COUNT(*) AS VARCHAR(10)) END AS N_MVT
FROM TB_MVT_RUM
GROUP BY ANNEE;
"""

EXECUTION = """\
---
id: 20261008-mvt-rum
type: execution
request: 20261007-mvt-rum
run_at: 2026-10-08 09:14
database: CORAPROD
executed_by: Francesco
modified: no
person_data: masked
---
| request_id | ANNEE | N_MVT |
|---|---|---|
| 20261007-mvt-rum | 2024 | 1520 |
| 20261007-mvt-rum | 2025 | <10 |
"""

SOURCE = """\
---
id: atih-guide-mco-2026
title: Guide méthodologique MCO
publisher: ATIH
edition: "2026"
location: https://www.atih.sante.fr/
authority: official
---
"""

READING = """\
---
id: 20261009-guide-rum
type: reading
source: atih-guide-mco-2026
locator: chapitre 1
read_by: Marie
read_at: 2026-10-09
---
> Le RUM est le résumé d'un passage dans une unité médicale.
"""

DOCUMENTARY = """\
---
review: unreviewed
id: rum-definition
kind: documentary
author: Marie
statement: Un RUM résume le passage d'un patient dans une unité médicale.
scope: PMSI MCO 2026
maturity: documented
lifecycle: active
terms: [pmsi:rum]
tables: []
supported_by: [20261009-guide-rum]
depends_on: []
---
Lecture directe du guide.
"""

EMPIRICAL = """\
---
review: unreviewed
id: mvt-rum-lien
kind: empirical
author: Francesco
statement: Dans CORA, TB_MVT_RUM relie chaque mouvement à ses RUM.
scope: CORA, MCO, 2024-2025
refuted_if: un mouvement MCO sans aucune ligne dans TB_MVT_RUM
maturity: observed
lifecycle: active
terms: [cora:mouvement, cora:rum]
tables: [TB_MVT, TB_MVT_RUM]
supported_by: [20261008-mvt-rum]
depends_on: []
---
Raisonnement et limites.
"""

FILES = {
    "systems/cora/GLOSSARY.md": "# Glossaire CORA\n\n## cora:mouvement\n\nUn passage.\n\n## cora:rum\n\nUn RUM.\n",
    "domains/pmsi/GLOSSARY.md": "# Glossaire PMSI\n\n## pmsi:rum\n\nRésumé d'unité médicale.\n",
    "systems/cora/requests/20261007-mvt-rum.sql": REQUEST,
    "systems/cora/evidence/20261008-mvt-rum.md": EXECUTION,
    "sources/atih-guide-mco-2026.md": SOURCE,
    "domains/pmsi/evidence/20261009-guide-rum.md": READING,
    "domains/pmsi/claims/rum-definition.md": DOCUMENTARY,
    "systems/cora/claims/mvt-rum-lien.md": EMPIRICAL,
}


def claim(identifier, author="Francesco", maturity="observed", lifecycle="active",
          depends_on="", extra=""):
    """Un claim empirique appuyé sur l'exécution de base."""
    return EMPIRICAL.replace("id: mvt-rum-lien", "id: " + identifier) \
        .replace("author: Francesco", "author: " + author) \
        .replace("maturity: observed", "maturity: " + maturity) \
        .replace("lifecycle: active", "lifecycle: " + lifecycle + extra) \
        .replace("depends_on: []", f"depends_on: [{depends_on}]")


def valid_nir():
    base = "1850775123456"
    return f"{base[0]} {base[1:3]} {base[3:5]} {base[5:7]} {base[7:10]} {base[10:]} {97 - int(base) % 97:02d}"


class RepositoryTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.root = Path(self.directory.name)
        self.write(FILES)

    def tearDown(self):
        self.directory.cleanup()

    def write(self, files):
        for name, text in files.items():
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(text, encoding="utf-8", newline="")

    def edit(self, name, old, new):
        path = self.root / name
        text = path.read_text(encoding="utf-8")
        self.assertIn(old, text)
        self.write({name: text.replace(old, new)})

    def run_checks(self):
        self.repository = Repository(self.root)
        return self.repository.run()

    def assertProblem(self, level, path, words):
        problems = self.run_checks()
        found = [p for p in problems if p["level"] == level and p["path"] == path and words in p["message"]]
        self.assertTrue(found, f"attendu {level} « {words} » sur {path} ; obtenu : {problems}")

    def assertClean(self):
        self.assertEqual(self.run_checks(), [])

    def review(self, identifier, by, status="reviewed", fingerprint=None):
        """Remplace « review: unreviewed » par un bloc de relecture complet."""
        fingerprint = fingerprint or self.current(identifier)
        name = self.repository_path(identifier)
        self.edit(name, "review: unreviewed", f"review:\n  status: {status}\n  by: {by}\n"
                  f"  at: 2026-10-12\n  work: recalcul, mêmes chiffres\n  fingerprint: {fingerprint}")

    def current(self, identifier):
        repository = Repository(self.root)
        repository.run()
        return repository.fingerprint(identifier)

    def repository_path(self, identifier):
        repository = Repository(self.root)
        repository.load()
        return repository.records[identifier]["path"]

    # Forme

    def test_baseline_is_clean(self):
        self.assertClean()

    def test_missing_field_is_red(self):
        self.edit("systems/cora/claims/mvt-rum-lien.md", "scope: CORA, MCO, 2024-2025\n", "")
        self.assertProblem(RED, "systems/cora/claims/mvt-rum-lien.md", "obligatoire")

    def test_review_must_come_first(self):
        self.edit("systems/cora/claims/mvt-rum-lien.md", "review: unreviewed\nid: mvt-rum-lien",
                  "id: mvt-rum-lien\nreview: unreviewed")
        self.assertProblem(RED, "systems/cora/claims/mvt-rum-lien.md", "premier champ")

    def test_id_must_match_file_name(self):
        self.edit("systems/cora/claims/mvt-rum-lien.md", "id: mvt-rum-lien", "id: autre-nom")
        self.assertProblem(RED, "systems/cora/claims/mvt-rum-lien.md", "nom du fichier")

    def test_id_characters(self):
        self.write({"systems/cora/claims/Mvt.md": claim("Mvt")})
        self.assertProblem(RED, "systems/cora/claims/Mvt.md", "caractères")

    def test_duplicate_id_across_folders(self):
        self.write({"systems/icca/claims/mvt-rum-lien.md": EMPIRICAL})
        self.assertProblem(RED, "systems/icca/claims/mvt-rum-lien.md", "existe déjà")

    def test_repeated_yaml_key_is_red(self):
        self.edit("systems/cora/claims/mvt-rum-lien.md", "lifecycle: active", "lifecycle: active\nlifecycle: withdrawn")
        self.assertProblem(RED, "systems/cora/claims/mvt-rum-lien.md", "clé répétée")

    def test_list_field_must_be_a_list(self):
        self.edit("systems/cora/claims/mvt-rum-lien.md", "tables: [TB_MVT, TB_MVT_RUM]", "tables: TB_MVT")
        self.assertProblem(RED, "systems/cora/claims/mvt-rum-lien.md", "liste")

    def test_unknown_value_is_red(self):
        self.edit("systems/cora/claims/mvt-rum-lien.md", "maturity: observed", "maturity: certain")
        self.assertProblem(RED, "systems/cora/claims/mvt-rum-lien.md", "non admise")

    # Liens et termes

    def test_unknown_term_is_red(self):
        self.edit("systems/cora/claims/mvt-rum-lien.md", "cora:rum]", "cora:sejour]")
        self.assertProblem(RED, "systems/cora/claims/mvt-rum-lien.md", "GLOSSARY")

    def test_missing_evidence_is_red(self):
        self.edit("systems/cora/claims/mvt-rum-lien.md", "[20261008-mvt-rum]", "[20261008-absent]")
        self.assertProblem(RED, "systems/cora/claims/mvt-rum-lien.md", "n'existe pas")

    def test_link_to_wrong_type_is_red(self):
        self.edit("systems/cora/claims/mvt-rum-lien.md", "supported_by: [20261008-mvt-rum]",
                  "supported_by: [20261008-mvt-rum, rum-definition]")
        self.assertProblem(RED, "systems/cora/claims/mvt-rum-lien.md", "type evidence")

    # Règles du claim

    def test_refuted_if_only_for_empirical(self):
        self.edit("systems/cora/claims/mvt-rum-lien.md", "refuted_if: un mouvement MCO sans aucune ligne dans TB_MVT_RUM\n", "")
        self.assertProblem(RED, "systems/cora/claims/mvt-rum-lien.md", "obligatoire")
        self.assertNotIn("refuted_if", (self.root / "domains/pmsi/claims/rum-definition.md").read_text(encoding="utf-8"))

    def test_decision_needs_responsible(self):
        self.write({"systems/cora/claims/choix-annee.md": claim("choix-annee")
                    .replace("kind: empirical", "kind: decision")
                    .replace("maturity: observed", "maturity: provisional")
                    .replace("refuted_if:", "reconsider_when:")})
        self.assertProblem(RED, "systems/cora/claims/choix-annee.md", "obligatoire")

    def test_authority_belongs_to_source(self):
        self.edit("systems/cora/claims/mvt-rum-lien.md", "lifecycle: active", "lifecycle: active\nauthority: official")
        self.assertProblem(RED, "systems/cora/claims/mvt-rum-lien.md", "autorité")

    def test_domain_claim_with_tables_is_red(self):
        self.edit("domains/pmsi/claims/rum-definition.md", "tables: []", "tables: [TB_RUM]")
        self.assertProblem(RED, "domains/pmsi/claims/rum-definition.md", "nomme des tables")

    def test_documentary_needs_a_reading(self):
        self.edit("domains/pmsi/claims/rum-definition.md", "kind: documentary", "kind: empirical\nrefuted_if: x")
        self.edit("systems/cora/claims/mvt-rum-lien.md", "kind: empirical", "kind: documentary")
        self.assertProblem(RED, "systems/cora/claims/mvt-rum-lien.md", "lecture")

    def test_observed_needs_attributed_execution(self):
        self.edit("systems/cora/evidence/20261008-mvt-rum.md", "database: CORAPROD", "database: unknown")
        self.assertProblem(RED, "systems/cora/claims/mvt-rum-lien.md", "observed")

    def test_provisional_accepts_unknown_context(self):
        self.edit("systems/cora/evidence/20261008-mvt-rum.md", "database: CORAPROD", "database: unknown")
        self.edit("systems/cora/claims/mvt-rum-lien.md", "maturity: observed", "maturity: provisional")
        self.assertClean()

    def test_system_claim_cannot_depend_on_investigation(self):
        self.write({"investigations/2026-duree-sejour/claims/hypothese.md": claim("hypothese")})
        self.edit("systems/cora/claims/mvt-rum-lien.md", "depends_on: []", "depends_on: [hypothese]")
        self.assertProblem(RED, "systems/cora/claims/mvt-rum-lien.md", "enquête")

    def test_superseded_needs_a_successor(self):
        self.edit("systems/cora/claims/mvt-rum-lien.md", "lifecycle: active", "lifecycle: superseded")
        self.assertProblem(RED, "systems/cora/claims/mvt-rum-lien.md", "remplacer")
        self.write({"systems/cora/claims/mvt-rum-lien-v2.md": claim("mvt-rum-lien-v2", extra="\nsupersedes: [mvt-rum-lien]")})
        self.assertClean()

    # Relecture et empreinte

    def test_current_review_is_clean(self):
        self.review("mvt-rum-lien", by="Marie")
        self.assertClean()

    def test_author_cannot_sign_reviewed(self):
        self.review("mvt-rum-lien", by="francesco")
        self.assertProblem(RED, "systems/cora/claims/mvt-rum-lien.md", "auteur")

    def test_author_reread_is_for_author(self):
        self.review("mvt-rum-lien", by="Marie", status="author-reread")
        self.assertProblem(RED, "systems/cora/claims/mvt-rum-lien.md", "réservé")

    def test_review_goes_stale_when_evidence_changes(self):
        self.review("mvt-rum-lien", by="Marie")
        self.edit("systems/cora/evidence/20261008-mvt-rum.md", "1520", "1521")
        self.assertProblem(ORANGE, "systems/cora/claims/mvt-rum-lien.md", "périmée")

    def test_review_goes_stale_when_request_or_premise_changes(self):
        self.write({"systems/cora/claims/mvt-annuel.md": claim("mvt-annuel", depends_on="mvt-rum-lien")})
        self.review("mvt-annuel", by="Marie")
        self.edit("systems/cora/requests/20261007-mvt-rum.sql", "GROUP BY ANNEE", "GROUP BY ANNEE, MOIS")
        self.assertProblem(ORANGE, "systems/cora/claims/mvt-annuel.md", "périmée")

    def test_fingerprint_ignores_review_and_line_endings(self):
        before = self.current("mvt-rum-lien")
        self.review("mvt-rum-lien", by="Marie")
        path = self.root / "systems/cora/claims/mvt-rum-lien.md"
        path.write_bytes(path.read_bytes().replace(b"\n", b"\r\n"))
        self.assertEqual(self.current("mvt-rum-lien"), before)
        self.assertRegex(before, r"^[0-9a-f]{12}$")

    # Réutilisation

    def test_reuse_of_unreviewed_claim_of_another_author(self):
        self.write({"systems/cora/claims/mvt-annuel.md": claim("mvt-annuel", author="Marie", depends_on="mvt-rum-lien")})
        self.assertProblem(RED, "systems/cora/claims/mvt-annuel.md", "autre personne")

    def test_reuse_is_orange_when_provisional_and_free_for_same_author(self):
        self.write({"systems/cora/claims/mvt-annuel.md": claim("mvt-annuel", author="Marie", maturity="provisional",
                                                                depends_on="mvt-rum-lien")})
        self.assertProblem(ORANGE, "systems/cora/claims/mvt-annuel.md", "autre personne")
        self.write({"systems/cora/claims/mvt-annuel.md": claim("mvt-annuel", depends_on="mvt-rum-lien")})
        self.assertClean()

    def test_inactive_premise_is_flagged_transitively(self):
        self.write({"systems/cora/claims/etape-1.md": claim("etape-1", depends_on="mvt-rum-lien"),
                    "systems/cora/claims/etape-2.md": claim("etape-2", depends_on="etape-1")})
        self.edit("systems/cora/claims/mvt-rum-lien.md", "lifecycle: active", "lifecycle: withdrawn")
        self.assertProblem(ORANGE, "systems/cora/claims/etape-2.md", "mvt-rum-lien (withdrawn)")

    # Preuves et requêtes

    def test_execution_must_match_request_person_data(self):
        self.edit("systems/cora/evidence/20261008-mvt-rum.md", "person_data: masked", "person_data: no-person-data")
        self.assertProblem(RED, "systems/cora/evidence/20261008-mvt-rum.md", "diffère")

    def test_modified_execution_keeps_the_sql(self):
        self.edit("systems/cora/evidence/20261008-mvt-rum.md", "modified: no", "modified: yes")
        self.assertProblem(RED, "systems/cora/evidence/20261008-mvt-rum.md", "version exécutée")

    def test_execution_lives_in_systems(self):
        self.write({"domains/pmsi/evidence/20261010-mvt.md": EXECUTION.replace("20261008-mvt-rum", "20261010-mvt")})
        self.assertProblem(RED, "domains/pmsi/evidence/20261010-mvt.md", "système")

    def test_reading_needs_a_quote(self):
        self.edit("domains/pmsi/evidence/20261009-guide-rum.md", "> Le RUM", "Le RUM")
        self.assertProblem(RED, "domains/pmsi/evidence/20261009-guide-rum.md", "citation")

    def test_masked_request_rules(self):
        self.edit("systems/cora/requests/20261007-mvt-rum.sql", "SELECT '20261007-mvt-rum' AS request_id,", "SELECT")
        self.edit("systems/cora/requests/20261007-mvt-rum.sql", "COUNT(*) < 10", "COUNT(*) < 5")
        problems = [p["message"] for p in self.run_checks()]
        self.assertTrue(any("première colonne" in m for m in problems), problems)
        self.assertTrue(any("<10" in m for m in problems), problems)

    def test_select_star_only_for_column_names(self):
        self.write({"systems/cora/requests/20261011-colonnes.sql":
                    "-- id: 20261011-colonnes\n-- person_data: no-person-data\n-- purpose: lister les colonnes\n"
                    "SELECT * FROM TB_MVT WHERE 1=0;\n"})
        self.assertClean()
        self.edit("systems/cora/requests/20261011-colonnes.sql", " WHERE 1=0", "")
        self.assertProblem(RED, "systems/cora/requests/20261011-colonnes.sql", "SELECT *")

    # Données personnelles

    def test_nir_with_valid_key_is_red_and_not_echoed(self):
        nir = valid_nir()
        self.write({"investigations/2026-test/notes.md": f"Patient : {nir}\n"})
        self.assertProblem(RED, "investigations/2026-test/notes.md", "NIR")
        self.assertNotIn(nir.replace(" ", "")[:7], str(self.run_checks()))

    def test_nir_with_wrong_key_is_ignored(self):
        nir = valid_nir()
        wrong = nir[:-2] + f"{(int(nir[-2:]) + 1) % 97:02d}"
        self.write({"investigations/2026-test/notes.md": f"Numéro : {wrong}\n"})
        self.assertClean()

    def test_birth_date_is_red(self):
        self.write({"investigations/2026-test/notes.md": "Date de naissance : 12/03/1951\n"})
        self.assertProblem(RED, "investigations/2026-test/notes.md", "naissance")

    def test_small_count_in_masked_result_is_red(self):
        self.edit("systems/cora/evidence/20261008-mvt-rum.md", "| 2025 | <10 |", "| 2025 | 7 |")
        self.assertProblem(RED, "systems/cora/evidence/20261008-mvt-rum.md", "inférieur à 10")

    # Skills

    def test_skill_copies_must_match(self):
        self.write({".agents/skills/frame/SKILL.md": "---\nname: frame\n---\nCadrer.\n"})
        self.assertProblem(RED, ".claude/skills", "diffère")
        sync(self.root)
        self.assertClean()

    # Cas limites

    def test_challenge_stays_orange_for_other_authors(self):
        self.write({"systems/cora/claims/mvt-annuel.md": claim("mvt-annuel", author="Marie", depends_on="mvt-rum-lien")})
        self.review("mvt-rum-lien", by="Marie")
        self.edit("systems/cora/claims/mvt-rum-lien.md", "lifecycle: active", "lifecycle: challenged")
        problems = self.run_checks()
        self.assertEqual([p["level"] for p in problems], [ORANGE], problems)
        self.assertIn("challenged", problems[0]["message"])

    def test_investigation_claim_can_rest_on_premises_only(self):
        answer = DOCUMENTARY.replace("id: rum-definition", "id: reponse") \
            .replace("supported_by: [20261009-guide-rum]", "supported_by: []") \
            .replace("depends_on: []", "depends_on: [rum-definition]")
        self.write({"investigations/uf-vs-rum/claims/reponse.md": answer})
        self.assertClean()
        self.edit("investigations/uf-vs-rum/claims/reponse.md", "depends_on: [rum-definition]", "depends_on: []")
        self.assertProblem(RED, "investigations/uf-vs-rum/claims/reponse.md", "au moins une preuve ou une prémisse")

    def test_terms_may_have_accents(self):
        self.edit("systems/cora/GLOSSARY.md", "## cora:rum", "## cora:séjour\n\nUn séjour.\n\n## cora:rum")
        self.edit("systems/cora/claims/mvt-rum-lien.md", "cora:rum]", "cora:rum, cora:séjour]")
        self.assertClean()

    def test_unquoted_hash_cuts_the_value(self):
        self.edit("systems/cora/claims/mvt-rum-lien.md", "scope: CORA, MCO, 2024-2025", "scope: CORA, MCO #2")
        self.assertProblem(RED, "systems/cora/claims/mvt-rum-lien.md", "« # »")
        self.edit("systems/cora/claims/mvt-rum-lien.md", "scope: CORA, MCO #2", 'scope: "CORA : MCO #2"')
        self.assertClean()

    def test_malformed_files_do_not_stop_the_check(self):
        self.write({"systems/cora/claims/cle-liste.md": "---\n[a, b]: c\nid: cle-liste\n---\n"})
        (self.root / "systems/cora/claims/latin.md").write_bytes(
            claim("latin").replace("relie", "relié").encode("latin-1"))
        self.edit("systems/cora/evidence/20261008-mvt-rum.md", "request: 20261007-mvt-rum", "request: [20261007-mvt-rum]")
        self.review("mvt-rum-lien", by="Marie", fingerprint="000000000000")
        messages = " ".join(p["message"] for p in self.run_checks())
        for words in ("clé non admise", "UTF-8", "texte simple"):
            self.assertIn(words, messages)

    def test_masked_query_for_column_names(self):
        self.write({"systems/cora/requests/20261011-colonnes.sql":
                    "-- id: 20261011-colonnes\n-- person_data: masked\n-- purpose: lister les colonnes\n"
                    "SELECT * FROM TB_PATIENT WHERE 1=0;\n"})
        self.assertClean()

    def test_select_star_variants_and_repeated_header(self):
        path = "systems/cora/requests/20261007-mvt-rum.sql"
        self.edit(path, "       ANNEE,", "       t.*,")
        self.assertProblem(RED, path, "SELECT *")
        self.edit(path, "SELECT '20261007-mvt-rum' AS request_id,\n       t.*,", "SELECT TOP 100 *, '20261007-mvt-rum',")
        self.assertProblem(RED, path, "SELECT *")
        self.write({path: REQUEST.replace("-- purpose:", "-- person_data: no-person-data\n-- purpose:")})
        self.assertProblem(RED, path, "clé répétée")

    def test_comments_do_not_count_in_a_request(self):
        path = "systems/cora/requests/20261013-patients.sql"
        header = "-- id: 20261013-patients\n-- person_data: masked\n-- purpose: test\n"
        self.write({path: header + "SELECT * FROM TB_PATIENT; -- WHERE 1=0\n"})
        self.assertProblem(RED, path, "SELECT *")
        self.write({path: header + "SELECT * FROM TB_PATIENT /* WHERE 1=0 */;\n"})
        self.assertProblem(RED, path, "SELECT *")
        self.edit("systems/cora/requests/20261007-mvt-rum.sql", "COUNT(*) < 10", "COUNT(*) < 5")
        self.edit("systems/cora/requests/20261007-mvt-rum.sql", "GROUP BY ANNEE;", "GROUP BY ANNEE; -- < 10")
        self.assertProblem(RED, "systems/cora/requests/20261007-mvt-rum.sql", "<10")

    def test_comment_marks_inside_a_literal_stay_sql(self):
        self.edit("systems/cora/requests/20261007-mvt-rum.sql", "       ANNEE,", "       'a--b' AS LIBELLE, t.*,")
        self.assertProblem(RED, "systems/cora/requests/20261007-mvt-rum.sql", "SELECT *")

    def test_column_names_query_is_a_single_select(self):
        path = "systems/cora/requests/20261013-patients.sql"
        self.write({path: "-- id: 20261013-patients\n-- person_data: masked\n-- purpose: test\n"
                          "SELECT * FROM TB_PATIENT WHERE 1=0 UNION SELECT * FROM TB_PATIENT;\n"})
        self.assertProblem(RED, path, "SELECT *")

    def test_masked_result_is_a_markdown_table(self):
        path = "systems/cora/evidence/20261008-mvt-rum.md"
        table = "| request_id | ANNEE | N_MVT |\n|---|---|---|\n| 20261007-mvt-rum | 2024 | 1520 |\n" \
                "| 20261007-mvt-rum | 2025 | <10 |\n"
        self.edit(path, table, "```text\nrequest_id\tANNEE\tN_MVT\n20261007-mvt-rum\t2025\t4\n```\n")
        self.assertProblem(RED, path, "tableau")
        self.edit(path, "```text", table + "\n```text")
        self.assertProblem(RED, path, "bloc")
        self.write({path: EXECUTION + "\nrequest_id\tANNEE\tN_MVT\n20261007-mvt-rum\t2023\t4\n"})
        self.assertProblem(RED, path, "hors du tableau")

    def test_mask_written_as_at_most_nine(self):
        self.edit("systems/cora/requests/20261007-mvt-rum.sql", "COUNT(*) < 10", "COUNT(*) <= 9")
        self.assertClean()

    def test_birth_date_false_positives(self):
        self.write({"investigations/2026-test/notes.md":
                    "Base de connaissances à jour au 2026-10-10.\n"
                    "Séjours de naissance du 01/01/2024 au 31/12/2024.\n",
                    "systems/cora/requests/20261012-age.sql": REQUEST.replace("20261007-mvt-rum", "20261012-age")
                    .replace("GROUP BY", "WHERE DT_NAISSANCE < '2008-10-01'\nGROUP BY")})
        self.assertClean()

    def test_birth_date_in_a_table_column(self):
        self.write({"investigations/2026-test/notes.md": "| SEXE | DATE_NAISSANCE |\n|---|---|\n| F | 1951-03-12 |\n"})
        self.assertProblem(RED, "investigations/2026-test/notes.md", "tableau")

    # Ligne de commande

    def test_command_line(self):
        script = str(Path(__file__).resolve().parent / "check.py")
        result = subprocess.run([sys.executable, script, "--root", str(self.root)],
                                capture_output=True, text=True, encoding="utf-8")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        result = subprocess.run([sys.executable, script, "--root", str(self.root), "--fingerprint", "mvt-rum-lien"],
                                capture_output=True, text=True, encoding="utf-8")
        self.assertEqual(result.stdout.strip(), self.current("mvt-rum-lien"))
        self.edit("systems/cora/claims/mvt-rum-lien.md", "maturity: observed", "maturity: certain")
        result = subprocess.run([sys.executable, script, "--root", str(self.root)],
                                capture_output=True, text=True, encoding="utf-8")
        self.assertEqual(result.returncode, 1)
        self.assertIn("ROUGE", result.stdout)


if __name__ == "__main__":
    unittest.main()
