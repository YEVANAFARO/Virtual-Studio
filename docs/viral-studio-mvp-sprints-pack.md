# Viral Studio — MVP 6 Sprints Pack

> Découpage réaliste de l’implémentation MVP en 6 sprints. Scope strict : objectifs, écrans, backend, tests, risques et version la plus simple à livrer.

## Sprint 1 — Auth + onboarding + profil créateur

### Objectifs
- Mettre en place l’entrée dans l’app sans friction.
- Créer le flow d’onboarding complet en 6 étapes.
- Sauvegarder un `creator_profile` exploitable par les moteurs IA.
- Sécuriser la base Supabase avec auth et RLS déjà prêtes.

### Écrans concernés
- `SplashPage`
- `AuthPage`
- `OnboardingStepGoalPage`
- `OnboardingStepPlatformPage`
- `OnboardingStepNichePage`
- `OnboardingStepTonePage`
- `OnboardingStepLevelPage`
- `OnboardingStepFrequencyPage`
- `OnboardingSummaryPage` en version minimum

### Backend concerné
- Supabase Auth
- table `creator_profiles`
- lecture de session utilisateur
- upsert profil lors du CTA `Construire ma stratégie`
- pas encore d’obligation de génération IA complète pendant les premiers jours du sprint

### Tests à faire
- création de compte email/password
- connexion utilisateur existant
- login Google si branché, sinon masquer proprement le bouton
- redirection correcte depuis `SplashPage`
- persistance des choix onboarding dans App State
- upsert `creator_profiles` avec les bons champs
- vérification RLS : un utilisateur ne lit que son profil
- retour arrière entre étapes sans perte de données locales

### Risques
- auth mal configurée dans FlutterFlow
- redirections cassées entre Splash, Auth et Onboarding
- App State non persisté entre les écrans onboarding
- création multiple de profils pour un même `user_id`

### Version la plus simple à livrer
- auth email/password uniquement
- bouton Google présent seulement si configuration finalisée
- `OnboardingSummaryPage` minimaliste : résumé profil + CTA entrer dans l’app
- pas encore de génération affichée si l’IA n’est pas branchée ; un placeholder `Votre stratégie arrive` est acceptable 48h maximum dans l’environnement de dev

## Sprint 2 — Home + Daily Idea

### Objectifs
- Donner le premier vrai `aha moment` produit.
- Générer une idée du jour utile et la rendre visible sur Home.
- Rendre la page Home capable de répondre à la question `Qu’est-ce que je fais maintenant ?`

### Écrans concernés
- `HomePage`
- `DailyIdeaPage`
- `OnboardingSummaryPage` finalisée si encore incomplète

### Backend concerné
- endpoint `POST /api/v1/daily-idea`
- table `daily_ideas`
- lecture `creator_profiles`
- lecture `daily_ideas` du jour
- éventuel calcul simple du `momentumScore` côté front si pas encore stocké

### Tests à faire
- appel API `daily-idea` avec profil valide
- validation JSON strict de la réponse
- insert/upsert de `daily_ideas` avec contrainte `(user_id, idea_date)`
- affichage correct sur `HomePage`
- affichage complet sur `DailyIdeaPage`
- régénération de l’idée du jour sans doublon
- copies hook/caption/hashtags fonctionnelles
- empty state si aucune idée n’existe

### Risques
- réponse IA non conforme au JSON attendu
- contenu trop générique ou trop long
- problème de fuseau/date créant plusieurs idées pour le même jour
- Home surchargé au lieu d’être focalisé sur l’action du jour

### Version la plus simple à livrer
- une seule idée du jour par utilisateur et par date
- `momentumScore` affiché comme score simple dérivé de régularité/complétion, sans algorithme avancé
- Home avec 4 blocs uniquement : header, momentum, action du jour, preview idée du jour

## Sprint 3 — Plan 7 Days

### Objectifs
- Structurer la semaine du créateur.
- Générer un plan de 7 jours lisible et actionnable.
- Permettre le suivi basique `todo/done`.

### Écrans concernés
- `Plan7DaysPage`
- `ReplacePlanItemBottomSheet` en version simple
- enrichissement léger de `HomePage` pour afficher la mission du jour issue du plan

### Backend concerné
- endpoint `POST /api/v1/weekly-plan`
- tables `weekly_plans` et `weekly_plan_items`
- update du `status` sur `weekly_plan_items`
- lecture du plan courant par `week_start`

### Tests à faire
- génération d’un plan 7 jours complet avec 7 items
- suppression/remplacement correct des anciens items de la même semaine
- affichage trié par `day_index`
- update `status = done`
- rechargement du plan après refresh
- cohérence entre `weekly_plans.week_theme` et les items affichés
- RLS sur lecture et update du plan

### Risques
- items dupliqués après régénération
- mauvaise gestion de `week_start`
- plan trop ambitieux par rapport à la fréquence choisie
- UX lourde si chaque card contient trop d’infos

### Version la plus simple à livrer
- un plan fixe de 7 cards verticales
- seulement deux statuts : `todo` et `done`
- remplacement d’un item possible via simple régénération manuelle plus tard si le bottom sheet n’est pas prêt

## Sprint 4 — Create / générateur de contenu

### Objectifs
- Permettre d’exécuter l’idée du jour ou un item de plan.
- Générer hooks, caption, script, hashtags et CTA depuis un brief.
- Sauvegarder les générations pour réutilisation.

### Écrans concernés
- `CreatePage`
- préremplissage depuis `DailyIdeaPage`
- préremplissage depuis `Plan7DaysPage`

### Backend concerné
- endpoint `POST /api/v1/generate-content`
- table `content_generations`
- lecture `creator_profiles`
- insert de chaque génération réussie

### Tests à faire
- validation des champs `brief`, `platform`, `format`
- appel API et parsing JSON strict
- affichage dans les onglets Hooks / Caption / Script / Hashtags / CTA
- copie des résultats
- sauvegarde correcte dans `content_generations`
- préremplissage depuis Daily Idea
- préremplissage depuis Plan 7 Days
- conservation du résultat à l’écran si l’insert DB échoue

### Risques
- temps de réponse IA trop long
- onglets vides à cause d’un JSON partiel
- brief trop pauvre donnant des résultats faibles
- page Create trop complexe pour le MVP

### Version la plus simple à livrer
- un seul bouton `Générer`
- 5 onglets de résultat
- `Créer 3 variantes` peut rester masqué si non stable
- script stocké en texte simple si le JSON de script est trop contraignant côté UI

## Sprint 5 — Growth + Before/After

### Objectifs
- Donner une preuve de progression visible.
- Permettre à l’utilisateur d’entrer ses stats manuellement.
- Rendre l’effet `avant / après Viral Studio` tangible.

### Écrans concernés
- `GrowthPage`
- `BeforeAfterPage`
- `ManualStatsBottomSheet`

### Backend concerné
- table `growth_snapshots`
- table `baseline_snapshots`
- endpoint `POST /api/v1/growth-insight`
- lecture historique des snapshots
- update du champ `main_insight`

### Tests à faire
- création d’un baseline si absent
- ajout d’un snapshot manuel
- affichage des KPI depuis le dernier snapshot
- affichage du chart avec plusieurs snapshots
- calcul simple des deltas avant/après
- appel `growth-insight` avec baseline + latest snapshot
- affichage du `main_insight`
- empty state si aucune donnée croissance n’existe

### Risques
- promesse analytics trop forte sans vraies intégrations sociales
- chiffres incohérents si l’utilisateur saisit mal ses stats
- chart cassé avec 0 ou 1 point seulement
- insight IA inutile si les données sont trop faibles

### Version la plus simple à livrer
- saisie manuelle obligatoire des stats
- 3 KPI minimum : followers, engagement, posts
- `BeforeAfterPage` avec comparaison texte + delta chips + timeline simple
- chart minimal sur les snapshots disponibles

## Sprint 6 — Pricing + polish + bêta privée

### Objectifs
- Ajouter la monétisation sans bloquer l’usage gratuit de base.
- Stabiliser la navigation, les states et les erreurs.
- Préparer une bêta testable par de vrais utilisateurs.

### Écrans concernés
- `PricingPage`
- `SettingsPage`
- retouches `HomePage`, `GrowthPage`, `CreatePage`
- `UpgradeBottomSheet` si retenu

### Backend concerné
- table `subscriptions`
- RevenueCat
- sync simple du plan actif vers Supabase
- mises à jour profil via `SettingsPage`

### Tests à faire
- affichage des offres
- achat sandbox RevenueCat
- sync du statut d’abonnement dans `subscriptions`
- changement de ton / fréquence dans `SettingsPage`
- logout complet
- test de non-régression sur le flow principal : signup → onboarding → daily idea → create → growth
- smoke test sur un compte gratuit et un compte premium

### Risques
- intégration RevenueCat plus longue que prévu
- paywall trop tôt dans l’expérience
- régressions de navigation après ajout de settings/pricing
- bêta lancée avec trop de bugs UI au lieu d’un scope réduit

### Version la plus simple à livrer
- plan Free + un seul plan Pro au début
- `PricingPage` statique si RevenueCat n’est pas finalisé, avec achat activé juste avant bêta
- `SettingsPage` limitée à niche, ton, fréquence, abonnement, logout
- gel du scope à la fin du sprint : aucun nouvel écran avant les premiers retours utilisateurs

## Recommandation d’exécution

### Ordre de priorité absolue
1. Sprint 1 doit être stable avant tout.
2. Sprint 2 doit créer l’effet `je sais quoi poster aujourd’hui`.
3. Sprint 3 et Sprint 4 transforment la promesse en routine.
4. Sprint 5 apporte la preuve.
5. Sprint 6 ne doit pas retarder la bêta : si RevenueCat ralentit, garder le paywall en soft-launch.

### Règle de cut scope
Si un sprint déborde, couper dans cet ordre :
1. animations et polish visuel
2. Google Sign-In
3. remplacement avancé d’item de plan
4. variantes de contenu secondaires
5. insights IA non essentiels

### Définition de bêta prête
La bêta est prête quand un utilisateur peut :
- s’inscrire,
- terminer l’onboarding,
- recevoir une idée du jour,
- consulter un plan 7 jours,
- générer un contenu,
- saisir ses stats,
- voir un avant/après simple,
- comprendre comment upgrader.
