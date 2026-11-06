---
review: unreviewed
id: cas-casemix-cora
kind: documentary
author: Pierre
statement: "Dans CORA, le CAS d'un RSS (casemix en CAS) se calcule dans cet ordre : CMD 14 donne O (obstétrique), CMD 15 N (nouveau-nés), CMD 28 S (séances) ; sinon le type du GHM décide, C donne C (chirurgie), K donne K (peu invasif), M ou Z donnent X (autres) ; un RSS non groupé ou en erreur (CMD 90) n'a pas de catégorie propre et tombe en X."
scope: "CORA, TB_SYNTH_RSS (CODE_CMD, CODE_GHM), requête par défaut « casemix en CAS » du catalogue ; la règle ne dépend pas de l'année"
maturity: documented
lifecycle: active
terms: [cora:cas, cora:rss]
tables: [cora:TB_SYNTH_RSS]
supported_by: [20261106-casemix-en-cas-requete-cora]
depends_on: []
---
## Pour s'en servir

Quand une question parle de « CAS » (C, K, N, O, S, X), c'est ce classement des RSS, pas un code d'OpRoom : le calculer depuis TB_SYNTH_RSS.CODE_CMD et le type du GHM (premier caractère de CODE_GHM, qui ne porte ni la CMD ni le préfixe), dans l'ordre ci-dessus, la CMD l'emportant sur le type du GHM. Pour classer une intervention OpRoom ou un séjour, rattacher d'abord son RSS (chainer-oproom-cora, joindre-rss-par-id-sejour) ; sans RSS, il n'a pas de CAS : le dire et le compter à part.

Les RSS dont le GHM est en erreur (CMD 90, GHM de type Z) tombent en X et gonflent « Autres » : en compter le nombre et le dire, surtout pour les deux derniers mois, pas encore codés (rss-mois-recents-non-codes).

## Ce qui l'appuie

La requête « casemix en CAS » du catalogue par défaut de CORA définit la colonne CAS par ce CASE et en donne les libellés (20261106-casemix-en-cas-requete-cora). Le dictionnaire ne le dit pas.

Points ouverts : que les RSS de CMD 90 tombent en X est déduit du CASE (leur type de GHM est Z), non vérifié par une exécution ; la requête n'a pas de branche pour un CODE_GHM vide, dont le CAS est vide.
