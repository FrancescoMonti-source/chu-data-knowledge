"""Recopie .agents/skills dans .claude/skills, le dossier que lit Claude Code.

On modifie seulement .agents/skills, puis on lance : python checks/sync_skills.py
"""

import shutil
import sys
from pathlib import Path


def sync(root):
    source, copy = Path(root) / ".agents" / "skills", Path(root) / ".claude" / "skills"
    if copy.exists():
        shutil.rmtree(copy)
    shutil.copytree(source, copy)
    return copy


if __name__ == "__main__":
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent
    print("Copie à jour :", sync(root))
