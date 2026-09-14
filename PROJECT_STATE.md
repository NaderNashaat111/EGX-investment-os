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
- GitHub Actions workflow `Production smoke checks`: **ENABLED AND VERIFIED PASS**. First run #1 completed successfully on 2026-09-13 in ~53 seconds.
- Latest frontend reliability changes preserve workspace/recommendation/history data across transient refresh failures and avoid false onboarding/false empty states.

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
- Tracked FULL_THESIS batch size: **19 dispatches**.
- **2026-09-14 update:** the Cairo daily provider budget reset occurred successfully and the worker resumed automatically.
- The tracked 19-dispatch batch is now **19 COMPLETED / 0 QUEUED / 0 RETRY / 0 RUNNING / 0 WAITING_PROVIDER / 0 FAILED**.
- Current Cairo-day provider usage at the latest check: **16 calls**, about **$1.91 estimated spend**, 334,885 input tokens and 21,923 output tokens.
- Budget function currently allows additional calls, while the worker gate reports `NO_DUE_WORK` because no thesis dispatches are due.
- Daily provider safety gate remains **20 calls per Cairo calendar day**.
- **Decision:** continue respecting the safety gate; do not bypass it merely to finish sooner.

## Frontend reliability / QA

Completed:
- Workspace initial-load failure no longer falsely routes existing users into onboarding.
- Retry/error state exists for initial workspace failure.
- Previously loaded workspace is preserved on transient refresh failure.
- Previously loaded recommendation/history data is preserved on transient refresh failure.
- Portfolio switches still clear portfolio-specific data intentionally to prevent cross-portfolio visual leakage.
- Production security/cache headers hardened.
- Automated production smoke checks added and first GitHub Actions run passed.
- Production operations runbook added to repository.

Known QA limitation:
- Full authenticated interactive browser click-through E2E has not been completed from the assistant environment because the required browser CLI/tool is unavailable there.
- This is an environment/tooling limitation, not currently a user configuration action.

## Current blockers / dependencies

1. **AI/shadow calibration:** thesis dispatch completion is no longer a blocker; next step is validating the completed outputs and downstream evaluation state.
2. **Authenticated browser E2E:** requires suitable interactive browser capability.
3. Supabase leaked-password warning is an **accepted plan limitation**, not a blocker.

## Next execution sequence

1. Validate the completed 19-thesis batch at attempt/output level and inspect any non-validated/incomplete attempts that were retried before final completion.
2. Verify downstream post-AI shadow operations and portfolio recommendation cycle consumed the completed batch correctly.
3. Run recommendation/shadow evaluation and begin quality/calibration analysis.
4. Reassess go-live readiness only after sufficient validation evidence; keep real-money execution disabled until explicit approval.

## Material change log

- **2026-09-13:** GitHub write blocker resolved; repository writes work again.
- **2026-09-13:** Production Vercel security/cache hardening deployed.
- **2026-09-13:** Workspace false-onboarding reliability fix deployed.
- **2026-09-13:** Recommendation/history transient-refresh preservation fix deployed.
- **2026-09-13:** Production operations runbook added.
- **2026-09-13:** Automated GitHub Actions production smoke workflow added; run #1 passed.
- **2026-09-13:** Supabase leaked-password protection explicitly recorded as unavailable on current plan and accepted, so it must not be repeatedly presented as a user action.
- **2026-09-13:** AI batch paused safely at daily 20-provider-call Cairo budget cap.
- **2026-09-14:** Cairo daily AI budget reset succeeded; worker resumed automatically and completed the remaining tracked thesis dispatches. Batch is now 19/19 completed with zero queued/retry/failed dispatches.
