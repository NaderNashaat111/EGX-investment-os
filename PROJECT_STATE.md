# EGX Investment OS — Project State & Decision Log

**Purpose:** Canonical continuity record. Read before proposing user actions, reopening blockers, or changing accepted decisions. Update whenever material implementation status, blockers, accepted limitations, safety decisions, deployment state, or next-step dependencies change.

**Last updated:** 2026-09-15 (Africa/Cairo)

## Working protocol
- Proceed continuously unless there is a genuine blocker, critical/destructive/security-sensitive decision, cost/authorization requirement, or required user input.
- Use conservative defaults for non-critical choices.
- Do not repeat completed/unavailable user actions unless new evidence changes status.
- Keep real-money/broker execution disabled until explicit approval after validation/go-live review.

## Production state
- Supabase production project: `egx-investment-os` (`hpolboqjrchstbsdhwuh`).
- GitHub: `NaderNashaat111/EGX-investment-os`, `main`; connector read/write WORKING.
- Vercel Git auto-deploy WORKING; production frontend HTTP 200 with hardened security/cache headers at latest verification.
- GitHub Actions `Production smoke checks` enabled with incident lifecycle alerting.
- Frontend reliability preserves workspace/recommendation/history data across transient refresh failures and avoids false onboarding/empty states.

## Backend / operations
- Market/evidence ingestion, analysis, AI thesis, deterministic decision engine, recommendation lifecycle, portfolio state, shadow recommendation/evaluation, and ops snapshots are implemented.
- 12/12 required cron jobs active with expected schedule/command at latest audit.
- Core user API, scheduler, data pipeline, shadow policy, release-lineage and execution-safety contracts passed latest non-AI verification.
- `real_money_execution=false`; records-only/no-trade boundary remains mandatory.
- Supabase performance advisor unused-index notices are informational on this young workload; do not remove indexes solely because usage is currently zero.

## Security / integrity
- Supabase `Leaked Password Protection Disabled` is unavailable on the current plan and is an accepted limitation, not a blocker. Do not ask the user to enable it again unless plan/capability changes.
- Deep integrity audit found zero tested recommendation/decision/AI relationship orphans and zero tested real-money rows.
- All public application tables have RLS enabled.
- Migration `harden_portfolio_positions_authenticated_privileges` removed unnecessary authenticated mutation/TRUNCATE privileges from `portfolio_positions`.
- User APIs require verified JWT sessions; internal workers/ingestors reviewed use backend-key authorization. Public `user-auth-portal` is GET-only.
- `ops/operational-readiness.sql` provides repeatable read-only integrity, RLS, mutation-surface, ops-snapshot and evidence-gap checks.
- `OPERATIONS_SLO.md` defines zero-tolerance safety invariants and scheduler/data/AI/API/recommendation/calibration/recovery thresholds.

## AI thesis / current cohort
- GPT-5.6 Sol provider path operational.
- Baseline FULL_THESIS cohort previously completed and validated: 19/19 latest attempts VALIDATED with READY evidence and deterministic risk ALLOW.
- Portfolio baseline: 19 recommendations = 4 BUY, 1 HOLD, 14 WATCH, 0 SELL; all `real_money_execution=false`.
- Shadow baseline: 19 candidates = 2 ELIGIBLE, 15 WATCH, 2 BLOCKED; pretrade 2 ALLOW / 0 BLOCK at baseline checkpoint.
- 68 outcome evaluations scheduled across 5/20/60/120-day horizons. Earliest due 2026-09-20 18:30 UTC / 21:30 Cairo.
- Decision: freeze AI prompt, decision thresholds, allocation policy, and performance-driven tuning until baseline outcome data matures.

## Recovery / backup — operational
- `ops/logical-backup.sh` safely exports roles/grants, schema and data with component checksum validation and guarded temporary storage.
- Private Cloudflare R2 bucket `egx-investment-os-backups` is the approved off-site destination.
- GitHub Actions secrets `SUPABASE_DB_URL`, `R2_ACCESS_KEY_ID`, and `R2_SECRET_ACCESS_KEY` are configured; credentials are not stored in repository files or chat.
- `.github/workflows/offsite-backup.yml` is enabled on a daily 01:20 UTC / 04:20 Cairo schedule plus manual dispatch.
- First real production backup run `35017101867` completed SUCCESS on 2026-09-15: roles, schema and data exported; component checks passed; bundle and checksum uploaded to R2; remote object presence verified; runner copy removed.
- Workflow hardened after the successful run to use Node-24-compatible `actions/checkout@v5` and to download the uploaded R2 bundle and require SHA-256 equality with the local bundle before success.
- Remaining backup-control item: enable a Cloudflare R2 Object lifecycle rule for prefix `daily/` with 35-day expiry. This is configuration-only; the actual automated off-site backup path is working.
- `RECOVERY.md` is updated with the live configuration, first successful run, retention target, restore caveats and restore-drill requirement.

## EGAL evidence gap
- One OPEN non-global-blocking source gap remains: `EGAL:2026-03-31:NET_PROFIT_COMPARABLE` / `KNOWN_OFFICIAL_DISCLOSURE_UNRETRIEVED`.
- Expected official bulletin: EGX bulletin 339881, published 2026-06-17, period 2025-07-01 to 2026-03-31.
- Secondary mirrors corroborate values but policy correctly forbids promoting secondary values to READY.
- Keep OPEN/non-blocking and retry only when an exact official first-party asset becomes retrievable.

## Frontend / QA
Completed: workspace initial-load failure handling, retry state, stale workspace/recommendation/history preservation, safe portfolio-switch clearing, hardened headers, production smoke/API boundary tests, operations runbook, responsive/mobile and accessibility static review.

Known limitation: full authenticated interactive browser click-through E2E cannot be completed from the current assistant environment. This is a tooling limitation, not user configuration work.

## Remaining blockers / dependencies
1. **Outcome calibration:** time-dependent; first 5-day evaluation due 2026-09-20 21:30 Cairo, then 20/60/120-day horizons.
2. **R2 retention policy:** user-owned Cloudflare bucket setting; enable 35-day expiry for prefix `daily/`. Backup creation/upload itself is verified working.
3. **Authenticated visual/browser E2E:** blocked by current assistant browser tooling.
4. **EGAL official evidence gap:** exact first-party attachment currently unretrievable; non-blocking and must not be filled from secondary mirrors.
5. Supabase leaked-password warning is accepted plan limitation, not blocker.

## Next execution sequence
1. Enable/verify the R2 35-day lifecycle rule, then close backup configuration as operationally complete.
2. Preserve baseline and continue normal scheduled ingestion/analysis/AI/shadow/recommendation cycles.
3. Continue production/security smoke checks, automatic incident lifecycle, and operational SLO monitoring.
4. Verify subsequent scheduled off-site backup succeeds with the new remote checksum comparison.
5. Retry EGAL official-asset retrieval only through exact official/first-party evidence paths.
6. At/after 2026-09-20 21:30 Cairo run `ops/calibration-report.sql` and analyze first mature 5-day outcomes; accumulate 20/60/120-day outcomes before stronger calibration conclusions.
7. Keep real-money execution disabled until explicit go-live approval.

## Material change log
- 2026-09-13: GitHub write restored; Vercel security/cache hardening, frontend reliability fixes, runbook, and production smoke deployed; leaked-password plan limitation accepted.
- 2026-09-14: Baseline 19/19 AI cohort completed and validated; downstream recommendations/evaluations created.
- 2026-09-14: Parallel hardening completed: integrity/security audit, smoke/API boundaries, calibration SQL, recovery runbook and frontend edge/static review.
- 2026-09-14: Authenticated mutation/TRUNCATE privileges removed from `portfolio_positions`.
- 2026-09-14: EGAL exact official asset remained unavailable; gap retained OPEN/non-blocking.
- 2026-09-15: Cloudflare R2 off-site destination and GitHub backup secrets configured. First production logical backup successfully exported and uploaded to R2 in Actions run `35017101867`.
- 2026-09-15: Backup workflow hardened with Node-24-compatible checkout and end-to-end remote SHA-256 verification; recovery documentation updated. Only R2 35-day lifecycle configuration remains before closing backup setup.
