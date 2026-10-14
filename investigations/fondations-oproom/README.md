# Que faut-il savoir des interventions d'OpRoom avant de les compter ou d'en mesurer les durées ?

Personne : Pierre
Issue : #39

## Cadrage
But : migrer les fiches OpRoom de la kb de DIM-code en claims qui disent à un agent comment compter les interventions et mesurer leurs durées. Population : interventions terminées ou clôturées (I_STATE 2 et 4) d'OpRoom, commencées depuis le 2023-01-01. Source : QBLOCP (production), par l'extraction de `requete_oproom.py` du 2026-10-09. Unité : l'intervention.

## Choix
- Développer sur QBLOCT, mesurer sur QBLOCP : décision de Pierre (claim developper-sur-qbloct).
- Pierre n'a pas accès à QBLOCP : une personne qui y a accès a lancé `analysis/2026-10_casemix_bloc/requete_oproom.py --base QBLOCP` (DIM-code), une ligne par intervention. L'extraction reste sur le poste de Pierre, dans `data/raw/OpRoom/` de DIM-code, hors de Git : elle contient le numéro d'admission et la clé du chirurgien.
- Les requêtes de l'enquête s'exécutent sur cette extraction et non sur Oracle : `scripts/cdk/executer_requetes_cdk.py --oproom-extraction` la charge dans une base SQLite en mémoire (table INTERVENTIONS, une colonne par colonne du CSV, valeurs en texte, vide = NULL ; table META avec la base et la date de l'extraction), puis exécute la requête et contrôle le masquage avant d'écrire. Le SQL est donc celui de SQLite. Aucune requête ne lit NO_ADMISSION ni CHIRURGIEN_KEY autrement que pour compter.
- Ce que l'extraction ne contient pas (tables de facturation, vacations, temps de référence, statistiques Oracle) attend une requête SQL sur QBLOCP : plan de #39, étape 6.
- Pierre : en théorie toutes les requêtes tournent sur la base ; passer par l'extraction est un pis-aller tant qu'il n'a pas accès à QBLOCP.
- hosptype-is-declarative : l'extraction ne permet pas de comparer au tableau de bord ni à CORA ; la consigne (passer par CORA pour l'ambulatoire PMSI) est reprise dans specialite-et-etat-intervention, la mesure attend le chaînage OpRoom → CORA.
- Fiches non migrées : thick-mode (configuration de l'outil, sa place est dans oproom_toolbox) ; convention.priority-at-request et convention.tmi-tros-bionet-included (propres au projet casemix-bloc).

## Conclusions
- developper-sur-qbloct (unreviewed)
- oproom-blocs-entres-par-etapes (unreviewed)
- fin-intervention-inclut-bionettoyage (unreviewed)
- salle-gillies-hors-bloc (unreviewed)
- specialite-et-etat-intervention (unreviewed)
