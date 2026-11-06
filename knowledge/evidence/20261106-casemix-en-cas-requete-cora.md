---
id: 20261106-casemix-en-cas-requete-cora
type: reading
source: requetes-cora-par-defaut-v1
locator: "analyse-medico-administrative/casemix/casemix-en-cas.txt, colonnes CAS et Libellé CAS"
read_by: Pierre
read_at: 2026-11-06
---
> « CASE WHEN RSS.CODE_CMD='14' THEN 'O' WHEN RSS.CODE_CMD='15' THEN 'N' WHEN RSS.CODE_CMD='28' THEN 'S' WHEN SUBSTR(RSS.CODE_GHM,1,1)='C' THEN 'C' WHEN SUBSTR(RSS.CODE_GHM,1,1)='K' THEN 'K' WHEN SUBSTR(RSS.CODE_GHM,1,1)='M' OR SUBSTR(RSS.CODE_GHM,1,1)='Z' THEN 'X' END AS "CAS" » (libellés : Obstétrique, Nouveau-Nés, Séances, Chirurgie, Peu Invasif, Autres)
