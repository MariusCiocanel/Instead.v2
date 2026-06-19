# Supabase Schema Notes

This directory captures database changes that must be reproducible outside the
live Supabase project.

## Migrations

- `migrations/20260616_fix_list_rls_recursion.sql` records the live RLS hotfix
  for Phase 3/Phase 4 sharing tables. It replaces recursive cross-table policy
  checks with `SECURITY DEFINER` helper functions, then recreates the `lists`,
  `list_items`, and `list_shares` policies from the live project.
- `migrations/20260616_phase4_sharing.sql` adds Phase 4 sharing helpers, RLS
  updates, invite RPCs, viewer/editor permissions, public list reads, and the
  minimum list/share columns used by the static app.
- `migrations/20260618_fix_list_shares_permission_constraint.sql` repairs the
  `list_shares_permission_check` constraint on databases that still carried an
  early draft's `('view', 'edit')` vocabulary. The Phase 4 migration adds the
  correct `('viewer', 'editor')` constraint only when one is absent (it is guarded
  by `exception when duplicate_object`), so a pre-existing stale constraint was
  silently kept and rejected every `'viewer'`/`'editor'` invite. This drops and
  recreates it unconditionally. (Fresh projects are unaffected — running it after
  the Phase 4 migration simply recreates the same correct constraint.)

- `migrations/20260619_builtin_seed_unique_index.sql` adds a partial unique index
  (`items_builtin_unique` on `(user_id, title, coalesce(url,''))` where
  `source = 'builtin'`) so a duplicate seed batch is rejected at the database, even
  if the client `syncInFlight` guard ever fails. Self-contained and idempotent: it
  first raises a clear error if duplicate built-in groups exist, then creates the
  index with `if not exists`. Applied live 2026-06-19 (pre-flight clean).
- `migrations/20260618_phase5_scheduled_purge.sql` adds a server-side daily
  `pg_cron` sweep (`purge_old_deleted_items()`) that hard-deletes every user's
  `deleted` items older than 30 days, independent of logins. The client-side
  login sweep (`purgeOldDeleted` in `index.html`) is retained as a fast-path
  backup. Requires the `pg_cron` extension (the migration creates it; on Supabase
  it can also be enabled in Dashboard → Database → Extensions).

Apply these migrations to a fresh Supabase project, in filename (date) order,
after the base tables exist and before testing Phase 4 sharing.

### Scheduled purge (Phase 5) checks

```sql
-- The cron job is registered and active
select jobid, jobname, schedule, active, command
from cron.job
where jobname = 'purge-old-deleted-items';

-- Run the sweep on demand; returns the row count it hard-deleted
select public.purge_old_deleted_items();

-- Recent run history (success/failure)
select status, return_message, start_time, end_time
from cron.job_run_details
where jobid = (select jobid from cron.job where jobname = 'purge-old-deleted-items')
order by start_time desc
limit 5;
```

## Verification Queries

Use these in Supabase SQL Editor to compare a live project against the committed
migration:

```sql
select *
from pg_policies
where schemaname = 'public'
  and tablename in ('lists', 'list_items', 'list_shares')
order by tablename, policyname;
```

```sql
select pg_get_functiondef('public.is_list_owner(uuid)'::regprocedure);

select pg_get_functiondef('public.is_list_shared_with_me(uuid)'::regprocedure);
```
