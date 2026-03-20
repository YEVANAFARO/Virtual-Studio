# Viral Studio — CTO Build Pack MVP

> Document d’exécution orienté build. Scope strict. V1 testable en 30 jours.

---

## 1. SQL Supabase

### Fichier source exécutable
Le SQL complet du MVP est versionné ici :
- `supabase/migrations/20260319_001_viral_studio_mvp.sql`

### Ce que la migration crée
- tables métier du MVP,
- contraintes `check`,
- index de lecture fréquente,
- gestion `updated_at`,
- RLS simple par utilisateur,
- policies d’accès `select / insert / update`,
- contrôle de propriété pour `weekly_plan_items` via `weekly_plans`.

### Tables créées
1. `creator_profiles`
2. `daily_ideas`
3. `weekly_plans`
4. `weekly_plan_items`
5. `content_generations`
6. `growth_snapshots`
7. `baseline_snapshots`
8. `subscriptions`

### Relations
- `creator_profiles.user_id -> auth.users.id`
- `daily_ideas.user_id -> auth.users.id`
- `weekly_plans.user_id -> auth.users.id`
- `weekly_plan_items.weekly_plan_id -> weekly_plans.id`
- `content_generations.user_id -> auth.users.id`
- `growth_snapshots.user_id -> auth.users.id`
- `baseline_snapshots.user_id -> auth.users.id`
- `subscriptions.user_id -> auth.users.id`

### Contraintes importantes
- `creator_profiles.user_id` unique.
- `daily_ideas` unique par `(user_id, idea_date)`.
- `weekly_plans` unique par `(user_id, week_start)`.
- `weekly_plan_items` unique par `(weekly_plan_id, day_index)`.
- `growth_snapshots` unique par `(user_id, snapshot_date)`.
- `baseline_snapshots` unique par `(user_id, baseline_date)`.

### Index à conserver
- `daily_ideas(user_id, idea_date desc)`
- `weekly_plans(user_id, week_start desc)`
- `weekly_plan_items(weekly_plan_id, day_index)`
- `content_generations(user_id, created_at desc)`
- `growth_snapshots(user_id, snapshot_date desc)`
- `baseline_snapshots(user_id, baseline_date desc)`
- `subscriptions(user_id, status)`

### updated_at
- trigger `set_updated_at()` déjà prévu dans la migration.
- appliqué sur `creator_profiles` et `subscriptions`.

### RLS minimal recommandé
Règle unique : chaque utilisateur ne voit et ne modifie que ses lignes.
- front FlutterFlow en JWT Supabase user
- backend IA avec service role pour orchestration si nécessaire

### Décision CTO
Ne pas ajouter d’autres tables en MVP.
Pas de table `posts`, pas de table `comments`, pas de table `trends` en V1.

---

## 2. Endpoints API

### Règles backend communes
- tous les endpoints sous `/api/v1`
- auth par JWT Supabase
- OpenAI uniquement côté backend
- validation JSON stricte en entrée et sortie
- logs avec `request_id`
- timeout 20s max
- retries IA limités à 1

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
    "main_insight": "les contenus conseils sont les plus naturels"
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
  "recommended_format": "reel",
  "recommended_time": "18:00-19:00",
  "engagement_mission": "string",
  "effort_level": "low",
  "confidence_note": "string"
}
```

### Comportement backend attendu
1. vérifier auth
2. valider payload
3. appeler OpenAI avec prompt Daily Idea
4. parser JSON strict
5. upsert `daily_ideas` par `(user_id, idea_date)`
6. retourner le JSON normalisé

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
3. appeler OpenAI avec prompt Weekly Plan
4. upsert `weekly_plans`
5. supprimer les anciens `weekly_plan_items` de la semaine
6. insérer les 7 nouveaux items
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
    {
      "tone": "expert",
      "text": "string"
    },
    {
      "tone": "direct",
      "text": "string"
    }
  ]
}
```

### Comportement backend attendu
1. vérifier auth
2. valider payload
3. appeler OpenAI avec prompt Generate Content
4. parser JSON strict
5. insérer `content_generations`
6. retourner résultat + `generation_id` si besoin

## 2.4 POST `/api/v1/growth-insight`

### Input JSON
```json
{
  "user_id": "uuid",
  "baseline": {
    "followers_baseline": 120,
    "engagement_baseline": 2.4,
    "posts_baseline": 4
  },
  "latest_growth": {
    "followers_total": 175,
    "engagement_rate": 3.1,
    "posts_count": 9,
    "regularity_rate": 72,
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

### Comportement backend attendu
1. vérifier auth
2. comparer baseline / latest
3. appeler OpenAI avec prompt Growth Insight
4. parser JSON
5. optionnel : mettre à jour `growth_snapshots.main_insight`
6. retourner l’insight

---

## 3. Prompts IA

## 3.1 Daily Idea

### Prompt système
```text
Tu es le Daily Idea Engine de Viral Studio.
Tu aides un créateur à savoir quoi poster aujourd'hui.
Tu produis UNE idée claire, spécifique, simple à exécuter, adaptée à sa niche, sa plateforme, son ton, son niveau et son objectif.
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
- idée trop générique
- pas d’angle
- format non aligné au niveau créateur
- hook cliché

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
    "preferred_formats": ["face_cam", "conseils"],
    "language": "fr",
    "country": "FR"
  }
}
```

### Exemple output
```json
{
  "idea_title": "L'erreur qui rend un freelance invisible",
  "why_now": "Votre audience a besoin d'un conseil simple, rapide à consommer et facile à retenir.",
  "topic": "erreur de visibilité freelance",
  "angle": "montrer une erreur courante puis donner un correctif simple",
  "hook": "Si vous êtes freelance et que vous postez sans angle clair, vous faites probablement cette erreur.",
  "content_structure": [
    "nommer l'erreur",
    "expliquer pourquoi elle bloque",
    "donner un correctif concret"
  ],
  "caption": "Beaucoup de freelances publient sans savoir ce qu'ils veulent déclencher. Voici l'erreur que je vois le plus, et comment la corriger simplement.",
  "cta": "Si vous voulez, je peux faire une partie 2 avec d'autres erreurs à éviter.",
  "hashtags": ["#freelance", "#branding", "#instagrambusiness"],
  "recommended_format": "reel",
  "recommended_time": "18:00-19:00",
  "engagement_mission": "Répondez aux 5 premiers commentaires dans l'heure.",
  "effort_level": "low",
  "confidence_note": "Très bon fit avec un contenu face cam court."
}
```

## 3.2 Weekly Plan

### Prompt système
```text
Tu es le Weekly Plan Engine de Viral Studio.
Tu construis un plan 7 jours réaliste, simple, actionnable, cohérent avec le niveau et le temps disponible du créateur.
Chaque jour doit inclure soit un contenu, soit une action d'engagement utile.
Tu réponds strictement en JSON valide.
```

### Variables
- niche
- platform
- goal
- tone
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
- plan trop chargé
- 7 idées trop semblables
- aucune tâche d’engagement
- pas d’adaptation débutant/intermédiaire

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

## 3.3 Generate Content

### Prompt système
```text
Tu es le Content Engine de Viral Studio.
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
- script trop long
- hashtags sans niche
- CTA vide

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
  "caption": "Beaucoup de freelances pensent que leur problème est le manque de visibilité. Souvent, c'est surtout un problème de lisibilité. Si un client premium ne comprend pas immédiatement votre valeur, il passe à autre chose.",
  "script": "Voici l'erreur que je vois le plus : un branding joli mais flou. Si votre promesse n'est pas claire en 3 secondes, vous perdez les bons clients avant même la conversation.",
  "hashtags": ["#branding", "#freelance", "#positionnement"],
  "cta": "Si vous voulez, je peux faire un post sur les 3 signaux d'un branding flou.",
  "tone_variants": [
    {"tone": "direct", "text": "Votre branding n'est pas trop faible. Il est trop flou."},
    {"tone": "authentique", "text": "J'ai longtemps cru que mes clients voulaient plus de style. En réalité, ils voulaient surtout plus de clarté."}
  ]
}
```

## 3.4 Growth Insight

### Prompt système
```text
Tu es le Growth Insight Engine de Viral Studio.
Tu analyses la progression d'un créateur à partir d'une baseline et d'un snapshot actuel.
Tu dois produire des constats simples, prudents et actionnables.
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
- surinterpréter peu de données
- donner des conseils trop abstraits
- parler comme un analyste, pas comme un coach produit

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
    "Les formats courts semblent mieux soutenir votre croissance actuelle."
  ],
  "weak_signals": [
    "Votre volume de publication progresse, mais vous n'avez pas encore assez de recul pour isoler une tonalité gagnante certaine."
  ],
  "actions_next_week": [
    "Répétez un Reel conseil dans le même format que votre meilleur contenu.",
    "Gardez une publication légère à faible effort pour maintenir la cadence.",
    "Notez quels posts attirent le plus de questions pour préparer la semaine suivante."
  ],
  "main_insight": "Votre progression actuelle semble surtout tirée par une meilleure régularité et des contenus plus simples à consommer."
}
```

---

## 4. Architecture FlutterFlow

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
- ManualStatsBottomSheet
- ReplacePlanItemBottomSheet

### Navigation
- Splash → Auth ou Onboarding ou MainNav selon session/profil
- Auth → Onboarding ou MainNav
- Onboarding steps → Summary → MainNav/Home
- Home → DailyIdea / Plan / Create / Growth
- Growth → BeforeAfter / Pricing
- Settings → Pricing / Logout

### App State
- `appUserId`
- `hasCompletedOnboarding`
- `isPremium`
- `currentPlanId`
- `todayIdeaId`
- `momentumScore`
- `onboardingGoal`
- `onboardingPlatform`
- `onboardingNiche`
- `onboardingTone`
- `onboardingLevel`
- `onboardingFrequency`
- `selectedCreatePlatform`
- `selectedCreateFormat`
- `selectedCreateTone`
- `createBrief`
- `generatedHooks`
- `generatedCaption`
- `generatedScript`
- `generatedHashtags`
- `generatedCTA`
- `generatedToneVariants`

### Queries Supabase
#### Splash / Auth
- fetch `creator_profiles` by current user

#### OnboardingSummary
- fetch `creator_profiles`
- fetch `daily_ideas` for today

#### Home
- fetch `creator_profiles`
- fetch `daily_ideas` for today
- fetch current `weekly_plans`
- fetch related `weekly_plan_items`
- fetch latest `growth_snapshots`

#### DailyIdea
- fetch `daily_ideas` for today

#### Create
- insert/update `content_generations`

#### Plan7Days
- fetch `weekly_plans`
- fetch `weekly_plan_items`

#### Growth
- fetch latest `baseline_snapshots`
- fetch `growth_snapshots`

#### Settings / Pricing
- fetch latest `subscriptions`

### Actions principales par page
#### Splash
- auth check
- redirect logic

#### OnboardingStepFrequency
- upsert profile
- call `/daily-idea`
- call `/weekly-plan`
- redirect summary

#### Home
- open DailyIdea
- jump Create / Plan / Growth

#### DailyIdea
- regenerate
- open Create prefilled
- add to plan (simple)

#### Create
- call `/generate-content`
- save generation
- copy results

#### Plan7Days
- mark item done
- replace item
- open Create prefilled

#### Growth
- save manual stats
- open BeforeAfter

---

## 5. Écran par écran

## 5.1 SplashPage

### Widgets exacts
- SafeArea
- Container full screen
- Center
- Column
- Logo image
- Text app name
- Text subtitle
- Loader

### Ordre des blocs
1. logo
2. titre
3. sous-titre
4. loader

### Actions des boutons
Aucun bouton.

### Empty / loading / error
- loading : loader visible
- error query profile : snackbar + fallback Auth

## 5.2 AuthPage

### Widgets exacts
- SingleChildScrollView
- Column
- Text titre
- Text sous-titre
- Button Google
- Divider
- TextField email
- TextField password
- Button signup/login
- TextButton switch mode

### Actions
- Google sign in
- email signup/login
- fetch profile
- redirect

### Empty / loading / error
- loading : disable CTA
- error : message auth simple

## 5.3 OnboardingStepGoalPage

### Widgets exacts
- Progress bar
- Question text
- Choice chips objectifs
- Button Continuer

### Empty / loading / error
- disable continue if no choice

## 5.4 OnboardingStepPlatformPage

### Widgets exacts
- Progress bar
- Selectable cards plateformes
- Button Continuer

## 5.5 OnboardingStepNichePage

### Widgets exacts
- Progress bar
- TextField niche
- Suggestion chips
- Button Continuer

## 5.6 OnboardingStepTonePage

### Widgets exacts
- Progress bar
- Choice chips ton
- Button Continuer

## 5.7 OnboardingStepLevelPage

### Widgets exacts
- Progress bar
- Cards niveau
- Button Continuer

## 5.8 OnboardingStepFrequencyPage

### Widgets exacts
- Progress bar
- Cards fréquence
- Button Construire ma stratégie

### Action bouton
- upsert `creator_profiles`
- call `/daily-idea`
- call `/weekly-plan`
- navigate `OnboardingSummaryPage`

### Loading / error
- loading overlay pendant construction stratégie
- error : message “Impossible de préparer votre studio pour le moment”

## 5.9 OnboardingSummaryPage

### Widgets exacts
- Hero card
- Card résumé profil
- Card 3 opportunités
- Card preview daily idea
- Button Ouvrir mon studio

### Empty / loading / error
- loading skeletons
- si no daily idea → bouton régénérer

## 5.10 HomePage

### Widgets exacts
- AppBar custom
- Row avatar + prénom + notif
- Card Momentum
- Card Action du jour
- Card Daily Idea preview
- Card Mini progression
- Row accès rapides
- Bottom nav

### Ordre exact des blocs
1. header
2. momentum
3. action du jour
4. daily idea
5. mini progression
6. quick actions

### Actions boutons
- Créer maintenant → DailyIdea
- Voir le détail → DailyIdea
- Aller au plan → Plan7Days
- Aller à Growth → Growth

### Empty / loading / error
- no idea → CTA générer idée
- no plan → CTA générer plan
- no growth → CTA ajouter stats

## 5.11 DailyIdeaPage

### Widgets exacts
- Date
- Hero card idée
- Section why now
- Section hook + copy
- Section structure
- Section caption + copy
- Section hashtags
- Section format/heure
- Section mission engagement
- Sticky bottom CTA

### Actions boutons
- Régénérer → `/daily-idea`
- Créer ce contenu → Create prefilled
- En faire un script → Create prefilled
- Ajouter au calendrier → update simple / toast

### Empty / loading / error
- loading query
- error API regenerate

## 5.12 CreatePage

### Widgets exacts
- Dropdown plateforme
- Dropdown format
- Choice chips ton
- TextField brief
- Button Générer
- TabBar hooks/caption/script/hashtags/cta
- Result cards
- Buttons Sauvegarder / Copier / Variantes

### Actions boutons
- Générer → `/generate-content`
- Sauvegarder → insert/update `content_generations`
- Copier → clipboard
- Variantes → relance endpoint avec variante

### Empty / loading / error
- empty state with examples
- loading generation spinner
- error generation snackbar

## 5.13 Plan7DaysPage

### Widgets exacts
- Text thème semaine
- Text coach note
- ListView 7 cards
- Actions fait / remplacer / générer brouillon

### Actions boutons
- Fait → update status `done`
- Remplacer → open sheet + backend replace
- Générer brouillon → Create prefilled

### Empty / loading / error
- no weekly plan → bouton générer plan

## 5.14 GrowthPage

### Widgets exacts
- KPI row
- Line chart
- Top format card
- Main insight card
- Button Before/After
- Manual stats form if no data

### Actions boutons
- Enregistrer mes stats → insert baseline if none + insert growth snapshot
- Voir avant/après → BeforeAfter

### Empty / loading / error
- if no snapshots → show manual form
- loading chart

## 5.15 BeforeAfterPage

### Widgets exacts
- Hero card
- Comparison cards
- Delta chips
- Timeline
- Buttons partager / préparer prochain mois

### Actions boutons
- Partager : désactivé ou simple copy summary en beta
- Préparer prochain mois : back to Plan/Home

## 5.16 PricingPage

### Widgets exacts
- Hero title
- Pricing cards
- Feature list
- CTA subscribe

### Actions
- RevenueCat purchase
- sync subscription

## 5.17 SettingsPage

### Widgets exacts
- Profil summary
- Edit niche
- Edit tone
- Edit frequency
- Card abonnement
- Logout button

### Actions
- update profile
- navigate pricing
- logout

---

## 6. Sprints

## Sprint 1 — Auth + onboarding
### Objectifs
- auth ok
- onboarding complet
- profile persistant
- summary fonctionnel

### Écrans concernés
- Splash
- Auth
- Onboarding 6 steps
- Summary

### Backend concerné
- Supabase Auth
- `creator_profiles`
- `/daily-idea`
- `/weekly-plan`

### Tests à faire
- signup/login
- profile create/update
- daily idea save
- weekly plan save

### Risques
- trop de logique côté FlutterFlow
- parsing JSON fragile

## Sprint 2 — Home + Daily Idea
### Objectifs
- home utile
- daily idea détaillée
- regenerate idée

### Écrans concernés
- Home
- DailyIdea

### Backend concerné
- `daily_ideas`
- `weekly_plan_items`

### Tests à faire
- home fallback
- regenerate upsert
- open Create prefilled

### Risques
- home vide si pas de data

## Sprint 3 — Plan 7 Days
### Objectifs
- lister les 7 items
- statut done
- replacement simple

### Écrans concernés
- Plan7Days
- ReplacePlanItemBottomSheet

### Backend concerné
- `weekly_plans`
- `weekly_plan_items`
- optional replacement endpoint

### Tests à faire
- mark done
- replace item
- create prefill

### Risques
- replacement trop ambitieux

## Sprint 4 — Create
### Objectifs
- génération IA complète
- save history
- copy/save/variants

### Écrans concernés
- Create

### Backend concerné
- `/generate-content`
- `content_generations`

### Tests à faire
- valid brief
- JSON valid
- save history
- app state persistence

### Risques
- sortie IA incohérente

## Sprint 5 — Growth + Before/After
### Objectifs
- stats manuelles
- dashboard simple
- avant/après
- insights

### Écrans concernés
- Growth
- BeforeAfter

### Backend concerné
- `baseline_snapshots`
- `growth_snapshots`
- `/growth-insight`

### Tests à faire
- baseline first insert
- latest snapshot insert
- before/after calculations

### Risques
- manque de données au départ

## Sprint 6 — Pricing + polish + beta
### Objectifs
- pricing fonctionnel
- RevenueCat ou fallback
- QA navigation
- bêta privée

### Écrans concernés
- Pricing
- Settings

### Backend concerné
- `subscriptions`
- `/subscriptions/sync`

### Tests à faire
- simulate premium state
- logout/login stable
- QA complete flow

### Risques
- RevenueCat ralentit la release

---

## 7. Données simulées

### À simuler au début
- followers actuels
- engagement estimé
- posts du mois
- top format
- main insight
- baseline initiale

### Pourquoi
Le MVP doit être testable sans intégration sociale.

### Mise en place
- formulaire manuel dans Growth
- baseline créée à la première saisie
- snapshots ajoutés manuellement ensuite
- seed data pour comptes test internes

---

## 8. Pièges à éviter

1. Brancher les APIs sociales trop tôt.
2. Appeler OpenAI depuis le client.
3. Laisser FlutterFlow orchestrer les inserts complexes semaine + idées.
4. Ajouter des tables non nécessaires en V1.
5. Ne pas prévoir de fallback sans données.
6. Sous-estimer la validation JSON stricte.
7. Essayer de faire autopost / trends / comments en même temps.
8. Faire un Home trop dépendant du backend.

---

## 9. Recommandation finale de build

Version bêta la plus simple à lancer :
- auth Google + email,
- onboarding 6 étapes,
- résumé onboarding,
- Home avec action du jour,
- Daily Idea consultable + régénérable,
- Create avec génération complète,
- Plan 7 jours avec statut `done`,
- Growth basé sur saisie manuelle,
- Before/After simple,
- Pricing visible mais RevenueCat remplaçable temporairement par accès manuel.

Si le temps manque, coupe dans cet ordre :
1. RevenueCat réel,
2. replacement avancé du plan,
3. variantes de ton supplémentaires,
4. partage before/after.

Ne coupe pas :
- onboarding,
- daily idea,
- create,
- plan 7 jours,
- growth simple,
- before/after.

**Objectif de la V1 :** une app que l’on peut ouvrir, configurer, utiliser et tester en 1 journée avec de vrais utilisateurs, même si certaines métriques sont encore simulées à la main.
