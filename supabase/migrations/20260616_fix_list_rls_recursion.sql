-- Phase 3 live hotfix: avoid infinite recursion in sharing RLS policies.
--
-- The original sharing policies queried across lists <-> list_shares directly,
-- which caused Postgres RLS recursion during cloud reads. These helper
-- functions run as SECURITY DEFINER and are then used by policies instead of
-- cross-table policy subqueries.

create or replace function public.is_list_owner(p_list_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from lists where id = p_list_id and owner_id = auth.uid());
$$;

create or replace function public.is_list_shared_with_me(p_list_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from list_shares
    where list_id = p_list_id
      and shared_with = auth.uid()
      and accepted = true
  );
$$;

revoke all on function public.is_list_owner(uuid) from public;
revoke all on function public.is_list_shared_with_me(uuid) from public;
grant execute on function public.is_list_owner(uuid) to anon, authenticated;
grant execute on function public.is_list_shared_with_me(uuid) to anon, authenticated;

alter table public.lists enable row level security;
alter table public.list_items enable row level security;
alter table public.list_shares enable row level security;

drop policy if exists "list_items: owner can delete" on public.list_items;
drop policy if exists "list_items: owner can insert" on public.list_items;
drop policy if exists "list_items: visible to owner and shared members" on public.list_items;
drop policy if exists "list_shares: owner can manage" on public.list_shares;
drop policy if exists "list_shares: recipient can update accepted" on public.list_shares;
drop policy if exists "list_shares: recipient can view and accept" on public.list_shares;
drop policy if exists "lists: owner can delete" on public.lists;
drop policy if exists "lists: owner can insert" on public.lists;
drop policy if exists "lists: owner can select" on public.lists;
drop policy if exists "lists: owner can update" on public.lists;
drop policy if exists "lists: public lists are readable" on public.lists;
drop policy if exists "lists: shared member can select" on public.lists;

create policy "list_items: owner can delete"
on public.list_items
for delete
to public
using (public.is_list_owner(list_id));

create policy "list_items: owner can insert"
on public.list_items
for insert
to public
with check (public.is_list_owner(list_id));

create policy "list_items: visible to owner and shared members"
on public.list_items
for select
to public
using (
  public.is_list_owner(list_id)
  or public.is_list_shared_with_me(list_id)
);

create policy "list_shares: owner can manage"
on public.list_shares
for all
to public
using (public.is_list_owner(list_id))
with check (public.is_list_owner(list_id));

create policy "list_shares: recipient can update accepted"
on public.list_shares
for update
to authenticated
using (shared_with = auth.uid())
with check (shared_with = auth.uid());

create policy "list_shares: recipient can view and accept"
on public.list_shares
for select
to authenticated
using (shared_with = auth.uid());

create policy "lists: owner can delete"
on public.lists
for delete
to authenticated
using (owner_id = auth.uid());

create policy "lists: owner can insert"
on public.lists
for insert
to authenticated
with check (owner_id = auth.uid());

create policy "lists: owner can select"
on public.lists
for select
to authenticated
using (owner_id = auth.uid());

create policy "lists: owner can update"
on public.lists
for update
to authenticated
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

create policy "lists: public lists are readable"
on public.lists
for select
to authenticated
using (is_public = true);

create policy "lists: shared member can select"
on public.lists
for select
to public
using (public.is_list_shared_with_me(id));
