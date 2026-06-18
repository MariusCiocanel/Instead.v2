# Instead — Roadmap & Outstanding Tasks

_Last updated: 2026-06-16. Resume point after Phase 3 (Supabase data layer) shipped and was live-tested._

## Where things stand

**Phase 3 (Supabase data integration) is complete, deployed to `main`, and verified live.**
All cloud write paths tested end-to-end against the real DB: add, edit, archive,
restore, soft-delete, Recently Deleted (restore + delete-forever), and URL-de-duped import.
Guest mode (localStorage) is preserved behind the `isCloud()` switch.

Relevant commits on `main`: `bb4c20c` (scaffolding) → `750e0b4` (seed/fetch/purge) →
`d8381ea` (add/edit) → `8cff23a` (archive/soft-delete) → `caaab81` (Recently Deleted) →
`22a7a22` (import) → `2d70445` (URL-match import) → `d68ba46` (double-seed guard).

### Bugs found & fixed during live testing
1. **RLS infinite recursion** in the sharing-table policies (`lists` ↔ `list_shares`),
   which broke ALL cloud reads. Fixed DB-side with two `SECURITY DEFINER` helpers:
   `public.is_list_owner(uuid)` and `public.is_list_shared_with_me(uuid)`, and rewriting
   the recursive policies to call them. The live hotfix is now captured in
   `supabase/migrations/20260616_fix_list_rls_recursion.sql`.
2. **Double-seed** on concurrent auth events (seeded 102 rows). Fixed with a `syncInFlight`
   guard in `syncOnLogin()` (`d68ba46`).

---

## A. Finish Phase 3 verification (small, do first) — ✅ DONE (2026-06-18)

All three verified against a throwaway Supabase account, driven through the live app.

1. ~~**Guest-mode regression**~~ — ✅ PASS. Signed-out add/edit/archive/restore/delete/surprise/backup
   all work and persist across reload. Note: "Recently Deleted" (restore / delete-forever) is
   **cloud-only** — in guest mode custom deletes are permanent and built-ins just hide.
2. ~~**Import built-in patch path**~~ — ✅ PASS, with one bug found & fixed. Both the
   auto-migration (first login → `migrateLocalToCloud`) and the manual import
   (`importLocalData`, URL-matched) patch built-ins in place with no duplicate rows; custom
   items insert and de-dupe correctly.
   - **Bug fixed:** `b23` "Fixing a Hole Short" shared an identical URL with `b4` "Fixing a Hole",
     so the URL-keyed `byKey` map collided and a local edit to one was patched onto the other.
     Removed the redundant `b23` (`df2bca9`); `BUILT_IN` now has no duplicate URLs.
3. ~~**30-day purge**~~ — ✅ PASS. A `deleted` row backdated 40 days is hard-deleted by
   `purgeOldDeleted()` (the function `syncOnLogin` runs); a 2-day-old `deleted` row survives.

## B. Phase 3 hardening (optional, low effort)

4. **DB-level seed safety net** — partial unique index on `items(user_id, source, title, url)`
   for built-ins, so a future concurrency bug can't double-seed even if the client guard fails.
5. **Cloud-aware backup** — `backupData()` should export from Supabase when signed in
   (currently exports in-memory/local only).

## C. Phase 4 — Sharing (main remaining feature)

Schema exists (`lists`, `list_items`, `list_shares`). RLS foundation is sound (the
`SECURITY DEFINER` helpers) — build on those, do NOT reintroduce cross-table policy subqueries.

_Implementation note: Phase 4 sharing has been added in `index.html` and
`supabase/migrations/20260616_phase4_sharing.sql`. Live Supabase migration and
end-to-end verification are still required before marking it shipped._

6. **Lists data layer** — CRUD for `lists` (create/rename/delete, `is_public`, `share_slug`), cloud-only.
7. **Lists UI** — a surface (sheet or tab) to view/create/manage lists.
8. **Add/remove items to lists** — `list_items` writes + an "Add to list" affordance on cards.
9. **Share a list** — create `list_shares` (pending). _See open decision below._
10. **Accept / view shared lists** — recipient sees pending shares, accepts (`accepted=true`),
    reads shared lists + items (relies on the RLS helpers), respecting `permission`.
11. **Public lists** — read-only public view via `share_slug` for `is_public` lists (no auth).

## D. Phase 5 — Exact-time purge (optional)

12. **Scheduled server-side purge** — Supabase scheduled Edge Function / `pg_cron` that
    hard-deletes `deleted` rows past 30 days, replacing the client-side login sweep.

---

## Suggested order
A (close out Phase 3) → C (Phase 4 sharing) → B and D as opportunistic hardening.

## Open decision before Phase 4 (tasks 9–11)
**How does sharing target a person?**
- **Email lookup** — needs a server-side way to resolve email → user id (`auth.users` is not
  directly queryable from the client; would require an RPC/Edge Function).
- **Invite link** — use `share_slug`, no lookup needed.

This choice shapes tasks 9–11; settle it before starting Phase 4.

## Schema reference (`items`)
`id uuid pk`, `user_id uuid`, `cat text` (CHECK: nourishment/professional/company/share/ideas),
`emoji`, `title`, `sub`, `notes`, `url`, `status text` (CHECK: active/archived/**deleted**),
`archived_at`, `deleted_at`, `source text` (CHECK: builtin/custom), `sort_order int`,
`created_at`, `updated_at`. (The `deleted` status + `deleted_at` were added during Phase 3.)
