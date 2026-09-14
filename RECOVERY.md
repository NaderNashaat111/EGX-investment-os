# EGX Investment OS — Backup & Recovery

## Current plan constraint

The production Supabase project is currently on the Free plan. Supabase does not provide normal downloadable automatic backups on Free. The project therefore relies on explicit logical exports for off-site recovery until the plan changes.

Supabase's current documentation recommends that Free plan projects regularly export their data using the Supabase CLI `db dump` command and retain off-site backups. The repository includes `ops/logical-backup.sh` as a guarded export helper for this purpose.

## Recovery objectives

- Preserve schema, data, and operational configuration needed to rebuild the database.
- Never place database passwords, service-role keys, provider secrets, or backup files in this public GitHub repository.
- Treat restores as destructive operations requiring explicit approval.
- Keep real-money execution disabled after any restore until integrity checks pass.

## Recommended backup method

Use Supabase CLI from a trusted machine or private CI environment with the database connection string supplied through a secret manager.

Suggested logical-backup components:

1. roles / grants where applicable
2. schema
3. data
4. a separate inventory of Edge Function names/versions and required secret names
5. repository source (`main`) for frontend, workflows, runbooks, and project state

The checked-in helper performs the database export portion:

```bash
export SUPABASE_DB_URL='loaded-from-your-secret-store'
export BACKUP_OUTPUT_DIR='/private/non-repository/path'
./ops/logical-backup.sh
```

The helper:

- requires `SUPABASE_DB_URL` and `BACKUP_OUTPUT_DIR`
- checks the installed Supabase CLI version before dumping
- refuses to place backup output anywhere inside the Git repository
- uses restrictive file permissions (`umask 077` and a mode-700 output directory)
- exports roles/grants, schema, and data separately
- validates component checksums before packaging
- emits a bundle checksum for off-site verification
- removes its temporary plaintext working directory on exit
- intentionally does not upload the resulting bundle anywhere

The final bundle still contains sensitive production data. It must be transferred to an approved private encrypted/off-site destination, verified there, and removed from the temporary/local location.

## Automated backup option

The export automation is now prepared, but scheduled off-site backup is intentionally **not enabled** until both of these user-owned items exist:

1. a private database connection secret (`SUPABASE_DB_URL`) in the chosen automation secret store
2. an approved private encrypted/off-site backup destination with its required credentials

Do **not** upload database dumps as artifacts from this public repository or commit them as repository files. Once a private destination is selected, wrap `ops/logical-backup.sh` in a scheduled private workflow/job that uploads the bundle, verifies the remote checksum, applies retention, deletes the runner copy, and alerts on failure.

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
