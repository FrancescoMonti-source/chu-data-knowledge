"""Tests des contrôles. Lancer : python -m unittest discover checks"""

import re
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from check import ORANGE, RED, Repository, front_matter, normalized, query_header  # noqa: E402
from sync_skills import sync  # noqa: E402

DOCS = Path(__file__).resolve().parent.parent / "method"

QUERY = """\
-- id: 20261007-mvt-rum
-- system: cora
-- person_data: masked
-- purpose: compter les mouvements par année
SELECT '20261007-mvt-rum' AS query_id,
       ANNEE,
       CASE WHEN COUNT(*) < 10 THEN '<10' ELSE CAST(COUNT(*) AS VARCHAR(10)) END AS N_MVT
FROM TB_MVT_RUM
GROUP BY ANNEE;
"""

SCRIPT = """\
# id: 20261016-grp-rss
# system: cora
# person_data: masked
# purpose: compter les RSS par mois dans un fichier groupé
l <- readLines("CHEMIN/VERS/fichier.grp")
n <- table(substr(l, 105, 110))
print(data.frame(QUERY_ID = "20261016-grp-rss", MOIS = names(n),
                 N_RSS = ifelse(n < 10, "<10", as.character(n))))
"""

ROUTINE = """\
# id: grp-par-mois
# system: cora
# person_data: masked
# purpose: compter les RSS d'un fichier groupé par mois de sortie
# version: 1
grp_par_mois <- function(query_id, fichier, masquer = TRUE) {
  n <- table(substr(readLines(fichier), 105, 110))
  print(data.frame(QUERY_ID = query_id, ROUTINE = "grp-par-mois v1", MOIS = names(n),
                   N_RSS = if (masquer) ifelse(n < 10, "<10", as.character(n)) else as.character(n)))
}
"""

ROUTINE_RUN = """\
# id: 20261020-grp-m8-par-mois
# system: cora
# person_data: masked
# purpose: compter les RSS du fichier M8 par mois
# routine: grp-par-mois
source("CHEMIN/VERS/knowledge/routines/grp-par-mois/grp-par-mois.R")
grp_par_mois(query_id = "20261020-grp-m8-par-mois", fichier = "CHEMIN/VERS/fichier.grp")
"""

EXECUTION = """\
---
id: 20261008-mvt-rum
type: execution
query: 20261007-mvt-rum
run_at: 2026-10-08 09:14
database: CORAPROD
executed_by: Francesco
modified: no
person_data: masked
---
| query_id | ANNEE | N_MVT |
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
tables: [cora:TB_MVT, cora:TB_MVT_RUM]
supported_by: [20261008-mvt-rum]
depends_on: []
---
Raisonnement et limites.
"""

FILES = {
    "knowledge/glossaries/README.md": "# Carte des contextes\n\n| Contexte | Sorte | Glossaire |\n|---|---|---|\n"
                                      "| pmsi | domaine | pmsi.md |\n| cora | système | cora.md |\n",
    "knowledge/glossaries/cora.md": "# Glossaire CORA\n\n## cora:mouvement\n\nUn passage.\n\n## cora:rum\n\nUn RUM.\n",
    "knowledge/glossaries/pmsi.md": "# Glossaire PMSI\n\n## pmsi:rum\n\nRésumé d'unité médicale.\n",
    "knowledge/queries/20261007-mvt-rum.sql": QUERY,
    "knowledge/evidence/20261008-mvt-rum.md": EXECUTION,
    "sources/atih-guide-mco-2026.md": SOURCE,
    "knowledge/evidence/20261009-guide-rum.md": READING,
    "knowledge/claims/rum-definition.md": DOCUMENTARY,
    "knowledge/claims/mvt-rum-lien.md": EMPIRICAL,
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
        self.edit("knowledge/claims/mvt-rum-lien.md", "scope: CORA, MCO, 2024-2025\n", "")
        self.assertProblem(RED, "knowledge/claims/mvt-rum-lien.md", "obligatoire")

    def test_review_must_come_first(self):
        self.edit("knowledge/claims/mvt-rum-lien.md", "review: unreviewed\nid: mvt-rum-lien",
                  "id: mvt-rum-lien\nreview: unreviewed")
        self.assertProblem(RED, "knowledge/claims/mvt-rum-lien.md", "premier champ")

    def test_id_must_match_file_name(self):
        self.edit("knowledge/claims/mvt-rum-lien.md", "id: mvt-rum-lien", "id: autre-nom")
        self.assertProblem(RED, "knowledge/claims/mvt-rum-lien.md", "nom du fichier")

    def test_id_characters(self):
        self.write({"knowledge/claims/Mvt.md": claim("Mvt")})
        self.assertProblem(RED, "knowledge/claims/Mvt.md", "caractères")

    def test_duplicate_id_across_folders(self):
        self.write({"knowledge/evidence/mvt-rum-lien.md": READING.replace("20261009-guide-rum", "mvt-rum-lien")})
        self.assertProblem(RED, "knowledge/evidence/mvt-rum-lien.md", "existe déjà")

    def test_repeated_yaml_key_is_red(self):
        self.edit("knowledge/claims/mvt-rum-lien.md", "lifecycle: active", "lifecycle: active\nlifecycle: withdrawn")
        self.assertProblem(RED, "knowledge/claims/mvt-rum-lien.md", "clé répétée")

    def test_list_field_must_be_a_list(self):
        self.edit("knowledge/claims/mvt-rum-lien.md", "tables: [cora:TB_MVT, cora:TB_MVT_RUM]", "tables: TB_MVT")
        self.assertProblem(RED, "knowledge/claims/mvt-rum-lien.md", "liste")

    def test_unknown_value_is_red(self):
        self.edit("knowledge/claims/mvt-rum-lien.md", "maturity: observed", "maturity: certain")
        self.assertProblem(RED, "knowledge/claims/mvt-rum-lien.md", "non admise")

    # Liens et termes

    def test_unknown_term_is_red(self):
        self.edit("knowledge/claims/mvt-rum-lien.md", "cora:rum]", "cora:sejour]")
        self.assertProblem(RED, "knowledge/claims/mvt-rum-lien.md", "knowledge/glossaries/cora.md")
        self.edit("knowledge/claims/mvt-rum-lien.md", "cora:sejour]", "rum]")
        self.assertProblem(RED, "knowledge/claims/mvt-rum-lien.md", "n'a pas de contexte")

    def test_term_is_defined_in_the_glossary_of_its_context(self):
        self.edit("knowledge/glossaries/cora.md", "## cora:rum", "## pmsi:sejour\n\nUn séjour.\n\n## cora:rum")
        self.edit("knowledge/claims/mvt-rum-lien.md", "cora:rum]", "cora:rum, pmsi:sejour]")
        self.assertProblem(RED, "knowledge/claims/mvt-rum-lien.md", "knowledge/glossaries/pmsi.md")
        self.assertProblem(RED, "knowledge/glossaries/cora.md", "pmsi:sejour")

    def test_term_is_defined_once(self):
        self.edit("knowledge/glossaries/cora.md", "Un RUM.\n", "Un RUM.\n\n## cora:rum\n\nUn autre RUM.\n")
        self.assertProblem(RED, "knowledge/glossaries/cora.md", "défini deux fois")

    def test_claim_needs_a_term(self):
        self.edit("knowledge/claims/mvt-rum-lien.md", "terms: [cora:mouvement, cora:rum]", "terms: []")
        self.assertProblem(RED, "knowledge/claims/mvt-rum-lien.md", "au moins un terme")

    def test_tables_name_their_system(self):
        path = "knowledge/claims/mvt-rum-lien.md"
        self.edit(path, "tables: [cora:TB_MVT, cora:TB_MVT_RUM]", "tables: [TB_MVT, cora:TB_MVT_RUM]")
        self.assertProblem(RED, path, "« TB_MVT » ne dit pas son système")
        self.edit(path, "tables: [TB_MVT,", "tables: [corra:TB_MVT,")
        self.assertProblem(RED, path, "« corra »")

    def test_missing_evidence_is_red(self):
        self.edit("knowledge/claims/mvt-rum-lien.md", "[20261008-mvt-rum]", "[20261008-absent]")
        self.assertProblem(RED, "knowledge/claims/mvt-rum-lien.md", "n'existe pas")

    def test_link_to_wrong_type_is_red(self):
        self.edit("knowledge/claims/mvt-rum-lien.md", "supported_by: [20261008-mvt-rum]",
                  "supported_by: [20261008-mvt-rum, rum-definition]")
        self.assertProblem(RED, "knowledge/claims/mvt-rum-lien.md", "type evidence")

    # Règles du claim

    def test_refuted_if_only_for_empirical(self):
        self.edit("knowledge/claims/mvt-rum-lien.md", "refuted_if: un mouvement MCO sans aucune ligne dans TB_MVT_RUM\n", "")
        self.assertProblem(RED, "knowledge/claims/mvt-rum-lien.md", "obligatoire")
        self.assertNotIn("refuted_if", (self.root / "knowledge/claims/rum-definition.md").read_text(encoding="utf-8"))

    def test_decision_needs_responsible(self):
        self.write({"knowledge/claims/choix-annee.md": claim("choix-annee")
                    .replace("kind: empirical", "kind: decision")
                    .replace("maturity: observed", "maturity: provisional")
                    .replace("refuted_if:", "reconsider_when:")})
        self.assertProblem(RED, "knowledge/claims/choix-annee.md", "obligatoire")

    def test_authority_belongs_to_source(self):
        self.edit("knowledge/claims/mvt-rum-lien.md", "lifecycle: active", "lifecycle: active\nauthority: official")
        self.assertProblem(RED, "knowledge/claims/mvt-rum-lien.md", "autorité")

    def test_documentary_needs_a_reading(self):
        self.edit("knowledge/claims/rum-definition.md", "kind: documentary", "kind: empirical\nrefuted_if: x")
        self.edit("knowledge/claims/mvt-rum-lien.md", "kind: empirical", "kind: documentary")
        self.assertProblem(RED, "knowledge/claims/mvt-rum-lien.md", "lecture")

    def test_observed_needs_attributed_execution(self):
        self.edit("knowledge/evidence/20261008-mvt-rum.md", "database: CORAPROD", "database: unknown")
        self.assertProblem(RED, "knowledge/claims/mvt-rum-lien.md", "observed")

    def test_provisional_accepts_unknown_context(self):
        self.edit("knowledge/evidence/20261008-mvt-rum.md", "database: CORAPROD", "database: unknown")
        self.edit("knowledge/claims/mvt-rum-lien.md", "maturity: observed", "maturity: provisional")
        self.assertClean()

    def test_superseded_needs_a_successor(self):
        self.edit("knowledge/claims/mvt-rum-lien.md", "lifecycle: active", "lifecycle: superseded")
        self.assertProblem(RED, "knowledge/claims/mvt-rum-lien.md", "remplacer")
        self.write({"knowledge/claims/mvt-rum-lien-v2.md": claim("mvt-rum-lien-v2", extra="\nsupersedes: [mvt-rum-lien]")})
        self.assertClean()

    # Relecture et empreinte

    def test_current_review_is_clean(self):
        self.review("mvt-rum-lien", by="Marie")
        self.assertClean()

    def test_author_cannot_sign_reviewed(self):
        self.review("mvt-rum-lien", by="francesco")
        self.assertProblem(RED, "knowledge/claims/mvt-rum-lien.md", "auteur")

    def test_author_reread_is_for_author(self):
        self.review("mvt-rum-lien", by="Marie", status="author-reread")
        self.assertProblem(RED, "knowledge/claims/mvt-rum-lien.md", "réservé")

    def test_review_goes_stale_when_evidence_changes(self):
        self.review("mvt-rum-lien", by="Marie")
        self.edit("knowledge/evidence/20261008-mvt-rum.md", "1520", "1521")
        self.assertProblem(ORANGE, "knowledge/claims/mvt-rum-lien.md", "périmée")

    def test_review_goes_stale_when_query_or_premise_changes(self):
        self.write({"knowledge/claims/mvt-annuel.md": claim("mvt-annuel", depends_on="mvt-rum-lien")})
        self.review("mvt-annuel", by="Marie")
        self.edit("knowledge/queries/20261007-mvt-rum.sql", "GROUP BY ANNEE", "GROUP BY ANNEE, MOIS")
        self.assertProblem(ORANGE, "knowledge/claims/mvt-annuel.md", "périmée")

    def test_review_goes_stale_when_a_term_definition_changes(self):
        self.review("mvt-rum-lien", by="Marie")
        self.edit("knowledge/glossaries/cora.md", "Un RUM.", "Un séjour entier, toutes UF confondues.")
        self.assertProblem(ORANGE, "knowledge/claims/mvt-rum-lien.md", "périmée")

    def test_whole_definition_counts_in_fingerprint(self):
        self.edit("knowledge/glossaries/cora.md", "Un RUM.", "Un RUM.\n\n```text\n# exemple\n```\n\nUne ligne par UF.")
        self.review("mvt-rum-lien", by="Marie")
        self.edit("knowledge/glossaries/cora.md", "Une ligne par UF.", "Une ligne par séjour.")
        self.assertProblem(ORANGE, "knowledge/claims/mvt-rum-lien.md", "périmée")

    def test_aliases_stay_out_of_fingerprint(self):
        self.review("mvt-rum-lien", by="Marie")
        self.edit("knowledge/glossaries/cora.md", "## cora:rum\n\n", "## cora:rum\n\nAlias : résumé d'unité\n\n")
        self.assertClean()
        self.edit("knowledge/glossaries/cora.md", "Alias : résumé d'unité", "Alias : résumé d'unité, RUM CORA")
        self.assertClean()
        self.edit("knowledge/glossaries/cora.md", "Alias : résumé d'unité, RUM CORA\n\n", "")
        self.assertClean()

    def test_alias_like_text_in_definition_counts_in_fingerprint(self):
        examples = {
            "fenced block": "```text\nAlias : une ligne par UF.\n```",
            "definition body": "Un RUM.\n\nAlias : une ligne par UF.",
            "multiline text": "Alias\n: une ligne par UF.",
            "indented block": "    Alias : une ligne par UF.",
        }
        for placement, definition in examples.items():
            with self.subTest(placement=placement):
                self.write(FILES)
                self.edit("knowledge/glossaries/cora.md", "Un RUM.", definition)
                self.review("mvt-rum-lien", by="Marie")
                self.edit("knowledge/glossaries/cora.md", "une ligne par UF.", "une ligne par séjour.")
                self.assertProblem(ORANGE, "knowledge/claims/mvt-rum-lien.md", "périmée")

    def test_fingerprint_ignores_review_and_line_endings(self):
        before = self.current("mvt-rum-lien")
        self.review("mvt-rum-lien", by="Marie")
        path = self.root / "knowledge/claims/mvt-rum-lien.md"
        path.write_bytes(path.read_bytes().replace(b"\n", b"\r\n"))
        self.assertEqual(self.current("mvt-rum-lien"), before)
        self.assertRegex(before, r"^[0-9a-f]{12}$")

    def test_fingerprint_needs_only_loading(self):
        self.write({"knowledge/claims/mvt-annuel.md": claim("mvt-annuel", depends_on="mvt-rum-lien")})
        repository = Repository(self.root)
        repository.load()
        self.assertEqual(repository.fingerprint("mvt-annuel"), self.current("mvt-annuel"))

    # Réutilisation

    def test_reuse_of_unreviewed_claim_of_another_author(self):
        self.write({"knowledge/claims/mvt-annuel.md": claim("mvt-annuel", author="Marie", depends_on="mvt-rum-lien")})
        self.assertProblem(RED, "knowledge/claims/mvt-annuel.md", "autre personne")

    def test_reuse_is_orange_when_provisional_and_free_for_same_author(self):
        self.write({"knowledge/claims/mvt-annuel.md": claim("mvt-annuel", author="Marie", maturity="provisional",
                                                                depends_on="mvt-rum-lien")})
        self.assertProblem(ORANGE, "knowledge/claims/mvt-annuel.md", "autre personne")
        self.write({"knowledge/claims/mvt-annuel.md": claim("mvt-annuel", depends_on="mvt-rum-lien")})
        self.assertClean()

    def test_inactive_premise_is_flagged_transitively(self):
        self.write({"knowledge/claims/etape-1.md": claim("etape-1", depends_on="mvt-rum-lien"),
                    "knowledge/claims/etape-2.md": claim("etape-2", depends_on="etape-1")})
        self.edit("knowledge/claims/mvt-rum-lien.md", "lifecycle: active", "lifecycle: withdrawn")
        self.assertProblem(ORANGE, "knowledge/claims/etape-2.md", "mvt-rum-lien (withdrawn)")

    # Preuves et requêtes

    def test_execution_must_match_query_person_data(self):
        self.edit("knowledge/evidence/20261008-mvt-rum.md", "person_data: masked", "person_data: no-person-data")
        self.assertProblem(RED, "knowledge/evidence/20261008-mvt-rum.md", "diffère")

    def test_execution_takes_its_system_from_its_query(self):
        self.edit("knowledge/evidence/20261008-mvt-rum.md", "person_data: masked", "person_data: masked\nsystem: icca")
        self.assertProblem(RED, "knowledge/evidence/20261008-mvt-rum.md", "vient de sa requête")

    def test_modified_execution_keeps_the_sql(self):
        self.edit("knowledge/evidence/20261008-mvt-rum.md", "modified: no", "modified: yes")
        self.assertProblem(RED, "knowledge/evidence/20261008-mvt-rum.md", "version exécutée")
        self.edit("knowledge/evidence/20261008-mvt-rum.md", "| <10 |\n", "| <10 |\n\n```r\nl <- 1\n```\n")
        self.assertProblem(RED, "knowledge/evidence/20261008-mvt-rum.md", "```sql")

    def test_query_names_its_system(self):
        path = "knowledge/queries/20261007-mvt-rum.sql"
        self.edit(path, "-- system: cora\n", "")
        self.assertProblem(RED, path, "obligatoire")
        self.write({path: QUERY.replace("-- system: cora", "-- system: corra")})
        self.assertProblem(RED, path, "corra")

    def test_the_map_is_not_a_context(self):
        path = "knowledge/queries/20261007-mvt-rum.sql"
        self.write({path: QUERY.replace("-- system: cora", "-- system: README")})
        self.assertProblem(RED, path, "« README » n'a pas de glossaire")

    def test_reading_needs_a_quote(self):
        self.edit("knowledge/evidence/20261009-guide-rum.md", "> Le RUM", "Le RUM")
        self.assertProblem(RED, "knowledge/evidence/20261009-guide-rum.md", "citation")

    def test_masked_query_rules(self):
        self.edit("knowledge/queries/20261007-mvt-rum.sql", "SELECT '20261007-mvt-rum' AS query_id,", "SELECT")
        self.edit("knowledge/queries/20261007-mvt-rum.sql", "COUNT(*) < 10", "COUNT(*) < 5")
        problems = [p["message"] for p in self.run_checks()]
        self.assertTrue(any("première colonne" in m for m in problems), problems)
        self.assertTrue(any("<10" in m for m in problems), problems)

    def test_script_on_a_file_is_a_query(self):
        path = "knowledge/queries/20261016-grp-rss.R"
        self.write({path: SCRIPT,
                    "knowledge/evidence/20261016-grp-rss-resultat.md": EXECUTION
                    .replace("id: 20261008-mvt-rum", "id: 20261016-grp-rss-resultat")
                    .replace("query: 20261007-mvt-rum", "query: 20261016-grp-rss")})
        self.assertClean()
        self.edit("knowledge/evidence/20261016-grp-rss-resultat.md", "modified: no", "modified: yes")
        self.assertProblem(RED, "knowledge/evidence/20261016-grp-rss-resultat.md", "version exécutée")
        self.edit("knowledge/evidence/20261016-grp-rss-resultat.md", "| <10 |\n", "| <10 |\n\n```sql\nSELECT 1\n```\n")
        self.assertProblem(RED, "knowledge/evidence/20261016-grp-rss-resultat.md", "```r")
        self.edit("knowledge/evidence/20261016-grp-rss-resultat.md", "```sql\nSELECT 1", "```r\nl <- 1")
        self.assertClean()

    def test_masked_script_rules(self):
        path = "knowledge/queries/20261016-grp-rss.R"
        self.write({path: SCRIPT.replace('QUERY_ID = "20261016-grp-rss", ', "")
                    .replace('ifelse(n < 10, "<10", as.character(n))', "n  # < 10")
                    .replace("table(", "unique(")})
        problems = [p["message"] for p in self.run_checks() if p["path"] == path]
        for words in ("première colonne", "agrégats", "<10"):
            self.assertTrue(any(words in m for m in problems), problems)
        self.write({path: SCRIPT.replace("# system: cora", "-- system: cora")})
        self.assertProblem(RED, path, "obligatoire")

    def routine_files(self):
        return {"knowledge/routines/grp-par-mois/grp-par-mois.R": ROUTINE,
                "knowledge/routines/grp-par-mois/README.md": "# grp-par-mois\n\nCe que la routine compte.\n",
                "knowledge/queries/20261020-grp-m8-par-mois.R": ROUTINE_RUN,
                "knowledge/evidence/20261020-grp-m8-par-mois-resultat.md": EXECUTION
                .replace("id: 20261008-mvt-rum", "id: 20261020-grp-m8-par-mois-resultat")
                .replace("query: 20261007-mvt-rum", "query: 20261020-grp-m8-par-mois")}

    def test_routine_and_its_run(self):
        self.write(self.routine_files())
        self.assertClean()

    def test_routine_rules(self):
        path = "knowledge/routines/grp-par-mois/grp-par-mois.R"
        self.write(self.routine_files())
        self.edit(path, "# version: 1", "# version: 2")
        self.assertProblem(RED, path, "« grp-par-mois v2 »")
        self.edit(path, "# version: 2", "# version: v1")
        self.assertProblem(RED, path, "entier")
        self.write({path: ROUTINE.replace('ifelse(n < 10, "<10", as.character(n))', "n").replace("table(", "unique(")})
        problems = [p["message"] for p in self.run_checks() if p["path"] == path]
        for words in ("agrégats", "<10"):
            self.assertTrue(any(words in m for m in problems), problems)
        (self.root / "knowledge/routines/grp-par-mois/README.md").unlink()
        self.assertProblem(RED, path, "README.md")

    def test_routine_lives_in_its_own_folder(self):
        self.write(self.routine_files())
        (self.root / "knowledge/routines/grp-par-mois").rename(self.root / "knowledge/routines/grp")
        self.assertProblem(RED, "knowledge/routines/grp/grp-par-mois.R", "dossier à son nom")
        self.write({"knowledge/routines/grp/notes.txt": "brouillon\n"})
        self.assertProblem(RED, "knowledge/routines/grp/notes.txt", "ne lit pas")

    def test_run_of_a_routine(self):
        path = "knowledge/queries/20261020-grp-m8-par-mois.R"
        self.write(self.routine_files())
        self.edit(path, "# routine: grp-par-mois", "# routine: grp-par-semaine")
        self.assertProblem(RED, path, "« grp-par-semaine » n'existe pas")
        self.edit(path, "# routine: grp-par-semaine", "# routine: 20261007-mvt-rum")
        self.assertProblem(RED, path, "de type routine")
        self.edit(path, "# routine: 20261007-mvt-rum", "# routine: grp-par-mois")
        self.edit(path, "grp-par-mois.R", "autre.R")
        self.assertProblem(RED, path, "ne charge pas")
        self.edit(path, 'query_id = "20261020-grp-m8-par-mois", ', "")
        self.assertProblem(RED, path, "l'id de la requête")
        self.edit("knowledge/routines/grp-par-mois/grp-par-mois.R", "# person_data: masked", "# person_data: no-person-data")
        self.assertProblem(RED, path, "routine")

    def test_routine_change_makes_the_review_stale(self):
        self.write(self.routine_files())
        self.write({"knowledge/claims/rss-par-mois.md": claim("rss-par-mois", author="Marie")
                    .replace("[20261008-mvt-rum]", "[20261020-grp-m8-par-mois-resultat]")})
        self.review("rss-par-mois", by="Francesco")
        self.assertClean()
        self.edit("knowledge/routines/grp-par-mois/grp-par-mois.R", "substr(", "substring(")
        self.assertProblem(ORANGE, "knowledge/claims/rss-par-mois.md", "périmée")

    def test_select_star_only_for_column_names(self):
        self.write({"knowledge/queries/20261011-colonnes.sql":
                    "-- id: 20261011-colonnes\n-- system: cora\n-- person_data: no-person-data\n-- purpose: lister les colonnes\n"
                    "SELECT * FROM TB_MVT WHERE 1=0;\n"})
        self.assertClean()
        self.edit("knowledge/queries/20261011-colonnes.sql", " WHERE 1=0", "")
        self.assertProblem(RED, "knowledge/queries/20261011-colonnes.sql", "SELECT *")

    # Données personnelles

    def test_nir_with_valid_key_is_red_and_not_echoed(self):
        nir = valid_nir()
        self.write({"investigations/2026-test/README.md": f"Patient : {nir}\n"})
        self.assertProblem(RED, "investigations/2026-test/README.md", "NIR")
        self.assertNotIn(nir.replace(" ", "")[:7], str(self.run_checks()))

    def test_nir_with_wrong_key_is_ignored(self):
        nir = valid_nir()
        wrong = nir[:-2] + f"{(int(nir[-2:]) + 1) % 97:02d}"
        self.write({"investigations/2026-test/README.md": f"Numéro : {wrong}\n"})
        self.assertClean()

    def test_birth_date_is_red(self):
        self.write({"investigations/2026-test/README.md": "Date de naissance : 12/03/1951\n"})
        self.assertProblem(RED, "investigations/2026-test/README.md", "naissance")

    def test_small_count_in_masked_result_is_red(self):
        self.edit("knowledge/evidence/20261008-mvt-rum.md", "| 2025 | <10 |", "| 2025 | 7 |")
        self.assertProblem(RED, "knowledge/evidence/20261008-mvt-rum.md", "inférieur à 10")

    # Rangement

    def test_old_folders_are_red(self):
        self.write({"systems/cora/claims/mvt-annuel.md": claim("mvt-annuel")})
        self.assertProblem(RED, "systems/cora/claims/mvt-annuel.md", "remplacé par knowledge/ (")
        self.write({"domains/pmsi/GLOSSARY.md": "# Glossaire PMSI\n"})
        self.assertProblem(RED, "domains/pmsi/GLOSSARY.md", "remplacé par knowledge/ (")
        self.write({"docs/agents/issue-tracker.md": "# Issues\n"})
        self.assertProblem(RED, "docs/agents/issue-tracker.md", "remplacé par method/ (")
        self.write({"docs/adr/0019-editions.md": "# 0019 — Éditions\n"})
        self.assertProblem(RED, "docs/adr/0019-editions.md", "remplacé par method/adr/ (")

    def test_gitkeep_keeps_an_empty_folder(self):
        self.write({"knowledge/queries/.gitkeep": ""})
        self.assertClean()

    def test_hidden_system_file_is_left_alone(self):
        self.write({"knowledge/claims/.DS_Store": "\x00\x00\x00\x01Bud1"})
        self.assertClean()

    def test_knowledge_has_no_subject_folders(self):
        self.write({"knowledge/claims/cora/mvt-annuel.md": claim("mvt-annuel")})
        self.assertProblem(RED, "knowledge/claims/cora/mvt-annuel.md", "sous-dossier")

    def test_raw_export_in_an_investigation_is_red(self):
        self.write({"investigations/uf-vs-rum/resultat.xlsx": "PK\x03\x04"})
        self.assertProblem(RED, "investigations/uf-vs-rum/resultat.xlsx", "README.md")

    def test_investigation_holds_only_its_readme(self):
        self.write({"investigations/uf-vs-rum/claims/reponse.md": claim("reponse")})
        self.assertProblem(RED, "investigations/uf-vs-rum/claims/reponse.md", "README.md")

    # Skills

    def test_skill_copies_must_match(self):
        self.write({".agents/skills/frame/SKILL.md": "---\nname: frame\n---\nCadrer.\n"})
        self.assertProblem(RED, ".claude/skills", "diffère")
        sync(self.root)
        self.assertClean()

    # Cas limites

    def test_challenge_stays_orange_for_other_authors(self):
        self.write({"knowledge/claims/mvt-annuel.md": claim("mvt-annuel", author="Marie", depends_on="mvt-rum-lien")})
        self.review("mvt-rum-lien", by="Marie")
        self.edit("knowledge/claims/mvt-rum-lien.md", "lifecycle: active", "lifecycle: challenged")
        problems = self.run_checks()
        self.assertEqual([p["level"] for p in problems], [ORANGE], problems)
        self.assertIn("challenged", problems[0]["message"])

    def test_investigation_claim_can_rest_on_premises_only(self):
        answer = DOCUMENTARY.replace("id: rum-definition", "id: reponse") \
            .replace("supported_by: [20261009-guide-rum]", "supported_by: []") \
            .replace("depends_on: []", "depends_on: [rum-definition]")
        self.write({"knowledge/claims/reponse.md": answer})
        self.assertClean()
        self.edit("knowledge/claims/reponse.md", "depends_on: [rum-definition]", "depends_on: []")
        self.assertProblem(RED, "knowledge/claims/reponse.md", "au moins une preuve ou une prémisse")

    def test_answer_maturity_follows_its_premises(self):
        path = "knowledge/claims/reponse.md"
        self.edit("knowledge/claims/rum-definition.md", "author: Marie", "author: Francesco")
        self.write({path: claim("reponse", depends_on="rum-definition, mvt-rum-lien")
                    .replace("supported_by: [20261008-mvt-rum]", "supported_by: []")})
        self.assertClean()
        self.edit(path, "maturity: observed", "maturity: documented")
        self.assertProblem(RED, path, "maturité")
        self.edit(path, "maturity: documented", "maturity: provisional")
        self.assertClean()
        self.edit(path, "maturity: provisional", "maturity: observed")
        self.edit("knowledge/claims/mvt-rum-lien.md", "maturity: observed", "maturity: provisional")
        self.assertProblem(RED, path, "maturité")

    def test_terms_may_have_accents(self):
        self.edit("knowledge/glossaries/cora.md", "## cora:rum", "## cora:séjour\n\nUn séjour.\n\n## cora:rum")
        self.edit("knowledge/claims/mvt-rum-lien.md", "cora:rum]", "cora:rum, cora:séjour]")
        self.assertClean()

    def test_unquoted_hash_cuts_the_value(self):
        self.edit("knowledge/claims/mvt-rum-lien.md", "scope: CORA, MCO, 2024-2025", "scope: CORA, MCO #2")
        self.assertProblem(RED, "knowledge/claims/mvt-rum-lien.md", "« # »")
        self.edit("knowledge/claims/mvt-rum-lien.md", "scope: CORA, MCO #2", 'scope: "CORA : MCO #2"')
        self.assertClean()

    def test_malformed_files_do_not_stop_the_check(self):
        self.write({"knowledge/claims/cle-liste.md": "---\n[a, b]: c\nid: cle-liste\n---\n"})
        (self.root / "knowledge/claims/latin.md").write_bytes(
            claim("latin").replace("relie", "relié").encode("latin-1"))
        self.edit("knowledge/evidence/20261008-mvt-rum.md", "query: 20261007-mvt-rum", "query: [20261007-mvt-rum]")
        self.review("mvt-rum-lien", by="Marie", fingerprint="000000000000")
        messages = " ".join(p["message"] for p in self.run_checks())
        for words in ("clé non admise", "UTF-8", "texte simple"):
            self.assertIn(words, messages)

    def test_masked_query_for_column_names(self):
        self.write({"knowledge/queries/20261011-colonnes.sql":
                    "-- id: 20261011-colonnes\n-- system: cora\n-- person_data: masked\n-- purpose: lister les colonnes\n"
                    "SELECT * FROM TB_PATIENT WHERE 1=0;\n"})
        self.assertClean()

    def test_select_star_variants_and_repeated_header(self):
        path = "knowledge/queries/20261007-mvt-rum.sql"
        self.edit(path, "       ANNEE,", "       t.*,")
        self.assertProblem(RED, path, "SELECT *")
        self.edit(path, "SELECT '20261007-mvt-rum' AS query_id,\n       t.*,", "SELECT TOP 100 *, '20261007-mvt-rum',")
        self.assertProblem(RED, path, "SELECT *")
        self.write({path: QUERY.replace("-- purpose:", "-- person_data: no-person-data\n-- purpose:")})
        self.assertProblem(RED, path, "clé répétée")

    def test_comments_do_not_count_in_a_query(self):
        path = "knowledge/queries/20261013-patients.sql"
        header = "-- id: 20261013-patients\n-- system: cora\n-- person_data: masked\n-- purpose: test\n"
        self.write({path: header + "SELECT * FROM TB_PATIENT; -- WHERE 1=0\n"})
        self.assertProblem(RED, path, "SELECT *")
        self.write({path: header + "SELECT * FROM TB_PATIENT /* WHERE 1=0 */;\n"})
        self.assertProblem(RED, path, "SELECT *")
        self.edit("knowledge/queries/20261007-mvt-rum.sql", "COUNT(*) < 10", "COUNT(*) < 5")
        self.edit("knowledge/queries/20261007-mvt-rum.sql", "GROUP BY ANNEE;", "GROUP BY ANNEE; -- < 10")
        self.assertProblem(RED, "knowledge/queries/20261007-mvt-rum.sql", "<10")

    def test_comment_marks_inside_a_literal_stay_sql(self):
        self.edit("knowledge/queries/20261007-mvt-rum.sql", "       ANNEE,", "       'a--b' AS LIBELLE, t.*,")
        self.assertProblem(RED, "knowledge/queries/20261007-mvt-rum.sql", "SELECT *")

    def test_column_names_query_is_a_single_select(self):
        path = "knowledge/queries/20261013-patients.sql"
        self.write({path: "-- id: 20261013-patients\n-- system: cora\n-- person_data: masked\n-- purpose: test\n"
                          "SELECT * FROM TB_PATIENT WHERE 1=0 UNION SELECT * FROM TB_PATIENT;\n"})
        self.assertProblem(RED, path, "SELECT *")

    def test_masked_result_is_a_markdown_table(self):
        path = "knowledge/evidence/20261008-mvt-rum.md"
        table = "| query_id | ANNEE | N_MVT |\n|---|---|---|\n| 20261007-mvt-rum | 2024 | 1520 |\n" \
                "| 20261007-mvt-rum | 2025 | <10 |\n"
        self.edit(path, table, "```text\nquery_id\tANNEE\tN_MVT\n20261007-mvt-rum\t2025\t4\n```\n")
        self.assertProblem(RED, path, "tableau")
        self.edit(path, "```text", table + "\n```text")
        self.assertProblem(RED, path, "bloc")
        self.write({path: EXECUTION + "\nquery_id\tANNEE\tN_MVT\n20261007-mvt-rum\t2023\t4\n"})
        self.assertProblem(RED, path, "hors du tableau")

    def test_mask_written_as_at_most_nine(self):
        self.edit("knowledge/queries/20261007-mvt-rum.sql", "COUNT(*) < 10", "COUNT(*) <= 9")
        self.assertClean()

    def test_birth_date_false_positives(self):
        self.write({"investigations/2026-test/README.md":
                    "Base de connaissances à jour au 2026-10-10.\n"
                    "Séjours de naissance du 01/01/2024 au 31/12/2024.\n",
                    "knowledge/queries/20261012-age.sql": QUERY.replace("20261007-mvt-rum", "20261012-age")
                    .replace("GROUP BY", "WHERE DT_NAISSANCE < '2008-10-01'\nGROUP BY")})
        self.assertClean()

    def test_birth_date_in_a_table_column(self):
        self.write({"investigations/2026-test/README.md": "| SEXE | DATE_NAISSANCE |\n|---|---|\n| F | 1951-03-12 |\n"})
        self.assertProblem(RED, "investigations/2026-test/README.md", "tableau")

    # Exemples de method/

    def test_doc_examples_pass_the_check(self):
        """Les exemples que les agents recopient, mis à la place des fichiers de base (mêmes ids), passent le contrôle."""
        folders = set()
        for doc in sorted(DOCS.glob("*.md")):
            text = normalized(doc.read_text(encoding="utf-8"))
            for language, example in re.findall(r"^```(markdown|sql|r)\n(.*?)^```", text, re.MULTILINE | re.DOTALL):
                if language == "sql":
                    name = f"knowledge/queries/{query_header(example)[0]['id']}.sql"
                elif language == "r":
                    header = query_header(example, "#")[0]
                    name = (f"knowledge/routines/{header['id']}/{header['id']}.R" if "version" in header
                            else f"knowledge/queries/{header['id']}.R")
                    if "version" in header:
                        self.write({f"knowledge/routines/{header['id']}/README.md": "# Méthode\n"})
                elif example.startswith("---\n"):
                    header = front_matter(example)[0]
                    folder = ("knowledge/claims" if "kind" in header else
                              "knowledge/evidence" if "type" in header else "sources")
                    name = f"{folder}/{header['id']}.md"
                else:
                    continue
                self.write({name: example})
                folders.add("routines" if "/routines/" in name else name.split("/")[-2])
        self.assertEqual(folders, {"claims", "evidence", "queries", "routines", "sources"})
        self.assertClean()

    # Ligne de commande

    def test_command_line(self):
        script = str(Path(__file__).resolve().parent / "check.py")
        result = subprocess.run([sys.executable, script, "--root", str(self.root)],
                                capture_output=True, text=True, encoding="utf-8")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        result = subprocess.run([sys.executable, script, "--root", str(self.root), "--fingerprint", "mvt-rum-lien"],
                                capture_output=True, text=True, encoding="utf-8")
        self.assertEqual(result.stdout.strip(), self.current("mvt-rum-lien"))
        self.edit("knowledge/claims/mvt-rum-lien.md", "maturity: observed", "maturity: certain")
        result = subprocess.run([sys.executable, script, "--root", str(self.root)],
                                capture_output=True, text=True, encoding="utf-8")
        self.assertEqual(result.returncode, 1)
        self.assertIn("ROUGE", result.stdout)


if __name__ == "__main__":
    unittest.main()
