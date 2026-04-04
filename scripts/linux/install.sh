#!/usr/bin/env bash
# Toji Agent — Installer (framework files + Invisible Governance)
#
# Run from the TARGET Git repository root (directory that contains .git).
#
# 1) Fetch the Toji bundle from upstream (shallow clone) or a local path (--source / TOJI_SOURCE)
# 2) Dispatch by mode: Copilot (.github/) or Antigravity (.agent/), or both
# 3) Seed docs/ai/ with any files missing locally (safe merge — never overwrites existing)
# 4) Append .git/info/exclude (mode-gated, idempotent), write AGENTS.md, install pre-commit hook
#
# Default source: https://github.com/kevsmir02/toji-agent.git  (requires git + network)
#
set -euo pipefail

DEFAULT_SOURCE="${TOJI_SOURCE:-https://github.com/kevsmir02/toji-agent.git}"
SOURCE="$DEFAULT_SOURCE"
INSTALL_MODE=copilot
ANTIGRAVITY_FLAG=0
BOTH_FLAG=0
SOURCE_IS_LOCAL=0
MIN_GIT_VERSION="2.20.0"
MIN_AWK_VERSION="1.0.0"
MIN_SED_VERSION="4.0.0"
ROLLBACK_DIR=""
ROLLBACK_ACTIVE=0
ROLLBACK_IN_PROGRESS=0

usage() {
  cat <<'EOF'
Toji install.sh — copy framework into your repo, then enable Invisible Governance.

Usage:
  ./scripts/linux/install.sh [--source <path|url>] [--antigravity | --both]

Flags:
  (none)         Install GitHub Copilot support (default)
  --antigravity  Install Antigravity support only
  --both         Install Copilot and Antigravity support

Environment:
  TOJI_SOURCE  Path to a Toji checkout or a Git remote
               (default: kevsmir02/toji-agent main)

Note: --antigravity and --both are mutually exclusive.

Requires: git, and network access when using a remote URL.

After install, framework files exist on disk under .github/ and/or .agent/;
matching paths are listed in .git/info/exclude — git status stays clean until you "Publicize Toji".
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
    echo "Toji install: incompatible environment detected." >&2
    for failure in "${failures[@]}"; do
      echo "  - $failure" >&2
    done
    echo "Toji install: graceful failure remediation steps:" >&2
    echo "  1) Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y git gawk sed" >&2
    echo "  2) Fedora/RHEL:   sudo dnf install -y git gawk sed" >&2
    echo "  3) macOS (brew):  brew install git gawk gnu-sed" >&2
    echo "  4) Re-run checks: git --version && awk -W version && sed --version" >&2
    exit 1
  fi
}

init_rollback_snapshot() {
  ROLLBACK_DIR="$ROOT/.toji_tmp/install.$$"
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

on_install_error() {
  local status=$?

  if [[ "$ROLLBACK_IN_PROGRESS" -eq 1 ]]; then
    exit "$status"
  fi

  if [[ "$ROLLBACK_ACTIVE" -eq 1 ]]; then
    ROLLBACK_IN_PROGRESS=1
    echo "Toji install: error detected. Restoring governance directories from .toji_tmp snapshot..." >&2
    set +e
    restore_rollback_snapshot
    local rollback_status=$?
    set -e
    if [[ "$rollback_status" -eq 0 ]]; then
      echo "Toji install: rollback completed for .github/ and .agent/." >&2
    else
      echo "Toji install: rollback encountered errors. Review your repository state." >&2
    fi
    finalize_rollback_snapshot
  fi

  echo "Toji install: graceful failure. Resolve the error above and re-run install.sh." >&2
  exit "$status"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --source)
    SOURCE="$2"
    shift 2
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
    echo "install.sh: unknown option '$1' (use --help)" >&2
    exit 1
    ;;
  esac
done

SELECTED_MODES=$((ANTIGRAVITY_FLAG + BOTH_FLAG))
if [[ "$SELECTED_MODES" -gt 1 ]]; then
  echo "install.sh: --antigravity and --both are mutually exclusive. Use one mode flag, or no flag for Copilot only." >&2
  exit 1
fi
if [[ "$BOTH_FLAG" -eq 1 ]]; then
  INSTALL_MODE=both
elif [[ "$ANTIGRAVITY_FLAG" -eq 1 ]]; then
  INSTALL_MODE=antigravity
else
  INSTALL_MODE=copilot
fi

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "Toji install: not a Git repository (no .git). Run this from your project root." >&2
  exit 1
}
cd "$ROOT"

run_system_audit

check_is_installed() {
  case "$INSTALL_MODE" in
  copilot) [[ -f ".github/copilot-instructions.md" ]] && return 0 ;;
  antigravity) [[ -f ".agent/agents/toji.agent.md" ]] && return 0 ;;
  both) [[ -f ".github/copilot-instructions.md" && -f ".agent/agents/toji.agent.md" ]] && return 0 ;;
  esac
  return 1
}

if check_is_installed; then
  echo "Toji Agent is already configured! Switching to updater/healer mode..."
fi
init_rollback_snapshot

TMP=""
cleanup() {
  if [[ -n "${TMP:-}" && -d "$TMP" ]]; then
    rm -rf "$TMP"
  fi
}
trap cleanup EXIT
trap on_install_error ERR

SRC_ROOT=""
if [[ -d "$SOURCE" ]] && [[ -f "$SOURCE/.github/copilot-instructions.md" || -f "$SOURCE/.github/copilot-instructions.template.md" ]]; then
  SOURCE_IS_LOCAL=1
  SRC_ROOT=$(cd "$SOURCE" && pwd)
elif [[ -f "$SOURCE" ]]; then
  echo "Toji install: --source must be a directory containing .github/copilot-instructions.md (or .template.md), or a Git remote URL. Got: $SOURCE" >&2
  exit 1
else
  TMP=$(mktemp -d "${TMPDIR:-/tmp}/toji-install.XXXXXX")
  echo "Toji install: fetching framework from $SOURCE ..."
  git clone --depth 1 --branch main "$SOURCE" "$TMP/repo"
  SRC_ROOT="$TMP/repo"
fi

if [[ ! -f "$SRC_ROOT/.github/copilot-instructions.md" ]] && [[ ! -f "$SRC_ROOT/.github/copilot-instructions.template.md" ]]; then
  echo "Toji install: source is not a valid Toji tree (missing .github/copilot-instructions.md or .template.md): $SRC_ROOT" >&2
  exit 1
fi



if [[ ! -x "$SRC_ROOT/scripts/linux/update.sh" ]] && [[ -f "$SRC_ROOT/scripts/linux/update.sh" ]]; then
  chmod +x "$SRC_ROOT/scripts/linux/update.sh" 2>/dev/null || true
fi

UPDATE_ARGS=(--source "$SRC_ROOT")
[[ "$INSTALL_MODE" == antigravity ]] && UPDATE_ARGS+=(--antigravity)
[[ "$INSTALL_MODE" == both ]] && UPDATE_ARGS+=(--both)
bash "$SRC_ROOT/scripts/linux/update.sh" "${UPDATE_ARGS[@]}"

echo ""
case "$INSTALL_MODE" in
copilot)
  echo "Toji install: complete (Copilot). Framework under .github/ and docs/ai/. Run /onboard in Copilot when ready."
  ;;
antigravity)
  echo "Toji install: complete (Antigravity). Rules/workflows under .agent/ and docs/ai/ are ready."
  ;;
both)
  echo "Toji install: complete (Copilot + Antigravity). Use ls .github/skills or ls .agent/workflows to confirm."
  ;;
esac

if [[ "$INSTALL_MODE" == antigravity || "$INSTALL_MODE" == both ]]; then
  echo "Toji install: MCP template seeded at .agent/mcp_config.template.json. Copy to .agent/mcp_config.json and enable the servers you need."
fi

finalize_rollback_snapshot

echo "Toji install: updater scripts are not copied into consumer repositories."
echo "Toji install: from this project root, later run one of:"
if [[ "$SOURCE_IS_LOCAL" -eq 1 ]]; then
  echo "  TOJI_SOURCE=\"$SRC_ROOT\" bash \"$SRC_ROOT/scripts/linux/update.sh\""
else
  if [[ "$SOURCE" == "$DEFAULT_SOURCE" ]]; then
    echo "  curl -fsSL https://raw.githubusercontent.com/kevsmir02/toji-agent/main/scripts/linux/update.sh | bash"
  else
    echo "  curl -fsSL https://raw.githubusercontent.com/kevsmir02/toji-agent/main/scripts/linux/update.sh | bash -s -- --source \"$SOURCE\""
  fi
fi
