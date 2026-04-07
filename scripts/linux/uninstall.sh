#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR=""
DRY_RUN="false"
UNINSTALL_MODE=copilot
ANTIGRAVITY_FLAG=0
BOTH_FLAG=0
COPILOT_CLI_FLAG=0
ALL_FLAG=0

TOJI_SECTION_START="<!-- toji:start -->"
TOJI_SECTION_END="<!-- toji:end -->"
HOOK_MARKER="Toji Invisible Governance — pre-commit guard"

usage() {
  cat <<'EOF'
Uninstall Toji Agent files from an existing project.

Usage:
  ./scripts/linux/uninstall.sh --target /path/to/project [OPTIONS]
  ./scripts/linux/uninstall.sh /path/to/project [OPTIONS]

Options:
  --target <path>          Target project directory
  --antigravity            Remove Antigravity Toji files only (.agent/* Toji-managed)
  --copilot-cli            Remove Copilot CLI instruction surfaces only
  --both                   Remove Copilot and Antigravity Toji bundles
  --all                    Remove Copilot, Copilot CLI, and Antigravity bundles
  --dry-run                Show what would be removed without changing files
  -h, --help               Show this help message

Default (no mode flag): Copilot path — .github/* Toji files, docs/ai/, etc.

Note: --antigravity, --copilot-cli, --both, and --all are mutually exclusive.

What this removes (default / Copilot):
  - .github/copilot-instructions.md
  - .github/prompts/
  - .github/instructions/
  - .github/skills/
  - .github/agents/
  - .github/lessons-learned.md

  - docs/ai/
  - .agent/rules/toji-*.md and skill-*.md
  - .agent/workflows/toji-*.md (legacy cleanup)
  - .agent/mcp_config.json (legacy cleanup)
  - .agent/mcp_config.template.json (legacy cleanup)
  - .agent/implementation_plan.md and .agent/task.md (legacy cleanup)
  - AGENTS.toji-bridge.md
  - Toji section block inside AGENTS.md (if present)
  - Toji-managed pre-commit and pre-push hooks (if present)
  - Toji lines inside .git/info/exclude

--antigravity: only .agent Toji files/rules/workflows listed above; unrelated .agent files kept.

--copilot-cli: same repository instruction surfaces as Copilot mode.

--both: Copilot list above plus Antigravity Toji files.

--all: Copilot + Copilot CLI + Antigravity Toji files.

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

remove_toji_agent_mds() {
  local dir_path="$1"
  local f

  if [[ ! -d "$dir_path" ]]; then
    log "skip (not found): $dir_path"
    return 0
  fi

  # Remove both toji-*.md (Tier 1 originals) and skill-*.md (transpiled)
  for f in "$dir_path"/toji-*.md "$dir_path"/skill-*.md; do
    if [[ ! -e "$f" ]]; then
      continue
    fi
    remove_path "$f"
  done
}

remove_toji_agent_files() {
  local base="$1"
  remove_toji_agent_mds "$base/.agent/rules"
  remove_toji_agent_mds "$base/.agent/workflows"
  remove_path "$base/.agent/mcp_config.json"
  remove_path "$base/.agent/mcp_config.template.json"
  remove_path "$base/.agent/implementation_plan.md"
  remove_path "$base/.agent/task.md"
}

remove_toji_agents_section() {
  local agents_path="$1"

  if [[ ! -f "$agents_path" ]]; then
    log "skip (not found): $agents_path"
    return 0
  fi

  if ! grep -qF "$TOJI_SECTION_START" "$agents_path" || ! grep -qF "$TOJI_SECTION_END" "$agents_path"; then
    log "skip (Toji section markers not found): $agents_path"
    return 0
  fi

  local tmp_file
  tmp_file="$(mktemp)"

  awk -v start="$TOJI_SECTION_START" -v end="$TOJI_SECTION_END" '
    $0 == start {in_block=1; next}
    $0 == end {in_block=0; next}
    !in_block {print}
  ' "$agents_path" >"$tmp_file"

  if [[ "$DRY_RUN" == "true" ]]; then
    if grep -q '[^[:space:]]' "$tmp_file"; then
      log "[dry-run] remove Toji section from: $agents_path"
    else
      log "[dry-run] remove: $agents_path"
    fi
    rm -f "$tmp_file"
    return 0
  fi

  if grep -q '[^[:space:]]' "$tmp_file"; then
    mv "$tmp_file" "$agents_path"
    log "updated: $agents_path"
  else
    rm -f "$tmp_file"
    rm -f "$agents_path"
    log "removed: $agents_path"
  fi
}

cleanup_empty_dir() {
  local dir_path="$1"

  if [[ ! -d "$dir_path" ]]; then
    return 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    if [[ -z "$(find "$dir_path" -mindepth 1 -maxdepth 1 2>/dev/null)" ]]; then
      log "[dry-run] remove empty dir: $dir_path"
    fi
    return 0
  fi

  rmdir "$dir_path" 2>/dev/null || true
}

remove_legacy_toji_root_scripts() {
  # One-time cleanup: old installers copied these into the consumer project root.
  local base="$1"
  local f path
  for f in install.sh update.sh uninstall.sh DOCUMENTATION.md; do
    path="$base/$f"
    [[ -f "$path" ]] || continue
    case "$f" in
    install.sh)
      head -n 8 "$path" | grep -qF "Toji Agent — Installer" || continue
      ;;
    update.sh)
      head -n 8 "$path" | grep -qF "Toji Agent — Invisible sync" || continue
      ;;
    uninstall.sh)
      head -n 35 "$path" | grep -qF "Uninstall Toji Agent files from an existing project." || continue
      ;;
    DOCUMENTATION.md)
      head -n 5 "$path" | grep -qF "# Toji — Framework manual" || continue
      ;;
    esac
    remove_path "$path"
  done
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

    if ! grep -qF "Toji Invisible Governance — pre-commit guard" "$hook_path" 2>/dev/null && ! grep -qF "$HOOK_MARKER" "$hook_path" 2>/dev/null; then
      log "skip (not managed by Toji): $hook_path"
      continue
    fi

    remove_path "$hook_path"
  done
}

remove_toji_exclude_lines() {
  local base="$1"
  local mode="$2"
  local exclude_path="$base/.git/info/exclude"

  if [[ ! -f "$exclude_path" ]]; then
    log "skip (not found): $exclude_path"
    return 0
  fi

  local tmp_file
  tmp_file="$(mktemp)"

  case "$mode" in
  both|all)
    awk '
      $0 == "# Toji Agent — Invisible Governance (install.sh)" {next}
      $0 == "docs/ai/" {next}
      $0 == ".github/skills/" {next}
      $0 == ".github/prompts/" {next}
      $0 == ".github/instructions/" {next}
      $0 == ".github/instructions/toji-stack-*.instructions.md" {next}
      $0 == ".github/agents/" {next}
      $0 == ".github/copilot-instructions.md" {next}
      $0 == ".github/lessons-learned.md" {next}

      $0 == "AGENTS.md" {next}
      $0 == ".agent/" {next}
      $0 == ".agent/rules/toji-stack-*.md" {next}
      $0 == ".agent/*.json" {next}
      {print}
    ' "$exclude_path" >"$tmp_file"
    ;;
  antigravity)
    awk '
      $0 == ".agent/" {next}
      $0 == ".agent/rules/toji-stack-*.md" {next}
      $0 == ".agent/*.json" {next}
      {print}
    ' "$exclude_path" >"$tmp_file"
    ;;
  *)
    awk '{print}' "$exclude_path" >"$tmp_file"
    ;;
  esac

  if [[ "$DRY_RUN" == "true" ]]; then
    if ! cmp -s "$exclude_path" "$tmp_file"; then
      log "[dry-run] remove Toji entries from: $exclude_path"
    else
      log "skip (no Toji entries in): $exclude_path"
    fi
    rm -f "$tmp_file"
    return 0
  fi

  if cmp -s "$exclude_path" "$tmp_file"; then
    rm -f "$tmp_file"
    log "skip (no Toji entries in): $exclude_path"
    return 0
  fi

  mv "$tmp_file" "$exclude_path"
  log "updated: $exclude_path"
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
  --antigravity)
    ANTIGRAVITY_FLAG=1
    shift
    ;;
  --copilot-cli)
    COPILOT_CLI_FLAG=1
    shift
    ;;
  --both)
    BOTH_FLAG=1
    shift
    ;;
  --all)
    ALL_FLAG=1
    shift
    ;;
  -h | --help)
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

SELECTED_MODES=$((ANTIGRAVITY_FLAG + COPILOT_CLI_FLAG + BOTH_FLAG + ALL_FLAG))
if [[ "$SELECTED_MODES" -gt 1 ]]; then
  log "Error: --antigravity, --copilot-cli, --both, and --all are mutually exclusive."
  usage
  exit 1
fi
if [[ "$ALL_FLAG" -eq 1 ]]; then
  UNINSTALL_MODE=all
elif [[ "$BOTH_FLAG" -eq 1 ]]; then
  UNINSTALL_MODE=both
elif [[ "$ANTIGRAVITY_FLAG" -eq 1 ]]; then
  UNINSTALL_MODE=antigravity
elif [[ "$COPILOT_CLI_FLAG" -eq 1 ]]; then
  UNINSTALL_MODE=copilot-cli
else
  UNINSTALL_MODE=copilot
fi

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

log "Uninstalling Toji Agent from: $TARGET_DIR (mode=$UNINSTALL_MODE)"
if [[ "$DRY_RUN" == "true" ]]; then
  log "Dry run mode enabled (no files will be changed)."
fi

remove_legacy_toji_root_scripts "$TARGET_DIR"

case "$UNINSTALL_MODE" in
copilot)
  remove_path "$TARGET_DIR/.github/copilot-instructions.md"
  remove_path "$TARGET_DIR/.github/prompts"
  remove_path "$TARGET_DIR/.github/instructions"
  remove_path "$TARGET_DIR/.github/skills"
  remove_path "$TARGET_DIR/.github/agents"
  remove_path "$TARGET_DIR/.github/lessons-learned.md"
  remove_toji_agent_files "$TARGET_DIR"
  remove_path "$TARGET_DIR/docs/ai"
  remove_path "$TARGET_DIR/AGENTS.toji-bridge.md"
  remove_toji_agents_section "$TARGET_DIR/AGENTS.md"
  remove_toji_git_hooks
  remove_toji_exclude_lines "$TARGET_DIR" both
  cleanup_empty_dir "$TARGET_DIR/.github"
  cleanup_empty_dir "$TARGET_DIR/.agent/rules"
  cleanup_empty_dir "$TARGET_DIR/.agent/workflows"
  cleanup_empty_dir "$TARGET_DIR/.agent"
  cleanup_empty_dir "$TARGET_DIR/docs"
  ;;
copilot-cli)
  remove_path "$TARGET_DIR/.github/copilot-instructions.md"
  remove_path "$TARGET_DIR/.github/prompts"
  remove_path "$TARGET_DIR/.github/instructions"
  remove_path "$TARGET_DIR/.github/skills"
  remove_path "$TARGET_DIR/.github/agents"
  remove_path "$TARGET_DIR/.github/lessons-learned.md"
  remove_toji_agent_files "$TARGET_DIR"
  remove_path "$TARGET_DIR/docs/ai"
  remove_path "$TARGET_DIR/AGENTS.toji-bridge.md"
  remove_toji_agents_section "$TARGET_DIR/AGENTS.md"
  remove_toji_git_hooks
  remove_toji_exclude_lines "$TARGET_DIR" both
  cleanup_empty_dir "$TARGET_DIR/.github"
  cleanup_empty_dir "$TARGET_DIR/.agent/rules"
  cleanup_empty_dir "$TARGET_DIR/.agent/workflows"
  cleanup_empty_dir "$TARGET_DIR/.agent"
  cleanup_empty_dir "$TARGET_DIR/docs"
  ;;
antigravity)
  remove_toji_agent_files "$TARGET_DIR"
  remove_toji_git_hooks
  remove_toji_exclude_lines "$TARGET_DIR" antigravity
  cleanup_empty_dir "$TARGET_DIR/.agent/rules"
  cleanup_empty_dir "$TARGET_DIR/.agent/workflows"
  cleanup_empty_dir "$TARGET_DIR/.agent"
  ;;
both)
  remove_path "$TARGET_DIR/.github/copilot-instructions.md"
  remove_path "$TARGET_DIR/.github/prompts"
  remove_path "$TARGET_DIR/.github/instructions"
  remove_path "$TARGET_DIR/.github/skills"
  remove_path "$TARGET_DIR/.github/agents"
  remove_path "$TARGET_DIR/.github/lessons-learned.md"
  remove_toji_agent_files "$TARGET_DIR"
  remove_path "$TARGET_DIR/docs/ai"
  remove_path "$TARGET_DIR/AGENTS.toji-bridge.md"
  remove_toji_agents_section "$TARGET_DIR/AGENTS.md"
  remove_toji_git_hooks
  remove_toji_exclude_lines "$TARGET_DIR" both
  cleanup_empty_dir "$TARGET_DIR/.github"
  cleanup_empty_dir "$TARGET_DIR/.agent/rules"
  cleanup_empty_dir "$TARGET_DIR/.agent/workflows"
  cleanup_empty_dir "$TARGET_DIR/.agent"
  cleanup_empty_dir "$TARGET_DIR/docs"
  ;;
all)
  remove_path "$TARGET_DIR/.github/copilot-instructions.md"
  remove_path "$TARGET_DIR/.github/prompts"
  remove_path "$TARGET_DIR/.github/instructions"
  remove_path "$TARGET_DIR/.github/skills"
  remove_path "$TARGET_DIR/.github/agents"
  remove_path "$TARGET_DIR/.github/lessons-learned.md"
  remove_toji_agent_files "$TARGET_DIR"
  remove_path "$TARGET_DIR/docs/ai"
  remove_path "$TARGET_DIR/AGENTS.toji-bridge.md"
  remove_toji_agents_section "$TARGET_DIR/AGENTS.md"
  remove_toji_git_hooks
  remove_toji_exclude_lines "$TARGET_DIR" both
  cleanup_empty_dir "$TARGET_DIR/.github"
  cleanup_empty_dir "$TARGET_DIR/.agent/rules"
  cleanup_empty_dir "$TARGET_DIR/.agent/workflows"
  cleanup_empty_dir "$TARGET_DIR/.agent"
  cleanup_empty_dir "$TARGET_DIR/docs"
  ;;
esac

if [[ "$DRY_RUN" == "true" ]]; then
  log "Uninstall complete (dry run)."
else
  log "Uninstall complete."
fi
