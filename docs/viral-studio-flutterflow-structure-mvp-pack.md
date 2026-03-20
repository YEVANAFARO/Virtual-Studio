# Viral Studio — FlutterFlow MVP Structure Pack

> Source de vérité FlutterFlow pour le MVP. Scope strict : arborescence, navigation, App State, queries Supabase et actions principales par page.

## 1. Arborescence des pages

```text
AppRoot
├── SplashPage
├── AuthPage
├── OnboardingFlow
│   ├── OnboardingStepGoalPage
│   ├── OnboardingStepPlatformPage
│   ├── OnboardingStepNichePage
│   ├── OnboardingStepTonePage
│   ├── OnboardingStepLevelPage
│   ├── OnboardingStepFrequencyPage
│   └── OnboardingSummaryPage
├── MainShellPage
│   ├── HomePage
│   ├── Plan7DaysPage
│   ├── CreatePage
│   ├── GrowthPage
│   └── SettingsPage
├── DailyIdeaPage
├── BeforeAfterPage
├── PricingPage
├── ManualStatsBottomSheet
├── ReplacePlanItemBottomSheet
└── UpgradeBottomSheet
```

### Pages MVP à créer dans FlutterFlow
- `SplashPage`
- `AuthPage`
- `OnboardingStepGoalPage`
- `OnboardingStepPlatformPage`
- `OnboardingStepNichePage`
- `OnboardingStepTonePage`
- `OnboardingStepLevelPage`
- `OnboardingStepFrequencyPage`
- `OnboardingSummaryPage`
- `MainShellPage`
- `HomePage`
- `DailyIdeaPage`
- `CreatePage`
- `Plan7DaysPage`
- `GrowthPage`
- `BeforeAfterPage`
- `PricingPage`
- `SettingsPage`

### Navigation bottom tab dans `MainShellPage`
- Onglet 1 : `HomePage`
- Onglet 2 : `Plan7DaysPage`
- Onglet 3 : `CreatePage`
- Onglet 4 : `GrowthPage`
- Onglet 5 : `SettingsPage`

## 2. Navigation globale

### Flux d’entrée
1. `SplashPage`
2. `AuthPage`
3. `OnboardingStepGoalPage`
4. `OnboardingStepPlatformPage`
5. `OnboardingStepNichePage`
6. `OnboardingStepTonePage`
7. `OnboardingStepLevelPage`
8. `OnboardingStepFrequencyPage`
9. `OnboardingSummaryPage`
10. `MainShellPage` avec `HomePage`

### Règles de redirection au chargement

#### `SplashPage`
- Si aucun utilisateur Supabase n’est connecté → `AuthPage`
- Si utilisateur connecté mais aucun `creator_profiles` trouvé → `OnboardingStepGoalPage`
- Si utilisateur connecté et `onboarding_complete = false` → `OnboardingStepGoalPage`
- Si utilisateur connecté et `onboarding_complete = true` → `MainShellPage` avec onglet `HomePage`

#### `AuthPage`
- Après `Sign Up` ou `Log In` réussi :
  - requête `creator_profiles` par `user_id`
  - aucun profil → `OnboardingStepGoalPage`
  - profil incomplet → `OnboardingStepGoalPage`
  - profil complet → `MainShellPage`

### Navigation primaire après onboarding
- `HomePage` ↔ `Plan7DaysPage` ↔ `CreatePage` ↔ `GrowthPage` ↔ `SettingsPage`

### Navigation secondaire
- `HomePage` → `DailyIdeaPage`
- `HomePage` → `CreatePage`
- `HomePage` → `Plan7DaysPage`
- `HomePage` → `GrowthPage`
- `Plan7DaysPage` → `CreatePage` avec paramètres préremplis
- `GrowthPage` → `BeforeAfterPage`
- `GrowthPage` → `PricingPage`
- `SettingsPage` → `PricingPage`
- `SettingsPage` → `AuthPage` après logout
- `OnboardingSummaryPage` → `HomePage`
- `OnboardingSummaryPage` → `DailyIdeaPage`

### Bottom sheets à ouvrir depuis les pages
- `GrowthPage` → `ManualStatsBottomSheet`
- `Plan7DaysPage` → `ReplacePlanItemBottomSheet`
- `HomePage`, `GrowthPage`, `SettingsPage` → `UpgradeBottomSheet` ou `PricingPage`

## 3. App State FlutterFlow

### Global App State

#### Auth et bootstrap
- `appUserId` (`String`)
- `hasCompletedOnboarding` (`bool`)
- `isPremium` (`bool`)
- `currentWeekPlanId` (`String`)
- `todayIdeaId` (`String`)

#### Onboarding temporaire
- `onboardingGoal` (`String`)
- `onboardingPlatform` (`String`)
- `onboardingNiche` (`String`)
- `onboardingTone` (`String`)
- `onboardingLevel` (`String`)
- `onboardingFrequency` (`int`)
- `onboardingPreferredFormats` (`List<String>`)
- `onboardingLanguage` (`String`)
- `onboardingCountry` (`String`)

#### Create flow
- `selectedCreatePlatform` (`String`)
- `selectedCreateFormat` (`String`)
- `selectedCreateTone` (`String`)
- `createBrief` (`String`)
- `generatedHooks` (`List<String>`)
- `generatedCaption` (`String`)
- `generatedScript` (`String`)
- `generatedHashtags` (`List<String>`)
- `generatedCTA` (`String`)
- `generatedToneVariantsJson` (`JSON`)
- `latestGenerationId` (`String`)

#### Growth flow
- `manualFollowersInput` (`int`)
- `manualEngagementInput` (`double`)
- `manualPostsInput` (`int`)
- `momentumScore` (`int`)

### Local Page State recommandé
- `SplashPage.isLoadingProfile` (`bool`)
- `AuthPage.isSubmittingAuth` (`bool`)
- `OnboardingStepFrequencyPage.isBuildingStrategy` (`bool`)
- `DailyIdeaPage.isRegeneratingIdea` (`bool`)
- `CreatePage.isGeneratingContent` (`bool`)
- `CreatePage.selectedResultTab` (`String`)
- `Plan7DaysPage.selectedPlanItemId` (`String`)
- `GrowthPage.showManualStatsForm` (`bool`)
- `GrowthPage.isSavingManualStats` (`bool`)

## 4. Queries Supabase par page

## `SplashPage`
### Queries
- `creator_profiles`
  - filtre : `user_id = auth.uid()`
  - limite : `1`
### But
- savoir si l’utilisateur existe déjà côté auth
- savoir si l’onboarding est terminé

## `AuthPage`
### Queries
- aucune query au chargement
- query après auth réussie : `creator_profiles`
  - filtre : `user_id = auth.uid()`
  - limite : `1`
### But
- déterminer si l’utilisateur part en onboarding ou dans l’app

## `OnboardingStepGoalPage`
### Queries
- aucune

## `OnboardingStepPlatformPage`
### Queries
- aucune

## `OnboardingStepNichePage`
### Queries
- aucune

## `OnboardingStepTonePage`
### Queries
- aucune

## `OnboardingStepLevelPage`
### Queries
- aucune

## `OnboardingStepFrequencyPage`
### Queries
- aucune query d’affichage
- mutations à déclencher ensuite :
  - `creator_profiles` upsert
  - `daily_ideas` insert/upsert
  - `weekly_plans` insert/upsert
  - `weekly_plan_items` batch insert

## `OnboardingSummaryPage`
### Queries
- `creator_profiles`
  - filtre : `user_id = auth.uid()`
  - limite : `1`
- `daily_ideas`
  - filtre : `user_id = auth.uid()` et `idea_date = today`
  - limite : `1`
- `weekly_plans`
  - filtre : `user_id = auth.uid()`
  - tri : `week_start desc`
  - limite : `1`
### But
- afficher résumé du profil
- afficher preview de l’idée du jour
- afficher le thème de la semaine

## `HomePage`
### Queries
- `creator_profiles`
  - filtre : `user_id = auth.uid()`
  - limite : `1`
- `daily_ideas`
  - filtre : `user_id = auth.uid()` et `idea_date = today`
  - limite : `1`
- `weekly_plans`
  - filtre : `user_id = auth.uid()`
  - tri : `week_start desc`
  - limite : `1`
- `weekly_plan_items`
  - filtre : `weekly_plan_id = currentWeekPlanId`
  - tri : `day_index asc`
- `growth_snapshots`
  - filtre : `user_id = auth.uid()`
  - tri : `snapshot_date desc`
  - limite : `1`
- `baseline_snapshots`
  - filtre : `user_id = auth.uid()`
  - tri : `baseline_date asc`
  - limite : `1`
### But
- alimenter le cockpit principal
- calculer la mission du jour
- alimenter la mini progression

## `DailyIdeaPage`
### Queries
- `daily_ideas`
  - filtre : `user_id = auth.uid()` et `idea_date = today`
  - limite : `1`
- optionnel si fallback :
  - `creator_profiles`
    - filtre : `user_id = auth.uid()`
    - limite : `1`
### But
- afficher l’idée complète du jour
- relancer une régénération si aucune idée n’existe

## `CreatePage`
### Queries
- `creator_profiles`
  - filtre : `user_id = auth.uid()`
  - limite : `1`
- `content_generations`
  - filtre : `user_id = auth.uid()`
  - tri : `created_at desc`
  - limite : `1`
### But
- préremplir plateforme / ton par défaut
- éventuellement réafficher la dernière génération

## `Plan7DaysPage`
### Queries
- `weekly_plans`
  - filtre : `user_id = auth.uid()`
  - tri : `week_start desc`
  - limite : `1`
- `weekly_plan_items`
  - filtre : `weekly_plan_id = currentWeekPlanId`
  - tri : `day_index asc`
- `creator_profiles`
  - filtre : `user_id = auth.uid()`
  - limite : `1`
### But
- afficher le plan actif
- fournir contexte pour remplacer ou brouillonner un item

## `GrowthPage`
### Queries
- `growth_snapshots`
  - filtre : `user_id = auth.uid()`
  - tri : `snapshot_date desc`
  - limite : `30`
- `baseline_snapshots`
  - filtre : `user_id = auth.uid()`
  - tri : `baseline_date asc`
  - limite : `1`
- `subscriptions`
  - filtre : `user_id = auth.uid()`
  - tri : `started_at desc`
  - limite : `1`
### But
- afficher KPI, historique, top format et insight principal
- savoir si l’utilisateur doit voir un CTA upgrade

## `BeforeAfterPage`
### Queries
- `baseline_snapshots`
  - filtre : `user_id = auth.uid()`
  - tri : `baseline_date asc`
  - limite : `1`
- `growth_snapshots`
  - filtre : `user_id = auth.uid()`
  - tri : `snapshot_date desc`
  - limite : `1`
- `weekly_plans`
  - filtre : `user_id = auth.uid()`
  - tri : `week_start asc`
  - limite : `4`
### But
- comparer baseline vs état actuel
- construire une timeline très simple

## `PricingPage`
### Queries
- `subscriptions`
  - filtre : `user_id = auth.uid()`
  - tri : `started_at desc`
  - limite : `1`
### But
- afficher le plan actif
- gérer l’état free / pro / growth

## `SettingsPage`
### Queries
- `creator_profiles`
  - filtre : `user_id = auth.uid()`
  - limite : `1`
- `subscriptions`
  - filtre : `user_id = auth.uid()`
  - tri : `started_at desc`
  - limite : `1`
### But
- afficher et modifier les infos de profil
- exposer l’état d’abonnement

## 5. Actions principales par page

## `SplashPage`
- Vérifier session Supabase
- Charger `creator_profiles`
- Remplir `appUserId`
- Remplir `hasCompletedOnboarding`
- Rediriger vers `AuthPage` ou `MainShellPage` ou `OnboardingStepGoalPage`

## `AuthPage`
- `Sign Up with Email`
- `Log In with Email`
- `Continue with Google`
- Après succès : requête `creator_profiles`
- Navigation conditionnelle vers onboarding ou app

## `OnboardingStepGoalPage`
- Stocker `onboardingGoal`
- Naviguer vers `OnboardingStepPlatformPage`

## `OnboardingStepPlatformPage`
- Stocker `onboardingPlatform`
- Naviguer vers `OnboardingStepNichePage`

## `OnboardingStepNichePage`
- Stocker `onboardingNiche`
- Stocker éventuellement `onboardingPreferredFormats`
- Naviguer vers `OnboardingStepTonePage`

## `OnboardingStepTonePage`
- Stocker `onboardingTone`
- Naviguer vers `OnboardingStepLevelPage`

## `OnboardingStepLevelPage`
- Stocker `onboardingLevel`
- Naviguer vers `OnboardingStepFrequencyPage`

## `OnboardingStepFrequencyPage`
### Action principale : `Construire ma stratégie`
1. Upsert `creator_profiles`
2. Appel backend `POST /api/v1/daily-idea`
3. Insert ou upsert `daily_ideas`
4. Appel backend `POST /api/v1/weekly-plan`
5. Insert ou upsert `weekly_plans`
6. Batch insert `weekly_plan_items`
7. Mettre `hasCompletedOnboarding = true`
8. Naviguer vers `OnboardingSummaryPage`

## `OnboardingSummaryPage`
- Charger le profil et l’idée du jour
- Bouton `Ouvrir mon studio` → `MainShellPage` / `HomePage`
- Bouton secondaire `Voir l’idée complète` → `DailyIdeaPage`

## `HomePage`
- Calculer la mission du jour à partir du premier item `todo`
- Ouvrir `DailyIdeaPage`
- Ouvrir `CreatePage`
- Ouvrir `Plan7DaysPage`
- Ouvrir `GrowthPage`
- Ouvrir `PricingPage` si fonctionnalité premium verrouillée

## `DailyIdeaPage`
- `Régénérer` → appel `POST /api/v1/daily-idea`
- Mettre à jour `daily_ideas`
- `Créer ce contenu` → ouvrir `CreatePage` avec brief prérempli
- `En faire un script` → ouvrir `CreatePage` avec format vidéo prérempli
- `Ajouter au calendrier` → update ou insert simple dans `weekly_plan_items` si choisi pour plus tard, sinon toast MVP
- `Copier hook`, `Copier caption`, `Copier hashtags`

## `CreatePage`
### Action principale : `Générer`
1. Valider `brief`, `platform`, `format`
2. Appeler `POST /api/v1/generate-content`
3. Remplir les App States de résultat
4. Insert dans `content_generations`
5. Afficher les onglets résultats

### Actions secondaires
- `Copier`
- `Sauvegarder`
- `Créer 3 variantes`
- `Réutiliser depuis Daily Idea`

## `Plan7DaysPage`
- `Marquer comme fait` → update `weekly_plan_items.status = done`
- `Remplacer` → ouvrir `ReplacePlanItemBottomSheet`
- `Générer brouillon` → ouvrir `CreatePage` avec `topic`, `angle`, `tone`, `platform`, `format`
- `Refresh plan` → refetch `weekly_plans` et `weekly_plan_items`

## `GrowthPage`
- Si aucune donnée : ouvrir ou afficher `ManualStatsBottomSheet`
- `Enregistrer mes stats` → insert `baseline_snapshots` si absente puis insert `growth_snapshots`
- `Voir avant / après` → `BeforeAfterPage`
- `Obtenir un insight` → appel `POST /api/v1/growth-insight` si assez de données, puis update `growth_snapshots.main_insight`
- `Upgrade` → `PricingPage`

## `BeforeAfterPage`
- Calculer les deltas followers / engagement / posts
- Construire une timeline simple à partir de baseline + semaines créées + dernier snapshot
- `Partager ma progression` → share sheet natif avec texte court
- `Préparer mon prochain mois` → `Plan7DaysPage` ou `PricingPage` selon offre

## `PricingPage`
- Charger l’offre active RevenueCat
- Lancer achat
- Mettre à jour `subscriptions`
- Mettre `isPremium = true` si purchase active
- Revenir vers `GrowthPage` ou `HomePage`

## `SettingsPage`
- Mettre à jour `creator_profiles`
- Modifier `desired_tone`
- Modifier `frequency_per_week`
- Ouvrir `PricingPage`
- `Logout` → clear App State + Supabase sign out + `AuthPage`
