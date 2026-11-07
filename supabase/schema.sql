-- TMoh optional student cloud sync: run in Supabase SQL Editor only.
-- Local offline profiles remain the default; never store raw passwords.
create table if not exists public.student_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  profile jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  constraint profile_object check (jsonb_typeof(profile) = 'object')
);
alter table public.student_data enable row level security;
-- One student may only read and modify their own record.
drop policy if exists student_select_own on public.student_data;
drop policy if exists student_insert_own on public.student_data;
drop policy if exists student_update_own on public.student_data;
drop policy if exists student_delete_own on public.student_data;
create policy student_select_own on public.student_data for select to authenticated using ((select auth.uid()) = user_id);
create policy student_insert_own on public.student_data for insert to authenticated with check ((select auth.uid()) = user_id);
create policy student_update_own on public.student_data for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy student_delete_own on public.student_data for delete to authenticated using ((select auth.uid()) = user_id);
revoke all on public.student_data from anon;
grant select, insert, update, delete on public.student_data to authenticated;
