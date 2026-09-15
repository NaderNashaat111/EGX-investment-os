# EGX Investment OS — Backup & Recovery

## Current plan constraint

The production Supabase project is currently on the Free plan. The project therefore retains an independent logical-export recovery path rather than depending on managed downloadable backups.

The repository includes `ops/logical-backup.sh` as a guarded export helper and `.github/workflows/offsite-backup.yml` as the scheduled off-site automation.

## Recovery objectives

- Preserve schema, data, and operational configuration needed to rebuild the database.
- Never place database passwords, service-role keys, provider secrets, or backup files in this public GitHub repository.
- Treat restores as destructive operations requiring explicit approval.
- Keep real-money execution disabled after any restore until integrity checks pass.

## Production backup configuration

Automated off-site logical backup is ENABLED.

- Schedule: daily at 01:20 UTC (04:20 Africa/Cairo).
- Source: production Supabase database through a private `SUPABASE_DB_URL` GitHub Actions secret.
- Destination: private Cloudflare R2 bucket `egx-investment-os-backups`.
- R2 credentials are restricted GitHub Actions secrets and are never committed to the repository.
- Object layout: `daily/YYYY/MM/DD/<backup-bundle>` plus its `.sha256` file.
- The runner removes its temporary backup directory even if a later step fails.
- The first production off-site backup completed successfully on 2026-09-15 in GitHub Actions run `35017101867`.
- That run exported roles/grants, schema and data, validated local component checksums, uploaded the bundle and checksum to R2, verified the remote object existed, and removed the runner copy.
- The workflow was subsequently hardened to download the uploaded R2 object and compare its SHA-256 with the local bundle. Future successful runs therefore require end-to-end remote checksum equality.

### Retention

Target retention for the `daily/` prefix is **35 days**. Configure this as an R2 Object lifecycle rule so expiry is enforced independently of GitHub Actions. Until the lifecycle rule is confirmed enabled in Cloudflare, retention configuration remains the only open backup-control item.

Recommended rule:

- Rule name: `expire-daily-backups-35d`
- Prefix: `daily/`
- Action: delete/expire objects
- Age: 35 days
- Status: enabled

Do not use an Empty Bucket operation. Do not create a lifecycle rule with a 1-day expiry. The `.tar.gz` bundle and `.sha256` sidecar share the `daily/` prefix and should expire together.

## Logical backup helper

The checked-in helper:

- requires `SUPABASE_DB_URL` and `BACKUP_OUTPUT_DIR`
- checks the installed Supabase CLI version before dumping
- refuses to place backup output anywhere inside the Git repository
- uses restrictive file permissions (`umask 077` and a mode-700 output directory)
- exports roles/grants, schema, and data separately
- validates component checksums before packaging
- emits a bundle checksum for off-site verification
- removes its temporary plaintext working directory on exit

The final bundle contains sensitive production data and must remain only in approved private storage.

## Restore sequence

1. Declare incident and stop state-changing user actions if necessary.
2. Preserve current evidence/logs before restoring.
3. Create/prepare the target Supabase project/database.
4. Restore schema first, then data, then grants/roles as appropriate. The current data-only dump can emit circular-FK restore warnings for tables such as `research_facts`, `legal_status_events`, `corporate_actions`, and `disclosure_documents`; perform restores in an isolated target and use the appropriate trigger/constraint handling rather than improvising in production.
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

## Periodic recovery test

A successful backup is not sufficient evidence of restorability. Perform a non-production restore drill after the backup format or schema changes materially and periodically thereafter. The drill must never overwrite production and must finish with the post-restore validation checks above.

## Plan-change note

If the Supabase organization upgrades, revisit the relationship between managed backups/PITR and this independent logical-export path. Retaining an independent off-site logical export remains useful for portability and disaster recovery.
