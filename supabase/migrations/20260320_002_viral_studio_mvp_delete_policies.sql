create policy "creator_profiles_delete_own"
on public.creator_profiles
for delete
using (auth.uid() = user_id);

create policy "daily_ideas_delete_own"
on public.daily_ideas
for delete
using (auth.uid() = user_id);

create policy "weekly_plans_delete_own"
on public.weekly_plans
for delete
using (auth.uid() = user_id);

create policy "weekly_plan_items_delete_own"
on public.weekly_plan_items
for delete
using (
  exists (
    select 1 from public.weekly_plans wp
    where wp.id = weekly_plan_items.weekly_plan_id
      and wp.user_id = auth.uid()
  )
);

create policy "content_generations_delete_own"
on public.content_generations
for delete
using (auth.uid() = user_id);

create policy "growth_snapshots_delete_own"
on public.growth_snapshots
for delete
using (auth.uid() = user_id);

create policy "baseline_snapshots_delete_own"
on public.baseline_snapshots
for delete
using (auth.uid() = user_id);

create policy "subscriptions_delete_own"
on public.subscriptions
for delete
using (auth.uid() = user_id);
