#!/usr/bin/env bash
# Toji Agent — Invisible sync: pull framework files from upstream without clobbering
# project memory, design tokens, or docs/ai/.
#
# Run while your current directory is the target repository root (directory
# containing .git). The script itself can live anywhere (local clone path,
# downloaded file, or piped from GitHub raw).
#
# Usage:
#   TOJI_SOURCE=/path/to/toji-agent bash /path/to/toji-agent/scripts/linux/update.sh
#   TOJI_SOURCE=/path/to/toji-agent bash /path/to/toji-agent/scripts/linux/update.sh --antigravity
#   curl -fsSL https://raw.githubusercontent.com/kevsmir02/toji-agent/main/scripts/linux/update.sh | bash -s -- --both
#
set -euo pipefail

DEFAULT_SOURCE="${TOJI_SOURCE:-https://github.com/kevsmir02/toji-agent.git}"
SOURCE="$DEFAULT_SOURCE"
DRY_RUN=false
UPDATE_MODE=copilot
ANTIGRAVITY_FLAG=0
BOTH_FLAG=0
MIN_GIT_VERSION="2.20.0"
MIN_AWK_VERSION="1.0.0"
MIN_SED_VERSION="4.0.0"
ROLLBACK_DIR=""
ROLLBACK_ACTIVE=0
ROLLBACK_IN_PROGRESS=0

usage() {
  cat <<'EOF'
Toji update.sh — sync framework files from upstream (preserves project memory).

Usage:
  TOJI_SOURCE=/abs/path/to/toji-agent bash /abs/path/to/toji-agent/scripts/linux/update.sh [--source <path|git-url>] [--dry-run] [--antigravity | --both]
  curl -fsSL https://raw.githubusercontent.com/kevsmir02/toji-agent/main/scripts/linux/update.sh | bash -s -- [--source <path|git-url>] [--dry-run] [--antigravity | --both]

Flags:
  (none)         Sync GitHub Copilot bundle under .github/ (default)
  --antigravity  Sync Antigravity Tier 1 rules/workflows under .agent/ with .github bridge files
  --both         Sync Copilot and Antigravity Tier 1 files

Note: --antigravity and --both are mutually exclusive.

Environment:
  TOJI_SOURCE   Default URL or path if --source omitted
                (setting this variable does not execute an update by itself)

Preserves (never overwrites if present, Copilot path only):
  .github/lessons-learned.md
  docs/ai/     (entire tree left untouched)
Also re-appends Invisible Governance exclude lines (mode-gated, idempotent).
EOF
  exit 0
}

extract_semver() {
  local input="$1"
  printf '%s\n' "$input" | grep -Eo '[0-9]+(\.[0-9]+){1,2}' | head -1
}

version_ge() {
  local current="$1"
  local required="$2"
  [[ "$current" == "$required" ]] && return 0
  [[ "$(printf '%s\n%s\n' "$required" "$current" | sort -V | head -1)" == "$required" ]]
}

run_system_audit() {
  local git_ver=""
  local awk_ver=""
  local sed_ver=""
  local awk_raw=""
  local sed_raw=""
  local -a failures=()

  if ! command -v git >/dev/null 2>&1; then
    failures+=("git is not installed")
  else
    git_ver=$(extract_semver "$(git --version 2>/dev/null || true)")
    if [[ -z "$git_ver" ]] || ! version_ge "$git_ver" "$MIN_GIT_VERSION"; then
      failures+=("git >= $MIN_GIT_VERSION required (found: ${git_ver:-unknown})")
    fi
  fi

  if ! command -v awk >/dev/null 2>&1; then
    failures+=("awk is not installed")
  else
    awk_raw=$(awk -W version 2>&1 || awk --version 2>&1 || true)
    awk_ver=$(extract_semver "$awk_raw")
    if [[ -z "$awk_ver" ]] || ! version_ge "$awk_ver" "$MIN_AWK_VERSION"; then
      failures+=("awk >= $MIN_AWK_VERSION required (found: ${awk_ver:-unknown})")
    fi
  fi

  if ! command -v sed >/dev/null 2>&1; then
    failures+=("sed is not installed")
  else
    sed_raw=$(sed --version 2>&1 || sed -V 2>&1 || true)
    sed_ver=$(extract_semver "$sed_raw")
    if [[ -z "$sed_ver" ]] || ! version_ge "$sed_ver" "$MIN_SED_VERSION"; then
      failures+=("sed >= $MIN_SED_VERSION required (found: ${sed_ver:-unknown})")
    fi
  fi

  if [[ ${#failures[@]} -gt 0 ]]; then
    echo "Toji update: incompatible environment detected." >&2
    for failure in "${failures[@]}"; do
      echo "  - $failure" >&2
    done
    echo "Toji update: graceful failure remediation steps:" >&2
    echo "  1) Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y git gawk sed" >&2
    echo "  2) Fedora/RHEL:   sudo dnf install -y git gawk sed" >&2
    echo "  3) macOS (brew):  brew install git gawk gnu-sed" >&2
    echo "  4) Re-run checks: git --version && awk -W version && sed --version" >&2
    exit 1
  fi
}

init_rollback_snapshot() {
  [[ "$DRY_RUN" == true ]] && return 0

  ROLLBACK_DIR="$ROOT/.toji_tmp/update.$$"
  rm -rf "$ROLLBACK_DIR"
  mkdir -p "$ROLLBACK_DIR"

  local dir
  for dir in .github .agent; do
    if [[ -e "$ROOT/$dir" ]]; then
      cp -a "$ROOT/$dir" "$ROLLBACK_DIR/$dir"
      printf '1\n' >"$ROLLBACK_DIR/$dir.exists"
    fi
  done

  if [[ -d "$ROOT/docs/ai" ]]; then
    mkdir -p "$ROLLBACK_DIR/docs"
    cp -a "$ROOT/docs/ai" "$ROLLBACK_DIR/docs/docs_ai"
    printf '1\n' >"$ROLLBACK_DIR/docs_ai.exists"
  fi

  if [[ -f "$ROOT/.git/info/exclude" ]]; then
    mkdir -p "$ROLLBACK_DIR/git/info" "$ROLLBACK_DIR/git/hooks"
    cp "$ROOT/.git/info/exclude" "$ROLLBACK_DIR/git/info/exclude"
    printf '1\n' >"$ROLLBACK_DIR/git_info_exclude.exists"
  fi

  if [[ -f "$ROOT/.git/hooks/pre-commit" ]]; then
    mkdir -p "$ROLLBACK_DIR/git/hooks"
    cp "$ROOT/.git/hooks/pre-commit" "$ROLLBACK_DIR/git/hooks/pre-commit"
    printf '1\n' >"$ROLLBACK_DIR/git_hooks_precommit.exists"
  fi

  ROLLBACK_ACTIVE=1
}

restore_rollback_snapshot() {
  [[ "$ROLLBACK_ACTIVE" -eq 1 ]] || return 0

  local dir
  for dir in .github .agent; do
    rm -rf "$ROOT/$dir"
    if [[ -f "$ROLLBACK_DIR/$dir.exists" ]]; then
      cp -a "$ROLLBACK_DIR/$dir" "$ROOT/$dir"
    fi
  done

  rm -rf "$ROOT/docs/ai"
  if [[ -f "$ROLLBACK_DIR/docs_ai.exists" ]]; then
    mkdir -p "$ROOT/docs"
    cp -a "$ROLLBACK_DIR/docs/docs_ai" "$ROOT/docs/ai"
  fi

  rm -f "$ROOT/.git/info/exclude"
  if [[ -f "$ROLLBACK_DIR/git_info_exclude.exists" ]]; then
    mkdir -p "$ROOT/.git/info"
    cp "$ROLLBACK_DIR/git/info/exclude" "$ROOT/.git/info/exclude"
  fi

  rm -f "$ROOT/.git/hooks/pre-commit"
  if [[ -f "$ROLLBACK_DIR/git_hooks_precommit.exists" ]]; then
    mkdir -p "$ROOT/.git/hooks"
    cp "$ROLLBACK_DIR/git/hooks/pre-commit" "$ROOT/.git/hooks/pre-commit"
    chmod +x "$ROOT/.git/hooks/pre-commit" 2>/dev/null || true
  fi
}

finalize_rollback_snapshot() {
  if [[ -n "$ROLLBACK_DIR" && -d "$ROLLBACK_DIR" ]]; then
    rm -rf "$ROLLBACK_DIR"
    rmdir "$(dirname "$ROLLBACK_DIR")" 2>/dev/null || true
  fi
  ROLLBACK_ACTIVE=0
}

on_update_error() {
  local status=$?

  if [[ "$ROLLBACK_IN_PROGRESS" -eq 1 ]]; then
    exit "$status"
  fi

  if [[ "$ROLLBACK_ACTIVE" -eq 1 ]]; then
    ROLLBACK_IN_PROGRESS=1
    echo "Toji update: error detected. Restoring governance directories from .toji_tmp snapshot..." >&2
    set +e
    restore_rollback_snapshot
    local rollback_status=$?
    set -e
    if [[ "$rollback_status" -eq 0 ]]; then
      echo "Toji update: rollback completed for .github/ and .agent/." >&2
    else
      echo "Toji update: rollback encountered errors. Review your repository state." >&2
    fi
    if [[ -x "$SRC_ROOT/scripts/linux/check.sh" && "$DRY_RUN" != true ]]; then
  echo "---"
  bash "$SRC_ROOT/scripts/linux/check.sh" ${UPDATE_MODE:+"--$UPDATE_MODE"} || true
fi

finalize_rollback_snapshot
  fi

  echo "Toji update: graceful failure. Resolve the error above and re-run update.sh." >&2
  exit "$status"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --source)
    SOURCE="$2"
    shift 2
    ;;
  --dry-run)
    DRY_RUN=true
    shift
    ;;
  --antigravity)
    ANTIGRAVITY_FLAG=1
    shift
    ;;
  --both)
    BOTH_FLAG=1
    shift
    ;;
  -h | --help)
    usage
    ;;
  *)
    echo "update.sh: unknown option '$1' (use --help)" >&2
    exit 1
    ;;
  esac
done

SELECTED_MODES=$((ANTIGRAVITY_FLAG + BOTH_FLAG))
if [[ "$SELECTED_MODES" -gt 1 ]]; then
  echo "update.sh: --antigravity and --both are mutually exclusive. Use one mode flag, or no flag for Copilot only." >&2
  exit 1
fi
if [[ "$BOTH_FLAG" -eq 1 ]]; then
  UPDATE_MODE=both
elif [[ "$ANTIGRAVITY_FLAG" -eq 1 ]]; then
  UPDATE_MODE=antigravity
else
  UPDATE_MODE=copilot
fi

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "Toji update: not a Git repository. Run from your project root." >&2
  exit 1
}
cd "$ROOT"

run_system_audit
init_rollback_snapshot

EXCLUDE_FILE=".git/info/exclude"
EXCLUDE_MARKER="# Toji Agent — Invisible Governance (install.sh)"

TMP=""
cleanup() {
  if [[ -n "$TMP" && -d "$TMP" ]]; then
    rm -rf "$TMP"
  fi
}
trap cleanup EXIT
trap on_update_error ERR

SRC_ROOT=""
if [[ -d "$SOURCE" ]] && [[ -f "$SOURCE/.github/copilot-instructions.md" ]]; then
  SRC_ROOT=$(cd "$SOURCE" && pwd)
elif [[ -f "$SOURCE" ]]; then
  echo "Toji update: --source must be a directory containing .github/copilot-instructions.md, or a Git remote URL. Got: $SOURCE" >&2
  exit 1
else
  TMP=$(mktemp -d "${TMPDIR:-/tmp}/toji-update.XXXXXX")
  echo "Toji update: cloning shallow from $SOURCE ..."
  git clone --depth 1 --branch main "$SOURCE" "$TMP/repo"
  SRC_ROOT="$TMP/repo"
fi

if [[ ! -f "$SRC_ROOT/.github/copilot-instructions.md" ]]; then
  echo "Toji update: source is not a valid Toji tree (missing .github/copilot-instructions.md): $SRC_ROOT" >&2
  exit 1
fi

if [[ ! -f "$SRC_ROOT/.github/toji-version.json" ]]; then
  echo "Toji update: warning: source missing .github/toji-version.json — sync anyway" >&2
fi

copy_file() {
  local from="$1" to="$2"
  # Skip when source and destination resolve to the same path (e.g. --source .)
  if [[ "$(realpath "$from" 2>/dev/null || echo "$from")" == "$(realpath "$to" 2>/dev/null || echo "$to")" ]]; then
    return 0
  fi
  if [[ "$DRY_RUN" == true ]]; then
    echo "[dry-run] cp $from -> $to"
    return 0
  fi
  mkdir -p "$(dirname "$to")"
  cp "$from" "$to"
}

prune_antigravity_files_for_mode() {
  if [[ "$UPDATE_MODE" != "copilot" ]]; then
    return 0
  fi

  local agent_dir="$ROOT/.agent"
  if [[ ! -d "$agent_dir" ]]; then
    return 0
  fi

  local removed=0
  while IFS= read -r -d '' agent_file; do
    removed=1
    if [[ "$DRY_RUN" == true ]]; then
      echo "[dry-run] rm $agent_file"
    else
      rm -f "$agent_file"
      echo "Toji update: removed Antigravity file in ${UPDATE_MODE} mode: ${agent_file#"$ROOT/"}"
    fi
  done < <(find "$agent_dir" -type f \( -name 'toji-*.md' -o -name 'skill-*.md' -o -name 'mcp_config.template.json' -o -name 'mcp_config.json' \) -print0 2>/dev/null || true)

  if [[ "$removed" -eq 1 && "$DRY_RUN" != true ]]; then
    rmdir "$ROOT/.agent/rules" 2>/dev/null || true
    rmdir "$ROOT/.agent/workflows" 2>/dev/null || true
    rmdir "$ROOT/.agent" 2>/dev/null || true
  fi
}

ensure_exclude_line() {
  local line="$1"
  mkdir -p .git/info
  if [[ ! -f "$EXCLUDE_FILE" ]]; then
    touch "$EXCLUDE_FILE"
  fi
  if ! grep -qF "$EXCLUDE_MARKER" "$EXCLUDE_FILE" 2>/dev/null; then
    if [[ "$DRY_RUN" == true ]]; then
      echo "[dry-run] would append exclude marker to $EXCLUDE_FILE"
    else
      printf '\n%s\n' "$EXCLUDE_MARKER" >>"$EXCLUDE_FILE"
    fi
  fi
  if grep -qFx "$line" "$EXCLUDE_FILE" 2>/dev/null; then
    return 0
  fi
  if [[ "$DRY_RUN" == true ]]; then
    echo "[dry-run] would append exclude line: $line"
  else
    echo "$line" >>"$EXCLUDE_FILE"
    echo "Toji update: appended exclude line: $line"
  fi
}

install_common_files() {
  if [[ -d "$SRC_ROOT/docs/ai" ]]; then
    local seeded=0
    while IFS= read -r -d '' srcfile; do
      rel="${srcfile#"$SRC_ROOT/docs/ai"/}"
      [[ -z "$rel" ]] && continue
      dest="$ROOT/docs/ai/$rel"
      if [[ -e "$dest" ]]; then
        continue
      fi
      if [[ "$DRY_RUN" == true ]]; then
        echo "[dry-run] would seed docs/ai/$rel"
        continue
      fi
      mkdir -p "$(dirname "$dest")"
      cp "$srcfile" "$dest"
      seeded=$((seeded + 1))
    done < <(find "$SRC_ROOT/docs/ai" -type f -print0 2>/dev/null || true)
    if [[ "$seeded" -gt 0 ]]; then
      echo "Toji update: seeded $seeded file(s) under docs/ai/ (existing paths left unchanged)"
    else
      echo "Toji update: docs/ai/ already had all template files (nothing to seed)"
    fi
  else
    echo "Toji update: warning: source has no docs/ai/ directory" >&2
  fi

  local agents_path="$ROOT/AGENTS.md"
  local agents_body
  agents_body="$(cat <<'EOF'
# Project Governance: Toji Agent

This repository is governed by the Toji Agent Lifecycle.

**Primary governance source:** `.github/copilot-instructions.md`

**AI agent surfaces:**
- GitHub Copilot: `.github/agents/toji.agent.md`
- Antigravity: `.agent/agents/toji.agent.md`

Both agent surfaces are synchronized with `docs/ai/governance-core.md` via `scripts/sync-governance.js`.

**Mandatory:** Before starting work, run `/onboard` to align with the current state.
EOF
)"

  if [[ "$DRY_RUN" == true ]]; then
    echo "[dry-run] would sync AGENTS.md pointer file"
  else
    if [[ ! -f "$agents_path" ]] || [[ "$(cat "$agents_path")" != "$agents_body" ]]; then
      printf '%s\n' "$agents_body" >"$agents_path"
      echo "Toji update: synchronized AGENTS.md pointer file"
    fi
  fi
}

write_pre_commit_hook() {
  local mode="$1"
  local HOOK_PATH=".git/hooks/pre-commit"
  local HOOK_MARKER="# Toji Invisible Governance — pre-commit guard"

  if [[ "$DRY_RUN" == true ]]; then
    if [[ ! -f "$HOOK_PATH" ]] || ! grep -qF "$HOOK_MARKER" "$HOOK_PATH" 2>/dev/null; then
      echo "[dry-run] would install pre-commit hook to $HOOK_PATH"
    fi
    return 0
  fi

  mkdir -p .git/hooks

  if [[ -f "$HOOK_PATH" ]] && ! grep -qF "$HOOK_MARKER" "$HOOK_PATH" 2>/dev/null; then
    local BACKUP="${HOOK_PATH}.bak.$(date +%Y%m%d%H%M%S)"
    cp "$HOOK_PATH" "$BACKUP"
    echo "Toji update: existing pre-commit backed up to $BACKUP"
  fi

  # Unified hook for all modes (copilot, antigravity, both)
  cat >"$HOOK_PATH" <<'HOOK'
#!/usr/bin/env bash
# Toji Invisible Governance — pre-commit guard (install.sh)
set -euo pipefail

STAGED_PATHS="$(git diff --cached --name-only --diff-filter=ACMRTUXB)"

while IFS= read -r path || [[ -n "${path:-}" ]]; do
  [[ -z "${path:-}" ]] && continue
  if [[ "$path" == .toji_tmp/* ]]; then
    echo "❌ TOJI ERROR: Transient installer artifacts are not allowed in commits." >&2
    echo "  Blocked path: .toji_tmp/" >&2
    exit 1
  fi
  if [[ "$path" == *docs/ai* ]] || [[ "$path" == *skills* ]] || [[ "$path" == *prompts* ]] || [[ "$path" == *".github/instructions/toji-stack-"* ]] || [[ "$path" == *".agent/"* ]]; then
    echo "❌ TOJI ERROR: Local governance files detected. Run git reset <file> to unstage." >&2
    echo "  Blocked path: ${path}" >&2
    exit 1
  fi
done <<< "$STAGED_PATHS"

if [[ -f "docs/maintainer/AI_SCALING_GUIDE.md" && -f "scripts/release/prepare-release.js" ]]; then
  has_non_metadata_changes=0
  version_staged=0
  changelog_staged=0

  while IFS= read -r path || [[ -n "${path:-}" ]]; do
    [[ -z "${path:-}" ]] && continue

    if [[ "$path" == ".github/toji-version.json" ]]; then
      version_staged=1
    fi
    if [[ "$path" == "CHANGELOG.md" ]]; then
      changelog_staged=1
    fi

    if [[ "$path" != "CHANGELOG.md" && "$path" != ".github/toji-version.json" ]]; then
      has_non_metadata_changes=1
    fi
  done <<< "$STAGED_PATHS"

  if [[ "$has_non_metadata_changes" -eq 1 && ( "$version_staged" -eq 0 || "$changelog_staged" -eq 0 ) ]]; then
    if ! command -v node >/dev/null 2>&1; then
      echo "❌ TOJI ERROR: node is required for maintainer release automation." >&2
      echo "  Install Node.js, then retry commit." >&2
      exit 1
    fi

    bump_type="${TOJI_RELEASE_BUMP:-patch}"
    summary="${TOJI_RELEASE_SUMMARY:-Maintainer pre-commit automation}"

    echo "Toji pre-commit: release metadata missing; running prepare-release ($bump_type)." >&2
    if ! node scripts/release/prepare-release.js --bump "$bump_type" --summary "$summary" --allow-missing-docs; then
      echo "❌ TOJI ERROR: release preparation failed." >&2
      echo "  Update docs as needed, or run prepare-release manually and retry commit." >&2
      exit 1
    fi

    git add .github/toji-version.json CHANGELOG.md
    echo "Toji pre-commit: staged .github/toji-version.json and CHANGELOG.md" >&2
  fi
fi

if git diff --cached --name-only --diff-filter=ACMRTUXB -- "AGENTS.md" | grep -q '^AGENTS.md$'; then
  echo "❌ TOJI ERROR: Local governance files detected. Run git reset <file> to unstage." >&2
  echo "  Blocked path: AGENTS.md" >&2
  exit 1
fi

exit 0
HOOK

  chmod +x "$HOOK_PATH"
  echo "Toji update: installed $HOOK_PATH (executable, mode=$mode)"
}

apply_excludes_for_mode() {
  case "$UPDATE_MODE" in
  copilot)
    ensure_exclude_line "docs/ai/"
    ensure_exclude_line ".github/skills/"
    ensure_exclude_line ".github/prompts/"
    ensure_exclude_line ".github/instructions/"
    ensure_exclude_line ".github/agents/"
    ensure_exclude_line ".github/copilot-instructions.md"
    ensure_exclude_line ".github/lessons-learned.md"
    ensure_exclude_line ".github/toji-version.json"
    ensure_exclude_line "AGENTS.md"
    ;;
  antigravity)
    ensure_exclude_line "docs/ai/"
    ensure_exclude_line ".github/skills/"
    ensure_exclude_line ".github/prompts/"
    ensure_exclude_line ".github/instructions/"
    ensure_exclude_line ".github/agents/"
    ensure_exclude_line ".github/copilot-instructions.md"
    ensure_exclude_line ".github/lessons-learned.md"
    ensure_exclude_line ".github/toji-version.json"
    ensure_exclude_line "AGENTS.md"
    ensure_exclude_line ".agent/"
    ensure_exclude_line ".agent/rules/toji-stack-*.md"
    ensure_exclude_line ".agent/*.json"
    ensure_exclude_line ".agent/agents/"
    ;;
  both)
    ensure_exclude_line "docs/ai/"
    ensure_exclude_line ".github/skills/"
    ensure_exclude_line ".github/prompts/"
    ensure_exclude_line ".github/instructions/"
    ensure_exclude_line ".github/agents/"
    ensure_exclude_line ".github/copilot-instructions.md"
    ensure_exclude_line ".github/lessons-learned.md"
    ensure_exclude_line ".github/toji-version.json"
    ensure_exclude_line "AGENTS.md"
    ensure_exclude_line ".agent/"
    ensure_exclude_line ".agent/rules/toji-stack-*.md"
    ensure_exclude_line ".agent/*.json"
    ensure_exclude_line ".agent/agents/"
    ;;
  esac
}

# --- Copilot / .github/ sync ---
if [[ "$UPDATE_MODE" == copilot || "$UPDATE_MODE" == antigravity || "$UPDATE_MODE" == both ]]; then
  # Prefer the consumer-safe template; fall back to the live file if the template is absent
  _ci_src=""
  if [[ -f "$SRC_ROOT/.github/copilot-instructions.template.md" ]]; then
    _ci_src="$SRC_ROOT/.github/copilot-instructions.template.md"
  elif [[ -f "$SRC_ROOT/.github/copilot-instructions.md" ]]; then
    _ci_src="$SRC_ROOT/.github/copilot-instructions.md"
  fi
  if [[ -n "$_ci_src" ]]; then
    copy_file "$_ci_src" "$ROOT/.github/copilot-instructions.md"
    echo "Toji update: synced .github/copilot-instructions.md (from $(basename "$_ci_src"))"
  fi

  if [[ -d "$SRC_ROOT/.github/prompts" ]]; then
    if [[ -d "$ROOT/.github/prompts" ]]; then
      for local_file in "$ROOT/.github/prompts"/*; do
        [[ -f "$local_file" ]] || continue
        file_name=$(basename "$local_file")
        if [[ ! -f "$SRC_ROOT/.github/prompts/$file_name" ]]; then
          if [[ "$DRY_RUN" == true ]]; then
            echo "[dry-run] would remove obsolete prompt: .github/prompts/$file_name"
          else
            rm -f "$local_file"
            echo "Toji update: swept obsolete prompt: $file_name"
          fi
        fi
      done
    fi

    while IFS= read -r -d '' f; do
      rel="${f#"$SRC_ROOT/.github/prompts"/}"
      [[ -z "$rel" ]] && continue
      dest="$ROOT/.github/prompts/$rel"
      copy_file "$f" "$dest"
    done < <(find "$SRC_ROOT/.github/prompts" -type f -print0 2>/dev/null || true)
    echo "Toji update: synced .github/prompts/"
  fi

  if [[ -d "$SRC_ROOT/.github/instructions" ]]; then
    if [[ -d "$ROOT/.github/instructions" ]]; then
      for local_file in "$ROOT/.github/instructions"/*; do
        [[ -f "$local_file" ]] || continue
        file_name=$(basename "$local_file")
        # Do not prune toji-stack-*.instructions.md as they are dynamically generated locally
        if [[ "$file_name" == toji-stack-*.instructions.md ]]; then continue; fi
        if [[ ! -f "$SRC_ROOT/.github/instructions/$file_name" ]]; then
          if [[ "$DRY_RUN" == true ]]; then
            echo "[dry-run] would remove obsolete instruction: .github/instructions/$file_name"
          else
            rm -f "$local_file"
            echo "Toji update: swept obsolete instruction: $file_name"
          fi
        fi
      done
    fi

    while IFS= read -r -d '' f; do
      rel="${f#"$SRC_ROOT/.github/instructions"/}"
      [[ -z "$rel" ]] && continue
      dest="$ROOT/.github/instructions/$rel"
      copy_file "$f" "$dest"
    done < <(find "$SRC_ROOT/.github/instructions" -type f -print0 2>/dev/null || true)
    echo "Toji update: synced .github/instructions/ (Tier 1)"
  fi

  if [[ -d "$SRC_ROOT/.github/skills" ]]; then
    if [[ -d "$ROOT/.github/skills" ]]; then
      for local_skill in "$ROOT/.github/skills"/*; do
        [[ -d "$local_skill" ]] || continue
        skill_name=$(basename "$local_skill")
        if [[ ! -d "$SRC_ROOT/.github/skills/$skill_name" ]]; then
          if [[ "$DRY_RUN" == true ]]; then
            echo "[dry-run] would remove obsolete skill directory: .github/skills/$skill_name"
          else
            rm -rf "$local_skill"
            echo "Toji update: swept obsolete skill: $skill_name"
          fi
        fi
      done
    fi

    while IFS= read -r -d '' f; do
      rel="${f#"$SRC_ROOT/.github/skills"/}"
      [[ -z "$rel" ]] && continue
      dest="$ROOT/.github/skills/$rel"
      copy_file "$f" "$dest"
    done < <(find "$SRC_ROOT/.github/skills" -type f -print0 2>/dev/null || true)
    echo "Toji update: synced .github/skills/"
  fi

  # Sync .github/agents/ directory (Copilot custom agents)
  if [[ -d "$SRC_ROOT/.github/agents" ]]; then
    mkdir -p "$ROOT/.github/agents"
    while IFS= read -r -d '' f; do
      rel="${f#"$SRC_ROOT/.github/agents"/}"
      [[ -z "$rel" ]] && continue
      dest="$ROOT/.github/agents/$rel"
      copy_file "$f" "$dest"
    done < <(find "$SRC_ROOT/.github/agents" -type f -print0 2>/dev/null || true)
    echo "Toji update: synced .github/agents/"
  fi

  if [[ -f "$ROOT/.github/lessons-learned.md" ]]; then
    echo "Toji update: preserved .github/lessons-learned.md"
  elif [[ -f "$SRC_ROOT/.github/lessons-learned.template.md" ]]; then
    copy_file "$SRC_ROOT/.github/lessons-learned.template.md" "$ROOT/.github/lessons-learned.md"
    echo "Toji update: seeded .github/lessons-learned.md from clean template (was missing)"
  elif [[ -f "$SRC_ROOT/.github/lessons-learned.md" ]]; then
    copy_file "$SRC_ROOT/.github/lessons-learned.md" "$ROOT/.github/lessons-learned.md"
    echo "Toji update: seeded .github/lessons-learned.md (legacy fallback; template missing)"
  fi

  extract_version() {
    local file="$1"
    sed -n 's/^[[:space:]]*\"version\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p' "$file" | head -1
  }

  NOW_UTC=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  if [[ -f "$SRC_ROOT/.github/toji-version.json" ]]; then
    UPSTREAM_VER=$(extract_version "$SRC_ROOT/.github/toji-version.json")
    if [[ -z "$UPSTREAM_VER" ]]; then
      UPSTREAM_VER="0.0.0"
    fi
    if [[ "$DRY_RUN" == true ]]; then
      echo "[dry-run] would write .github/toji-version.json version=$UPSTREAM_VER last_update=$NOW_UTC"
    else
      mkdir -p "$ROOT/.github"
      printf '{\n  "version": "%s",\n  "last_update": "%s"\n}\n' "$UPSTREAM_VER" "$NOW_UTC" >"$ROOT/.github/toji-version.json"
      echo "Toji update: wrote .github/toji-version.json (version $UPSTREAM_VER, last_update $NOW_UTC)"
    fi
  fi
fi

cleanup_legacy_antigravity_rules() {
  local rules_dir="$ROOT/.agent/rules"
  local removed=0

  [[ -d "$rules_dir" ]] || {
    echo "Toji update: legacy Antigravity mirror cleanup skipped (.agent/rules missing)"
    return 0
  }

  local pattern_file
  for pattern_file in "$rules_dir"/skill-*.md "$rules_dir"/toji-core.md; do
    [[ -e "$pattern_file" ]] || continue
    removed=$((removed + 1))
    if [[ "$DRY_RUN" == true ]]; then
      echo "[dry-run] remove legacy mirror: ${pattern_file#$ROOT/}"
    else
      rm -f "$pattern_file"
    fi
  done

  if [[ "$DRY_RUN" == true ]]; then
    echo "Toji update: [dry-run] would remove $removed legacy mirror file(s)"
  else
    echo "Toji update: removed $removed legacy mirror file(s)"
  fi
}

# --- Antigravity Tier 1 sync ---
if [[ "$UPDATE_MODE" == antigravity || "$UPDATE_MODE" == both ]]; then
  if [[ -d "$SRC_ROOT/.agent/workflows" ]]; then
    while IFS= read -r -d '' f; do
      rel="${f#"$SRC_ROOT/.agent/workflows"/}"
      [[ -z "$rel" ]] && continue
      case "$rel" in
      toji-*.md) ;;
      *) continue ;;
      esac
      dest="$ROOT/.agent/workflows/$rel"
      copy_file "$f" "$dest"
    done < <(find "$SRC_ROOT/.agent/workflows" -maxdepth 1 -type f -name 'toji-*.md' -print0 2>/dev/null || true)
    echo "Toji update: synced .agent/workflows/ (toji-*.md)"
  else
    echo "Toji update: warning: source has no .agent/workflows/ directory" >&2
  fi

  if [[ -f "$SRC_ROOT/.agent/mcp_config.template.json" ]]; then
    copy_file "$SRC_ROOT/.agent/mcp_config.template.json" "$ROOT/.agent/mcp_config.template.json"
    echo "Toji update: synced .agent/mcp_config.template.json"
  else
    echo "Toji update: warning: source missing .agent/mcp_config.template.json" >&2
  fi

  # Sync .agent/agents/ directory (Antigravity agent personas)
  if [[ -d "$SRC_ROOT/.agent/agents" ]]; then
    mkdir -p "$ROOT/.agent/agents"
    while IFS= read -r -d '' f; do
      rel="${f#"$SRC_ROOT/.agent/agents"/}"
      [[ -z "$rel" ]] && continue
      dest="$ROOT/.agent/agents/$rel"
      copy_file "$f" "$dest"
    done < <(find "$SRC_ROOT/.agent/agents" -type f -print0 2>/dev/null || true)
    echo "Toji update: synced .agent/agents/"
  fi

  cleanup_legacy_antigravity_rules
fi

prune_antigravity_files_for_mode

apply_excludes_for_mode
install_common_files
write_pre_commit_hook "$UPDATE_MODE"

echo ""
echo "Toji update: finished (mode=$UPDATE_MODE). Project data preserved: lessons-learned (if existed), global design-system/ rules, docs/ai/ (untouched)."
if [[ "$UPDATE_MODE" == antigravity || "$UPDATE_MODE" == both ]]; then
  echo "Toji update: MCP template available at .agent/mcp_config.template.json (copy to .agent/mcp_config.json and enable required servers)."
fi

if [[ -x "$SRC_ROOT/scripts/linux/check.sh" && "$DRY_RUN" != true ]]; then
  echo "---"
  bash "$SRC_ROOT/scripts/linux/check.sh" ${UPDATE_MODE:+"--$UPDATE_MODE"} || true
fi

finalize_rollback_snapshot
