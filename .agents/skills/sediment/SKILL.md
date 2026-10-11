---
name: sediment
description: Transformer les preuves d'une enquête en claims et les faire entrer dans le dépôt ; aussi pour réutiliser, contester ou remplacer un claim, et pour suspendre ou fermer une enquête.
---

# sediment

1. **Écrire les claims.** Un claim par test possible (claims.md, « Taille »), rangé selon layout.md, avec ses preuves dans supported_by et ses prémisses dans depends_on. La réponse à la question devient un claim d'enquête qui dépend des claims atomiques.
   Fini quand : chaque conclusion de l'enquête est un claim, et chaque claim cite ses preuves ou ses prémisses.
2. **Relire ce qu'on réutilise** (review.md). Pour chaque prémisse d'une autre personne sans relecture à jour : la relecture au réemploi. Pour chaque prémisse de la même personne, venue d'une autre enquête : author-reread, dans une nouvelle session. Pour chaque prémisse qui est un claim d'enquête : la promotion (layout.md).
   Fini quand : chaque prémisse est relue ou déjà à jour, sauf pour un claim provisional.
3. **Contrôler :** `python checks/check.py`.
   Fini quand : aucun ROUGE ; les ORANGE restants sont listés pour la personne.
4. **Faire entrer.** La personne qui mène l'enquête relit et confirme ; l'agent fait le merge de la branche de l'enquête dans la branche principale (investigations/README.md, « La branche »). Sur GitHub, par une PR qui écrit « Refs #N », jamais « Closes #N ». Un résultat partiel peut entrer pendant que l'enquête reste ouverte.
   Fini quand : la personne a confirmé et le merge est fait.
5. **Suspendre ou fermer.** Mettre à jour la section Conclusions du README de l'enquête : les claims, avec leur état de relecture.
   Fini quand : la section est à jour.

**Contester ou remplacer un claim :** review.md, « Contestation », puis les étapes 3 et 4.
