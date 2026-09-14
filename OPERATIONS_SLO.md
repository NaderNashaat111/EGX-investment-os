# EGX Investment OS — Operational SLOs

These thresholds are production-readiness guardrails for the research/shadow system. They do not authorize broker or real-money execution.

## Safety invariants (zero tolerance)

- `real_money_execution=true`: 0 rows across recommendations, generation runs, shadow execution artifacts, and operational state.
- Orphan recommendation/decision/AI lineage rows: 0.
- Duplicate AI dispatch per request or duplicate attempt number per request: 0.
- Authenticated/anonymous `TRUNCATE` privilege on public application tables: 0.
- Broker order execution capability: disabled.

Any violation is **CRITICAL** and blocks downstream actionability until investigated.

## Scheduler and pipeline

- Expected cron jobs: 12/12 active with exact registered schedules.
- Latest run failure for any required job: **ERROR**.
- Required job stale/running beyond its normal execution window: **ERROR**.
- Any non-success cron result in the prior 24h: **WARN**, escalated to **ERROR** if it affects current market/evidence/AI/recommendation settlement.
- Market-data freshness must match the latest expected EGX session. A missing expected session is **ERROR**; calendar-day age during weekends/holidays is not itself an error.
- Current AI universe must settle to the expected eligible-instrument count before allocation/recommendation actionability.

## AI/provider

- Provider budget gate must always be honored; budget exhaustion is **WARN/WAIT**, never bypassed automatically.
- Terminal provider/validator failures in the current release cohort: **ERROR**.
- Isolated retryable incomplete/server/timeout responses: **WARN** until recovered; clear after validated retry.
- Prompt/schema/worker/release-lineage mismatch: **ERROR**.
- Daily call/input/output/USD caps remain safety constraints, not targets.

## User APIs

- Missing/invalid authentication on user APIs must be rejected.
- Backend-only functions must reject requests without the backend key.
- Any broker-execution capability exposed through a user API is **CRITICAL**.
- Non-success API outcomes are reviewed over a rolling 24h window. Repeated systemic failures are **ERROR**; isolated client validation errors are diagnostic unless they indicate contract drift.

## Recommendation/shadow lifecycle

- Stale recommendations cannot accept new decisions.
- BUY/ADD acceptance must remain within cash/single-stock/sector concentration limits.
- Manual execution records require the permitted lifecycle state and must preserve transaction cardinality.
- Current candidate generation must match current release lineage and current thesis freshness.
- Pretrade veto/review states are never converted to executable state automatically.

## Calibration

- Baseline cohort policy/prompt/allocation settings remain frozen until outcome observations mature.
- First review: 5-day outcomes; stronger conclusions require 20/60/120-day horizons.
- Calibration reports must include absolute return, EGX30 benchmark return, excess return, action/candidate state, quality/risk gates, and sample size.
- No go-live conclusion is made from an immature or very small outcome sample.

## Recovery objective

- Recovery is considered successful only after schema/migrations restore, required secrets are restored outside source control, all safety invariants pass, all 12 scheduled jobs are verified, API boundary smoke tests pass, and `real_money_execution=false` is reconfirmed.
