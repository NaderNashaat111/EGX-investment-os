# EGX Investment OS — Project State & Decision Log

**Purpose:** Canonical continuity record for future EGX Investment OS work. Read this before proposing user actions, re-opening blockers, or changing an accepted decision. Update it whenever a material implementation status, blocker, accepted limitation, safety decision, deployment state, or next-step dependency changes.

**Last updated:** 2026-09-14 (Africa/Cairo)

## Working protocol

- Proceed continuously without pausing unless there is a genuine blocker, critical/destructive/security-sensitive decision, cost/authorization requirement, or required user input.
- Use conservative defaults for non-critical choices.
- Do not ask the user to repeat an action already recorded here as completed, unavailable, or accepted unless new evidence changes its status.
- Real-money/broker execution remains disabled unless explicitly approved after validation and go-live readiness review.

## Current production state

- Supabase project `egx-investment-os` (`hpolboqjrchstbsdhwuh`) is the production backend.
- GitHub repository: `NaderNashaat111/EGX-investment-os`, default branch `main`.
- GitHub connector read/write access: **WORKING**.
- Vercel Git auto-deployment: **WORKING**.
- Production Vercel project: `egx-investment-os`.
- Production frontend returns HTTP 200 and hardened security/cache headers are live.
- GitHub Actions workflow `Production smoke checks`: **ENABLED AND VERIFIED PASS**.
- Frontend reliability changes preserve workspace/recommendation/history data across transient refresh failures and avoid false onboarding/false empty states.

## Backend / operations

- Core market/evidence ingestion, analysis, AI thesis, deterministic decision engine, recommendation lifecycle, portfolio state, shadow recommendation/evaluation, and operational snapshot infrastructure are implemented.
- All 12 required cron jobs are present, active, and matched their expected schedules at the latest audit.
- Latest audit found zero non-success cron runs in the prior 24 hours.
- Supabase performance advisor reports 55 `unused_index` notices. **Decision: do not remove indexes yet**; system is too new for usage statistics to justify deletion. Revisit after meaningful workload history.

## Security decisions / accepted limitations

### Supabase Leaked Password Protection
- Advisor warning: `Leaked Password Protection Disabled`.
- **Known limitation:** this feature is only available on a Supabase paid/Pro plan for the user's current setup.
- The user and assistant already attempted to enable it and could not because of the plan restriction.
- **Decision:** accepted limitation on the current plan. It is **NOT a blocker and requires NO user action**.
- Do **not** ask the user to enable it again unless the Supabase plan changes or Supabase makes the feature available on the current plan.

### Real-money execution
- `real_money_execution=false` and records-only/no-trade behavior are intentional.
- **Decision:** keep real-money execution disabled through AI validation, shadow evaluation, calibration, and explicit go-live approval.

## AI thesis batch / budget

- AI provider/model path is operational and successfully producing GPT-5.6 Sol theses.
- Tracked FULL_THESIS cohort: **19 dispatches, all COMPLETED**.
- Final/latest attempt for **19/19 is VALIDATED**; all 19 have READY evidence and deterministic risk state ALLOW.
- There were **21 total attempts**: two first attempts ended `PROVIDER_INCOMPLETE:max_output_tokens`; both were correctly rejected, retried, and subsequently VALIDATED. There are no unresolved provider/validator failures in this cohort.
- Cairo daily provider budget reset succeeded and the worker resumed automatically.
- Daily provider safety gate remains **20 calls per Cairo calendar day**. **Decision:** continue respecting it.

## Latest downstream cohort state

- Post-AI settlement is **SETTLED**: 19/19 with thesis, 19/19 fresh, 19/19 mode matches, 19/19 current-release matches, 19/19 quality PASS, zero pending/failed dispatches.
- Current release lineage: `decision-release-v0.8.3`, `decision-engine-v0.8.3`, `analysis-packet-v0.9`, `risk-v0.4`, `thesis-prompt-v0.2`.
- Portfolio recommendation generation consumed the cohort and created **19 recommendations**: **4 BUY, 1 HOLD, 14 WATCH, 0 SELL**. All have risk state ALLOW and `real_money_execution=false`.
- Shadow cohort has **19 candidates**: 2 ELIGIBLE, 15 WATCH, 2 BLOCKED; 2 are PRETRADE_PENDING and 17 SCREEN_ONLY.
- Pretrade produced **2 ALLOW / 0 BLOCK** assessments for this cohort. No real-money execution occurred.
- **68 shadow outcome evaluations** are scheduled across 5/20/60/120-day horizons. None are due/evaluated yet; earliest due timestamp is **2026-09-20 18:30 UTC (21:30 Cairo)**.
- **Decision:** do not tune AI prompts, decision thresholds, allocation policy, or indexes based on outcome performance before the first due evaluation data arrives; preserve this cohort as a clean calibration baseline.

## Frontend reliability / QA

Completed:
- Workspace initial-load failure no longer falsely routes existing users into onboarding.
- Retry/error state exists for initial workspace failure.
- Previously loaded workspace is preserved on transient refresh failure.
- Previously loaded recommendation/history data is preserved on transient refresh failure.
- Portfolio switches still clear portfolio-specific data intentionally to prevent cross-portfolio visual leakage.
- Production security/cache headers hardened.
- Automated production smoke checks added and verified.
- Production operations runbook added to repository.

Known QA limitation:
- Full authenticated interactive browser click-through E2E has not been completed from the assistant environment because the required browser CLI/tool is unavailable there.
- This is an environment/tooling limitation, not currently a user configuration action.

## Current blockers / dependencies

1. **Outcome calibration:** infrastructure and schedules are ready, but actual cohort performance evaluation is time-dependent. First 5-day evaluation is due 2026-09-20 21:30 Cairo; longer horizons follow.
2. **Authenticated browser E2E:** requires suitable interactive browser capability.
3. Supabase leaked-password warning is an **accepted plan limitation**, not a blocker.

## Next execution sequence

1. Preserve the validated 19-name cohort as the baseline; do not make premature policy/prompt tuning changes.
2. Continue normal scheduled ingestion/analysis/shadow cycles and verify no operational regressions.
3. At/after 2026-09-20 21:30 Cairo, verify the first 5-day outcome evaluations populate and analyze return/excess-return/outcome-state quality.
4. Accumulate subsequent 20/60/120-day outcomes before stronger calibration conclusions.
5. Reassess go-live readiness only after sufficient validation evidence; keep real-money execution disabled until explicit approval.

## Material change log

- **2026-09-13:** GitHub write blocker resolved; repository writes work again.
- **2026-09-13:** Production Vercel security/cache hardening deployed.
- **2026-09-13:** Workspace false-onboarding reliability fix deployed.
- **2026-09-13:** Recommendation/history transient-refresh preservation fix deployed.
- **2026-09-13:** Production operations runbook added.
- **2026-09-13:** Automated GitHub Actions production smoke workflow added and passed.
- **2026-09-13:** Supabase leaked-password protection recorded as unavailable on current plan and accepted.
- **2026-09-13:** AI batch paused safely at daily 20-provider-call Cairo budget cap.
- **2026-09-14:** Cairo daily AI budget reset succeeded; worker resumed and completed the tracked batch.
- **2026-09-14:** Cohort audit completed: 19/19 final attempts VALIDATED; two max-output-token incomplete attempts recovered correctly on retry; downstream universe settled 19/19 quality PASS/current-release/fresh; 19 portfolio recommendations generated; 68 shadow evaluations scheduled, first due 2026-09-20 21:30 Cairo.
