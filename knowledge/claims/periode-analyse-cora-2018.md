---
review: unreviewed
id: periode-analyse-cora-2018
kind: decision
author: Pierre
statement: "Au CHU, une analyse des séjours CORA porte par défaut sur l'activité à partir du 1er janvier 2018 ; remonter avant 2018 demande de le justifier et de traiter les défauts connus de 2014-2017."
scope: "CORA, toute analyse de séjours"
responsible: Pierre
reconsider_when: "les défauts de 2014-2017 sont expliqués et corrigeables (lien séjour → RSS de 2016-2017, #25 ; séjours sans sortie de 2017) ; un défaut comparable apparaît après 2018"
maturity: documented
lifecycle: active
terms: [cora:sejour]
tables: [cora:TB_SEJOUR]
supported_by: [20261014-decision-periode-analyse, 20261013-sejours-sans-rss-resultat]
depends_on: [date-sortie-manquante, dernier-mouvement-date-la-sortie]
---
## Pour s'en servir

Borner l'analyse au 1er janvier 2018 sauf demande contraire, et le dire. Tant que la date de référence du séjour n'est pas fixée (#33), borner les séjours clos sur DATE_SORTIE >= DATE '2018-01-01' et les séjours sans sortie sur DATE_ENTREE >= DATE '2018-01-01'.

Une série qui remonte avant 2018 doit traiter à part : 2014-2015 (peu de séjours ; séjours sans sortie presque tous sans mouvement, #32), 2016-2017 (aucun lien séjour → RSS par TB_MVT_RUM ; en 2016, la jointure par TB_SYNTH_RSS.ID_SEJOUR retrouve les RSS, joindre-rss-par-id-sejour ; en 2017, il n'y a presque pas de RSS), 2017 (30 % de séjours sans sortie).

## Ce qui l'appuie

Défauts mesurés avant 2018 :

- 2017 : environ 30 % des séjours sans DATE_SORTIE, contre 0,1 à 8,5 % les autres années depuis 2018 (date-sortie-manquante) ; la fin du dernier mouvement ne tombe le jour de la sortie que pour 92 % des séjours clos, contre 99 % ou plus ailleurs (dernier-mouvement-date-la-sortie).
- 2016-2017 : 97 à 100 % des séjours clos sans RSS relié par TB_MVT → TB_MVT_RUM, contre 3 % en 2014-2015 et 80 % depuis 2018 (20261013-sejours-sans-rss-resultat ; #25).
- 2014-2015 : peu de séjours (environ 130 000 et 142 000 par an, contre 860 000 en 2018).

Pierre a fixé le 1er janvier 2018 au vu de ces défauts (20261014-decision-periode-analyse).
