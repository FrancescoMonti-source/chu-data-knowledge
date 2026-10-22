"""Générateurs de tables : chacun s'inscrit par son nom et rend un dict {nom de table: DataFrame}."""
from __future__ import annotations

GENERATORS: dict = {}


def generator(name: str):
    def register(fn):
        GENERATORS[name] = fn
        return fn
    return register
