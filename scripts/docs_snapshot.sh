#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SNAPSHOT_ROOT="${REPO_ROOT}/.codex/docs-snapshots"

usage() {
  cat <<'USAGE'
Usage:
  scripts/docs_snapshot.sh create [--label <label>] [--baseline]
  scripts/docs_snapshot.sh list
  scripts/docs_snapshot.sh verify [<snapshot-id|latest|baseline>]
  scripts/docs_snapshot.sh rollback [<snapshot-id|latest|baseline>]

Notes:
  - Snapshot scope includes all .md files under docs/.
  - Excludes snapshot storage.
  - rollback defaults to baseline if no target is provided.
USAGE
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

log() {
  printf '%s\n' "$*"
}

ensure_snapshot_root() {
  mkdir -p "${SNAPSHOT_ROOT}"
}

sanitize_label() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9._-' '-'
}

metadata_get() {
  local metadata_file="$1"
  local key="$2"
  awk -F $'\t' -v lookup="$key" '$1 == lookup {print $2; exit}' "${metadata_file}"
}

collect_scope_paths() {
  find "${REPO_ROOT}/docs" \
    \( -path "${SNAPSHOT_ROOT}" -o -path "${SNAPSHOT_ROOT}/*" \) -prune -o \
    -type f -name '*.md' -print \
    | sed "s#^${REPO_ROOT}/##" \
    | LC_ALL=C sort
}

create_snapshot_id() {
  local label="$1"
  local timestamp slug candidate suffix

  timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
  slug="$(sanitize_label "$label")"
  if [[ -z "${slug}" ]]; then
    slug="snapshot"
  fi

  candidate="${timestamp}-${slug}"
  suffix=1
  while [[ -e "${SNAPSHOT_ROOT}/${candidate}" ]]; do
    candidate="${timestamp}-${slug}-${suffix}"
    suffix=$((suffix + 1))
  done

  printf '%s' "${candidate}"
}

write_manifest() {
  local paths_file="$1"
  local manifest_file="$2"
  local rel_path abs_path sha256 size mode

  : > "${manifest_file}"
  while IFS= read -r rel_path; do
    [[ -z "${rel_path}" ]] && continue
    abs_path="${REPO_ROOT}/${rel_path}"
    [[ -f "${abs_path}" ]] || die "Path missing while creating manifest: ${rel_path}"

    sha256="$(shasum -a 256 "${abs_path}" | awk '{print $1}')"
    size="$(stat -f '%z' "${abs_path}")"
    mode="$(stat -f '%Mp%Lp' "${abs_path}")"

    printf '%s\t%s\t%s\t%s\n' "${sha256}" "${size}" "${mode}" "${rel_path}" >> "${manifest_file}"
  done < "${paths_file}"
}

create_snapshot_internal() {
  local label="$1"
  local baseline_flag="$2"
  local set_latest_flag="$3"
  local purpose="$4"

  ensure_snapshot_root

  local id snapshot_dir paths_file manifest_file archive_file metadata_file
  id="$(create_snapshot_id "${label}")"
  snapshot_dir="${SNAPSHOT_ROOT}/${id}"
  mkdir -p "${snapshot_dir}"

  paths_file="${snapshot_dir}/paths.txt"
  manifest_file="${snapshot_dir}/manifest.tsv"
  archive_file="${snapshot_dir}/docs.tar.gz"
  metadata_file="${snapshot_dir}/metadata.tsv"

  collect_scope_paths > "${paths_file}"

  local file_count
  file_count="$(wc -l < "${paths_file}" | tr -d '[:space:]')"
  [[ "${file_count}" -gt 0 ]] || die "No markdown files found in snapshot scope"

  write_manifest "${paths_file}" "${manifest_file}"

  tar -czf "${archive_file}" -C "${REPO_ROOT}" -T "${paths_file}"

  local manifest_sha archive_sha created_at
  manifest_sha="$(shasum -a 256 "${manifest_file}" | awk '{print $1}')"
  archive_sha="$(shasum -a 256 "${archive_file}" | awk '{print $1}')"
  created_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  {
    printf 'id\t%s\n' "${id}"
    printf 'created_at\t%s\n' "${created_at}"
    printf 'label\t%s\n' "${label}"
    printf 'purpose\t%s\n' "${purpose}"
    printf 'baseline\t%s\n' "${baseline_flag}"
    printf 'file_count\t%s\n' "${file_count}"
    printf 'manifest_sha256\t%s\n' "${manifest_sha}"
    printf 'archive_sha256\t%s\n' "${archive_sha}"
    printf 'repo_root\t%s\n' "${REPO_ROOT}"
    printf 'scope\t%s\n' "docs/*.md excluding .codex/docs-snapshots"
  } > "${metadata_file}"

  if [[ "${baseline_flag}" == "true" ]]; then
    printf '%s\n' "${id}" > "${SNAPSHOT_ROOT}/baseline"
  fi

  if [[ "${set_latest_flag}" == "true" ]]; then
    printf '%s\n' "${id}" > "${SNAPSHOT_ROOT}/latest"
  fi

  printf '%s\n' "${id}"
}

resolve_snapshot_id() {
  local ref="${1:-latest}"

  case "${ref}" in
    latest|"")
      [[ -f "${SNAPSHOT_ROOT}/latest" ]] || die "No latest snapshot pointer found"
      ref="$(cat "${SNAPSHOT_ROOT}/latest")"
      ;;
    baseline)
      [[ -f "${SNAPSHOT_ROOT}/baseline" ]] || die "No baseline snapshot pointer found"
      ref="$(cat "${SNAPSHOT_ROOT}/baseline")"
      ;;
  esac

  [[ -d "${SNAPSHOT_ROOT}/${ref}" ]] || die "Snapshot not found: ${ref}"
  printf '%s' "${ref}"
}

list_snapshots() {
  ensure_snapshot_root

  if ! compgen -G "${SNAPSHOT_ROOT}/*/metadata.tsv" > /dev/null; then
    log "No docs snapshots found in ${SNAPSHOT_ROOT}"
    return 0
  fi

  local baseline_id latest_id
  baseline_id=""
  latest_id=""
  [[ -f "${SNAPSHOT_ROOT}/baseline" ]] && baseline_id="$(cat "${SNAPSHOT_ROOT}/baseline")"
  [[ -f "${SNAPSHOT_ROOT}/latest" ]] && latest_id="$(cat "${SNAPSHOT_ROOT}/latest")"

  log "ID | Created At (UTC) | Label | Purpose | Flags"
  while IFS= read -r metadata_file; do
    local id created_at label purpose flags
    id="$(metadata_get "${metadata_file}" id)"
    created_at="$(metadata_get "${metadata_file}" created_at)"
    label="$(metadata_get "${metadata_file}" label)"
    purpose="$(metadata_get "${metadata_file}" purpose)"
    flags=""

    [[ "${id}" == "${latest_id}" ]] && flags="${flags}latest "
    [[ "${id}" == "${baseline_id}" ]] && flags="${flags}baseline "
    flags="${flags%% }"

    printf '%s | %s | %s | %s | %s\n' "${id}" "${created_at}" "${label}" "${purpose}" "${flags}"
  done < <(find "${SNAPSHOT_ROOT}" -type f -name metadata.tsv | LC_ALL=C sort)
}

verify_snapshot_by_id() {
  local id="$1"
  local snapshot_dir manifest_file
  snapshot_dir="${SNAPSHOT_ROOT}/${id}"
  manifest_file="${snapshot_dir}/manifest.tsv"

  [[ -f "${manifest_file}" ]] || die "Manifest missing for snapshot: ${id}"

  local tmp_dir current_paths manifest_paths missing_file extras_file
  tmp_dir="$(mktemp -d)"
  current_paths="${tmp_dir}/current.txt"
  manifest_paths="${tmp_dir}/manifest.txt"
  missing_file="${tmp_dir}/missing.txt"
  extras_file="${tmp_dir}/extras.txt"

  trap '[[ -n "${tmp_dir:-}" ]] && rm -rf "${tmp_dir}"' RETURN

  collect_scope_paths > "${current_paths}"
  cut -f 4 "${manifest_file}" | LC_ALL=C sort > "${manifest_paths}"

  comm -23 "${manifest_paths}" "${current_paths}" > "${missing_file}"
  comm -13 "${manifest_paths}" "${current_paths}" > "${extras_file}"

  local missing_count extras_count
  missing_count="$(wc -l < "${missing_file}" | tr -d '[:space:]')"
  extras_count="$(wc -l < "${extras_file}" | tr -d '[:space:]')"

  if [[ "${missing_count}" -gt 0 ]]; then
    log "Missing files compared to snapshot ${id}:"
    sed -n '1,20p' "${missing_file}"
  fi

  if [[ "${extras_count}" -gt 0 ]]; then
    log "Extra in-scope files not in snapshot ${id}:"
    sed -n '1,20p' "${extras_file}"
  fi

  local mismatch_count line expected_sha expected_size expected_mode rel_path abs_path actual_sha actual_size actual_mode
  mismatch_count=0

  while IFS=$'\t' read -r expected_sha expected_size expected_mode rel_path; do
    [[ -z "${rel_path}" ]] && continue
    abs_path="${REPO_ROOT}/${rel_path}"

    if [[ ! -f "${abs_path}" ]]; then
      mismatch_count=$((mismatch_count + 1))
      continue
    fi

    actual_sha="$(shasum -a 256 "${abs_path}" | awk '{print $1}')"
    actual_size="$(stat -f '%z' "${abs_path}")"
    actual_mode="$(stat -f '%Mp%Lp' "${abs_path}")"

    if [[ "${actual_sha}" != "${expected_sha}" || "${actual_size}" != "${expected_size}" || "${actual_mode}" != "${expected_mode}" ]]; then
      mismatch_count=$((mismatch_count + 1))
      log "Mismatch: ${rel_path}"
    fi
  done < "${manifest_file}"

  if [[ "${missing_count}" -gt 0 || "${extras_count}" -gt 0 || "${mismatch_count}" -gt 0 ]]; then
    die "Verification failed for snapshot ${id} (missing=${missing_count}, extras=${extras_count}, mismatches=${mismatch_count})"
  fi

  log "Verification passed for snapshot ${id}: exact file set, hashes, sizes, and modes match."
}

verify_snapshot() {
  local ref="${1:-latest}"
  ensure_snapshot_root
  local id
  id="$(resolve_snapshot_id "${ref}")"
  verify_snapshot_by_id "${id}"
}

rollback_to_snapshot() {
  local ref="${1:-baseline}"
  ensure_snapshot_root

  local id snapshot_dir archive_file manifest_file
  id="$(resolve_snapshot_id "${ref}")"
  snapshot_dir="${SNAPSHOT_ROOT}/${id}"
  archive_file="${snapshot_dir}/docs.tar.gz"
  manifest_file="${snapshot_dir}/manifest.tsv"

  [[ -f "${archive_file}" ]] || die "Archive missing for snapshot: ${id}"
  [[ -f "${manifest_file}" ]] || die "Manifest missing for snapshot: ${id}"

  local safety_id
  safety_id="$(create_snapshot_internal "pre-rollback-${id}" false false pre-rollback)"
  log "Safety snapshot created: ${safety_id}"

  local tmp_dir current_paths target_paths extras_file rel_path
  tmp_dir="$(mktemp -d)"
  current_paths="${tmp_dir}/current.txt"
  target_paths="${tmp_dir}/target.txt"
  extras_file="${tmp_dir}/extras.txt"
  trap '[[ -n "${tmp_dir:-}" ]] && rm -rf "${tmp_dir}"' RETURN

  collect_scope_paths > "${current_paths}"
  cut -f 4 "${manifest_file}" | LC_ALL=C sort > "${target_paths}"
  comm -13 "${target_paths}" "${current_paths}" > "${extras_file}"

  while IFS= read -r rel_path; do
    [[ -z "${rel_path}" ]] && continue
    rm -f "${REPO_ROOT}/${rel_path}"
  done < "${extras_file}"

  tar -xzf "${archive_file}" -C "${REPO_ROOT}"

  while IFS=$'\t' read -r _ _ mode rel_path; do
    [[ -z "${rel_path}" ]] && continue
    chmod "${mode}" "${REPO_ROOT}/${rel_path}"
  done < "${manifest_file}"

  verify_snapshot_by_id "${id}"
  log "Rollback complete. Restored docs to snapshot ${id}."
}

main() {
  local cmd="${1:-}"
  shift || true

  case "${cmd}" in
    create)
      local label baseline_flag
      label="manual"
      baseline_flag="false"

      while [[ $# -gt 0 ]]; do
        case "$1" in
          --label)
            [[ $# -ge 2 ]] || die "Missing value for --label"
            label="$2"
            shift 2
            ;;
          --baseline)
            baseline_flag="true"
            shift
            ;;
          -h|--help)
            usage
            return 0
            ;;
          *)
            die "Unknown option for create: $1"
            ;;
        esac
      done

      local id
      id="$(create_snapshot_internal "${label}" "${baseline_flag}" true manual)"
      log "Snapshot created: ${id}"
      if [[ "${baseline_flag}" == "true" ]]; then
        log "Baseline pointer updated to: ${id}"
      fi
      ;;
    list)
      list_snapshots
      ;;
    verify)
      verify_snapshot "${1:-latest}"
      ;;
    rollback)
      rollback_to_snapshot "${1:-baseline}"
      ;;
    -h|--help|help|"")
      usage
      ;;
    *)
      die "Unknown command: ${cmd}"
      ;;
  esac
}

main "$@"
