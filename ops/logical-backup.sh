#!/usr/bin/env bash
set -euo pipefail

# Creates a local logical export bundle only.
# It intentionally does NOT upload the bundle anywhere. The caller must move it
# to a private encrypted/off-site destination and remove the local copy.

umask 077

: "${SUPABASE_DB_URL:?SUPABASE_DB_URL must be set in a private secret store}"
: "${BACKUP_OUTPUT_DIR:?BACKUP_OUTPUT_DIR must point to a private, non-repository directory}"

for cmd in supabase tar sha256sum mktemp realpath git; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "Required command not found: $cmd" >&2
    exit 1
  }
done

mkdir -p "$BACKUP_OUTPUT_DIR"
chmod 700 "$BACKUP_OUTPUT_DIR"

OUTPUT_DIR="$(realpath "$BACKUP_OUTPUT_DIR")"
if REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  REPO_ROOT="$(realpath "$REPO_ROOT")"
  case "$OUTPUT_DIR/" in
    "$REPO_ROOT"/*)
      echo "Refusing to write database backups inside the Git repository: $OUTPUT_DIR" >&2
      exit 1
      ;;
  esac
fi

STAMP="$(date -u +'%Y%m%dT%H%M%SZ')"
WORK_DIR="$(mktemp -d)"
ARCHIVE="$OUTPUT_DIR/egx-investment-os-${STAMP}.tar.gz"
CHECKSUM="$ARCHIVE.sha256"

cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

printf 'Supabase CLI: '
supabase --version

echo 'Exporting roles/grants...'
supabase db dump --db-url "$SUPABASE_DB_URL" --role-only -f "$WORK_DIR/roles.sql"

echo 'Exporting schema...'
supabase db dump --db-url "$SUPABASE_DB_URL" -f "$WORK_DIR/schema.sql"

echo 'Exporting data...'
supabase db dump --db-url "$SUPABASE_DB_URL" --data-only -f "$WORK_DIR/data.sql"

cat > "$WORK_DIR/README.txt" <<EOF
EGX Investment OS logical database export
Created: ${STAMP}
Contents: roles.sql, schema.sql, data.sql

This bundle may contain sensitive production data.
Keep it private, encrypt it at rest, and never commit it to the repository.
Production secrets are intentionally not included.
EOF

(
  cd "$WORK_DIR"
  sha256sum roles.sql schema.sql data.sql > MANIFEST.sha256
  sha256sum -c MANIFEST.sha256
  tar -czf "$ARCHIVE" roles.sql schema.sql data.sql MANIFEST.sha256 README.txt
)

sha256sum "$ARCHIVE" > "$CHECKSUM"

echo "Logical backup created: $ARCHIVE"
echo "Checksum created: $CHECKSUM"
echo 'Next required step: move the bundle to an approved private encrypted/off-site destination, verify it there, then remove this local copy.'
