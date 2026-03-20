create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.creator_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users(id) on delete cascade,
  niche text not null,
  primary_platform text not null check (primary_platform in ('instagram', 'tiktok', 'linkedin', 'youtube_shorts', 'x', 'threads', 'facebook', 'pinterest')),
  goal text not null check (goal in ('followers', 'engagement', 'visibility', 'sales', 'personal_brand')),
  desired_tone text not null check (desired_tone in ('authentique', 'expert', 'drole', 'inspirant', 'direct', 'educatif')),
  level text not null check (level in ('debutant', 'intermediaire', 'avance_stagnant')),
  frequency_per_week integer not null check (frequency_per_week between 1 and 14),
  preferred_formats text[] not null default '{}',
  language text not null default 'fr',
  country text,
  onboarding_complete boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.daily_ideas (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  idea_date date not null,
  idea_title text not null,
  why_now text not null,
  topic text not null,
  angle text not null,
  hook text not null,
  content_structure jsonb not null default '[]'::jsonb,
  caption text not null,
  cta text not null,
  hashtags text[] not null default '{}',
  recommended_format text not null,
  recommended_time text,
  engagement_mission text,
  effort_level text not null check (effort_level in ('low', 'medium', 'high')),
  confidence_note text,
  created_at timestamptz not null default timezone('utc', now()),
  unique (user_id, idea_date)
);

create table if not exists public.weekly_plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  week_start date not null,
  week_theme text not null,
  coach_note text,
  created_at timestamptz not null default timezone('utc', now()),
  unique (user_id, week_start)
);

create table if not exists public.weekly_plan_items (
  id uuid primary key default gen_random_uuid(),
  weekly_plan_id uuid not null references public.weekly_plans(id) on delete cascade,
  day_index integer not null check (day_index between 1 and 7),
  platform text not null,
  objective text not null,
  format text not null,
  topic text not null,
  angle text not null,
  tone text not null,
  time_window text,
  engagement_task text,
  effort text not null check (effort in ('low', 'medium', 'high')),
  status text not null default 'planned' check (status in ('planned', 'done', 'skipped', 'replaced')),
  created_at timestamptz not null default timezone('utc', now()),
  unique (weekly_plan_id, day_index)
);

create table if not exists public.content_generations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  source_brief text not null,
  platform text not null,
  format text not null,
  tone text not null,
  hooks jsonb not null default '[]'::jsonb,
  caption text not null,
  script text,
  hashtags text[] not null default '{}',
  cta text,
  tone_variants jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.growth_snapshots (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  snapshot_date date not null,
  followers_total integer not null default 0 check (followers_total >= 0),
  engagement_rate numeric(5,2) not null default 0 check (engagement_rate >= 0),
  posts_count integer not null default 0 check (posts_count >= 0),
  regularity_rate numeric(5,2) not null default 0 check (regularity_rate >= 0),
  top_format text,
  main_insight text,
  created_at timestamptz not null default timezone('utc', now()),
  unique (user_id, snapshot_date)
);

create table if not exists public.baseline_snapshots (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  baseline_date date not null,
  followers_baseline integer not null default 0 check (followers_baseline >= 0),
  engagement_baseline numeric(5,2) not null default 0 check (engagement_baseline >= 0),
  posts_baseline integer not null default 0 check (posts_baseline >= 0),
  notes text,
  created_at timestamptz not null default timezone('utc', now()),
  unique (user_id, baseline_date)
);

create table if not exists public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  plan_name text not null check (plan_name in ('free', 'pro', 'growth')),
  status text not null check (status in ('active', 'trialing', 'expired', 'canceled', 'past_due')),
  started_at timestamptz not null default timezone('utc', now()),
  expires_at timestamptz,
  provider_customer_id text,
  provider_subscription_id text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_daily_ideas_user_date on public.daily_ideas(user_id, idea_date desc);
create index if not exists idx_weekly_plans_user_week on public.weekly_plans(user_id, week_start desc);
create index if not exists idx_weekly_plan_items_plan on public.weekly_plan_items(weekly_plan_id, day_index);
create index if not exists idx_content_generations_user_created on public.content_generations(user_id, created_at desc);
create index if not exists idx_growth_snapshots_user_date on public.growth_snapshots(user_id, snapshot_date desc);
create index if not exists idx_baseline_snapshots_user_date on public.baseline_snapshots(user_id, baseline_date desc);
create index if not exists idx_subscriptions_user_status on public.subscriptions(user_id, status);

create trigger set_creator_profiles_updated_at
before update on public.creator_profiles
for each row
execute function public.set_updated_at();

create trigger set_subscriptions_updated_at
before update on public.subscriptions
for each row
execute function public.set_updated_at();

alter table public.creator_profiles enable row level security;
alter table public.daily_ideas enable row level security;
alter table public.weekly_plans enable row level security;
alter table public.weekly_plan_items enable row level security;
alter table public.content_generations enable row level security;
alter table public.growth_snapshots enable row level security;
alter table public.baseline_snapshots enable row level security;
alter table public.subscriptions enable row level security;

create policy "creator_profiles_select_own"
on public.creator_profiles
for select
using (auth.uid() = user_id);

create policy "creator_profiles_insert_own"
on public.creator_profiles
for insert
with check (auth.uid() = user_id);

create policy "creator_profiles_update_own"
on public.creator_profiles
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "daily_ideas_select_own"
on public.daily_ideas
for select
using (auth.uid() = user_id);

create policy "daily_ideas_insert_own"
on public.daily_ideas
for insert
with check (auth.uid() = user_id);

create policy "daily_ideas_update_own"
on public.daily_ideas
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "weekly_plans_select_own"
on public.weekly_plans
for select
using (auth.uid() = user_id);

create policy "weekly_plans_insert_own"
on public.weekly_plans
for insert
with check (auth.uid() = user_id);

create policy "weekly_plans_update_own"
on public.weekly_plans
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "weekly_plan_items_select_own"
on public.weekly_plan_items
for select
using (
  exists (
    select 1 from public.weekly_plans wp
    where wp.id = weekly_plan_items.weekly_plan_id
      and wp.user_id = auth.uid()
  )
);

create policy "weekly_plan_items_insert_own"
on public.weekly_plan_items
for insert
with check (
  exists (
    select 1 from public.weekly_plans wp
    where wp.id = weekly_plan_items.weekly_plan_id
      and wp.user_id = auth.uid()
  )
);

create policy "weekly_plan_items_update_own"
on public.weekly_plan_items
for update
using (
  exists (
    select 1 from public.weekly_plans wp
    where wp.id = weekly_plan_items.weekly_plan_id
      and wp.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.weekly_plans wp
    where wp.id = weekly_plan_items.weekly_plan_id
      and wp.user_id = auth.uid()
  )
);

create policy "content_generations_select_own"
on public.content_generations
for select
using (auth.uid() = user_id);

create policy "content_generations_insert_own"
on public.content_generations
for insert
with check (auth.uid() = user_id);

create policy "content_generations_update_own"
on public.content_generations
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "growth_snapshots_select_own"
on public.growth_snapshots
for select
using (auth.uid() = user_id);

create policy "growth_snapshots_insert_own"
on public.growth_snapshots
for insert
with check (auth.uid() = user_id);

create policy "growth_snapshots_update_own"
on public.growth_snapshots
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "baseline_snapshots_select_own"
on public.baseline_snapshots
for select
using (auth.uid() = user_id);

create policy "baseline_snapshots_insert_own"
on public.baseline_snapshots
for insert
with check (auth.uid() = user_id);

create policy "baseline_snapshots_update_own"
on public.baseline_snapshots
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "subscriptions_select_own"
on public.subscriptions
for select
using (auth.uid() = user_id);

create policy "subscriptions_insert_own"
on public.subscriptions
for insert
with check (auth.uid() = user_id);

create policy "subscriptions_update_own"
on public.subscriptions
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
