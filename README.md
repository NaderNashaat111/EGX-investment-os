# EGX Investment OS — Frontend

Production frontend for the EGX Investment OS research and portfolio decision-support application.

## Production operating model

- Static frontend deployed on Vercel.
- Supabase provides authentication, portfolio state, reference data, recommendation workflow, transaction history, and backend jobs.
- The application is **decision support only**.
- Recommendation acceptance does **not** place a broker order.
- Trades are executed outside the application and may only be recorded afterward.
- Real-money execution remains disabled by design.

## Production URL

Primary production application: `https://egx-investment-os.vercel.app`

## Critical user flows

1. Sign in / session refresh.
2. Load portfolio workspace and EGX reference data.
3. Create or switch portfolios.
4. Review current portfolio and research readiness.
5. Review recommendations.
6. Record ACCEPT / DEFER / REJECT decisions.
7. Record an external execution only after a broker trade has already occurred.
8. Review transaction and execution history.
9. Change password / recover account.

## Failure-state requirements

The frontend must never infer that a user has no portfolio merely because an API request failed.

- Initial workspace failure → show **Workspace temporarily unavailable** with Retry.
- Refresh failure after successful load → preserve existing workspace data and show a warning.
- Recommendation/history refresh failure → preserve already-loaded data.
- Portfolio switch → intentionally clear recommendation/history data before loading the new portfolio so data from another portfolio cannot be displayed.
- Upstream research not ready → show the real operational state; never fabricate recommendations.

## Production security requirements

Expected response headers include:

- `Strict-Transport-Security`
- `Content-Security-Policy`
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Cross-Origin-Opener-Policy: same-origin`
- `Cross-Origin-Resource-Policy: same-origin`
- `X-Permitted-Cross-Domain-Policies: none`
- restrictive `Permissions-Policy`
- `Cache-Control: no-store, max-age=0` on the app document

## Deployment verification checklist

After any production deployment:

1. Confirm Vercel deployment reaches `READY`.
2. Confirm production root returns HTTP 200.
3. Confirm required security headers remain present.
4. Confirm the page contains `EGX Investment OS`.
5. Confirm production copy still states that no broker execution occurs in-app.
6. Check Vercel runtime errors.
7. When an authenticated browser runner is available, test login → workspace → portfolio switch → recommendation decision → history.

## Backend operational checks

The production backend has scheduled jobs for market/evidence ingestion, AI thesis processing, decision-shadow processing, portfolio recommendation lifecycle, evaluations, and system operational snapshots.

AI processing is budget-gated. Reaching the configured provider call/spend budget is an expected safety condition, not a worker failure; queued dispatches should resume after the Cairo daily budget resets.

## Security follow-up

Supabase Auth leaked-password protection should remain enabled once configured in the Supabase dashboard. Security advisors should be rechecked after any auth or database policy change.
