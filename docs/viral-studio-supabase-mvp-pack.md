# Viral Studio — SQL Supabase complet du MVP

> Livrable SQL uniquement. Pas de stratégie. Pas d’UX. Pas d’API. Uniquement le socle base de données MVP.

## Fichiers SQL à appliquer dans l’ordre
1. `supabase/migrations/20260319_001_viral_studio_mvp.sql`
2. `supabase/migrations/20260320_002_viral_studio_mvp_delete_policies.sql`

---

## 1. Tables

### `creator_profiles`
**But** : stocker le profil créateur issu de l’onboarding.  
**Colonnes** :
- `id uuid primary key`
- `user_id uuid not null unique references auth.users(id) on delete cascade`
- `niche text not null`
- `primary_platform text not null`
- `goal text not null`
- `desired_tone text not null`
- `level text not null`
- `frequency_per_week integer not null`
- `preferred_formats text[] not null default '{}'`
- `language text not null default 'fr'`
- `country text null`
- `onboarding_complete boolean not null default false`
- `created_at timestamptz not null default timezone('utc', now())`
- `updated_at timestamptz not null default timezone('utc', now())`

### `daily_ideas`
**But** : stocker une idée du jour unique par utilisateur et par date.  
**Colonnes** :
- `id uuid primary key`
- `user_id uuid not null references auth.users(id) on delete cascade`
- `idea_date date not null`
- `idea_title text not null`
- `why_now text not null`
- `topic text not null`
- `angle text not null`
- `hook text not null`
- `content_structure jsonb not null default '[]'::jsonb`
- `caption text not null`
- `cta text not null`
- `hashtags text[] not null default '{}'`
- `recommended_format text not null`
- `recommended_time text null`
- `engagement_mission text null`
- `effort_level text not null`
- `confidence_note text null`
- `created_at timestamptz not null default timezone('utc', now())`

### `weekly_plans`
**But** : stocker le conteneur d’un plan 7 jours.  
**Colonnes** :
- `id uuid primary key`
- `user_id uuid not null references auth.users(id) on delete cascade`
- `week_start date not null`
- `week_theme text not null`
- `coach_note text null`
- `created_at timestamptz not null default timezone('utc', now())`

### `weekly_plan_items`
**But** : stocker les 7 items du plan hebdomadaire.  
**Colonnes** :
- `id uuid primary key`
- `weekly_plan_id uuid not null references public.weekly_plans(id) on delete cascade`
- `day_index integer not null`
- `platform text not null`
- `objective text not null`
- `format text not null`
- `topic text not null`
- `angle text not null`
- `tone text not null`
- `time_window text null`
- `engagement_task text null`
- `effort text not null`
- `status text not null default 'planned'`
- `created_at timestamptz not null default timezone('utc', now())`

### `content_generations`
**But** : stocker l’historique des générations Create.  
**Colonnes** :
- `id uuid primary key`
- `user_id uuid not null references auth.users(id) on delete cascade`
- `source_brief text not null`
- `platform text not null`
- `format text not null`
- `tone text not null`
- `hooks jsonb not null default '[]'::jsonb`
- `caption text not null`
- `script text null`
- `hashtags text[] not null default '{}'`
- `cta text null`
- `tone_variants jsonb not null default '[]'::jsonb`
- `created_at timestamptz not null default timezone('utc', now())`

### `growth_snapshots`
**But** : stocker des snapshots de progression par date.  
**Colonnes** :
- `id uuid primary key`
- `user_id uuid not null references auth.users(id) on delete cascade`
- `snapshot_date date not null`
- `followers_total integer not null default 0`
- `engagement_rate numeric(5,2) not null default 0`
- `posts_count integer not null default 0`
- `regularity_rate numeric(5,2) not null default 0`
- `top_format text null`
- `main_insight text null`
- `created_at timestamptz not null default timezone('utc', now())`

### `baseline_snapshots`
**But** : stocker la baseline utilisée par Before / After.  
**Colonnes** :
- `id uuid primary key`
- `user_id uuid not null references auth.users(id) on delete cascade`
- `baseline_date date not null`
- `followers_baseline integer not null default 0`
- `engagement_baseline numeric(5,2) not null default 0`
- `posts_baseline integer not null default 0`
- `notes text null`
- `created_at timestamptz not null default timezone('utc', now())`

### `subscriptions`
**But** : stocker l’état d’abonnement synchronisé avec RevenueCat ou un système manuel.  
**Colonnes** :
- `id uuid primary key`
- `user_id uuid not null references auth.users(id) on delete cascade`
- `plan_name text not null`
- `status text not null`
- `started_at timestamptz not null default timezone('utc', now())`
- `expires_at timestamptz null`
- `provider_customer_id text null`
- `provider_subscription_id text null`
- `created_at timestamptz not null default timezone('utc', now())`
- `updated_at timestamptz not null default timezone('utc', now())`

---

## 2. Contraintes

### Enum / check constraints
- `creator_profiles.primary_platform in ('instagram', 'tiktok', 'linkedin', 'youtube_shorts', 'x', 'threads', 'facebook', 'pinterest')`
- `creator_profiles.goal in ('followers', 'engagement', 'visibility', 'sales', 'personal_brand')`
- `creator_profiles.desired_tone in ('authentique', 'expert', 'drole', 'inspirant', 'direct', 'educatif')`
- `creator_profiles.level in ('debutant', 'intermediaire', 'avance_stagnant')`
- `creator_profiles.frequency_per_week between 1 and 14`
- `daily_ideas.effort_level in ('low', 'medium', 'high')`
- `weekly_plan_items.day_index between 1 and 7`
- `weekly_plan_items.effort in ('low', 'medium', 'high')`
- `weekly_plan_items.status in ('planned', 'done', 'skipped', 'replaced')`
- `growth_snapshots.followers_total >= 0`
- `growth_snapshots.engagement_rate >= 0`
- `growth_snapshots.posts_count >= 0`
- `growth_snapshots.regularity_rate >= 0`
- `baseline_snapshots.followers_baseline >= 0`
- `baseline_snapshots.engagement_baseline >= 0`
- `baseline_snapshots.posts_baseline >= 0`
- `subscriptions.plan_name in ('free', 'pro', 'growth')`
- `subscriptions.status in ('active', 'trialing', 'expired', 'canceled', 'past_due')`

### Uniques
- `creator_profiles(user_id)`
- `daily_ideas(user_id, idea_date)`
- `weekly_plans(user_id, week_start)`
- `weekly_plan_items(weekly_plan_id, day_index)`
- `growth_snapshots(user_id, snapshot_date)`
- `baseline_snapshots(user_id, baseline_date)`

### FKs et cascade
- toutes les tables `user_id` référencent `auth.users(id)` avec `on delete cascade`
- `weekly_plan_items.weekly_plan_id` référence `weekly_plans(id)` avec `on delete cascade`

---

## 3. Index

À appliquer et conserver :
- `idx_daily_ideas_user_date on public.daily_ideas(user_id, idea_date desc)`
- `idx_weekly_plans_user_week on public.weekly_plans(user_id, week_start desc)`
- `idx_weekly_plan_items_plan on public.weekly_plan_items(weekly_plan_id, day_index)`
- `idx_content_generations_user_created on public.content_generations(user_id, created_at desc)`
- `idx_growth_snapshots_user_date on public.growth_snapshots(user_id, snapshot_date desc)`
- `idx_baseline_snapshots_user_date on public.baseline_snapshots(user_id, baseline_date desc)`
- `idx_subscriptions_user_status on public.subscriptions(user_id, status)`

---

## 4. updated_at

### Fonction
- `public.set_updated_at()`

### Triggers déjà en place
- `set_creator_profiles_updated_at`
- `set_subscriptions_updated_at`

### Règle MVP
Aucun autre `updated_at` n’est nécessaire pour l’instant.
`created_at` suffit pour les tables de logs / snapshots / générations.

---

## 5. RLS simples par utilisateur

### Principe
Chaque utilisateur authentifié peut uniquement :
- lire ses lignes,
- insérer ses lignes,
- modifier ses lignes,
- supprimer ses lignes.

### Tables avec RLS activé
- `creator_profiles`
- `daily_ideas`
- `weekly_plans`
- `weekly_plan_items`
- `content_generations`
- `growth_snapshots`
- `baseline_snapshots`
- `subscriptions`

### Policies de base
#### creator_profiles
- select own
- insert own
- update own
- delete own

#### daily_ideas
- select own
- insert own
- update own
- delete own

#### weekly_plans
- select own
- insert own
- update own
- delete own

#### weekly_plan_items
- select own via parent `weekly_plans`
- insert own via parent `weekly_plans`
- update own via parent `weekly_plans`
- delete own via parent `weekly_plans`

#### content_generations
- select own
- insert own
- update own
- delete own

#### growth_snapshots
- select own
- insert own
- update own
- delete own

#### baseline_snapshots
- select own
- insert own
- update own
- delete own

#### subscriptions
- select own
- insert own
- update own
- delete own

### Règle front / backend
- FlutterFlow agit avec le JWT user
- backend IA peut utiliser service role si le front ne doit pas écrire directement certaines lignes

---

## 6. Ordre d’application recommandé

1. appliquer `20260319_001_viral_studio_mvp.sql`
2. appliquer `20260320_002_viral_studio_mvp_delete_policies.sql`
3. vérifier les tables via `\dt public.*`
4. vérifier les indexes via `\di public.*`
5. vérifier les policies via `select * from pg_policies where schemaname = 'public';`
