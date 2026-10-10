# Vocabulaire de la méthode

Les mots du dépôt lui-même. Les termes des systèmes et des domaines sont dans leurs propres GLOSSARY.md (voir GLOSSARY-MAP.md).

## claim
Une affirmation sur les données du CHU, dans un fichier, avec ses preuves. Format : claims.md.

## preuve (evidence)
Une observation dans un fichier : l'exécution d'une requête, ou la lecture d'un passage. Format : evidence.md.

## requête (request)
Un fichier .sql préparé par un agent et exécuté à l'hôpital par une personne. Format : requests.md.

## source
La fiche d'un document : titre, éditeur, édition, où le trouver, autorité. Une fiche par édition.

## contexte
Le modèle dans lequel un terme a un sens : un système (cora, edsan, icca, oproom) ou un domaine (pmsi). Un terme s'écrit avec son contexte : cora:mouvement.

## pont
Un claim dont les terms viennent de deux contextes. Il dit comment deux modèles se correspondent.

## enquête (investigation)
Le travail pour répondre à une question précise. Un dossier dans investigations/.

## relay
L'aller-retour à l'hôpital : l'agent prépare la requête, une personne l'exécute et rapporte le résultat agrégé.

## prémisse
Un claim cité dans depends_on : le claim s'appuie dessus.

## relecture (review)
Le contrôle d'un claim par une autre personne, au moment où elle le réutilise. Voir review.md.

## empreinte (fingerprint)
Un code de 12 caractères calculé à partir d'un claim, de ses preuves et de ses prémisses. Si l'un d'eux change, l'empreinte change et la relecture est périmée.

## promotion
Le passage d'un claim d'enquête vers systems/ ou domains/, avec le même id, quand une autre enquête le réutilise.

## friction
Tout accroc pendant une session : une correction de la personne, un contrôle qui échoue, une étape refaite, une règle introuvable. La retro en fait une issue GitHub avec l'étiquette friction.

## ROUGE, ORANGE
Les deux niveaux des contrôles : ROUGE bloque, ORANGE signale un travail à faire. Voir checks.md.

## mainteneur
La personne qui garde les règles du jeu : Francesco pour l'instant.
