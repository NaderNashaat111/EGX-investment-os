# EGX Investment OS — Backup & Recovery

## Current plan constraint

The production Supabase project is currently on the Free plan. Supabase does not provide normal downloadable automatic backups on Free. The project therefore relies on explicit logical exports for off-site recovery until the plan changes.

## Recovery objectives

- Preserve schema, data, and operational configuration needed to rebuild the database.
- Never place database passwords, service-role keys, provider secrets, or backup files in this public GitHub repository.
- Treat restores as destructive operations requiring explicit approval.
- Keep real-money execution disabled after any restore until integrity checks pass.

## Recommended backup method

Use Supabase CLI / `pg_dump` from a trusted machine or private CI environment with the database connection string supplied through a secret manager.

Suggested logical-backup components:

1. roles / grants where applicable
2. schema
3. data
4. a separate inventory of Edge Function names/versions and required secret names
5. repository source (`main`) for frontend, workflows, runbooks, and project state

Example pattern (run only from a trusted environment; do not commit output):

```bash
supabase db dump --db-url "$SUPABASE_DB_URL" --role-only -f roles.sql
supabase db dump --db-url "$SUPABASE_DB_URL" -f schema.sql
supabase db dump --db-url "$SUPABASE_DB_URL" --data-only -f data.sql
```

Exact CLI flags should be checked against the installed Supabase CLI version before execution.

## Automated backup option

A private GitHub Actions workflow can automate logical dumps using a `SUPABASE_DB_URL` repository secret and upload the encrypted dump to a private/off-site destination. Do **not** store the dump as a public repository file or expose the connection string in workflow output.

This is intentionally not enabled yet because the required database connection secret is not available to the current automation context. Adding that secret is a user-owned credential action.

## Restore sequence

1. Declare incident and stop state-changing user actions if necessary.
2. Preserve current evidence/logs before restoring.
3. Create/prepare the target Supabase project/database.
4. Restore schema first, then data, then grants/roles as appropriate.
5. Reconfigure required Edge Function secrets manually from the secret manager; backups must not contain production secrets.
6. Deploy the known-good Edge Function versions and frontend from GitHub.
7. Run security advisor and integrity checks.
8. Verify all production API builds and scheduled jobs.
9. Verify portfolio/recommendation/shadow relationships have zero orphans.
10. Verify every `real_money_execution` safety invariant remains false/zero.
11. Run production smoke checks.
12. Re-enable normal scheduled processing only after verification.

## Post-restore validation

At minimum verify:

- Supabase project healthy
- expected cron jobs active
- market/evidence ingestion can run
- AI worker authorization still requires backend key
- user APIs still require valid JWT sessions
- portfolio state is readable for an authenticated test user
- recommendation workflow remains records-only/no-trade
- no orphan recommendation, thesis, portfolio, decision, execution, or shadow-evaluation records
- no `real_money_execution=true` records
- Vercel production returns HTTP 200 with expected security headers
- GitHub Production smoke workflow passes

## Plan-change note

If the Supabase organization upgrades to Pro, revisit this document. Paid plans provide managed daily backups; PITR is a separate paid add-on. Even then, retaining an independent logical-export procedure is useful for portability and disaster recovery.
