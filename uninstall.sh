#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR=""
DRY_RUN="false"

AGENTS_BRIDGE_START="<!-- TOJI_AGENT_BRIDGE_START -->"
AGENTS_BRIDGE_END="<!-- TOJI_AGENT_BRIDGE_END -->"
HOOK_MARKER="TOJI_AGENT_HOOK"

usage() {
  cat <<'EOF'
Uninstall Toji Agent files from an existing project.

Usage:
  ./uninstall.sh --target /path/to/project [OPTIONS]
  ./uninstall.sh /path/to/project [OPTIONS]

Options:
  --target <path>          Target project directory
  --dry-run                Show what would be removed without changing files
  -h, --help               Show this help message

What this removes:
  - .github/copilot-instructions.md
  - .github/prompts/
  - .github/skills/
  - docs/ai/
  - AGENTS.toji-bridge.md
  - Toji bridge block inside AGENTS.md (if present)
  - Toji-managed pre-commit and pre-push hooks (if present)

Notes:
  - Unrelated files are kept.
  - Empty parent directories are cleaned up when possible.
EOF
}

log() {
  printf '%s\n' "$1"
}

remove_path() {
  local path="$1"

  if [[ ! -e "$path" ]]; then
    log "skip (not found): $path"
    return 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    log "[dry-run] remove: $path"
    return 0
  fi

  rm -rf "$path"
  log "removed: $path"
}

remove_agents_bridge_block() {
  local agents_path="$1"

  if [[ ! -f "$agents_path" ]]; then
    log "skip (not found): $agents_path"
    return 0
  fi

  if ! grep -q "$AGENTS_BRIDGE_START" "$agents_path"; then
    log "skip (bridge block not found): $agents_path"
    return 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    log "[dry-run] remove Toji bridge block from: $agents_path"
    return 0
  fi

  local tmp_file
  tmp_file="$(mktemp)"

  awk -v start="$AGENTS_BRIDGE_START" -v end="$AGENTS_BRIDGE_END" '
    $0 ~ start {in_block=1; next}
    $0 ~ end {in_block=0; next}
    !in_block {print}
  ' "$agents_path" > "$tmp_file"

  mv "$tmp_file" "$agents_path"
  log "updated: $agents_path"
}

remove_bridge_agents_file_if_template() {
  local agents_path="$1"

  if [[ ! -f "$agents_path" ]]; then
    return 0
  fi

  # If AGENTS.md looks like a Toji-generated minimal bridge file,
  # remove it to leave the repo clean after uninstall.
  if grep -q '^# Toji Agent Bridge$' "$agents_path"; then
    remove_path "$agents_path"
    return 0
  fi
}

cleanup_empty_dir() {
  local dir_path="$1"

  if [[ ! -d "$dir_path" ]]; then
    return 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    # Only report potential cleanup when dir is currently empty.
    if [[ -z "$(find "$dir_path" -mindepth 1 -maxdepth 1 2>/dev/null)" ]]; then
      log "[dry-run] remove empty dir: $dir_path"
    fi
    return 0
  fi

  rmdir "$dir_path" 2>/dev/null || true
}

remove_toji_git_hooks() {
  if ! command -v git >/dev/null 2>&1; then
    log "skip git hooks cleanup: git command not found"
    return 0
  fi

  if ! git -C "$TARGET_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    log "skip git hooks cleanup: target is not a git repository"
    return 0
  fi

  local hooks_dir
  hooks_dir="$(git -C "$TARGET_DIR" rev-parse --git-path hooks)"

  if [[ -z "$hooks_dir" || ! -d "$hooks_dir" ]]; then
    log "skip git hooks cleanup: hooks directory not found"
    return 0
  fi

  local hook_path
  for hook_path in "$hooks_dir/pre-commit" "$hooks_dir/pre-push"; do
    if [[ ! -f "$hook_path" ]]; then
      log "skip (not found): $hook_path"
      continue
    fi

    if ! grep -q "$HOOK_MARKER" "$hook_path"; then
      log "skip (not managed by Toji): $hook_path"
      continue
    fi

    remove_path "$hook_path"
  done
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET_DIR="${2:-}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [[ -z "$TARGET_DIR" ]]; then
        TARGET_DIR="$1"
        shift
      else
        log "Unknown argument: $1"
        usage
        exit 1
      fi
      ;;
  esac
done

if [[ -z "$TARGET_DIR" ]]; then
  log "Error: target path is required."
  usage
  exit 1
fi

if [[ ! -d "$TARGET_DIR" ]]; then
  log "Error: target directory does not exist: $TARGET_DIR"
  exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

log "Uninstalling Toji Agent from: $TARGET_DIR"
if [[ "$DRY_RUN" == "true" ]]; then
  log "Dry run mode enabled (no files will be changed)."
fi

remove_path "$TARGET_DIR/.github/copilot-instructions.md"
remove_path "$TARGET_DIR/.github/prompts"
remove_path "$TARGET_DIR/.github/skills"
remove_path "$TARGET_DIR/docs/ai"
remove_path "$TARGET_DIR/AGENTS.toji-bridge.md"

remove_agents_bridge_block "$TARGET_DIR/AGENTS.md"
remove_bridge_agents_file_if_template "$TARGET_DIR/AGENTS.md"
remove_toji_git_hooks

cleanup_empty_dir "$TARGET_DIR/.github"
cleanup_empty_dir "$TARGET_DIR/docs"

if [[ "$DRY_RUN" == "true" ]]; then
  log "Uninstall complete (dry run)."
else
  log "Uninstall complete."
fi
