# EGX Investment OS — Project State & Decision Log

**Purpose:** Canonical continuity record. Read before proposing user actions, reopening blockers, or changing accepted decisions. Update whenever material implementation status, blockers, accepted limitations, safety decisions, deployment state, or next-step dependencies change.

**Last updated:** 2026-09-14 (Africa/Cairo)

## Working protocol
- Proceed continuously unless there is a genuine blocker, critical/destructive/security-sensitive decision, cost/authorization requirement, or required user input.
- Use conservative defaults for non-critical choices.
- Do not repeat completed/unavailable user actions unless new evidence changes status.
- Keep real-money/broker execution disabled until explicit approval after validation/go-live review.

## Production state
- Supabase production project: `egx-investment-os` (`hpolboqjrchstbsdhwuh`).
- GitHub: `NaderNashaat111/EGX-investment-os`, `main`; connector read/write WORKING.
- Vercel Git auto-deploy WORKING; production frontend HTTP 200 with hardened security/cache headers.
- GitHub Actions `Production smoke checks` enabled, runs every 6 hours plus push/manual, and latest hardened run PASS.
- Frontend reliability preserves workspace/recommendation/history data across transient refresh failures and avoids false onboarding/empty states.

## Backend / operations
- Market/evidence ingestion, analysis, AI thesis, deterministic decision engine, recommendation lifecycle, portfolio state, shadow recommendation/evaluation, and ops snapshots are implemented.
- 12/12 required cron jobs active with expected schedule/command at latest audit.
- Latest audit: 0 non-success cron runs in prior 24h; 0 non-success user API outcomes; latest ops/self-test PASS; `real_money_execution=false`.
- Current AI/release contracts, user API health, scheduler health, data pipeline health, shadow policy contract, release lineage, and execution safety all PASS.
- Supabase performance advisor currently reports 53 `unused_index` INFO notices. Decision: do not remove indexes until meaningful workload history exists.

## Security / integrity
- Supabase security advisor is clean except `Leaked Password Protection Disabled`, which is unavailable on the current plan and is an accepted limitation, not a blocker. Do not ask user to enable again unless plan/capability changes. Reference: https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection
- Deep integrity audit: 0 recommendation portfolio/instrument orphans; 0 decision recommendation orphans; 0 AI attempt/request or dispatch/request orphans; 0 duplicate dispatch/request groups; 0 duplicate `(request_id,attempt_no)` groups; 0 tested real-money recommendation/generation rows.
- All public application tables have RLS enabled.
- Audit discovered an unnecessary authenticated mutation surface on `portfolio_positions`, including `TRUNCATE` privilege. Migration `harden_portfolio_positions_authenticated_privileges` revoked authenticated INSERT/UPDATE/DELETE/TRUNCATE on that table. Verification leaves only the intentionally supported authenticated mutations: `portfolios UPDATE` and `portfolio_transactions INSERT`, both RLS constrained.
- Post-migration security advisor still has only the accepted leaked-password warning.
- User APIs require verified JWT sessions; internal `verify_jwt=false` workers/ingestors reviewed use backend-key authorization. Public `user-auth-portal` is GET-only.
- `ops/operational-readiness.sql` now provides repeatable read-only integrity, RLS, mutation-surface, ops-snapshot, and evidence-gap checks.
- `OPERATIONS_SLO.md` defines zero-tolerance safety invariants and scheduler/data/AI/API/recommendation/calibration/recovery thresholds.

## AI thesis / current cohort
- GPT-5.6 Sol provider path operational.
- Tracked FULL_THESIS cohort: 19 dispatches COMPLETED; 19/19 latest attempts VALIDATED with READY evidence and deterministic risk ALLOW.
- 21 attempts total: two initial `PROVIDER_INCOMPLETE:max_output_tokens` attempts correctly rejected/retried and recovered. No unresolved provider/validator failures.
- Cairo daily budget reset succeeded; worker resumed automatically. Daily safety gate remains 20 provider calls/Cairo day and must be respected.
- Post-AI settlement: 19/19 thesis/fresh/mode/current-release/quality PASS, zero pending/failed dispatches.
- Current release: `decision-release-v0.8.3`, engine `decision-engine-v0.8.3`, packet `analysis-packet-v0.9`, risk `risk-v0.4`, prompt `thesis-prompt-v0.2`.
- Portfolio cohort: 19 recommendations = 4 BUY, 1 HOLD, 14 WATCH, 0 SELL; all `real_money_execution=false`.
- Shadow cohort: 19 candidates = 2 ELIGIBLE, 15 WATCH, 2 BLOCKED; 2 PRETRADE_PENDING; pretrade 2 ALLOW / 0 BLOCK. Research-only intents wait for a valid market bar.
- 68 outcome evaluations scheduled across 5/20/60/120-day horizons. Earliest due 2026-09-20 18:30 UTC / 21:30 Cairo.
- Decision: freeze AI prompt, decision thresholds, allocation policy, and performance-driven tuning until baseline outcome data matures.

## Parallel hardening — completed 2026-09-14
- Data-integrity and privilege audit completed; unsafe `portfolio_positions` authenticated privileges removed.
- Failure/recovery smoke coverage expanded: unauthenticated user APIs must reject; backend-only functions reject missing backend key; auth portal POST rejected; no-live-broker assertion retained.
- Operational monitoring improved to six-hour external smoke checks plus internal ops snapshots/cron health.
- Calibration preparation completed: `ops/calibration-report.sql` covers maturity, absolute/benchmark/excess return, outcomes, candidate details, quality/risk and safety invariants.
- Recovery readiness documented in `RECOVERY.md`; off-site logical backup automation remains credential-dependent and credentials must stay in a private secret store.
- Operational SLOs and repeatable production integrity audit added.
- Frontend/API contract/static UX review found no current contract blocker; responsive/mobile, empty/loading/error/retry/onboarding/accessibility states are implemented. Full authenticated visual E2E remains tooling-blocked.
- Repository housekeeping completed: obsolete `vercel-trigger.txt` removed. Production deploy remains Git-driven.

## EGAL evidence gap
- One OPEN non-global-blocking source gap remains: `EGAL:2026-03-31:NET_PROFIT_COMPARABLE` / `KNOWN_OFFICIAL_DISCLOSURE_UNRETRIEVED`.
- Expected official bulletin: EGX bulletin 339881, published 2026-06-17, period 2025-07-01 to 2026-03-31.
- Secondary mirrors consistently corroborate reported net profit 10,447,306,397 and comparator 9,894,435,798, but policy correctly forbids promoting those secondary values to READY.
- Existing attempts include EGX news search, financial-statements filter/date range, issuer IR index, attachment discovery, frontend contract discovery, and public-web attachment discovery.
- A fresh public-web search on 2026-09-14 did not recover a first-party EGX/issuer asset. Therefore the gap cannot be safely closed now without weakening evidence policy. Decision: keep OPEN/non-blocking and retry only when an exact official asset becomes retrievable.

## Frontend / QA
Completed: workspace initial-load failure handling, retry state, stale workspace/recommendation/history preservation, safe portfolio-switch clearing, hardened headers, production smoke/API boundary tests, operations runbook, responsive/mobile and accessibility static review.

Known limitation: full authenticated interactive browser click-through E2E cannot be completed from the assistant environment because the required interactive browser capability is unavailable. This is a tooling limitation, not user configuration work.

## Recovery / backup
- `RECOVERY.md` documents logical dump/restore, secrets handling and post-restore acceptance checks.
- Automated off-site DB export is not enabled because it requires a private DB connection credential in a secret store. Never place credentials/backups in the public repository or chat.

## Remaining blockers / dependencies
1. **Outcome calibration:** time-dependent; first 5-day evaluation due 2026-09-20 21:30 Cairo, then 20/60/120-day horizons.
2. **Authenticated visual/browser E2E:** blocked by assistant environment browser tooling.
3. **Automated off-site DB backup:** blocked on private DB credential/secret-store configuration; documented manual recovery path exists.
4. **EGAL official evidence gap:** exact first-party attachment currently unretrievable; non-blocking and must not be filled from secondary mirrors.
5. Supabase leaked-password warning is accepted plan limitation, not blocker.

## Next execution sequence
1. Preserve baseline and continue normal scheduled ingestion/analysis/AI/shadow/recommendation cycles.
2. Continue six-hour production/security smoke checks and operational SLO monitoring.
3. Verify simulated shadow fills after next valid market bar.
4. Retry EGAL official-asset retrieval only through exact official/first-party evidence paths.
5. At/after 2026-09-20 21:30 Cairo run `ops/calibration-report.sql` and analyze first mature 5-day outcomes; accumulate 20/60/120-day outcomes before stronger calibration conclusions.
6. Keep real-money execution disabled until explicit go-live approval.

## Material change log
- 2026-09-13: GitHub write restored; Vercel security/cache hardening, frontend reliability fixes, runbook, and production smoke deployed; leaked-password plan limitation accepted; AI cohort safely paused at daily call cap.
- 2026-09-14: Cairo budget reset; 19/19 cohort completed and validated; downstream 19 recommendations/68 evaluations created.
- 2026-09-14: Parallel hardening completed: integrity/security audit, six-hour smoke/API boundaries, calibration SQL, recovery runbook, frontend edge/static review.
- 2026-09-14: Deep privilege audit found and removed authenticated mutation/TRUNCATE privileges from `portfolio_positions`; post-migration security advisor remains clean except accepted auth warning.
- 2026-09-14: Added `ops/operational-readiness.sql` and `OPERATIONS_SLO.md`; removed obsolete `vercel-trigger.txt`.
- 2026-09-14: EGAL bulletin 339881 retrieval retried; exact official asset still unavailable, so gap remains correctly OPEN/non-blocking rather than weakening evidence standards.
