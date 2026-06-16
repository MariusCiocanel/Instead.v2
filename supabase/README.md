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

Apply these migrations to a fresh Supabase project after the base tables exist
and before testing Phase 4 sharing.

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
