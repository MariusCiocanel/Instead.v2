-- Phase 4 sharing: public lists, email invites, invite links, and viewer/editor permissions.

alter table public.lists
  add column if not exists title text not null default 'Untitled list',
  add column if not exists is_public boolean not null default false,
  add column if not exists share_slug text;

alter table public.list_shares
  add column if not exists permission text not null default 'viewer',
  add column if not exists accepted boolean not null default false;

do $$
begin
  alter table public.list_shares
    add constraint list_shares_permission_check
    check (permission in ('viewer', 'editor'));
exception
  when duplicate_object then null;
end $$;

create or replace function public.is_list_public(p_list_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from lists
    where id = p_list_id
      and is_public = true
  );
$$;

create or replace function public.can_view_list(p_list_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.is_list_public(p_list_id)
    or public.is_list_owner(p_list_id)
    or public.is_list_shared_with_me(p_list_id);
$$;

create or replace function public.can_edit_list(p_list_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.is_list_owner(p_list_id)
    or exists (
      select 1 from list_shares
      where list_id = p_list_id
        and shared_with = auth.uid()
        and accepted = true
        and permission = 'editor'
    );
$$;

create or replace function public.can_view_item_via_list(p_item_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from list_items li
    where li.item_id = p_item_id
      and public.can_view_list(li.list_id)
  );
$$;

create or replace function public.can_add_item_to_list(p_list_id uuid, p_item_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.can_edit_list(p_list_id)
    and exists (
      select 1 from items
      where id = p_item_id
        and user_id = auth.uid()
        and status = 'active'
    );
$$;

revoke all on function public.is_list_public(uuid) from public;
revoke all on function public.can_view_list(uuid) from public;
revoke all on function public.can_edit_list(uuid) from public;
revoke all on function public.can_view_item_via_list(uuid) from public;
revoke all on function public.can_add_item_to_list(uuid, uuid) from public;
grant execute on function public.is_list_public(uuid) to anon, authenticated;
grant execute on function public.can_view_list(uuid) to anon, authenticated;
grant execute on function public.can_edit_list(uuid) to anon, authenticated;
grant execute on function public.can_view_item_via_list(uuid) to anon, authenticated;
grant execute on function public.can_add_item_to_list(uuid, uuid) to anon, authenticated;

create unique index if not exists lists_share_slug_key
  on public.lists (share_slug)
  where share_slug is not null;

create unique index if not exists list_items_list_id_item_id_key
  on public.list_items (list_id, item_id);

create unique index if not exists list_shares_list_id_shared_with_key
  on public.list_shares (list_id, shared_with)
  where shared_with is not null;

create index if not exists list_items_item_id_idx
  on public.list_items (item_id);

drop policy if exists "items: visible via readable lists" on public.items;
create policy "items: visible via readable lists"
on public.items
for select
to public
using (public.can_view_item_via_list(id));

drop policy if exists "list_items: owner can delete" on public.list_items;
drop policy if exists "list_items: owner can insert" on public.list_items;
drop policy if exists "list_items: visible to owner and shared members" on public.list_items;
drop policy if exists "list_items: editor can delete" on public.list_items;
drop policy if exists "list_items: editor can insert" on public.list_items;
drop policy if exists "list_items: visible to readable lists" on public.list_items;

create policy "list_items: editor can delete"
on public.list_items
for delete
to public
using (public.can_edit_list(list_id));

create policy "list_items: editor can insert"
on public.list_items
for insert
to public
with check (public.can_add_item_to_list(list_id, item_id));

create policy "list_items: visible to readable lists"
on public.list_items
for select
to public
using (public.can_view_list(list_id));

drop policy if exists "list_shares: owner can manage" on public.list_shares;
drop policy if exists "list_shares: recipient can update accepted" on public.list_shares;
drop policy if exists "list_shares: recipient can view and accept" on public.list_shares;
drop policy if exists "list_shares: owner can manage shares" on public.list_shares;
drop policy if exists "list_shares: recipient can view" on public.list_shares;

create policy "list_shares: owner can manage shares"
on public.list_shares
for all
to authenticated
using (public.is_list_owner(list_id))
with check (public.is_list_owner(list_id));

create policy "list_shares: recipient can view"
on public.list_shares
for select
to authenticated
using (shared_with = auth.uid());

drop policy if exists "lists: shared member can select" on public.lists;
drop policy if exists "lists: public lists are readable" on public.lists;
drop policy if exists "lists: readable by owner shared and public" on public.lists;

create policy "lists: readable by owner shared and public"
on public.lists
for select
to public
using (public.can_view_list(id));

create or replace function public.create_list_share_by_email(
  p_list_id uuid,
  p_email text,
  p_permission text default 'viewer'
)
returns uuid
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_target uuid;
  v_share_id uuid;
  v_permission text := lower(trim(coalesce(p_permission, 'viewer')));
begin
  if not public.is_list_owner(p_list_id) then
    raise exception 'Only the list owner can share this list';
  end if;

  if v_permission not in ('viewer', 'editor') then
    raise exception 'Permission must be viewer or editor';
  end if;

  select id into v_target
  from auth.users
  where lower(email) = lower(trim(p_email))
  limit 1;

  if v_target is null then
    raise exception 'No account exists for that email address';
  end if;

  if v_target = auth.uid() then
    raise exception 'You already own this list';
  end if;

  update public.list_shares
  set permission = v_permission
  where list_id = p_list_id
    and shared_with = v_target
  returning id into v_share_id;

  if v_share_id is null then
    insert into public.list_shares (list_id, shared_with, permission, accepted)
    values (p_list_id, v_target, v_permission, false)
    returning id into v_share_id;
  end if;

  return v_share_id;
end;
$$;

create or replace function public.accept_list_share(p_share_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_list_id uuid;
begin
  update public.list_shares
  set accepted = true
  where id = p_share_id
    and shared_with = auth.uid()
  returning list_id into v_list_id;

  if v_list_id is null then
    raise exception 'Share not found';
  end if;

  return v_list_id;
end;
$$;

create or replace function public.accept_list_invite(p_share_slug text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_list_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Sign in to accept this invite';
  end if;

  select id into v_list_id
  from public.lists
  where share_slug = p_share_slug
  limit 1;

  if v_list_id is null then
    raise exception 'Invite not found';
  end if;

  if public.is_list_owner(v_list_id) or public.is_list_public(v_list_id) then
    return v_list_id;
  end if;

  update public.list_shares
  set accepted = true
  where list_id = v_list_id
    and shared_with = auth.uid();

  if not found then
    insert into public.list_shares (list_id, shared_with, permission, accepted)
    values (v_list_id, auth.uid(), 'viewer', true);
  end if;

  return v_list_id;
end;
$$;

create or replace function public.decline_list_share(p_share_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from public.list_shares
  where id = p_share_id
    and shared_with = auth.uid()
    and accepted = false;
end;
$$;

revoke all on function public.create_list_share_by_email(uuid, text, text) from public;
revoke all on function public.accept_list_share(uuid) from public;
revoke all on function public.accept_list_invite(text) from public;
revoke all on function public.decline_list_share(uuid) from public;
grant execute on function public.create_list_share_by_email(uuid, text, text) to authenticated;
grant execute on function public.accept_list_share(uuid) to authenticated;
grant execute on function public.accept_list_invite(text) to authenticated;
grant execute on function public.decline_list_share(uuid) to authenticated;
