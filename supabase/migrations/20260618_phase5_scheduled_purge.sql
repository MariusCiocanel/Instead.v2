-- Phase 5: server-side scheduled purge of soft-deleted items.
--
-- The app already runs a client-side sweep on login (`purgeOldDeleted` in
-- index.html), but that only purges the rows of whoever just signed in and only
-- when they sign in — so a user who never returns leaves >30-day `deleted` rows
-- behind, and purges are never exact-time. This adds an authoritative server-side
-- sweep via pg_cron that hard-deletes EVERY user's expired rows daily, regardless
-- of logins. The client-side sweep is kept as a fast-path backup.
--
-- Window is 30 days, matching PURGE_DAYS in the app.

-- 1. pg_cron extension. On Supabase this can also be enabled in
--    Dashboard -> Database -> Extensions; creating it here is idempotent.
create extension if not exists pg_cron;

-- 2. Purge function. SECURITY DEFINER so the sweep spans all users' rows
--    (bypasses RLS); returns the number of rows hard-deleted.
create or replace function public.purge_old_deleted_items()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_deleted integer;
begin
  delete from public.items
  where status = 'deleted'
    and deleted_at is not null
    and deleted_at < now() - interval '30 days';
  get diagnostics v_deleted = row_count;
  return v_deleted;
end;
$$;

-- Only the scheduler / service role should invoke it; not anon/authenticated.
revoke all on function public.purge_old_deleted_items() from public;
grant execute on function public.purge_old_deleted_items() to service_role;

-- 3. Schedule it daily at 03:15 UTC. Unschedule first so re-running this
--    migration re-points the job cleanly instead of erroring on a duplicate name.
do $$
begin
  perform cron.unschedule('purge-old-deleted-items');
exception
  when others then null;  -- job did not exist yet
end $$;

select cron.schedule(
  'purge-old-deleted-items',
  '15 3 * * *',
  $$select public.purge_old_deleted_items();$$
);
