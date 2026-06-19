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
-- PRE-FLIGHT: index creation fails if duplicates already exist. Check first, and
-- de-duplicate if this returns any rows:
--   select user_id, title, coalesce(url,'') as u, count(*)
--   from public.items
--   where source = 'builtin'
--   group by 1, 2, 3
--   having count(*) > 1;

create unique index if not exists items_builtin_unique
  on public.items (user_id, title, coalesce(url, ''))
  where source = 'builtin';
