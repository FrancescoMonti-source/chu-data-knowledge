---
name: research
description: Lire un document (texte réglementaire, guide de l'ATIH, documentation d'un éditeur, document du CHU) et en tirer des preuves de lecture. Utiliser quand une étape du plan demande une source documentaire.
---

# research

Cette skill donne les étapes. Les formats sont dans docs/agents/evidence.md.

1. **Identifier le document :** titre, éditeur, édition, champ et période d'application (pour le PMSI, l'édition de l'année). Chercher sa fiche dans sources/ ; si elle manque, la créer.
   Fini quand : la fiche existe, avec l'édition dans l'id et l'autorité.
2. **Lire les passages utiles.** Pour chaque passage, un fichier de lecture dans le dossier evidence/ du sujet du passage (docs/agents/layout.md), avec l'endroit exact et une courte citation.
   Fini quand : chaque passage dont l'enquête se sert a son fichier, et aucune citation ne contient de donnée de personne (docs/agents/privacy.md).
3. **Relier au plan.** Dans le plan de l'enquête, une ligne par preuve : son id et l'étape qu'elle couvre.
   Fini quand : chaque nouvelle preuve est citée dans le plan.
4. **Contrôler et enregistrer :** `python checks/check.py`, puis commit sur la branche de l'enquête.
   Fini quand : aucun ROUGE, et le commit est fait.
