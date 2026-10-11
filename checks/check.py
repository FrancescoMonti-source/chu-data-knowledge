"""Contrôles du dépôt.

ROUGE  : quelque chose est cassé ; à corriger avant le merge (code de sortie 1).
ORANGE : du travail reste à faire (relecture périmée, claim à réexaminer) ; ne bloque pas.

Usage :
    python checks/check.py                   contrôle tout le dépôt
    python checks/check.py --fingerprint ID  affiche l'empreinte à recopier dans une relecture

Les règles contrôlées et leurs limites : docs/agents/checks.md.
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

CLAIM_FIELDS = ("review", "id", "kind", "author", "statement", "scope", "maturity",
                "lifecycle", "terms", "tables", "supported_by", "depends_on")
CLAIM_LISTS = ("terms", "tables", "supported_by", "depends_on", "challenges", "supersedes")
CLAIM_VALUES = {"kind": ("documentary", "empirical", "decision"),
                "maturity": ("documented", "observed", "provisional"),
                "lifecycle": ("active", "challenged", "superseded", "withdrawn")}
KIND_FIELDS = {"empirical": ("refuted_if",), "decision": ("responsible", "reconsider_when")}
EXECUTION_FIELDS = ("id", "type", "request", "run_at", "database", "executed_by",
                    "modified", "person_data")
READING_FIELDS = ("id", "type", "source", "locator", "read_by", "read_at")
SOURCE_FIELDS = ("id", "title", "publisher", "edition", "location", "authority")
SOURCE_AUTHORITY = ("official", "vendor-doc", "local", "unknown")
PERSON_DATA = ("masked", "no-person-data")
REQUEST_FIELDS = ("id", "person_data", "purpose")
INACTIVE = ("challenged", "superseded", "withdrawn")
DOCS = {"claim": "claims.md", "evidence": "evidence.md", "source": "evidence.md", "request": "requests.md"}
SCANNED = (".md", ".sql", ".txt", ".csv", ".tsv", ".json", ".yml", ".yaml")

NIR = re.compile(r"\b[12]\s?\d{2}\s?\d{2}\s?(?:\d{2}|2[AB])\s?\d{3}\s?\d{3}\s?\d{2}\b")
FULL_DATE = r"\b(?:\d{2}/\d{2}/\d{4}|\d{4}-\d{2}-\d{2})\b"
BIRTH_DATE = re.compile(r"(?i)\b(?:date\s+de\s+naissance|n[ée]e?\s+le|ddn|dob|date\s+of\s+birth|birth\s*date)\b"
                        r"[^\n]{0,40}?" + FULL_DATE)
BIRTH_COLUMN = re.compile(r"(?i)(?:^|[_\s])(?:naiss|birth|dob|ddn)")
COUNT_COLUMN = re.compile(r"(?i)^(?:n|nb)_")
SELECT_STAR = re.compile(r"(?i)(?:\bselect\s+(?:(?:distinct|all)\s+|top\s*\(?\s*\d+\s*\)?\s+(?:percent\s+)?)*|,\s*)"
                         r"(?:[\w\"\[\]]+\.)?\*")
NO_ROWS = re.compile(r"(?i)\bwhere\s+1\s*=\s*0\b")
SELECT = re.compile(r"(?i)\bselect\b")
SQL_COMMENT = re.compile(r"--[^\n]*|/\*.*?\*/", re.DOTALL)
FENCE = re.compile(r"^\s*```\s*(\S*)", re.MULTILINE)
MASK = re.compile(r"(?<!')<\s*10\b|<=\s*9\b|>=\s*10\b|>\s*9\b")
AGGREGATE = re.compile(r"(?i)\b(?:count|sum|avg|min|max)\s*\(")
UNQUOTED_HASH = re.compile(r"\s*([\w-]+):\s+[^\"'\s\[{][^\n]*\s#")


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


def request_header(text):
    """Lit les lignes « -- clé: valeur » au début d'un fichier .sql."""
    header, body = {}, []
    lines = normalized(text).split("\n")
    for index, line in enumerate(lines):
        match = re.match(r"--\s*([a-z_]+)\s*:\s*(.*)", line)
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
        self.terms = set()
        self.fingerprints = {}

    def report(self, level, path, field, message, fix):
        self.problems.append({"level": level, "path": path, "field": field,
                              "message": message, "fix": fix})

    def relative(self, path):
        return path.relative_to(self.root).as_posix()

    # Lecture

    def load(self):
        for path in sorted(self.root.rglob("*")):
            if path.is_file() and path.suffix.lower() in SCANNED and ".git" not in path.parts:
                try:
                    text = path.read_text(encoding="utf-8")
                except UnicodeDecodeError:
                    self.report(RED, self.relative(path), None, "le fichier n'est pas encodé en UTF-8.",
                                "L'enregistrer en UTF-8.")
                    text = path.read_text(encoding="utf-8", errors="replace")
                self.check_privacy(self.relative(path), text)
        for glossary in sorted(self.root.glob("*/*/GLOSSARY.md")):
            if glossary.parts[-3] in ("systems", "domains"):
                self.terms.update(TERM_HEADING.findall(glossary.read_text(encoding="utf-8", errors="replace")))
        for path in sorted(self.root.glob("*/*/claims/*.md")):
            if path.parts[-4] in ("systems", "domains", "investigations"):
                self.add(path, "claim", place=path.parts[-4], context=path.parts[-3])
        for path in sorted(self.root.glob("*/*/evidence/*.md")):
            if path.parts[-4] in ("systems", "domains"):
                self.add(path, "evidence", place=path.parts[-4], context=path.parts[-3])
        for path in sorted(self.root.glob("sources/*.md")):
            self.add(path, "source")
        for path in sorted(self.root.glob("systems/*/requests/*.sql")):
            self.add(path, "request", context=path.parts[-3])

    def add(self, path, role, place=None, context=None):
        name = self.relative(path)
        text = path.read_text(encoding="utf-8", errors="replace")
        try:
            header, body = request_header(text) if role == "request" else front_matter(text)
        except ValueError as error:
            self.report(RED, name, None, str(error), "Corriger l'en-tête : voir docs/agents/" + DOCS[role] + ".")
            return
        record = {"role": role, "path": name, "place": place, "context": context,
                  "header": header, "body": body, "text": normalized(text)}
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

    # Contrôles

    def run(self):
        self.load()
        for record in self.records.values():
            if record["role"] == "claim":
                record["valid"] = self.claim_shape(record)
        for record in self.records.values():
            getattr(self, "check_" + record["role"])(record)
        self.check_reuse()
        self.check_skill_copies()
        return self.problems

    def require(self, record, fields):
        """Champs présents et non vides ; texte simple, sauf review et les listes du claim."""
        header, wrong = record["header"], []
        for field in fields:
            value = header.get(field)
            if not (value or value == []):
                self.report(RED, record["path"], field, "champ obligatoire absent ou vide.",
                            "Remplir le champ (docs/agents/" + DOCS[record["role"]] + ").")
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

    def claim_shape(self, claim):
        """Forme du claim : sans elle, les autres contrôles du claim n'ont pas de sens."""
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
        for term in header["terms"]:
            if term not in self.terms:
                self.report(RED, path, "terms", f"le terme « {term} » n'est dans aucun GLOSSARY.md.",
                            "Ajouter le terme au glossaire de son contexte, ou corriger le terme.")
        self.linked(claim, "supported_by", header["supported_by"], "evidence")
        for field in ("depends_on", "challenges", "supersedes"):
            self.linked(claim, field, header.get(field, []), "claim")
        evidence = [self.records[i] for i in header["supported_by"]
                    if i in self.records and self.records[i]["role"] == "evidence"]
        if claim["place"] in ("systems", "domains"):
            if not header["supported_by"]:
                self.report(RED, path, "supported_by", "un claim de systems/ ou domains/ cite au moins une preuve.",
                            "Ajouter la preuve dans evidence/ et la citer.")
            for identifier in header["depends_on"]:
                if self.records.get(identifier, {}).get("place") == "investigations":
                    self.report(RED, path, "depends_on", f"« {identifier} » est un claim d'enquête.",
                                "Une enquête dépend de systems/ et domains/, jamais l'inverse : "
                                "promouvoir d'abord le claim (docs/agents/layout.md).")
        elif not header["supported_by"] and not header["depends_on"]:
            self.report(RED, path, "supported_by", "un claim s'appuie sur au moins une preuve ou une prémisse.",
                        "Citer ses preuves dans supported_by ou ses prémisses dans depends_on.")
        if claim["place"] == "domains" and header["tables"]:
            self.report(RED, path, "tables", "un claim qui nomme des tables décrit un système.",
                        "Le déplacer dans systems/<système>/claims/ (docs/agents/layout.md).")
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
        self.check_review(claim)

    def check_review(self, claim):
        review, path, author = claim["header"]["review"], claim["path"], claim["header"]["author"]
        if review == "unreviewed":
            return
        if not isinstance(review, dict) or review.get("status") not in ("reviewed", "author-reread"):
            self.report(RED, path, "review", "valeur non admise.",
                        "Écrire review: unreviewed, ou un bloc status/by/at/work/fingerprint "
                        "(docs/agents/review.md).")
            return
        missing = [field for field in ("by", "at", "work", "fingerprint")
                   if not isinstance(review.get(field), str) or not review[field]]
        if missing:
            self.report(RED, path, "review", "relecture incomplète : " + ", ".join(missing) + ".",
                        "Compléter le bloc review (docs/agents/review.md).")
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
                        "Relire à nouveau puis recopier la nouvelle empreinte (docs/agents/review.md).")

    def check_evidence(self, evidence):
        header, path = evidence["header"], evidence["path"]
        kind = header.get("type")
        if kind == "execution":
            if not self.require(evidence, EXECUTION_FIELDS):
                return
            if evidence["place"] != "systems":
                self.report(RED, path, "type", "une exécution lit toujours un système.",
                            "Ranger la preuve dans systems/<système>/evidence/.")
            self.allowed(evidence, "modified", ("yes", "no", "unknown"))
            self.allowed(evidence, "person_data", PERSON_DATA)
            self.linked(evidence, "request", [header["request"]], "request")
            request = self.records.get(header["request"], {})
            if request.get("role") == "request" and request["header"].get("person_data") != header["person_data"]:
                self.report(RED, path, "person_data", "la valeur diffère de celle de la requête.",
                            "Recopier person_data de la requête.")
            if header["modified"] == "yes" and "```sql" not in evidence["body"]:
                self.report(RED, path, "modified", "la requête a été modifiée mais la version exécutée manque.",
                            "Ajouter la requête réellement exécutée dans un bloc ```sql.")
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

    def check_request(self, request):
        header, path = request["header"], request["path"]
        sql = SQL_COMMENT.sub(" ", request["body"])  # un commentaire ne compte ni comme masquage ni comme WHERE 1=0
        if not self.require(request, REQUEST_FIELDS):
            return
        self.allowed(request, "person_data", PERSON_DATA)
        if NO_ROWS.search(sql) and len(SELECT.findall(sql)) == 1:
            return
        if SELECT_STAR.search(sql):
            self.report(RED, path, None, "SELECT * n'est admis qu'avec WHERE 1=0 (noms des colonnes seulement).",
                        "Nommer les colonnes une par une.")
        if header["person_data"] != "masked":
            return
        if f"'{header['id']}'" not in sql:
            self.report(RED, path, None, "la première colonne du résultat doit afficher l'id de la requête.",
                        f"Ajouter '{header['id']}' AS request_id en tête du SELECT.")
        if not AGGREGATE.search(sql):
            self.report(RED, path, None, "une requête sur des personnes ne renvoie que des agrégats.",
                        "Agréger (COUNT, SUM…) au lieu de renvoyer des lignes individuelles.")
        if not MASK.search(sql):
            self.report(RED, path, None, "le masquage <10 n'apparaît pas dans la requête.",
                        "Masquer toute statistique sous 10 dans la requête elle-même (docs/agents/requests.md).")

    def check_masked_result(self, evidence):
        """Le contrôle des effectifs ne lit que les tableaux : le résultat doit en être un."""
        body, path = evidence["body"], evidence["path"]
        if not re.search(r"^\s*\|", body, re.MULTILINE):
            self.report(RED, path, None, "le résultat n'est pas un tableau Markdown.",
                        "Recopier le résultat en tableau Markdown, avec ses colonnes (docs/agents/evidence.md).")
        if any(tag.lower() != "sql" for tag in FENCE.findall(body)[::2]):
            self.report(RED, path, None, "un résultat masqué n'a pas d'autre bloc que la requête exécutée (```sql).",
                        "Mettre le résultat dans le tableau, et retirer le bloc.")
        self.check_small_counts(evidence)

    def check_small_counts(self, evidence):
        for columns, cells in table_rows(evidence["body"]):
            for name, value in zip(columns, cells):
                if COUNT_COLUMN.match(name) and value.isdigit() and 0 < int(value) < 10:
                    self.report(RED, evidence["path"], name, "un effectif inférieur à 10 apparaît en clair.",
                                "Ne pas conserver ce résultat ; corriger le masquage de la requête "
                                "(docs/agents/privacy.md).")

    def check_privacy(self, name, text):
        stop = "Arrêter : ne pas diffuser ce fichier, prévenir le mainteneur (docs/agents/privacy.md)."
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
                            "Relire ce claim (docs/agents/review.md), ou garder ce claim en provisional.")
            if header["lifecycle"] != "active":
                continue
            chain = self.inactive_premises(claims, identifier)
            if chain:
                self.report(ORANGE, claim["path"], "depends_on",
                            "à réexaminer : il s'appuie sur " + ", ".join(chain) + ".",
                            "Revoir la conclusion ; la confirmer, la corriger ou la retirer (docs/agents/review.md).")

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
        """Empreinte du claim, de ses preuves (avec requête ou source) et de ses prémisses."""
        if not seen and identifier in self.fingerprints:
            return self.fingerprints[identifier]
        claim = self.records[identifier]
        header = {key: value for key, value in claim["header"].items() if key not in ("review", "lifecycle")}
        parts = [json.dumps(header, sort_keys=True, ensure_ascii=False), claim["body"]]
        for evidence_id in header.get("supported_by", []):
            evidence = self.records.get(evidence_id, {})
            parts.append(evidence.get("text", "absent:" + evidence_id))
            origin = evidence.get("header", {}).get("request") or evidence.get("header", {}).get("source")
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

    def check_skill_copies(self):
        source, copy = self.root / ".agents" / "skills", self.root / ".claude" / "skills"
        if not source.is_dir():
            return
        files = {p.relative_to(source): p.read_bytes() for p in source.rglob("*") if p.is_file()}
        copies = ({p.relative_to(copy): p.read_bytes() for p in copy.rglob("*") if p.is_file()}
                  if copy.is_dir() else {})
        if files != copies:
            self.report(RED, ".claude/skills", None, "la copie des skills diffère de .agents/skills.",
                        "Lancer python checks/sync_skills.py ; modifier seulement .agents/skills.")


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
