"""Contrôles du dépôt.

ROUGE  : quelque chose est cassé ; à corriger avant le merge (code de sortie 1).
ORANGE : du travail reste à faire (relecture périmée, claim à réexaminer) ; ne bloque pas.

Usage :
    python checks/check.py                   contrôle tout le dépôt
    python checks/check.py --fingerprint ID  affiche l'empreinte à recopier dans une relecture

Les règles contrôlées et leurs limites : method/checks.md.
"""

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

import yaml

RED, ORANGE = "ROUGE", "ORANGE"
ID_PATTERN = re.compile(r"[a-z0-9][a-z0-9-]*")
TERM_HEADING = re.compile(r"^##\s+([\w-]+:[\w-]+)\s*$", re.MULTILINE)
ALIAS_LINE = re.compile(r"\A(?:[ \t]*\n)*Alias[ \t]*:[^\n]*(?:\n|$)")

CLAIM_FIELDS = ("review", "id", "kind", "author", "statement", "scope", "maturity",
                "lifecycle", "terms", "tables", "supported_by", "depends_on")
CLAIM_LISTS = ("terms", "tables", "supported_by", "depends_on", "challenges", "supersedes")
CLAIM_VALUES = {"kind": ("documentary", "empirical", "decision"),
                "maturity": ("documented", "observed", "provisional"),
                "lifecycle": ("active", "challenged", "superseded", "withdrawn")}
KIND_FIELDS = {"empirical": ("refuted_if",), "decision": ("responsible", "reconsider_when")}
EXECUTION_FIELDS = ("id", "type", "query", "run_at", "database", "executed_by",
                    "modified", "person_data")
READING_FIELDS = ("id", "type", "source", "locator", "read_by", "read_at")
SOURCE_FIELDS = ("id", "title", "publisher", "edition", "location", "authority")
SOURCE_AUTHORITY = ("official", "vendor-doc", "local", "unknown")
PERSON_DATA = ("masked", "no-person-data")
QUERY_FIELDS = ("id", "system", "person_data", "purpose")
ROUTINE_FIELDS = ("id", "system", "purpose")
INACTIVE = ("challenged", "superseded", "withdrawn")
DOCS = {"claim": "claims.md", "evidence": "evidence.md", "source": "evidence.md", "query": "queries.md",
        "routine": "queries.md"}
ROLES = {"knowledge/claims/*.md": "claim", "knowledge/evidence/*.md": "evidence", "sources/*.md": "source",
         "knowledge/queries/*": "query", "knowledge/routines/*/*": "routine"}  # requête, routine : selon LANGUAGES
GLOSSARIES = "knowledge/glossaries/*.md"
READMES = ("investigations/README.md", "investigations/*/README.md", "knowledge/routines/*/README.md")
OLD_FOLDERS = {"systems": "knowledge/", "domains": "knowledge/",
               "docs/agents": "method/", "docs/adr": "method/adr/"}

NIR = re.compile(r"\b[12]\s?\d{2}\s?\d{2}\s?(?:\d{2}|2[AB])\s?\d{3}\s?\d{3}\s?\d{2}\b")
FULL_DATE = r"\b(?:\d{2}/\d{2}/\d{4}|\d{4}-\d{2}-\d{2})\b"
BIRTH_DATE = re.compile(r"(?i)\b(?:date\s+de\s+naissance|n[ée]e?\s+le|ddn|dob|date\s+of\s+birth|birth\s*date)\b"
                        r"[^\n]{0,40}?" + FULL_DATE)
BIRTH_COLUMN = re.compile(r"(?i)(?:^|[_\s])(?:naiss|birth|dob|ddn)")
COUNT_COLUMN = re.compile(r"(?i)^(?:n|nb)(?:_|$)")
SELECT_STAR = re.compile(r"(?i)(?:\bselect\s+(?:(?:distinct|all)\s+|top\s*\(?\s*\d+\s*\)?\s+(?:percent\s+)?)*|,\s*)"
                         r"(?:[\w\"\[\]]+\.)?\*")
NO_ROWS = re.compile(r"(?i)\bwhere\s+1\s*=\s*0\b")
SELECT = re.compile(r"(?i)\bselect\b")
SQL_COMMENT = re.compile(r"'(?:[^']|'')*'|\"(?:[^\"]|\"\")*\"|--[^\n]*|/\*.*?\*/", re.DOTALL)
HASH_COMMENT = re.compile(r"'(?:[^'\\]|\\.)*'|\"(?:[^\"\\]|\\.)*\"|#[^\n]*")
FENCE = re.compile(r"\s*```\s*(\S*)")
MASK = re.compile(r"(?<!')<\s*10\b|<=\s*9\b|>=\s*10\b|>\s*9\b")
AGGREGATE = re.compile(r"(?i)\b(?:count|sum|avg|min|max)\s*\(")
SCRIPT_AGGREGATE = re.compile(r"\b(?:sum|length|nrow|table|tabulate|aggregate|tapply|mean|median|min|max"
                              r"|len|count|value_counts|groupby|size|nunique|Counter)\s*\(")
UNQUOTED_HASH = re.compile(r"\s*([\w-]+):\s+[^\"'\s\[{][^\n]*\s#")

# Les langages d'une requête, un par ligne ; la casse de la fin du fichier ne compte pas (.R ou .r).
# fence : le bloc de la version exécutée dans une preuve ; mark : le début des lignes d'en-tête ;
# quotes : les guillemets autour de l'id dans le résultat ; roles : requête, et routine pour un outil qu'on relance.
SCRIPT = {"mark": "#", "comments": HASH_COMMENT, "aggregate": SCRIPT_AGGREGATE, "quotes": "'\"",
          "roles": ("query", "routine"), "id_fix": 'Mettre QUERY_ID = "{}" en tête du tableau imprimé.',
          "aggregate_fix": "Compter (sum, length, table…) au lieu d'imprimer des lignes du fichier."}
LANGUAGES = {
    ".sql": {"fence": "sql", "mark": "--", "comments": SQL_COMMENT, "aggregate": AGGREGATE, "quotes": "'",
             "roles": ("query",), "id_fix": "Ajouter '{}' AS query_id en tête du SELECT.",
             "aggregate_fix": "Agréger (COUNT, SUM…) au lieu de renvoyer des lignes individuelles."},
    ".R": {**SCRIPT, "fence": "r"},
    ".py": {**SCRIPT, "fence": "python"},
}
ROUTINE_ENDINGS = [ending for ending, row in LANGUAGES.items() if "routine" in row["roles"]]
LOADS_ROUTINE = re.compile(r"routines[/\\]+[\w-]+[/\\]+[\w-]+\.(?i:"
                           + "|".join(re.escape(ending[1:]) for ending in ROUTINE_ENDINGS) + r")\b")
SCANNED = (".md", ".txt", ".csv", ".tsv", ".json", ".yml", ".yaml", *(ending.lower() for ending in LANGUAGES))


def listed(items):
    return ", ".join(items[:-1]) + " ou " + items[-1] if len(items) > 1 else items[0]


UNREAD = {
    "knowledge": ("le contrôle ne lit pas ce fichier : knowledge/ a un dossier par type, sans sous-dossier "
                  f"sauf un par routine, et des fichiers .md ({listed(list(LANGUAGES))} pour les requêtes, "
                  f"{listed(ROUTINE_ENDINGS)} et README.md pour une routine).",
                  "Le ranger dans knowledge/claims/, evidence/, queries/, glossaries/ ou routines/<id>/, au format "
                  "de son type (method/layout.md)."),
    "investigations": ("une enquête n'a que son README.md : le contrôle ne lit pas ce fichier.",
                       "Un claim va dans knowledge/claims/ ; un résultat devient une preuve de knowledge/evidence/, "
                       "après le filtre de method/privacy.md."),
}


class Loader(yaml.BaseLoader):
    """Lit chaque valeur comme du texte : `no` reste "no", une date reste une chaîne."""


def _unique_mapping(loader, node, deep=False):
    keys = set()
    for key_node, _ in node.value:
        key = loader.construct_object(key_node, deep=deep)
        if not isinstance(key, str):
            raise yaml.constructor.ConstructorError(
                None, None, "clé non admise : une clé est un mot simple", key_node.start_mark)
        if key in keys:
            raise yaml.constructor.ConstructorError(
                None, None, f"clé répétée : {key}", key_node.start_mark)
        keys.add(key)
    return loader.construct_mapping(node, deep=deep)


Loader.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, _unique_mapping)


def normalized(text):
    lines = text.replace("\r\n", "\n").removeprefix("﻿").split("\n")
    return "\n".join(line.rstrip() for line in lines).strip("\n") + "\n"


def front_matter(text):
    """Renvoie (en-tête, corps) d'un fichier Markdown à en-tête YAML."""
    text = normalized(text)
    if not text.startswith("---\n"):
        raise ValueError("le fichier ne commence pas par un en-tête YAML entre deux lignes ---")
    end = text.find("\n---\n", 3)
    if end == -1:
        raise ValueError("l'en-tête YAML n'est pas fermé par une ligne ---")
    for line in text[4:end].split("\n"):
        match = UNQUOTED_HASH.match(line)
        if match:
            raise ValueError(f"« # » coupe la valeur de {match.group(1)} : le reste de la ligne est ignoré")
    try:
        header = yaml.load(text[4:end], Loader=Loader)
    except yaml.YAMLError as error:
        raise ValueError("en-tête YAML illisible : " + str(error).splitlines()[0]) from error
    if not isinstance(header, dict):
        raise ValueError("l'en-tête YAML doit être une liste de champs « clé: valeur »")
    return header, text[end + 5:]


def table_rows(text):
    """Les lignes de données des tableaux Markdown : (colonnes, cellules)."""
    columns = None
    for line in text.split("\n"):
        if not line.lstrip().startswith("|"):
            columns = None
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if columns is None:
            columns = cells
        elif not all(set(cell) <= set("-: ") for cell in cells):
            yield columns, cells


def definitions(text):
    """Les termes d'un glossaire : (terme, définition), la définition allant jusqu'au terme suivant.
    Couper plus tôt, à un « # » dans un bloc de code par exemple, laisserait une relecture à jour à tort.
    Seule la ligne « Alias : » juste sous le titre reste hors de la définition (0021)."""
    text = normalized(text)
    matches = list(TERM_HEADING.finditer(text))
    for match, end in zip(matches, [m.start() for m in matches[1:]] + [len(text)]):
        yield match.group(1), ALIAS_LINE.sub("", text[match.end():end], count=1).strip()


def query_header(text, mark="--"):
    """Lit les lignes « -- clé: valeur » au début d'un fichier .sql, « # clé: valeur » au début d'un script."""
    header, body = {}, []
    lines = normalized(text).split("\n")
    for index, line in enumerate(lines):
        match = re.match(re.escape(mark) + r"\s*([a-z_]+)\s*:\s*(.*)", line)
        if not match:
            body = lines[index:]
            break
        if match.group(1) in header:
            raise ValueError("clé répétée : " + match.group(1))
        header[match.group(1)] = match.group(2).strip()
    return header, "\n".join(body)


class Repository:
    def __init__(self, root):
        self.root = Path(root)
        self.problems = []
        self.records = {}
        self.contexts = set()
        self.terms = {}
        self.fingerprints = {}

    def report(self, level, path, field, message, fix):
        self.problems.append({"level": level, "path": path, "field": field,
                              "message": message, "fix": fix})

    def relative(self, path):
        return path.relative_to(self.root).as_posix()

    # Lecture

    def load(self):
        for path in sorted(self.root.rglob("*")):
            if (path.is_file() and path.suffix.lower() in SCANNED and ".git" not in path.parts
                    and not (path.suffix == ".py" and path.parent == self.root / "checks")):  # ses tests portent des données fausses
                try:
                    text = path.read_text(encoding="utf-8")
                except UnicodeDecodeError:
                    self.report(RED, self.relative(path), None, "le fichier n'est pas encodé en UTF-8.",
                                "L'enregistrer en UTF-8.")
                    text = path.read_text(encoding="utf-8", errors="replace")
                self.check_privacy(self.relative(path), text)
        for glossary in sorted(self.root.glob(GLOSSARIES)):
            if glossary.name == "README.md":  # la carte des contextes, pas un glossaire
                continue
            self.contexts.add(glossary.stem)
            for term, definition in definitions(glossary.read_text(encoding="utf-8", errors="replace")):
                if not term.startswith(glossary.stem + ":"):
                    self.report(RED, self.relative(glossary), None,
                                f"« {term} » n'est pas un terme du contexte {glossary.stem}.",
                                f"Le définir dans knowledge/glossaries/{term.split(':')[0]}.md, "
                                "le glossaire de son contexte.")
                elif term in self.terms:
                    self.report(RED, self.relative(glossary), None, f"« {term} » est défini deux fois.",
                                "Garder une seule définition, sous un seul titre ## " + term + ".")
                else:
                    self.terms[term] = definition
        for path, role in self.files():
            self.add(path, role)

    def files(self):
        """Les fichiers lus avec leur rôle ; une requête ou une routine se reconnaît à son langage."""
        for pattern, role in ROLES.items():
            for path in sorted(self.root.glob(pattern)):
                if pattern.endswith(".md") or role in (language(path) or {}).get("roles", ()):
                    yield path, role

    def add(self, path, role):
        name = self.relative(path)
        text = path.read_text(encoding="utf-8", errors="replace")
        try:
            header, body = (query_header(text, language(path)["mark"]) if role in ("query", "routine")
                            else front_matter(text))
        except ValueError as error:
            self.report(RED, name, None, str(error), "Corriger l'en-tête : voir method/" + DOCS[role] + ".")
            return
        record = {"role": role, "path": name, "header": header, "body": body, "text": normalized(text)}
        identifier = header.get("id")
        if identifier != path.stem:
            self.report(RED, name, "id", f"l'id doit être le nom du fichier : « {path.stem} ».",
                        "Mettre le même texte dans le champ id et dans le nom du fichier.")
            return
        if not ID_PATTERN.fullmatch(identifier):
            self.report(RED, name, "id", "l'id contient des caractères non admis.",
                        "Utiliser seulement des minuscules, des chiffres et des tirets.")
            return
        if identifier in self.records:
            self.report(RED, name, "id", "cet id existe déjà : " + self.records[identifier]["path"] + ".",
                        "Choisir un id unique dans tout le dépôt.")
            return
        self.records[identifier] = record
        if role == "claim":
            record["valid"] = self.claim_shape(record)

    # Contrôles

    def run(self):
        self.load()
        for record in self.records.values():
            getattr(self, "check_" + record["role"])(record)
        self.check_reuse()
        self.check_places()
        self.check_skill_copies()
        return self.problems

    def require(self, record, fields):
        """Champs présents et non vides ; texte simple, sauf review et les listes du claim."""
        header, wrong = record["header"], []
        for field in fields:
            value = header.get(field)
            if not (value or value == []):
                self.report(RED, record["path"], field, "champ obligatoire absent ou vide.",
                            "Remplir le champ (method/" + DOCS[record["role"]] + ").")
            elif field not in CLAIM_LISTS + ("review",) and not isinstance(value, str):
                self.report(RED, record["path"], field, "ce champ doit être un texte simple.",
                            "Écrire la valeur sur la même ligne, sans liste ni sous-champs.")
            else:
                continue
            wrong.append(field)
        return not wrong

    def allowed(self, record, field, values):
        if record["header"].get(field) not in values:
            self.report(RED, record["path"], field, "valeur non admise.",
                        "Choisir parmi : " + ", ".join(values) + ".")

    def linked(self, record, field, identifiers, role):
        for identifier in identifiers:
            target = self.records.get(identifier)
            if target is None:
                self.report(RED, record["path"], field, f"« {identifier} » n'existe pas.",
                            "Corriger l'id, ou ajouter le fichier manquant.")
            elif target["role"] != role:
                self.report(RED, record["path"], field, f"« {identifier} » n'est pas un fichier de type {role}.",
                            "Citer un fichier du bon type.")

    def known_context(self, record, field, context):
        """Le système d'une requête ou d'une table est un contexte qui a son glossaire."""
        if context not in self.contexts:
            self.report(RED, record["path"], field, f"« {context} » n'a pas de glossaire dans knowledge/glossaries/.",
                        "Écrire le système comme dans la carte (knowledge/glossaries/README.md) ; un système absent "
                        "de la carte y entre d'abord, avec son glossaire (method/layout.md).")

    def claim_shape(self, claim):
        """Forme du claim, vue au chargement : sans elle, ses autres contrôles et son empreinte n'ont pas de sens."""
        header, path = claim["header"], claim["path"]
        if list(header)[:1] != ["review"]:
            self.report(RED, path, "review", "review doit être le premier champ.",
                        "Placer review en tête de l'en-tête YAML.")
        if not self.require(claim, CLAIM_FIELDS):
            return False
        for field in CLAIM_LISTS:
            value = header.get(field, [])
            if not isinstance(value, list) or not all(isinstance(item, str) for item in value):
                self.report(RED, path, field, "ce champ doit être une liste d'ids ou de termes.",
                            "Écrire par exemple : " + field + ": [a, b] ou " + field + ": [].")
                return False
        return True

    def check_claim(self, claim):
        if not claim["valid"]:
            return
        header, path = claim["header"], claim["path"]
        for field, values in CLAIM_VALUES.items():
            self.allowed(claim, field, values)
        self.require(claim, KIND_FIELDS.get(header["kind"], ()))
        if "authority" in header:
            self.report(RED, path, "authority", "l'autorité appartient à la source ou à la preuve, pas au claim.",
                        "Retirer authority ; décrire l'autorité dans la fiche de la source.")
        if not header["terms"]:
            self.report(RED, path, "terms", "un claim cite au moins un terme : ses termes disent son contexte.",
                        "Citer ses termes avec leur contexte, par exemple cora:mouvement "
                        "(method/layout.md, « Termes et glossaires »).")
        for term in header["terms"]:
            context, colon, _ = term.partition(":")
            if not colon:
                self.report(RED, path, "terms", f"le terme « {term} » n'a pas de contexte.",
                            "L'écrire avec son contexte, par exemple pmsi:rum "
                            "(method/layout.md, « Termes et glossaires »).")
            elif term not in self.terms:
                self.report(RED, path, "terms", f"le terme « {term} » n'est pas défini dans "
                            f"knowledge/glossaries/{context}.md.",
                            "Ajouter le terme à ce glossaire, ou corriger le terme "
                            "(method/layout.md, « Termes et glossaires »).")
        for table in header["tables"]:
            context, colon, _ = table.partition(":")
            if not colon:
                self.report(RED, path, "tables", f"la table « {table} » ne dit pas son système.",
                            "L'écrire avec son système, par exemple cora:TB_MVT_RUM (method/claims.md).")
            else:
                self.known_context(claim, "tables", context)
        self.linked(claim, "supported_by", header["supported_by"], "evidence")
        for field in ("depends_on", "challenges", "supersedes"):
            self.linked(claim, field, header.get(field, []), "claim")
        evidence = [self.records[i] for i in header["supported_by"]
                    if i in self.records and self.records[i]["role"] == "evidence"]
        if not header["supported_by"] and not header["depends_on"]:
            self.report(RED, path, "supported_by", "un claim s'appuie sur au moins une preuve ou une prémisse.",
                        "Citer ses preuves dans supported_by ou ses prémisses dans depends_on.")
        # Sans preuve propre, un claim d'enquête est contrôlé à travers ses prémisses.
        if (header["supported_by"] and header["kind"] == "documentary"
                and not any(e["header"].get("type") == "reading" for e in evidence)):
            self.report(RED, path, "supported_by", "un claim documentaire cite au moins une lecture.",
                        "Ajouter une preuve de type reading.")
        if (header["supported_by"] and header["kind"] == "empirical" and header["maturity"] == "observed"
                and not any(attributed_execution(e) for e in evidence)):
            self.report(RED, path, "maturity", "observed demande une exécution dont tout le contexte est connu.",
                        "Citer une exécution sans valeur unknown, ou passer maturity à provisional.")
        if header["lifecycle"] == "superseded" and not any(
                claim["header"]["id"] in other["header"].get("supersedes", [])
                for other in self.records.values() if other["role"] == "claim"):
            self.report(RED, path, "lifecycle", "aucun claim ne déclare remplacer celui-ci.",
                        "Ajouter supersedes: [" + header["id"] + "] dans le claim qui le remplace.")
        if not header["supported_by"]:
            self.check_derived_maturity(claim)
        self.check_review(claim)

    def check_derived_maturity(self, claim):
        """Sans preuve propre, la maturité vient des prémisses : seul provisional est plus faible."""
        header = claim["header"]
        premises = [self.records[i]["header"]["maturity"] for i in header["depends_on"]
                    if self.records.get(i, {}).get("valid")]
        if not premises:
            return
        if "provisional" in premises:
            expected = "provisional"
        elif header["kind"] == "empirical" and "observed" in premises:
            expected = "observed"
        else:
            expected = "documented"
        if header["maturity"] not in (expected, "provisional"):
            self.report(RED, claim["path"], "maturity", f"la maturité ne suit pas celle des prémisses : {expected} attendu.",
                        f"Écrire maturity: {expected}, ou provisional "
                        "(method/claims.md, « Claim sans preuve propre »).")

    def check_review(self, claim):
        review, path, author = claim["header"]["review"], claim["path"], claim["header"]["author"]
        if review == "unreviewed":
            return
        if not isinstance(review, dict) or review.get("status") not in ("reviewed", "author-reread"):
            self.report(RED, path, "review", "valeur non admise.",
                        "Écrire review: unreviewed, ou un bloc status/by/at/work/fingerprint "
                        "(method/review.md).")
            return
        missing = [field for field in ("by", "at", "work", "fingerprint")
                   if not isinstance(review.get(field), str) or not review[field]]
        if missing:
            self.report(RED, path, "review", "relecture incomplète : " + ", ".join(missing) + ".",
                        "Compléter le bloc review (method/review.md).")
            return
        same_person = review["by"].strip().casefold() == author.strip().casefold()
        if review["status"] == "reviewed" and same_person:
            self.report(RED, path, "review", "l'auteur ne peut pas signer reviewed.",
                        "Utiliser author-reread, ou faire relire par une autre personne.")
        elif review["status"] == "author-reread" and not same_person:
            self.report(RED, path, "review", "author-reread est réservé à l'auteur.",
                        "Utiliser reviewed pour une autre personne.")
        elif review["fingerprint"] != self.fingerprint(claim["header"]["id"]):
            self.report(ORANGE, path, "review", "relecture périmée : le claim ou ses appuis ont changé.",
                        "Relire à nouveau puis recopier la nouvelle empreinte (method/review.md).")

    def check_evidence(self, evidence):
        header, path = evidence["header"], evidence["path"]
        kind = header.get("type")
        if kind == "execution":
            if not self.require(evidence, EXECUTION_FIELDS):
                return
            self.allowed(evidence, "modified", ("yes", "no", "unknown"))
            self.allowed(evidence, "person_data", PERSON_DATA)
            self.linked(evidence, "query", [header["query"]], "query")
            query = self.records.get(header["query"], {})
            if query.get("role") == "query" and query["header"].get("person_data") != header["person_data"]:
                self.report(RED, path, "person_data", "la valeur diffère de celle de la requête.",
                            "Recopier person_data de la requête.")
            if "system" in header:
                self.report(RED, path, "system", "le système d'une exécution vient de sa requête.",
                            "Retirer system : la requête le donne dans son en-tête (method/evidence.md).")
            fence = "```" + (language(query.get("path", "")) or LANGUAGES[".sql"])["fence"]
            executed = re.compile("^" + fence + r"[ \t]*\n[ \t]*\S.*?^```", re.MULTILINE | re.DOTALL)
            if header["modified"] == "yes" and not executed.search(evidence["body"]):
                self.report(RED, path, "modified", f"la requête a été modifiée mais la version exécutée manque (bloc {fence}).",
                            f"Ajouter la requête réellement exécutée dans un bloc {fence}, le langage de la requête.")
            if header["person_data"] == "masked":
                self.check_masked_result(evidence)
        elif kind == "reading":
            if self.require(evidence, READING_FIELDS):
                self.linked(evidence, "source", [header["source"]], "source")
            if not re.search(r"^>", evidence["body"], re.MULTILINE):
                self.report(RED, path, None, "la citation manque.",
                            "Ajouter sous l'en-tête une courte citation, en ligne commençant par >.")
        else:
            self.report(RED, path, "type", "valeur non admise.", "Choisir parmi : execution, reading.")

    def check_source(self, source):
        if self.require(source, SOURCE_FIELDS):
            self.allowed(source, "authority", SOURCE_AUTHORITY)

    def check_query(self, query):
        header, path = query["header"], query["path"]
        code_language = language(path)
        code = without_comments(query["body"], code_language["comments"])
        if not self.require(query, QUERY_FIELDS):
            return
        self.allowed(query, "person_data", PERSON_DATA)
        self.known_context(query, "system", header["system"])
        if LOADS_ROUTINE.search(code):
            self.report(RED, path, None, "une requête ne charge pas une routine : la routine change, la requête "
                        "exécutée ne change plus (règle 6).",
                        "Recopier dans le script le calcul de la routine (method/queries.md, « Une routine »).")
        if code_language["fence"] == "sql":
            if NO_ROWS.search(code) and len(SELECT.findall(code)) == 1:
                return
            if SELECT_STAR.search(code):
                self.report(RED, path, None, "SELECT * n'est admis qu'avec WHERE 1=0 (noms des colonnes seulement).",
                            "Nommer les colonnes une par une.")
        if header["person_data"] == "masked":
            self.check_masked_output(query, code, code_language)

    def check_masked_output(self, query, code, code_language):
        """Une requête sur des personnes, en SQL ou en script sur un fichier gardé à l'hôpital (method/queries.md)."""
        identifier, path = query["header"]["id"], query["path"]
        if not any(quote + identifier + quote in code for quote in code_language["quotes"]):
            self.report(RED, path, None, "la première colonne du résultat doit afficher l'id de la requête.",
                        code_language["id_fix"].format(identifier))
        if not code_language["aggregate"].search(code):
            self.report(RED, path, None, "une requête sur des personnes ne renvoie que des agrégats.",
                        code_language["aggregate_fix"])
        if not MASK.search(code):
            self.report(RED, path, None, "le masquage <10 n'apparaît pas dans la requête.",
                        "Masquer toute statistique sous 10 dans la requête elle-même (method/queries.md).")

    def check_routine(self, routine):
        """Une routine : un outil R ou Python qu'on lance à l'hôpital, dans knowledge/routines/<id>/ avec son README.md.
        Son résultat reste à l'hôpital : ses règles de masquage ne sont pas celles d'une requête (method/adr/0027)."""
        header, path = routine["header"], routine["path"]
        folder = (self.root / path).parent
        if folder.name != header["id"]:
            self.report(RED, path, "id", f"une routine est rangée dans un dossier à son nom : knowledge/routines/{header['id']}/.",
                        "Mettre le même nom au dossier, au fichier et dans le champ id.")
        if not (folder / "README.md").is_file():
            self.report(RED, path, None, "la routine n'a pas de README.md qui décrit sa méthode.",
                        "Écrire README.md dans le dossier de la routine (method/queries.md, « Une routine »).")
        if self.require(routine, ROUTINE_FIELDS):
            self.known_context(routine, "system", header["system"])

    def check_masked_result(self, evidence):
        """Le contrôle des effectifs ne lit que les tableaux : hors d'un bloc sql, le résultat n'est qu'un tableau."""
        path, tags, outside, inside = evidence["path"], [], [], False
        for line in evidence["body"].split("\n"):
            fence = FENCE.match(line)
            if fence:
                tags += [] if inside else [fence.group(1).lower()]
                inside = not inside
            elif not inside and line.strip():
                outside.append(line)
        if inside:
            self.report(RED, path, None, "un bloc de code n'est pas fermé.",
                        "Fermer le bloc par une ligne ```.")
        if not outside:
            self.report(RED, path, None, "le résultat n'est pas un tableau Markdown.",
                        "Recopier le résultat en tableau Markdown, avec ses colonnes (method/evidence.md).")
        elif any(not line.lstrip().startswith("|") for line in outside):
            self.report(RED, path, None, "des lignes sont hors du tableau Markdown du résultat.",
                        "Mettre tout le résultat dans le tableau, et retirer le reste (method/evidence.md).")
        fences = [row["fence"] for row in LANGUAGES.values()]
        if any(tag not in fences for tag in tags):
            self.report(RED, path, None, "un résultat masqué n'a pas d'autre bloc que la requête exécutée "
                        f"({listed(['```' + fence for fence in fences])}, selon son langage).",
                        "Mettre le résultat dans le tableau, et retirer le bloc.")
        self.check_small_counts(evidence)

    def check_small_counts(self, evidence):
        for columns, cells in table_rows(evidence["body"]):
            for name, value in zip(columns, cells):
                if COUNT_COLUMN.match(name) and value.isdigit() and 0 < int(value) < 10:
                    self.report(RED, evidence["path"], name, "un effectif inférieur à 10 apparaît en clair.",
                                "Ne pas conserver ce résultat ; corriger le masquage de la requête "
                                "(method/privacy.md).")

    def check_privacy(self, name, text):
        stop = "Arrêter : ne pas diffuser ce fichier, prévenir un mainteneur (method/privacy.md)."
        birth = ("Si c'est la date d'une personne : " + stop[0].lower() + stop[1:]
                 + " Si c'est un critère ou une période : écrire l'année seule, ou le mois et l'année.")
        text = normalized(text)
        for number, line in enumerate(text.split("\n"), 1):
            for match in NIR.finditer(line):
                digits = re.sub(r"\s", "", match.group()).replace("2A", "19").replace("2B", "18")
                if 97 - int(digits[:13]) % 97 == int(digits[13:]):
                    self.report(RED, name, f"ligne {number}", "un numéro de sécurité sociale (NIR) semble présent.", stop)
            if BIRTH_DATE.search(line):
                self.report(RED, name, f"ligne {number}", "une date de naissance semble présente.", birth)
        for columns, cells in table_rows(text):
            for column, value in zip(columns, cells):
                if BIRTH_COLUMN.search(column) and re.search(FULL_DATE, value):
                    self.report(RED, name, column, "une date de naissance semble présente dans un tableau.", birth)

    def check_reuse(self):
        claims = {i: r for i, r in self.records.items() if r.get("valid")}
        for identifier, claim in claims.items():
            header = claim["header"]
            for premise_id in header["depends_on"]:
                premise = claims.get(premise_id)
                if premise is None or same_author(premise, claim) or self.review_is_current(premise):
                    continue
                level = ORANGE if header["maturity"] == "provisional" else RED
                self.report(level, claim["path"], "depends_on",
                            f"« {premise_id} » est le claim d'une autre personne, sans relecture à jour.",
                            "Relire ce claim (method/review.md), ou garder ce claim en provisional.")
            if header["lifecycle"] != "active":
                continue
            chain = self.inactive_premises(claims, identifier)
            if chain:
                self.report(ORANGE, claim["path"], "depends_on",
                            "à réexaminer : il s'appuie sur " + ", ".join(chain) + ".",
                            "Revoir la conclusion ; la confirmer, la corriger ou la retirer (method/review.md).")

    def inactive_premises(self, claims, identifier):
        found, pending, seen = [], list(claims[identifier]["header"]["depends_on"]), {identifier}
        while pending:
            premise_id = pending.pop(0)
            if premise_id in seen or premise_id not in claims:
                continue
            seen.add(premise_id)
            lifecycle = claims[premise_id]["header"]["lifecycle"]
            if lifecycle in INACTIVE:
                found.append(f"{premise_id} ({lifecycle})")
            pending.extend(claims[premise_id]["header"]["depends_on"])
        return found

    def review_is_current(self, claim):
        review = claim["header"]["review"]
        return (isinstance(review, dict) and review.get("status") == "reviewed"
                and review.get("fingerprint") == self.fingerprint(claim["header"]["id"]))

    def fingerprint(self, identifier, seen=()):
        """Empreinte du claim, de la définition de ses termes, de ses preuves (avec requête ou source)
        et de ses prémisses."""
        if not seen and identifier in self.fingerprints:
            return self.fingerprints[identifier]
        claim = self.records[identifier]
        header = {key: value for key, value in claim["header"].items() if key not in ("review", "lifecycle")}
        parts = [json.dumps(header, sort_keys=True, ensure_ascii=False), claim["body"]]
        parts += [self.terms.get(term, "absent:" + term) for term in header.get("terms", [])]
        for evidence_id in header.get("supported_by", []):
            evidence = self.records.get(evidence_id, {})
            parts.append(evidence.get("text", "absent:" + evidence_id))
            origin = evidence.get("header", {}).get("query") or evidence.get("header", {}).get("source")
            if isinstance(origin, str):
                parts.append(self.records.get(origin, {}).get("text", "absent:" + origin))
        for premise_id in header.get("depends_on", []):
            if premise_id in seen or not self.records.get(premise_id, {}).get("valid"):
                parts.append("absent:" + premise_id)
            else:
                parts.append(self.fingerprint(premise_id, (*seen, identifier)))
        value = hashlib.sha256("\n\x00".join(parts).encode("utf-8")).hexdigest()[:12]
        if not seen:
            self.fingerprints[identifier] = value
        return value

    def check_places(self):
        """Un fichier hors de sa place : sous un ancien dossier, ou non lu par le contrôle dans knowledge/ ou
        investigations/ ; un fichier caché, comme .gitkeep, reste permis (method/adr/0018)."""
        for old, new in OLD_FOLDERS.items():
            for path in sorted((self.root / old).rglob("*")):
                if path.is_file():
                    self.report(RED, self.relative(path), None,
                                f"{old}/ est remplacé par {new} (method/adr/0018-ranger-par-type.md).",
                                "Déplacer le fichier dans le dossier de son type (method/layout.md).")
        read = {path for path, _ in self.files()} | {
            path for pattern in (GLOSSARIES, *READMES) for path in self.root.glob(pattern)}
        for folder, (message, fix) in UNREAD.items():
            for path in sorted((self.root / folder).rglob("*")):
                if path.is_file() and not path.name.startswith(".") and path not in read:
                    self.report(RED, self.relative(path), None, message, fix)

    def check_skill_copies(self):
        source, copy = self.root / ".agents" / "skills", self.root / ".claude" / "skills"
        if not source.is_dir():
            return
        for skill in sorted(source.rglob("SKILL.md")):
            try:
                front_matter(skill.read_text(encoding="utf-8", errors="replace"))
            except ValueError as error:
                self.report(RED, self.relative(skill), None, str(error),
                            "Écrire la valeur entre guillemets doubles si elle contient « : » ou « # » : "
                            "un lecteur YAML strict ne charge pas la skill.")
        files = {p.relative_to(source): p.read_bytes() for p in source.rglob("*") if p.is_file()}
        copies = ({p.relative_to(copy): p.read_bytes() for p in copy.rglob("*") if p.is_file()}
                  if copy.is_dir() else {})
        if files != copies:
            self.report(RED, ".claude/skills", None, "la copie des skills diffère de .agents/skills.",
                        "Lancer python checks/sync_skills.py ; modifier seulement .agents/skills.")


def language(path):
    """La ligne de LANGUAGES d'un fichier, ou None."""
    suffix = Path(path).suffix.lower()
    return next((row for ending, row in LANGUAGES.items() if ending.lower() == suffix), None)


def without_comments(code, pattern):
    """Un commentaire ne compte ni comme masquage ni comme WHERE 1=0 ; un texte entre guillemets reste."""
    return pattern.sub(lambda m: m.group() if m.group()[0] in "'\"" else " ", code)


def attributed_execution(evidence):
    header = evidence["header"]
    return header.get("type") == "execution" and "unknown" not in (
        header.get(field) for field in ("run_at", "database", "executed_by", "modified"))


def same_author(first, second):
    return first["header"]["author"].strip().casefold() == second["header"]["author"].strip().casefold()


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--root", default=Path(__file__).resolve().parent.parent, type=Path,
                        help="racine du dépôt (par défaut : le dépôt de ce script)")
    parser.add_argument("--fingerprint", metavar="ID", help="affiche l'empreinte d'un claim")
    arguments = parser.parse_args()
    for stream in (sys.stdout, sys.stderr):
        stream.reconfigure(encoding="utf-8")
    repository = Repository(arguments.root)
    problems = repository.run()
    if arguments.fingerprint:
        if not repository.records.get(arguments.fingerprint, {}).get("valid"):
            print(f"« {arguments.fingerprint} » n'est pas un claim valide du dépôt.", file=sys.stderr)
            return 1
        print(repository.fingerprint(arguments.fingerprint))
        return 0
    for problem in problems:
        field = f" [{problem['field']}]" if problem["field"] else ""
        print(f"{problem['level']:<6} {problem['path']}{field} : {problem['message']}\n"
              f"       → {problem['fix']}")
    red = sum(problem["level"] == RED for problem in problems)
    print(f"{red} rouge(s), {len(problems) - red} orange(s), {len(repository.records)} fichier(s) lus.")
    return 1 if red else 0


if __name__ == "__main__":
    raise SystemExit(main())
