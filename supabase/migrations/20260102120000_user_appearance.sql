-- Per-user appearance preferences (theme + palette)
-- Used by the app to sync settings across devices.

create table if not exists public.user_appearance (
  user_id uuid primary key references auth.users(id) on delete cascade,
  theme text not null default 'system',
  palette text not null default 'default',
  updated_at timestamptz not null default now()
);

alter table public.user_appearance enable row level security;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'user_appearance'
      and policyname = 'Users can read their appearance'
  ) then
    create policy "Users can read their appearance"
      on public.user_appearance
      for select
      to authenticated
      using (auth.uid() = user_id);
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'user_appearance'
      and policyname = 'Users can insert their appearance'
  ) then
    create policy "Users can insert their appearance"
      on public.user_appearance
      for insert
      to authenticated
      with check (auth.uid() = user_id);
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'user_appearance'
      and policyname = 'Users can update their appearance'
  ) then
    create policy "Users can update their appearance"
      on public.user_appearance
      for update
      to authenticated
      using (auth.uid() = user_id)
      with check (auth.uid() = user_id);
  end if;
end $$;

