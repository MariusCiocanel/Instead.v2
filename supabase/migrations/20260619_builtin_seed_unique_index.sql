-- Phase 3 hardening: DB-level guard against double-seeding built-ins.
--
-- The client guards re-seeds with the `syncInFlight` flag in syncOnLogin(), but a
-- concurrency bug (the earlier incident that seeded 102 rows) could still insert
-- the built-in set twice. This partial unique index makes each built-in unique per
-- user at the database level, so a duplicate seed batch is rejected outright.
--
-- A given built-in is exactly one row per user across its lifecycle (archive/delete
-- change `status`, not identity), so the natural key is (user_id, title, url) scoped
-- to source = 'builtin'. coalesce(url,'') is used because several built-ins seed with
-- a NULL url, and NULLs are treated as distinct in a unique index by default — without
-- the coalesce, two url-less built-ins with the same title would NOT collide.
--
-- Applied live and verified on the production project on 2026-06-19
-- (pre-flight returned 0 duplicate groups; index created successfully).
--
-- This migration is self-contained and idempotent: it first fails loudly if any
-- duplicate built-in groups exist (the unique index cannot be created over them),
-- then creates the index with `if not exists`.

-- Step 1 — Pre-flight guard: abort with a clear message if duplicates exist, so a
-- dirty database gets an actionable error instead of a cryptic index-creation failure.
do $$
declare
  v_dupe_groups integer;
begin
  select count(*)
    into v_dupe_groups
  from (
    select 1
    from public.items
    where source = 'builtin'
    group by user_id, title, coalesce(url, '')
    having count(*) > 1
  ) d;

  if v_dupe_groups > 0 then
    raise exception 'Cannot create items_builtin_unique: % duplicate built-in group(s) exist. De-duplicate (keep one row per user_id/title/url for source=builtin), then re-run.', v_dupe_groups;
  end if;
end $$;

-- Step 2 — The partial unique index: one built-in per user, rejecting duplicate seeds.
create unique index if not exists items_builtin_unique
  on public.items (user_id, title, coalesce(url, ''))
  where source = 'builtin';
