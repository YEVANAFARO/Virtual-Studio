# Viral Studio — MVP Construction Pack

> Source de vérité d’exécution. Scope MVP strict. Pas de stratégie, uniquement de la construction.

---

## 1. SQL Supabase complet

### Fichier SQL à appliquer
Utiliser directement :
- `supabase/migrations/20260319_001_viral_studio_mvp.sql`

### Tables à créer
- `creator_profiles`
- `daily_ideas`
- `weekly_plans`
- `weekly_plan_items`
- `content_generations`
- `growth_snapshots`
- `baseline_snapshots`
- `subscriptions`

### Relations à conserver
- `creator_profiles.user_id -> auth.users.id`
- `daily_ideas.user_id -> auth.users.id`
- `weekly_plans.user_id -> auth.users.id`
- `weekly_plan_items.weekly_plan_id -> weekly_plans.id`
- `content_generations.user_id -> auth.users.id`
- `growth_snapshots.user_id -> auth.users.id`
- `baseline_snapshots.user_id -> auth.users.id`
- `subscriptions.user_id -> auth.users.id`

### Contraintes à conserver
- `creator_profiles.user_id` unique
- `daily_ideas (user_id, idea_date)` unique
- `weekly_plans (user_id, week_start)` unique
- `weekly_plan_items (weekly_plan_id, day_index)` unique
- `growth_snapshots (user_id, snapshot_date)` unique
- `baseline_snapshots (user_id, baseline_date)` unique

### Index à garder
- `idx_daily_ideas_user_date`
- `idx_weekly_plans_user_week`
- `idx_weekly_plan_items_plan`
- `idx_content_generations_user_created`
- `idx_growth_snapshots_user_date`
- `idx_baseline_snapshots_user_date`
- `idx_subscriptions_user_status`

### updated_at
- trigger `set_updated_at()` déjà créé
- appliqué sur `creator_profiles`
- appliqué sur `subscriptions`

### RLS simple par utilisateur
Règle : le front FlutterFlow ne lit, insère et modifie que les lignes du user connecté.
Le backend IA peut utiliser un service role pour écrire si besoin.

### Décision MVP stricte
Ne pas créer d’autres tables tant que le flow principal n’est pas stable.
Pas de tables trends, comments, posts publiés ou benchmarks en V1.

---

## 2. Endpoints API

### Règles communes backend
- préfixe : `/api/v1`
- auth via JWT Supabase
- backend appelle OpenAI
- sortie JSON strictement validée
- logs avec `request_id`
- timeout max 20 secondes
- si JSON invalide : 1 retry IA max, puis erreur propre

## 2.1 POST `/api/v1/daily-idea`

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
    "regularity_rate": 50,
    "main_insight": "les conseils simples performent le mieux"
  }
}
```

### Output JSON
```json
{
  "idea_date": "2026-03-20",
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

### Comportement backend attendu
1. vérifier auth
2. valider payload
3. appeler OpenAI
4. parser JSON strict
5. upsert `daily_ideas`
6. retourner le JSON final

## 2.2 POST `/api/v1/weekly-plan`

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

### Comportement backend attendu
1. vérifier auth
2. calculer `week_start`
3. appeler OpenAI
4. upsert `weekly_plans`
5. supprimer anciens `weekly_plan_items` de la semaine
6. insérer 7 nouveaux items
7. retourner le plan complet

## 2.3 POST `/api/v1/generate-content`

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
  "hashtags": ["#string"],
  "cta": "string",
  "tone_variants": [
    {"tone": "expert", "text": "string"},
    {"tone": "direct", "text": "string"}
  ]
}
```

### Comportement backend attendu
1. vérifier auth
2. valider payload
3. appeler OpenAI
4. parser JSON strict
5. insérer `content_generations`
6. retourner résultat

## 2.4 POST `/api/v1/growth-insight`

### Input JSON
```json
{
  "user_id": "uuid",
  "baseline": {
    "followers_baseline": 100,
    "engagement_baseline": 2.0,
    "posts_baseline": 3
  },
  "latest_growth": {
    "followers_total": 142,
    "engagement_rate": 2.9,
    "posts_count": 8,
    "regularity_rate": 75,
    "top_format": "reel"
  }
}
```

### Output JSON
```json
{
  "wins": ["string"],
  "weak_signals": ["string"],
  "actions_next_week": ["string"],
  "main_insight": "string"
}
```

### Comportement backend attendu
1. vérifier auth
2. comparer baseline et latest
3. appeler OpenAI
4. parser JSON
5. retourner l’insight

---

## 3. Prompts IA

## 3.1 Prompt Daily Idea

### Prompt système
```text
Tu es le Daily Idea Engine de Viral Studio.
Tu aides un créateur à savoir quoi poster aujourd'hui.
Tu produis UNE idée claire, spécifique, faisable aujourd'hui, adaptée à sa niche, sa plateforme, son ton, son niveau et son objectif.
Tu ne promets jamais la viralité.
Tu réponds strictement en JSON valide.
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

### JSON strict
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
- idée générique
- pas d’angle
- contenu trop complexe
- pas de CTA

### Exemple input
```json
{
  "creator_profile": {
    "niche": "freelance branding",
    "primary_platform": "instagram",
    "goal": "followers",
    "desired_tone": "authentique",
    "level": "debutant",
    "frequency_per_week": 4,
    "preferred_formats": ["face_cam"],
    "language": "fr",
    "country": "FR"
  }
}
```

### Exemple output
```json
{
  "idea_title": "L'erreur qui rend un freelance invisible",
  "why_now": "Votre audience a besoin d'un conseil simple et rapide à consommer.",
  "topic": "erreur de visibilité freelance",
  "angle": "montrer une erreur courante puis donner un correctif simple",
  "hook": "Si vous êtes freelance et que vous postez sans angle clair, vous faites probablement cette erreur.",
  "content_structure": [
    "nommer l'erreur",
    "expliquer pourquoi elle bloque",
    "donner un correctif simple"
  ],
  "caption": "Beaucoup de freelances publient sans savoir ce qu'ils veulent déclencher. Voici l'erreur que je vois le plus, et comment la corriger simplement.",
  "cta": "Si vous voulez, je peux faire une partie 2 avec d'autres erreurs à éviter.",
  "hashtags": ["#freelance", "#branding", "#instagrambusiness"],
  "recommended_format": "reel",
  "recommended_time": "18:00-19:00",
  "engagement_mission": "Répondez aux 5 premiers commentaires dans l'heure.",
  "effort_level": "low",
  "confidence_note": "Très bon fit avec un format face cam court."
}
```

## 3.2 Prompt Weekly Plan

### Prompt système
```text
Tu es le Weekly Planning Engine de Viral Studio.
Tu construis un plan 7 jours réaliste, simple, actionnable, cohérent avec le niveau, le temps disponible et l'objectif du créateur.
Tu réponds strictement en JSON valide.
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

### JSON strict
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
- plan trop dense
- 7 posts quasi identiques
- aucune mission d’engagement

### Exemple input
```json
{
  "creator_profile": {
    "niche": "coaching bien-être",
    "primary_platform": "instagram",
    "goal": "visibility",
    "desired_tone": "inspirant",
    "level": "debutant",
    "frequency_per_week": 4,
    "preferred_formats": ["conseils", "storytelling"],
    "language": "fr",
    "country": "FR"
  }
}
```

### Exemple output
```json
{
  "week_theme": "Se rendre identifiable en 7 jours",
  "coach_note": "Cette semaine, on cherche surtout la régularité et la clarté, pas la perfection.",
  "days": [
    {
      "day_index": 1,
      "platform": "instagram",
      "objective": "visibility",
      "format": "reel",
      "topic": "erreur bien-être courante",
      "angle": "conseil simple",
      "tone": "inspirant",
      "time_window": "18:00-19:00",
      "engagement_task": "Répondre à 5 stories de comptes de niche.",
      "effort": "low",
      "status": "planned"
    }
  ]
}
```

## 3.3 Prompt Generate Content

### Prompt système
```text
Tu es le Content Generation Engine de Viral Studio.
Tu transformes un brief simple en contenu prêt à publier.
Tu génères des hooks, une caption, un script court, des hashtags, un CTA et deux variantes de ton.
Tu réponds strictement en JSON valide.
```

### Variables
- creator_profile
- brief
- platform
- format
- tone

### JSON strict
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
- ton robotique
- hashtags sans niche
- script trop long

### Exemple input
```json
{
  "creator_profile": {
    "niche": "design freelance",
    "primary_platform": "linkedin",
    "goal": "clients",
    "desired_tone": "expert",
    "level": "intermediaire",
    "frequency_per_week": 3,
    "preferred_formats": ["conseils"],
    "language": "fr",
    "country": "FR"
  },
  "brief": "post sur l'erreur de branding qui fait perdre des clients premium",
  "platform": "linkedin",
  "format": "post",
  "tone": "expert"
}
```

### Exemple output
```json
{
  "hooks": [
    "L'erreur de branding la plus chère chez les freelances.",
    "Pourquoi certains freelances repoussent les clients premium sans le voir.",
    "Votre branding ne manque peut-être pas de style, mais de clarté."
  ],
  "caption": "Beaucoup de freelances pensent que leur problème est le manque de visibilité. Souvent, c'est surtout un problème de lisibilité.",
  "script": "Voici l'erreur que je vois le plus : un branding joli mais flou. Si votre promesse n'est pas claire en 3 secondes, vous perdez les bons clients avant même la conversation.",
  "hashtags": ["#branding", "#freelance", "#positionnement"],
  "cta": "Si vous voulez, je peux faire un post sur les 3 signaux d'un branding flou.",
  "tone_variants": [
    {"tone": "direct", "text": "Votre branding n'est pas faible. Il est flou."},
    {"tone": "authentique", "text": "J'ai longtemps cru que mes clients voulaient plus de style. En réalité, ils voulaient surtout plus de clarté."}
  ]
}
```

## 3.4 Prompt Growth Insight

### Prompt système
```text
Tu es le Growth Insight Engine de Viral Studio.
Tu analyses une baseline et un snapshot récent.
Tu produis des constats simples, prudents et actionnables.
Tu réponds strictement en JSON valide.
```

### Variables
- baseline
- latest_growth

### JSON strict
```json
{
  "wins": ["string"],
  "weak_signals": ["string"],
  "actions_next_week": ["string"],
  "main_insight": "string"
}
```

### Erreurs à éviter
- surinterpréter avec peu de données
- conseils trop vagues
- ton trop analytique

### Exemple input
```json
{
  "baseline": {
    "followers_baseline": 100,
    "engagement_baseline": 2.0,
    "posts_baseline": 3
  },
  "latest_growth": {
    "followers_total": 142,
    "engagement_rate": 2.9,
    "posts_count": 8,
    "regularity_rate": 75,
    "top_format": "reel"
  }
}
```

### Exemple output
```json
{
  "wins": [
    "Votre régularité est nettement meilleure qu'au départ.",
    "Les formats courts semblent mieux soutenir votre progression actuelle."
  ],
  "weak_signals": [
    "Vous manquez encore de recul pour isoler une tonalité gagnante certaine."
  ],
  "actions_next_week": [
    "Répéter un Reel conseil proche de votre meilleur format.",
    "Maintenir un post à faible effort pour garder la cadence.",
    "Noter les questions qui reviennent pour inspirer le prochain plan."
  ],
  "main_insight": "Votre progression actuelle semble surtout tirée par une meilleure régularité et des contenus plus simples à consommer."
}
```

---

## 4. Structure FlutterFlow

### Arborescence des pages
- SplashPage
- AuthPage
- OnboardingStepGoalPage
- OnboardingStepPlatformPage
- OnboardingStepNichePage
- OnboardingStepTonePage
- OnboardingStepLevelPage
- OnboardingStepFrequencyPage
- OnboardingSummaryPage
- MainNavPage
  - HomePage
  - Plan7DaysPage
  - CreatePage
  - GrowthPage
  - SettingsPage
- DailyIdeaPage
- BeforeAfterPage
- PricingPage
- ReplacePlanItemBottomSheet
- ManualStatsBottomSheet

### Navigation
- Splash → Auth ou Onboarding ou MainNav selon session/profil
- Auth → Onboarding ou MainNav
- Onboarding steps → OnboardingSummary → MainNav/Home
- Home → DailyIdea / Create / Plan / Growth
- Growth → BeforeAfter / Pricing
- Settings → Pricing / Logout

### App State
- `onboardingGoal`
- `onboardingPlatform`
- `onboardingNiche`
- `onboardingTone`
- `onboardingLevel`
- `onboardingFrequency`
- `selectedCreatePlatform`
- `selectedCreateFormat`
- `selectedCreateTone`
- `generatedHooks`
- `generatedCaption`
- `generatedScript`
- `generatedHashtags`
- `generatedCTA`
- `generatedToneVariants`

### Queries Supabase
#### Splash / Auth
- `creator_profiles` by current user

#### OnboardingSummary
- `creator_profiles`
- `daily_ideas` today

#### Home
- `creator_profiles`
- `daily_ideas` today
- `weekly_plans` current week
- `weekly_plan_items` current week
- `growth_snapshots` latest

#### DailyIdea
- `daily_ideas` today

#### Create
- insert/update `content_generations`

#### Plan7Days
- `weekly_plans` current week
- `weekly_plan_items` linked

#### Growth
- `baseline_snapshots` latest
- `growth_snapshots` latest/all

#### Settings / Pricing
- `subscriptions` latest

### Actions principales par page
- Splash : auth check + redirect
- OnboardingStepFrequency : upsert profile + call `/daily-idea` + call `/weekly-plan` + navigate summary
- Home : ouvrir DailyIdea / Plan / Create / Growth
- DailyIdea : regenerate / open Create prefilled
- Create : call `/generate-content` + save generation
- Plan7Days : mark done / replace / open Create prefilled
- Growth : save manual stats / open BeforeAfter
- Pricing : RevenueCat
- Settings : update profile / logout

---

## 5. Écrans page par page

## 5.1 SplashPage

### Widgets exacts
- Container full screen
- Center
- Column
- Logo
- Text Viral Studio
- Tagline
- Loader

### Ordre des blocs
1. logo
2. titre
3. tagline
4. loader

### Actions des boutons
Aucun bouton.

### États
- loading : loader visible
- error : snackbar + fallback vers Auth

## 5.2 AuthPage

### Widgets exacts
- Text titre
- Text sous-titre
- TextField email
- TextField mot de passe
- Button Google
- Button créer compte
- Button se connecter

### Actions boutons
- signup/login Supabase Auth
- puis fetch profile
- puis redirection intelligente

### États
- loading : boutons désactivés
- error : message auth simple

## 5.3 OnboardingStepGoalPage

### Widgets exacts
- Progress bar
- Question
- Choice chips objectifs
- Button Continuer

### Actions boutons
- set `onboardingGoal`
- navigate `OnboardingStepPlatformPage`

### États
- disable CTA si rien n’est choisi

## 5.4 OnboardingStepPlatformPage

### Widgets exacts
- Question
- Cartes plateformes
- Button Continuer

### Actions boutons
- set `onboardingPlatform`
- navigate `OnboardingStepNichePage`

## 5.5 OnboardingStepNichePage

### Widgets exacts
- Question
- TextField niche
- Suggestions
- Button Continuer

### Actions boutons
- set `onboardingNiche`
- navigate `OnboardingStepTonePage`

## 5.6 OnboardingStepTonePage

### Widgets exacts
- Choix de ton
- Button Continuer

### Actions boutons
- set `onboardingTone`
- navigate `OnboardingStepLevelPage`

## 5.7 OnboardingStepLevelPage

### Widgets exacts
- Choix niveau
- Button Continuer

### Actions boutons
- set `onboardingLevel`
- navigate `OnboardingStepFrequencyPage`

## 5.8 OnboardingStepFrequencyPage

### Widgets exacts
- Choix fréquence
- Button Construire ma stratégie

### Actions boutons
1. upsert `creator_profiles`
2. call `/api/v1/daily-idea`
3. insert `daily_ideas`
4. call `/api/v1/weekly-plan`
5. insert `weekly_plans`
6. insert `weekly_plan_items`
7. navigate `OnboardingSummaryPage`

### États
- loading overlay pendant la construction
- error API avec retry manuel

## 5.9 OnboardingSummaryPage

### Widgets exacts
- Card profil
- Card 3 opportunités
- Preview idée du jour
- Button Ouvrir mon studio

### Actions boutons
- navigate Home

### États
- loading skeletons
- si no daily idea : CTA régénérer

## 5.10 HomePage

### Widgets exacts
- Header bonjour
- Card momentum
- Card action du jour
- Card idée du jour preview
- Card mini progression
- Accès rapides vers Plan / Create / Growth
- Bottom nav

### Actions boutons
- Créer maintenant → DailyIdea
- Voir détail → DailyIdea
- Aller au plan → Plan7Days
- Aller à Growth → Growth

### États
- no idea → CTA générer idée
- no growth → CTA ajouter stats

## 5.11 DailyIdeaPage

### Widgets exacts
- Titre idée
- Why now
- Hook
- Structure
- Caption
- Hashtags
- Format
- Heure
- Mission engagement
- Boutons : créer / script / calendrier / régénérer

### Actions boutons
- régénérer = call `/api/v1/daily-idea` puis update row
- en faire un script = navigate Create avec params
- créer ce contenu = navigate Create prérempli

### États
- loading query
- error regenerate

## 5.12 CreatePage

### Widgets exacts
- Dropdown plateforme
- Dropdown format
- Choix ton
- Brief textfield
- Button Générer
- Tabs Hooks / Caption / Script / Hashtags / CTA
- Buttons sauvegarder / copier / variantes

### Actions boutons
1. call `/api/v1/generate-content`
2. set App State
3. insert `content_generations`
4. save / copy / regenerate variant

### États
- empty state avec exemples
- loading generation
- error JSON/API

## 5.13 Plan7DaysPage

### Widgets exacts
- Thème semaine
- Liste 7 cartes
- Chaque carte : jour / plateforme / format / sujet / angle / ton / créneau / mission / effort / status
- Boutons : fait / remplacer / générer brouillon

### Actions boutons
- fait = update status
- générer brouillon = navigate Create
- remplacer = call API simple ou régénération guidée

### États
- no plan → CTA générer plan

## 5.14 GrowthPage

### Widgets exacts
- KPI row
- Line chart
- Top format
- Main insight
- Button Voir avant / après
- Formulaire manuel si pas de données

### Actions boutons
- si pas baseline → insert `baseline_snapshots`
- insert `growth_snapshots`
- navigate BeforeAfter

### États
- no data → show manual form
- loading chart

## 5.15 BeforeAfterPage

### Widgets exacts
- Hero card
- Comparaison avant / maintenant
- Delta chips
- Timeline progression
- Buttons partager / préparer prochain mois

### Actions boutons
- partager : beta simple ou désactivé
- préparer prochain mois : retour Growth ou Plan

## 5.16 PricingPage

### Widgets exacts
- Hero
- Cards Free / Pro / Growth
- Bénéfices
- CTA abonnement

### Actions boutons
- RevenueCat
- update `subscriptions`

## 5.17 SettingsPage

### Widgets exacts
- Résumé profil
- Modifier niche
- Modifier ton
- Modifier fréquence
- Abonnement
- Logout

### Actions boutons
- update `creator_profiles`
- navigate Pricing
- logout
