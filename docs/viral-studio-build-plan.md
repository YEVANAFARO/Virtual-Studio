# Viral Studio — Plan de build MVP exécutable

## 1. Vue d’ensemble du MVP

### Objectif du MVP en 30 jours
Livrer une application mobile-first FlutterFlow qui donne à un créateur :
- un onboarding intelligent,
- une idée du jour personnalisée,
- un plan 7 jours,
- un générateur de contenu IA,
- un dashboard de croissance simple,
- un comparatif avant/après,
- un paywall simple.

### Ce que le MVP doit absolument réussir
1. **Créer un “aha moment” en moins de 5 minutes** : profil + idée du jour + plan 7 jours.
2. **Donner une utilité quotidienne** : Home, Daily Idea, Create.
3. **Créer une preuve de valeur simple** : Growth + Before/After.
4. **Ne dépendre d’aucune intégration sociale complexe** au lancement.

### Ce que le MVP ne fait pas
- pas d’autopost multi-plateformes,
- pas d’inbox commentaires cross-platform,
- pas de trend engine temps réel complexe,
- pas de clone de ton avancé,
- pas de benchmark concurrentiel,
- pas de scoring viral ML sophistiqué.

### Stack de build recommandée
- **App** : FlutterFlow mobile app.
- **DB/Auth** : Supabase.
- **Backend API** : Supabase Edge Functions ou backend léger Node/TypeScript.
- **IA** : OpenAI API.
- **Abonnement** : RevenueCat.
- **Automatisation légère optionnelle** : Make / n8n plus tard.

### Règles CTO pour aller vite
- 1 base de données,
- 1 backend API simple,
- 1 set de prompts IA versionnés,
- 1 design system cohérent,
- 1 logique de données lisible,
- aucun couplage fort à une API sociale tierce en V1.

---

## 2. Arborescence des écrans

```text
AppRoot
├── SplashPage
├── AuthPage
├── OnboardingStepGoalPage
├── OnboardingStepPlatformPage
├── OnboardingStepNichePage
├── OnboardingStepTonePage
├── OnboardingStepLevelPage
├── OnboardingStepFrequencyPage
├── OnboardingSummaryPage
├── MainShell
│   ├── HomePage
│   ├── Plan7DaysPage
│   ├── CreatePage
│   ├── GrowthPage
│   └── SettingsPage
├── DailyIdeaPage
├── BeforeAfterPage
├── PricingPage
├── ManualStatsSheet
├── ReplacePlanItemSheet
└── PaywallSheet
```

### Écrans MVP strict
- SplashPage
- AuthPage
- OnboardingStepGoalPage
- OnboardingStepPlatformPage
- OnboardingStepNichePage
- OnboardingStepTonePage
- OnboardingStepLevelPage
- OnboardingStepFrequencyPage
- OnboardingSummaryPage
- HomePage
- DailyIdeaPage
- CreatePage
- Plan7DaysPage
- GrowthPage
- BeforeAfterPage
- PricingPage
- SettingsPage

### Bottom navigation
- Home
- Plan
- Create
- Growth
- Settings

---

## 3. Navigation globale

## Flux principal
1. SplashPage
2. AuthPage
3. Onboarding steps
4. OnboardingSummaryPage
5. MainShell > HomePage
6. Navigation secondaire vers DailyIdea / Create / Plan / Growth / Settings / Pricing / BeforeAfter

## Règles de navigation

### SplashPage
- si pas d’utilisateur connecté → AuthPage
- si connecté + pas de creator profile → OnboardingStepGoalPage
- si connecté + profile onboarding_complete = false → reprendre dernière étape connue (simplifié : OnboardingStepGoalPage)
- si connecté + onboarding_complete = true → MainShell avec HomePage

### AuthPage
- login / signup ok → fetch creator_profiles
- si aucun profil → OnboardingStepGoalPage
- si profil incomplet → OnboardingStepGoalPage
- si profil complet → MainShell

### OnboardingSummaryPage
- bouton principal → MainShell/HomePage
- bouton secondaire → DailyIdeaPage

### HomePage
- action du jour → DailyIdeaPage
- idée du jour preview → DailyIdeaPage
- CTA Plan → Plan7DaysPage
- CTA Growth → GrowthPage
- CTA Create → CreatePage

### GrowthPage
- bouton Before/After → BeforeAfterPage
- bouton Upgrade → PricingPage

### SettingsPage
- abonnement → PricingPage
- logout → AuthPage

---

## 4. App State FlutterFlow

## App States globaux à créer

### Auth / bootstrap
- `appUserId` (String)
- `hasCompletedOnboarding` (bool)
- `isPremium` (bool)

### Onboarding temporary state
- `onboardingGoal` (String)
- `onboardingPlatform` (String)
- `onboardingNiche` (String)
- `onboardingTone` (String)
- `onboardingLevel` (String)
- `onboardingFrequency` (int)
- `onboardingPreferredFormats` (List<String>)

### Create flow state
- `selectedCreatePlatform` (String)
- `selectedCreateFormat` (String)
- `selectedCreateTone` (String)
- `createBrief` (String)
- `generatedHooks` (List<String>)
- `generatedCaption` (String)
- `generatedScript` (String)
- `generatedHashtags` (List<String>)
- `generatedCTA` (String)
- `generatedToneVariantsJson` (JSON)
- `latestGenerationId` (String)

### Home / dashboard state
- `momentumScore` (int)
- `currentWeekPlanId` (String)
- `todayIdeaId` (String)

### Growth state
- `manualFollowersInput` (int)
- `manualEngagementInput` (double)
- `manualPostsInput` (int)

## Local page states recommandés

### DailyIdeaPage
- `isRegeneratingIdea` (bool)

### CreatePage
- `isGeneratingContent` (bool)
- `selectedResultTab` (String)

### Plan7DaysPage
- `selectedPlanItemId` (String)

### GrowthPage
- `showManualStatsForm` (bool)

---

## 5. Tables Supabase détaillées

## Schéma recommandé
- toutes les tables sous `public`
- relation principale via `auth.users.id`
- RLS activé sur toutes les tables métier
- accès front uniquement sur lignes du user courant
- génération IA via backend sécurisé, pas direct depuis FlutterFlow vers OpenAI

## SQL complet de migration
Le SQL exécutable du MVP est versionné dans :
- `supabase/migrations/20260319_001_viral_studio_mvp.sql`

## Résumé des tables

### `creator_profiles`
Usage : source de vérité du profil créateur.

Champs clés :
- `user_id` unique
- `niche`
- `primary_platform`
- `goal`
- `desired_tone`
- `level`
- `frequency_per_week`
- `preferred_formats`
- `language`
- `country`
- `onboarding_complete`

### `daily_ideas`
Usage : stocker l’idée quotidienne du user.

Champs clés :
- `user_id`
- `idea_date`
- `idea_title`
- `why_now`
- `topic`
- `angle`
- `hook`
- `content_structure` (JSONB)
- `caption`
- `cta`
- `hashtags` (text[])
- `recommended_format`
- `recommended_time`
- `engagement_mission`
- `effort_level`
- `confidence_note`

### `weekly_plans`
Usage : plan 7 jours principal.

Champs clés :
- `user_id`
- `week_start`
- `week_theme`
- `coach_note`

### `weekly_plan_items`
Usage : chaque jour du plan.

Champs clés :
- `weekly_plan_id`
- `day_index`
- `platform`
- `objective`
- `format`
- `topic`
- `angle`
- `tone`
- `time_window`
- `engagement_task`
- `effort`
- `status`

### `content_generations`
Usage : historique Create.

Champs clés :
- `user_id`
- `source_brief`
- `platform`
- `format`
- `tone`
- `hooks` (JSONB)
- `caption`
- `script`
- `hashtags` (text[])
- `cta`
- `tone_variants` (JSONB)

### `growth_snapshots`
Usage : KPI saisis ou calculés.

Champs clés :
- `user_id`
- `snapshot_date`
- `followers_total`
- `engagement_rate`
- `posts_count`
- `regularity_rate`
- `top_format`
- `main_insight`

### `baseline_snapshots`
Usage : point de départ pour before/after.

Champs clés :
- `user_id`
- `baseline_date`
- `followers_baseline`
- `engagement_baseline`
- `posts_baseline`
- `notes`

### `subscriptions`
Usage : état d’abonnement pour paywall.

Champs clés :
- `user_id`
- `plan_name`
- `status`
- `started_at`
- `expires_at`
- `provider_customer_id`
- `provider_subscription_id`

## Relations
- `creator_profiles.user_id -> auth.users.id`
- `daily_ideas.user_id -> auth.users.id`
- `weekly_plans.user_id -> auth.users.id`
- `weekly_plan_items.weekly_plan_id -> weekly_plans.id`
- `content_generations.user_id -> auth.users.id`
- `growth_snapshots.user_id -> auth.users.id`
- `baseline_snapshots.user_id -> auth.users.id`
- `subscriptions.user_id -> auth.users.id`

## Requêtes Supabase clés par écran

### Splash / Auth
- `select * from creator_profiles where user_id = currentUserId limit 1`

### OnboardingSummary
- `select * from creator_profiles where user_id = currentUserId`
- `select * from daily_ideas where user_id = currentUserId and idea_date = today`

### Home
- `select * from creator_profiles where user_id = currentUserId`
- `select * from daily_ideas where user_id = currentUserId and idea_date = today`
- `select * from weekly_plans where user_id = currentUserId and week_start = start_of_week`
- `select * from weekly_plan_items where weekly_plan_id = currentWeekPlanId order by day_index asc`
- `select * from growth_snapshots where user_id = currentUserId order by snapshot_date desc limit 1`

### Plan7Days
- `select * from weekly_plans where user_id = currentUserId and week_start = start_of_week`
- `select * from weekly_plan_items where weekly_plan_id = currentWeekPlanId order by day_index asc`

### Create
- `select * from creator_profiles where user_id = currentUserId`
- `insert into content_generations ...`

### Growth
- `select * from baseline_snapshots where user_id = currentUserId order by baseline_date asc limit 1`
- `select * from growth_snapshots where user_id = currentUserId order by snapshot_date desc`

### Settings / Pricing
- `select * from subscriptions where user_id = currentUserId order by started_at desc limit 1`

---

## 6. Détail écran par écran FlutterFlow

## 6.1 SplashPage

### Widgets exacts
1. `Container` full screen background color `#0B1020`
2. `Column` centered
3. `Image` logo
4. `Text` “Viral Studio”
5. `Text` sous-titre
6. `CircularProgressIndicator`

### Actions on Page Load
1. `Auth -> Check Current User`
2. If no user → `Navigate AuthPage`
3. Else `Backend Query creator_profiles single row`
4. If no row → `Navigate OnboardingStepGoalPage`
5. If row.onboarding_complete = false → `Navigate OnboardingStepGoalPage`
6. Else → `Navigate MainShell (initial tab Home)`

### States nécessaires
Aucun state local.

### Empty / loading / error
- loading = loader visible
- error profile fetch = fallback vers AuthPage avec snackbar

---

## 6.2 AuthPage

### Widgets exacts
1. `SafeArea`
2. `SingleChildScrollView`
3. `Column`
4. `Text` titre
5. `Text` sous-titre
6. `Button` Continuer avec Google
7. `Divider`
8. `TextField` email
9. `TextField` mot de passe
10. `Button` Commencer gratuitement
11. `TextButton` J’ai déjà un compte

### Actions bouton Google
1. `Authentication -> Sign in with Google`
2. On success → `Backend Query creator_profiles`
3. If no profile or onboarding incomplete → `Navigate OnboardingStepGoalPage`
4. Else → `Navigate MainShell`

### Actions bouton email
Option A simple MVP : séparer en mode signup/login via boolean local state `isLoginMode`.
1. Validate fields
2. `Authentication -> Create Account` ou `Sign In`
3. Puis même logique que Google

### Backend queries
- creator_profiles by `authUser.uid`

### Empty / loading / error
- loading : disable buttons
- error : snackbar message propre

---

## 6.3 OnboardingStepGoalPage

### Widgets exacts
1. `ProgressBar` 1/6
2. `Text` question
3. `Wrap` de `ChoiceChip`
4. `Button` Continuer
5. `TextButton` Retour

### Bindings
- sélection liée à `FFAppState().onboardingGoal`

### Action bouton Continuer
1. set app state `onboardingGoal`
2. navigate `OnboardingStepPlatformPage`

### Query backend
Aucune.

---

## 6.4 OnboardingStepPlatformPage

### Widgets exacts
1. `ProgressBar` 2/6
2. `Text`
3. `Column` de `Container` sélectionnables ou `ChoiceChip`
4. `Button` Continuer

### Options
- Instagram
- TikTok
- LinkedIn
- YouTube Shorts

### Action bouton
- set `onboardingPlatform`
- navigate `OnboardingStepNichePage`

---

## 6.5 OnboardingStepNichePage

### Widgets exacts
1. `ProgressBar` 3/6
2. `Text`
3. `TextField` niche
4. `Wrap` suggestion chips
5. `Button` Continuer

### Action bouton
- set `onboardingNiche`
- navigate `OnboardingStepTonePage`

---

## 6.6 OnboardingStepTonePage

### Widgets exacts
1. `ProgressBar` 4/6
2. `Wrap` de `ChoiceChip`
3. `Button` Continuer

### Action bouton
- set `onboardingTone`
- navigate `OnboardingStepLevelPage`

---

## 6.7 OnboardingStepLevelPage

### Widgets exacts
1. `ProgressBar` 5/6
2. `Column` de `Selectable Cards`
3. `Button` Continuer

### Action bouton
- set `onboardingLevel`
- navigate `OnboardingStepFrequencyPage`

---

## 6.8 OnboardingStepFrequencyPage

### Widgets exacts
1. `ProgressBar` 6/6
2. `Column` de `Selectable Cards`
3. `Button` Construire ma stratégie

### Action bouton Construire ma stratégie
1. Set local loading true
2. `Supabase -> Upsert creator_profiles`
   - `user_id = currentUserUid`
   - `niche = FFAppState().onboardingNiche`
   - `primary_platform = FFAppState().onboardingPlatform`
   - `goal = FFAppState().onboardingGoal`
   - `desired_tone = FFAppState().onboardingTone`
   - `level = FFAppState().onboardingLevel`
   - `frequency_per_week = FFAppState().onboardingFrequency`
   - `preferred_formats = []`
   - `onboarding_complete = true`
3. `API Call /daily-idea`
4. `Supabase -> Upsert daily_ideas`
5. `API Call /weekly-plan`
6. `Supabase -> Upsert weekly_plans`
7. `Supabase -> Insert weekly_plan_items` dans loop
8. `Conditional Query baseline_snapshots`
9. Si none → insert baseline snapshot vide (0/0/0 + note onboarding)
10. Navigate `OnboardingSummaryPage`

### Important FlutterFlow
Pour insérer plusieurs `weekly_plan_items`, utiliser :
- `Backend Call` sur endpoint backend qui écrit directement DB **ou**
- `Action Loop` sur JSON `days[]` renvoyé par l’API.

**Recommandation CTO** : faire écrire `weekly_plans` et `weekly_plan_items` directement par le backend `/weekly-plan` pour éviter la complexité dans FlutterFlow.

---

## 6.9 OnboardingSummaryPage

### Widgets exacts
1. `SingleChildScrollView`
2. `Hero Card`
3. `Card Profil`
4. `Card Opportunités x3`
5. `Card Daily Idea Preview`
6. `Button` Ouvrir mon studio

### Backend queries
- creator_profiles current user
- daily_ideas today

### Action bouton
- navigate `MainShell > HomePage`

### Empty state
Si daily idea absente → bouton `Générer mon idée du jour` → API `/daily-idea`

---

## 6.10 MainShell

### Configuration FlutterFlow
Créer un `NavBar Page` avec 5 tabs :
- HomePage
- Plan7DaysPage
- CreatePage
- GrowthPage
- SettingsPage

---

## 6.11 HomePage

### Widgets exacts ordre strict
1. `SafeArea`
2. `SingleChildScrollView`
3. `Column`
4. `Row`
   - avatar circle
   - `Column` bonjour + sous-titre
   - notification icon button
5. `Container/Card` Momentum
   - score
   - delta
6. `Container/Card` Action du jour
   - mission
   - tags
   - CTA `Créer maintenant`
7. `Container/Card` Idée du jour preview
   - sujet
   - hook
   - format
   - heure
   - CTA `Voir le détail`
8. `Container/Card` Mini progression
   - tâches faites / 7
   - mini progress bar
9. `Row/Grid` accès rapide
   - Plan
   - Create
   - Growth

### Queries backend
- profile current user
- today daily idea
- current weekly plan
- weekly plan items
- latest growth snapshot

### Bindings clés
- score momentum = calcul simple client ou renvoyé par snapshot `regularity_rate` si rien d’autre
- action du jour = item du plan du jour si trouvé, sinon daily idea fallback

### Actions boutons
- `Créer maintenant` → Navigate `DailyIdeaPage`
- `Voir le détail` → Navigate `DailyIdeaPage`
- `Plan` → tab Plan
- `Create` → tab Create
- `Growth` → tab Growth

### Empty states
- pas de daily idea → bouton `Générer mon idée du jour`
- pas de plan semaine → bouton `Créer mon plan 7 jours`
- pas de growth snapshot → message `Ajoutez vos stats pour voir votre progression`

---

## 6.12 DailyIdeaPage

### Widgets exacts
1. `AppBar`
2. `SingleChildScrollView`
3. `Text` date du jour
4. `Hero Card`
   - idea_title
   - why_now
5. `Section Hook`
   - text
   - copy icon
6. `Section Structure`
   - list generated from `content_structure`
7. `Section Caption`
   - text
   - copy button
8. `Section CTA`
9. `Section Hashtags`
   - Wrap chips
10. `Section Format + Heure`
11. `Section Mission engagement`
12. `BottomBar Sticky`
   - `Créer ce contenu`
   - `En faire un script`
   - `Ajouter au calendrier`
   - `Régénérer`

### Query backend
- daily_ideas where `idea_date = today`

### Actions
#### Régénérer
1. call `/daily-idea`
2. backend upsert row du jour
3. refresh query

#### Créer ce contenu
- navigate `CreatePage` with params:
  - brief = topic + angle
  - platform = recommended_format platform fallback profile.primary_platform
  - tone = profile.desired_tone

#### En faire un script
- navigate `CreatePage`
- set format preselected = `video_short`
- set brief with hook + angle

#### Ajouter au calendrier
**MVP simple** : pas de vraie table calendrier distincte.
- update le `weekly_plan_item` du jour si trouvé
- sinon toast `Ajouté à votre plan du jour`

---

## 6.13 CreatePage

### Widgets exacts
1. `AppBar`
2. `SingleChildScrollView`
3. `Dropdown` plateforme
4. `Dropdown` format
5. `Wrap` tone chips
6. `TextField` multiline brief
7. `Button` Générer
8. `TabBar`
   - Hooks
   - Caption
   - Script
   - Hashtags
   - CTA
9. `Conditional Result Area`
10. `Buttons Row`
    - Sauvegarder
    - Copier
    - Créer 3 variantes

### State bindings
- dropdowns vers AppState
- brief vers local state ou AppState
- résultats vers AppState

### Action bouton Générer
1. Validate brief non vide
2. API `/generate-content`
3. Parse response into AppState
4. Insert row `content_generations`
5. Show result tabs

### Action Sauvegarder
- insert/update `content_generations`

### Action Copier
- copy text of selected tab

### Action Créer 3 variantes
**MVP recommandé** : refaire `/generate-content` avec param `variants=true`

### Empty state
Afficher cartes de raccourci :
- Hook Instagram
- Caption LinkedIn
- Script Reel
- Hashtags niche

---

## 6.14 Plan7DaysPage

### Widgets exacts
1. `AppBar`
2. `SingleChildScrollView`
3. `Text` week_theme
4. `Text` coach_note
5. `ListView` non-scrollable inside parent scroll
6. card x7 items

### Structure card jour
- jour / index
- plateforme
- format
- sujet
- angle
- ton
- créneau
- engagement_task
- effort badge
- status chip
- buttons row : `Fait`, `Remplacer`, `Générer brouillon`

### Query backend
- current weekly plan
- linked items ordered by `day_index`

### Actions
#### Fait
- update `weekly_plan_items.status = 'done'`
- optionally insert/update today growth snapshot regularity later

#### Remplacer
**MVP rapide** : ouvrir `ReplacePlanItemSheet`
- bouton sheet `Générer alternative`
- call `/weekly-plan/replacement`
- backend update line
- refresh page

#### Générer brouillon
- navigate `CreatePage` with prefill topic + angle + tone + platform

### Empty state
- bouton `Générer mon plan 7 jours`

---

## 6.15 GrowthPage

### Widgets exacts
1. `AppBar`
2. `SingleChildScrollView`
3. `Row` KPI cards x4
   - followers gagnés
   - engagement
   - posts
   - régularité
4. `LineChart`
5. `Card` top format
6. `Card` insight principal
7. `Button` Voir avant / après
8. `Conditional Form` si pas de data
   - followers actuels
   - engagement estimé
   - posts du mois
   - button enregistrer

### Query backend
- latest baseline snapshot
- growth snapshots ordered asc/desc

### Action Enregistrer mes stats
1. if no baseline exists → insert baseline with entered values
2. insert growth_snapshot for today
3. if no subscription row exists → ignore
4. refresh page

### Action Voir avant / après
- navigate `BeforeAfterPage`

### MVP calculs affichés
- followers gagnés = latest.followers_total - baseline.followers_baseline
- engagement delta = latest.engagement_rate - baseline.engagement_baseline
- posts delta = latest.posts_count - baseline.posts_baseline
- regularity = latest.regularity_rate

---

## 6.16 BeforeAfterPage

### Widgets exacts
1. `AppBar`
2. `SingleChildScrollView`
3. `Hero Card`
4. `Row` comparison cards
   - followers avant / maintenant
   - engagement avant / maintenant
   - posts avant / maintenant
5. `Delta chips`
6. `Timeline` verticale simple
7. `Button` Préparer mon prochain mois
8. `Button` Partager ma progression (disabled MVP if no export)

### Query backend
- earliest baseline snapshot
- latest growth snapshot
- weekly plan count / daily idea count optional for timeline labels

### Timeline MVP simple
- baseline created
- first daily idea generated
- first weekly plan generated
- first growth snapshot saved

---

## 6.17 PricingPage

### Widgets exacts
1. `AppBar`
2. `Column`
3. `Hero Text`
4. `Pricing Cards` Free / Pro / Growth
5. `Features list`
6. `Button Subscribe`

### Actions
- call RevenueCat purchase flow
- on success call backend `/subscriptions/sync` or direct upsert subscription row

### MVP simplification
Si RevenueCat pas prêt en beta fermée :
- bouton `Rejoindre Pro` → Typeform / Stripe Payment Link manuel
- sync manuel des accès

---

## 6.18 SettingsPage

### Widgets exacts
1. `AppBar`
2. `ListView`
3. `Card profil`
4. `Input niche`
5. `Dropdown ton`
6. `Dropdown fréquence`
7. `Card abonnement`
8. `Button Sauvegarder`
9. `Button Déconnexion`

### Query backend
- creator_profiles current user
- latest subscription current user

### Actions
- save => update `creator_profiles`
- deconnexion => `Auth -> Sign Out` -> AuthPage

---

## 7. Endpoints API

## Recommandation technique
Créer des **Supabase Edge Functions** ou un micro-backend Node derrière `/api/v1/*`.

### Convention commune
- toutes les requêtes authentifiées avec JWT Supabase,
- backend re-fetch le `creator_profile` si nécessaire,
- backend appelle OpenAI,
- backend valide le JSON,
- backend écrit en DB si endpoint “generate-and-save”.

## 7.1 POST `/api/v1/daily-idea`

### Input JSON
```json
{
  "user_id": "uuid",
  "creator_profile": {
    "niche": "business",
    "primary_platform": "instagram",
    "goal": "followers",
    "desired_tone": "authentique",
    "level": "debutant",
    "frequency_per_week": 4,
    "preferred_formats": ["face_cam", "conseils"],
    "language": "fr",
    "country": "FR"
  },
  "recent_growth": {
    "top_format": "reel",
    "regularity_rate": 40,
    "main_insight": "les conseils courts fonctionnent mieux"
  }
}
```

### Output JSON
```json
{
  "idea_date": "2026-03-19",
  "idea_title": "string",
  "why_now": "string",
  "topic": "string",
  "angle": "string",
  "hook": "string",
  "content_structure": ["string", "string", "string"],
  "caption": "string",
  "cta": "string",
  "hashtags": ["#one", "#two"],
  "recommended_format": "reel",
  "recommended_time": "18:00-19:00",
  "engagement_mission": "string",
  "effort_level": "low",
  "confidence_note": "string"
}
```

### Backend behavior
1. validate payload
2. call OpenAI
3. validate strict JSON
4. upsert `daily_ideas` by `(user_id, idea_date)`
5. return payload

## 7.2 POST `/api/v1/weekly-plan`

### Input JSON
```json
{
  "user_id": "uuid",
  "creator_profile": {
    "niche": "business",
    "primary_platform": "instagram",
    "goal": "followers",
    "desired_tone": "authentique",
    "level": "debutant",
    "frequency_per_week": 4,
    "preferred_formats": ["conseils"],
    "language": "fr",
    "country": "FR"
  }
}
```

### Output JSON
```json
{
  "week_start": "2026-03-16",
  "week_theme": "string",
  "coach_note": "string",
  "days": [
    {
      "day_index": 1,
      "platform": "instagram",
      "objective": "followers",
      "format": "reel",
      "topic": "string",
      "angle": "string",
      "tone": "authentique",
      "time_window": "18:00-19:00",
      "engagement_task": "string",
      "effort": "low",
      "status": "planned"
    }
  ]
}
```

### Backend behavior
1. validate payload
2. generate plan
3. upsert `weekly_plans`
4. delete old `weekly_plan_items` for that week
5. insert 7 new `weekly_plan_items`
6. return full plan

## 7.3 POST `/api/v1/weekly-plan/replacement`

### Input JSON
```json
{
  "user_id": "uuid",
  "weekly_plan_item_id": "uuid",
  "creator_profile": {"primary_platform": "instagram", "goal": "followers", "desired_tone": "authentique", "niche": "business", "level": "debutant", "frequency_per_week": 4, "preferred_formats": [], "language": "fr", "country": "FR"}
}
```

### Output JSON
```json
{
  "weekly_plan_item_id": "uuid",
  "platform": "instagram",
  "objective": "followers",
  "format": "reel",
  "topic": "string",
  "angle": "string",
  "tone": "authentique",
  "time_window": "18:00-19:00",
  "engagement_task": "string",
  "effort": "low",
  "status": "replaced"
}
```

## 7.4 POST `/api/v1/generate-content`

### Input JSON
```json
{
  "user_id": "uuid",
  "creator_profile": {
    "niche": "business",
    "primary_platform": "instagram",
    "goal": "followers",
    "desired_tone": "authentique",
    "level": "debutant",
    "frequency_per_week": 4,
    "preferred_formats": ["face_cam"],
    "language": "fr",
    "country": "FR"
  },
  "brief": "Je veux un Reel court sur l'erreur n°1 des freelances qui veulent mieux vendre.",
  "platform": "instagram",
  "format": "reel",
  "tone": "authentique"
}
```

### Output JSON
```json
{
  "hooks": ["string", "string", "string"],
  "caption": "string",
  "script": "string",
  "hashtags": ["#one", "#two"],
  "cta": "string",
  "tone_variants": [
    {"tone": "expert", "text": "string"},
    {"tone": "direct", "text": "string"}
  ]
}
```

### Backend behavior
1. validate payload
2. call OpenAI
3. validate output
4. insert `content_generations`
5. return payload + generated id if needed

## 7.5 POST `/api/v1/growth-insight`

### Input JSON
```json
{
  "user_id": "uuid",
  "baseline": {
    "followers_baseline": 100,
    "engagement_baseline": 2.1,
    "posts_baseline": 4
  },
  "latest_growth": {
    "followers_total": 145,
    "engagement_rate": 3.2,
    "posts_count": 9,
    "regularity_rate": 71,
    "top_format": "reel"
  }
}
```

### Output JSON
```json
{
  "wins": ["string", "string"],
  "weak_signals": ["string"],
  "actions_next_week": ["string", "string", "string"],
  "main_insight": "string"
}
```

### Backend behavior
1. compare baseline/latest
2. generate insight
3. optionally update latest `growth_snapshots.main_insight`
4. return JSON

## 7.6 POST `/api/v1/subscriptions/sync`

### Input JSON
```json
{
  "user_id": "uuid",
  "plan_name": "pro",
  "status": "active",
  "started_at": "2026-03-19T10:00:00Z",
  "expires_at": "2026-04-19T10:00:00Z",
  "provider_customer_id": "rc_customer_123",
  "provider_subscription_id": "sub_123"
}
```

### Output JSON
```json
{
  "ok": true
}
```

---

## 8. Prompts IA API-ready

> Tous les prompts doivent être exécutés côté backend. Toujours forcer une réponse JSON stricte, puis valider avec un parser JSON + schéma.

## 8.1 Daily Idea

### Prompt système
```text
Tu es le Daily Idea Engine de Viral Studio.
Tu aides un créateur à savoir quoi poster aujourd'hui.
Tu dois produire UNE idée du jour claire, spécifique, adaptée à sa niche, sa plateforme, son ton, son niveau et son objectif.
Tu privilégies la simplicité, la clarté et l'exécution rapide.
Tu ne promets jamais la viralité.
Tu réponds strictement en JSON valide correspondant exactement au schéma demandé.
```

### Variables
- niche
- primary_platform
- goal
- desired_tone
- level
- frequency_per_week
- preferred_formats
- language
- country
- recent_growth optional

### Format JSON strict attendu
```json
{
  "idea_title": "string",
  "why_now": "string",
  "topic": "string",
  "angle": "string",
  "hook": "string",
  "content_structure": ["string", "string", "string"],
  "caption": "string",
  "cta": "string",
  "hashtags": ["#string"],
  "recommended_format": "string",
  "recommended_time": "string",
  "engagement_mission": "string",
  "effort_level": "low|medium|high",
  "confidence_note": "string"
}
```

### Erreurs à éviter
- idée générique sans angle,
- hook cliché,
- contenu trop complexe pour débutant,
- hashtags ultra génériques uniquement.

### Exemple d’entrée user prompt
```json
{
  "creator_profile": {
    "niche": "business freelance",
    "primary_platform": "instagram",
    "goal": "followers",
    "desired_tone": "authentique",
    "level": "debutant",
    "frequency_per_week": 4,
    "preferred_formats": ["face_cam", "conseils"],
    "language": "fr",
    "country": "FR"
  },
  "recent_growth": {
    "top_format": "reel",
    "regularity_rate": 40,
    "main_insight": "les conseils simples performent mieux que les posts inspirationnels"
  }
}
```

### Exemple de sortie
```json
{
  "idea_title": "L'erreur n°1 qui fait perdre du temps aux freelances",
  "why_now": "Votre audience réagit mieux aux conseils simples et vous avez besoin d'un format rapide à produire cette semaine.",
  "topic": "erreur de positionnement freelance",
  "angle": "montrer une erreur fréquente puis donner un correctif simple",
  "hook": "Si vous êtes freelance et que vous publiez sans angle clair, vous faites probablement cette erreur.",
  "content_structure": [
    "nommer l'erreur",
    "expliquer pourquoi elle coûte cher",
    "donner une correction simple"
  ],
  "caption": "Beaucoup de freelances postent sans savoir ce qu'ils veulent déclencher. Résultat : du contenu visible mais peu mémorable. Voici l'erreur que je vois le plus, et comment la corriger simplement.",
  "cta": "Si vous voulez, je peux faire une partie 2 avec d'autres erreurs à éviter.",
  "hashtags": ["#freelance", "#personalbranding", "#contenuinstagram"],
  "recommended_format": "reel",
  "recommended_time": "18:00-19:00",
  "engagement_mission": "Répondez aux 5 premiers commentaires dans l'heure.",
  "effort_level": "low",
  "confidence_note": "Bon fit avec votre rythme et vos formats les plus naturels."
}
```

## 8.2 Weekly Plan

### Prompt système
```text
Tu es le Planning Engine de Viral Studio.
Tu dois produire un plan 7 jours réaliste pour un créateur.
Le plan doit être actionnable, simple à suivre, aligné au niveau, au temps disponible, à la plateforme principale et à l'objectif.
Chaque jour doit contenir une vraie action éditoriale ou d'engagement.
Tu réponds strictement en JSON valide.
```

### Format JSON strict attendu
```json
{
  "week_theme": "string",
  "coach_note": "string",
  "days": [
    {
      "day_index": 1,
      "platform": "string",
      "objective": "string",
      "format": "string",
      "topic": "string",
      "angle": "string",
      "tone": "string",
      "time_window": "string",
      "engagement_task": "string",
      "effort": "low|medium|high",
      "status": "planned"
    }
  ]
}
```

### Erreurs à éviter
- plan trop dense,
- répétition du même sujet 7 fois,
- pas de mission d’engagement,
- pas de logique débutant.

## 8.3 Generate Content

### Prompt système
```text
Tu es le Content Engine de Viral Studio.
Tu transformes un brief simple en contenu prêt à publier.
Tu dois produire des hooks, une caption, un script, des hashtags, un CTA et deux variantes de ton.
Le résultat doit être naturel, spécifique et aligné au profil créateur.
Tu réponds strictement en JSON valide.
```

### Format JSON strict attendu
```json
{
  "hooks": ["string", "string", "string"],
  "caption": "string",
  "script": "string",
  "hashtags": ["#string"],
  "cta": "string",
  "tone_variants": [
    {
      "tone": "string",
      "text": "string"
    }
  ]
}
```

### Erreurs à éviter
- texte trop robotique,
- hashtags non reliés au sujet,
- script trop long,
- ton qui ne colle pas à la niche.

## 8.4 Growth Insight

### Prompt système
```text
Tu es l'Insight Engine de Viral Studio.
Tu analyses une baseline et un snapshot de croissance actuel.
Tu dois expliquer en langage simple ce qui progresse, ce qui stagne et quelle est la prochaine meilleure action.
Tu ne sur-interprètes pas les données.
Tu réponds strictement en JSON valide.
```

### Format JSON strict attendu
```json
{
  "wins": ["string"],
  "weak_signals": ["string"],
  "actions_next_week": ["string"],
  "main_insight": "string"
}
```

### Erreurs à éviter
- conclusions absolues sur peu de données,
- langage analytique trop abstrait,
- conseils impossibles à exécuter.

---

## 9. Build sprint par sprint

## Sprint 1 — Auth + onboarding + profils

### Objectifs
- auth fonctionnelle,
- onboarding complet,
- création du creator_profile,
- bootstrap app.

### Écrans concernés
- SplashPage
- AuthPage
- OnboardingStep* pages
- OnboardingSummaryPage

### Backend concerné
- Supabase Auth
- table `creator_profiles`
- endpoint `/daily-idea`
- endpoint `/weekly-plan`

### Tests à faire
- signup Google ok,
- onboarding complet écrit bien en DB,
- summary charge bien profile + daily idea,
- plan 7 jours créé correctement.

### Risques
- complexité du loop d’insert weekly items dans FlutterFlow,
- erreurs de parsing JSON.

### Solution
Faire persister `weekly_plans` + `weekly_plan_items` côté backend, pas côté front.

## Sprint 2 — Daily idea + Home

### Objectifs
- Home utile et clair,
- daily idea consultable,
- régénération fonctionnelle.

### Écrans concernés
- HomePage
- DailyIdeaPage

### Backend concerné
- `daily_ideas`
- queries current week

### Tests à faire
- home charge sur user complet,
- fallback si daily idea absente,
- regenerate upsert correctement la row du jour.

### Risques
- home trop vide si pas de data.

### Solution
fallbacks basés sur weekly plan + messages pédagogiques.

## Sprint 3 — Weekly plan

### Objectifs
- afficher le plan 7 jours,
- marquer des items comme faits,
- remplacer un item,
- envoyer vers Create.

### Écrans concernés
- Plan7DaysPage
- ReplacePlanItemSheet

### Backend concerné
- `weekly_plans`
- `weekly_plan_items`
- `/weekly-plan/replacement`

### Tests à faire
- update status done,
- replacement update la bonne row,
- navigate to Create avec pré-remplissage.

## Sprint 4 — Create

### Objectifs
- générateur IA complet,
- stockage historique,
- copy/save/variants.

### Écrans concernés
- CreatePage

### Backend concerné
- `content_generations`
- `/generate-content`

### Tests à faire
- validation brief,
- génération JSON valide,
- historique bien écrit,
- switching tabs sans perte d’état.

### Risques
- erreurs JSON OpenAI,
- longueur excessive des sorties.

### Solution
parser strict + retries backend + max tokens contrôlés.

## Sprint 5 — Growth + baseline + before/after

### Objectifs
- formulaire manuel de stats,
- growth dashboard simple,
- before/after exploitable,
- growth insight.

### Écrans concernés
- GrowthPage
- BeforeAfterPage
- ManualStatsSheet

### Backend concerné
- `growth_snapshots`
- `baseline_snapshots`
- `/growth-insight`

### Tests à faire
- insert baseline première fois,
- nouveaux snapshots calculent bien le delta,
- before/after fonctionne sans API sociale.

### Risques
- confusion baseline/latest,
- manque de données au début.

### Solution
UX claire : “entrez vos stats actuelles pour démarrer le suivi”.

## Sprint 6 — Pricing + polish + beta

### Objectifs
- pricing screen,
- RevenueCat ou fallback manuel,
- design polish,
- QA complète,
- beta privée TestFlight / APK.

### Écrans concernés
- PricingPage
- SettingsPage
- PaywallSheet

### Backend concerné
- `subscriptions`
- `/subscriptions/sync`

### Tests à faire
- accès pro simulé,
- logout/login conserve les données,
- app state cohérent entre sessions,
- QA navigation complète.

### Risques
- RevenueCat peut ralentir la release.

### Solution
fallback temporaire : abonnement manuel en beta.

---

## 10. Données à simuler manuellement au début

### À simuler en MVP beta
- growth stats sociales réelles,
- followers initiaux,
- engagement estimé,
- posts du mois,
- top format,
- main insight si peu de données.

### Comment les simuler
- formulaire manuel dans GrowthPage,
- seed data dans Supabase pour comptes tests,
- quelques `daily_ideas` et `weekly_plan_items` générées en staging.

### À ne pas bloquer pour lancer
- analytics connectées Instagram/TikTok,
- autopost,
- commentaires sync,
- tendances live.

---

## 11. Pièges à éviter

1. **Faire trop d’intégrations dès le départ**. Le MVP doit survivre sans API sociales.
2. **Appeler OpenAI directement depuis FlutterFlow**. Toujours passer par backend sécurisé.
3. **Laisser FlutterFlow gérer toute la logique complexe de persistance**. Préférer backend pour `/weekly-plan` et `/daily-idea`.
4. **Surpromettre la mesure de croissance**. Le MVP doit d’abord accepter les stats manuelles.
5. **Créer trop de pages secondaires**. Le cœur doit rester Home, Daily Idea, Plan, Create, Growth.
6. **Sous-estimer la validation JSON**. Toujours parser et rejeter les réponses incomplètes.
7. **Mélanger auth, RLS et service role sans discipline**. Le front doit rester en RLS user-scoped, le backend service-role pour écritures orchestrées.
8. **Oublier les empty states**. Ils sont essentiels quand l’utilisateur n’a encore aucune donnée.
9. **Rendre Home dépendant de trop de requêtes**. Garder 4-5 queries max et utiliser fallbacks.
10. **Retarder la beta pour RevenueCat ou les graphes**. Lancer avec une version fonctionnelle même si l’abonnement est semi-manuel.

---

## 12. Recommandations finales de build

### Recommandation 1
Dans FlutterFlow, construis d’abord la navigation, les App States et les pages statiques avant de brancher les APIs.

### Recommandation 2
Déporte la logique métier dans 4 endpoints seulement au début :
- `/daily-idea`
- `/weekly-plan`
- `/generate-content`
- `/growth-insight`

### Recommandation 3
Fais écrire le backend dans Supabase pour les flows complexes. FlutterFlow doit surtout :
- afficher,
- saisir,
- appeler,
- naviguer.

### Recommandation 4
Pour la beta, accepte les stats manuelles. C’est suffisant pour valider la promesse de progression visible.

### Recommandation 5
Si le temps manque, coupe dans cet ordre :
1. RevenueCat réel,
2. replacement avancé du plan,
3. variants de ton multiples,
4. sharing before/after.

### Recommandation 6
Ne coupe pas :
- onboarding,
- daily idea,
- plan 7 jours,
- create,
- growth simple,
- before/after.

### Recommandation finale
Le bon MVP Viral Studio n’est pas celui qui fait “le plus”. C’est celui qui fait vivre rapidement cette phrase au créateur :

**“Je sais quoi faire aujourd’hui, je peux le créer vite, et je vois enfin que j’avance.”**
