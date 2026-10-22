"""Durées asymétriques : gamma-Poisson (binomiale négative), moyenne m et dispersion phi (variance = m + phi·m²)."""
from __future__ import annotations

import numpy as np


def sample_nb(rng: np.random.Generator, m, phi: float, dmin: int = 0) -> np.ndarray:
    """Tire des durées entières de moyenne m (scalaire ou tableau) ; rabattues à `dmin` au minimum."""
    m = np.asarray(m, dtype=float)
    d = rng.poisson(m) if phi < 1e-6 else rng.poisson(rng.gamma(1.0 / phi, m * phi))
    return np.maximum(d, dmin)


def sample_from_classes(rng: np.random.Generator, shares: dict[str, float], n: int, tail_excess_mean: float, phi: float) -> np.ndarray:
    """Durées d'après des parts par classe observées (« 0 »…« 4 », « 5+ »).

    La classe « 5+ » prolonge par 5 + gamma-Poisson d'espérance `tail_excess_mean` : l'asymétrie à droite y est supposée.
    """
    labels = list(shares)
    p = np.array([shares[l] for l in labels], dtype=float)
    pick = rng.choice(len(labels), size=n, p=p / p.sum())
    out = np.empty(n, dtype=int)
    for i, label in enumerate(labels):
        mask = pick == i
        if label.endswith("+"):
            out[mask] = int(label[:-1]) + sample_nb(rng, np.full(mask.sum(), tail_excess_mean), phi)
        else:
            out[mask] = int(label)
    return out
