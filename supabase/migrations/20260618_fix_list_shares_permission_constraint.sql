-- Fix drift in the list_shares.permission check constraint.
--
-- An earlier draft created `list_shares_permission_check` with the vocabulary
-- ('view', 'edit'). The Phase 4 migration (20260616_phase4_sharing.sql) adds the
-- correct ('viewer', 'editor') constraint, but guards it with
-- `exception when duplicate_object then null` — so on any database that already
-- had the old constraint, the add was silently skipped and the stale ('view',
-- 'edit') definition survived. The app and `create_list_share_by_email` both send
-- 'viewer'/'editor', so every invite failed the constraint and rolled back
-- (no list_shares row was ever created).
--
-- This drops the stale constraint and installs the correct one unconditionally,
-- and aligns the column default. The drop-then-add form is idempotent (re-running
-- always drops first). Safe to run on an empty or correctly-populated table; if a
-- legacy row still held 'view'/'edit' it would need to be remapped first.

alter table public.list_shares
  drop constraint if exists list_shares_permission_check;

alter table public.list_shares
  add constraint list_shares_permission_check
  check (permission in ('viewer', 'editor'));

-- The original column default may still be the legacy 'view'; the invite RPC always
-- sets permission explicitly, but keep the default consistent with the constraint.
alter table public.list_shares
  alter column permission set default 'viewer';
