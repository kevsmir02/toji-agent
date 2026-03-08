#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=""
SOURCE_DIR=""
CLEANUP_DIR=""
TARGET_DIR=""
FORCE="false"
DRY_RUN="false"
RUN_DETECT_STACK="false"
AGENTS_MODE="keep-bridge"
AGENTS_MODE_EXPLICIT="false"
SOURCE_IS_LOCAL="false"

REPO_ARCHIVE_URL="https://codeload.github.com/kevsmir02/toji-agent/tar.gz/refs/heads/main"

AGENTS_BRIDGE_START="<!-- TOJI_AGENT_BRIDGE_START -->"
AGENTS_BRIDGE_END="<!-- TOJI_AGENT_BRIDGE_END -->"
STACK_MARKERS=()

usage() {
  cat <<'EOF'
Install Toji Agent into an existing project.

Usage:
  ./install.sh --target /path/to/project [OPTIONS]
  ./install.sh /path/to/project [OPTIONS]

Default behaviour (no flags):
  - .github/    always overwritten with latest Toji Agent files
  - docs/       safe merge  (existing files kept, new files added)
  - .gitignore  kept if it already exists
  - AGENTS.md   auto-detected: sidecar-only if a third-party owner is found (e.g. Laravel Boost),
                otherwise keep-bridge (reference block appended)

Options:
  --target <path>          Target project directory
  --force                  Backup and overwrite everything, including docs/
  --dry-run                Show what would happen without copying files
  --detect-stack           Run stack detection and update active profile after install
  --agents-mode <mode>     AGENTS.md handling: keep-bridge | sidecar-only | overwrite
  -h, --help               Show this help message
EOF
}

log() {
  printf '%s\n' "$1"
}

cleanup() {
  if [[ -n "$CLEANUP_DIR" && -d "$CLEANUP_DIR" ]]; then
    rm -rf "$CLEANUP_DIR"
  fi
}

resolve_script_dir() {
  local script_source="${BASH_SOURCE[0]-}"

  if [[ -n "$script_source" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "$script_source")" && pwd)"
  else
    SCRIPT_DIR="$PWD"
  fi
}

resolve_source_dir() {
  # Only treat the script's directory as the source when the script is running
  # from an actual file on disk (not piped through curl | bash).
  local script_source="${BASH_SOURCE[0]-}"
  local is_real_file="false"
  if [[ -n "$script_source" && -f "$script_source" ]]; then
    is_real_file="true"
  fi

  if [[ "$is_real_file" == "true" && -d "$SCRIPT_DIR/.github" && -d "$SCRIPT_DIR/docs" && -f "$SCRIPT_DIR/.gitignore" ]]; then
    SOURCE_DIR="$SCRIPT_DIR"
    SOURCE_IS_LOCAL="true"
    return 0
  fi

  log "Local template files not found; downloading from GitHub..."

  CLEANUP_DIR="$(mktemp -d)"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$REPO_ARCHIVE_URL" | tar -xz -C "$CLEANUP_DIR"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$REPO_ARCHIVE_URL" | tar -xz -C "$CLEANUP_DIR"
  else
    log "Error: curl or wget is required to download template files in piped mode."
    exit 1
  fi

  SOURCE_DIR="$(find "$CLEANUP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
  if [[ -z "$SOURCE_DIR" ]]; then
    log "Error: failed to extract template archive."
    exit 1
  fi

  if [[ ! -d "$SOURCE_DIR/.github" || ! -d "$SOURCE_DIR/docs" || ! -f "$SOURCE_DIR/.gitignore" ]]; then
    log "Error: downloaded template is missing required files."
    exit 1
  fi
}


backup_existing() {
  local path="$1"
  local stamp
  stamp="$(date +%Y%m%d-%H%M%S)"
  local backup_path="${path}.bak.${stamp}"

  if [[ "$DRY_RUN" == "true" ]]; then
    log "[dry-run] backup: $path -> $backup_path"
    return 0
  fi

  mv "$path" "$backup_path"
  log "backed up: $path -> $backup_path"
}

copy_item() {
  local src="$1"
  local dest="$2"

  if [[ -d "$src" ]]; then
    if [[ "$DRY_RUN" == "true" ]]; then
      log "[dry-run] copy dir: $src -> $dest"
      return 0
    fi
    cp -R "$src" "$dest"
    return 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    log "[dry-run] copy file: $src -> $dest"
    return 0
  fi
  cp "$src" "$dest"
}

write_bridge_file() {
  local bridge_path="$1"
  local content
  content=$(cat <<'EOF'
# Toji Agent Bridge

This file is a compatibility bridge for agent runtimes that read AGENTS.md.

## Source of Truth
- `.github/copilot-instructions.md`
- `docs/ai/features/`
- `docs/ai/implementation/`
- `docs/ai/testing/`
- `docs/ai/deployment/`
- `docs/ai/monitoring/`

## Precedence
1. Feature docs in `docs/ai/features/`
2. Active stack skill from `.github/skills/`
3. `.github/copilot-instructions.md`
4. Tool/runtime defaults

## Bridge Rules
- Do not redefine coding standards here.
- Do not duplicate workflows already defined in Toji docs and instructions.
- Use this file only for runtime compatibility and delegation.
EOF
)

  if [[ "$DRY_RUN" == "true" ]]; then
    log "[dry-run] write bridge file: $bridge_path"
    return 0
  fi

  printf '%s\n' "$content" > "$bridge_path"
  log "wrote bridge file: $bridge_path"
}

append_agents_reference_block() {
  local agents_file="$1"
  local bridge_name="$2"

  if grep -q "$AGENTS_BRIDGE_START" "$agents_file"; then
    log "AGENTS bridge reference already present: $agents_file"
    return 0
  fi

  local block
  block=$(cat <<EOF

$AGENTS_BRIDGE_START
## Toji Agent Bridge

This project uses Toji Agent as the policy source.
See $bridge_name for precedence and delegation rules.
$AGENTS_BRIDGE_END
EOF
)

  if [[ "$DRY_RUN" == "true" ]]; then
    log "[dry-run] append bridge reference block to: $agents_file"
    return 0
  fi

  printf '%s\n' "$block" >> "$agents_file"
  log "updated AGENTS reference: $agents_file"
}

contains_in_file_set() {
  local pattern="$1"
  shift

  local file_name file
  for file_name in "$@"; do
    while IFS= read -r -d '' file; do
      if grep -Eiq "$pattern" "$file" 2>/dev/null; then
        return 0
      fi
    done < <(find "$TARGET_DIR" -maxdepth 4 -type f -name "$file_name" -print0 2>/dev/null)
  done

  return 1
}

contains_in_json_files() {
  local pattern="$1"
  contains_in_file_set "$pattern" "package.json"
}

file_exists_in_tree() {
  local file_name
  for file_name in "$@"; do
    if find "$TARGET_DIR" -maxdepth 4 -type f -name "$file_name" -print -quit 2>/dev/null | grep -q .; then
      return 0
    fi
  done

  return 1
}

record_stack_marker() {
  local marker="$1"
  STACK_MARKERS+=("$marker")
}

detect_stack_id() {
  local has_laravel="false"
  local has_inertia_backend="false"
  local has_inertia_react="false"
  local has_react="false"
  local has_ziggy="false"
  local has_tailwind="false"
  local has_pest="false"
  local has_vitest="false"

  STACK_MARKERS=()

  if contains_in_file_set '"laravel/framework"' "composer.json" || [[ -f "$TARGET_DIR/artisan" ]]; then
    has_laravel="true"
    record_stack_marker "laravel"
  fi

  if contains_in_file_set '"inertiajs/inertia-laravel"' "composer.json"; then
    has_inertia_backend="true"
    record_stack_marker "inertia-laravel"
  fi

  if contains_in_json_files '@inertiajs/react'; then
    has_inertia_react="true"
    record_stack_marker "inertia-react"
  fi

  if contains_in_json_files '"react"|"react-dom"'; then
    has_react="true"
    record_stack_marker "react"
  fi

  if contains_in_file_set 'tightenco/ziggy|ziggy-js' "composer.json" "package.json"; then
    has_ziggy="true"
    record_stack_marker "ziggy"
  fi

  if contains_in_json_files 'tailwindcss' || file_exists_in_tree "tailwind.config.js" "tailwind.config.cjs" "tailwind.config.mjs" "tailwind.config.ts"; then
    has_tailwind="true"
    record_stack_marker "tailwind"
  fi

  if contains_in_file_set 'pestphp/pest|pestphp/pest-plugin' "composer.json" || file_exists_in_tree "Pest.php"; then
    has_pest="true"
    record_stack_marker "pest"
  fi

  if contains_in_json_files '"vitest"' || file_exists_in_tree "vitest.config.js" "vitest.config.cjs" "vitest.config.mjs" "vitest.config.ts"; then
    has_vitest="true"
    record_stack_marker "vitest"
  fi

  if contains_in_json_files '"vite"'; then
    record_stack_marker "vite"
  fi

  if [[ "$has_laravel" == "true" && "$has_react" == "true" ]] && [[ "$has_inertia_backend" == "true" || "$has_inertia_react" == "true" ]]; then
    if [[ "$has_ziggy" == "true" || "$has_tailwind" == "true" || "$has_pest" == "true" || "$has_vitest" == "true" ]]; then
      :
    fi
    printf '%s\n' "laravel-inertia-react"
    return 0
  fi

  local has_express="false"
  local has_mongo="false"

  if contains_in_json_files '"express"'; then
    has_express="true"
    record_stack_marker "express"
  fi
  if contains_in_json_files '"mongoose"|"mongodb"'; then
    has_mongo="true"
    record_stack_marker "mongodb"
  fi

  if [[ "$has_express" == "true" && "$has_react" == "true" && "$has_mongo" == "true" ]]; then
    printf '%s\n' "mern"
    return 0
  fi

  printf '%s\n' "none"
}

resolve_stack_skill_path() {
  local stack_id="$1"
  local candidate_a="$TARGET_DIR/.github/skills/stack-${stack_id}/SKILL.md"
  local candidate_b="$TARGET_DIR/.github/skills/${stack_id}/SKILL.md"

  if [[ -f "$candidate_a" ]]; then
    printf '%s\n' ".github/skills/stack-${stack_id}/SKILL.md"
    return 0
  fi

  if [[ -f "$candidate_b" ]]; then
    printf '%s\n' ".github/skills/${stack_id}/SKILL.md"
    return 0
  fi

  printf '%s\n' "none"
}

update_active_stack_profile() {
  local instructions_path="$TARGET_DIR/.github/copilot-instructions.md"
  local mode="$1"
  local stack_id="$2"
  local active_skill="$3"
  local last_detected="$4"

  if [[ ! -f "$instructions_path" ]]; then
    log "skipped stack profile update: .github/copilot-instructions.md not found"
    return 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    log "[dry-run] update active stack profile in: $instructions_path"
    log "[dry-run] Mode=$mode Stack ID=$stack_id Active Skill=$active_skill Last Detected=$last_detected"
    return 0
  fi

  local tmp_file
  tmp_file="$(mktemp)"

  awk \
    -v mode="$mode" \
    -v stack_id="$stack_id" \
    -v active_skill="$active_skill" \
    -v last_detected="$last_detected" \
    '{
      if ($0 ~ /^- Mode:/) {
        print "- Mode: `" mode "`"
      } else if ($0 ~ /^- Stack ID:/) {
        print "- Stack ID: `" stack_id "`"
      } else if ($0 ~ /^- Active Skill:/) {
        print "- Active Skill: `" active_skill "`"
      } else if ($0 ~ /^- Last Detected:/) {
        print "- Last Detected: `" last_detected "`"
      } else {
        print $0
      }
    }' "$instructions_path" > "$tmp_file"

  mv "$tmp_file" "$instructions_path"
  log "updated active stack profile: $instructions_path"
}

# Known third-party AGENTS.md markers — add new tools here as needed
THIRD_PARTY_AGENTS_MARKERS=(
  "laravel-boost-guidelines"
)

agents_file_is_third_party() {
  local agents_path="$1"
  for marker in "${THIRD_PARTY_AGENTS_MARKERS[@]}"; do
    if grep -q "$marker" "$agents_path" 2>/dev/null; then
      printf '%s\n' "$marker"
      return 0
    fi
  done
  return 1
}

handle_agents_file() {
  local agents_path="$TARGET_DIR/AGENTS.md"
  local bridge_sidecar_path="$TARGET_DIR/AGENTS.toji-bridge.md"

  if [[ ! -f "$agents_path" ]]; then
    log "AGENTS.md not found. Creating minimal bridge AGENTS.md"
    write_bridge_file "$agents_path"
    return 0
  fi

  # Auto-detect third-party ownership unless user explicitly set --agents-mode
  if [[ "$AGENTS_MODE_EXPLICIT" == "false" && "$AGENTS_MODE" == "keep-bridge" ]]; then
    local detected_marker
    if detected_marker=$(agents_file_is_third_party "$agents_path"); then
      log "Detected third-party AGENTS.md owner ($detected_marker). Switching to sidecar-only to avoid conflicts."
      AGENTS_MODE="sidecar-only"
    fi
  fi

  case "$AGENTS_MODE" in
    keep-bridge)
      write_bridge_file "$bridge_sidecar_path"
      append_agents_reference_block "$agents_path" "AGENTS.toji-bridge.md"
      ;;
    sidecar-only)
      write_bridge_file "$bridge_sidecar_path"
      log "kept existing AGENTS.md unchanged"
      ;;
    overwrite)
      write_bridge_file "$agents_path"
      log "overwrote AGENTS.md with Toji bridge"
      ;;
    *)
      log "Unknown --agents-mode value: $AGENTS_MODE"
      log "Expected one of: keep-bridge | sidecar-only | overwrite"
      exit 1
      ;;
  esac
}

handle_stack_detection() {
  if [[ "$RUN_DETECT_STACK" != "true" ]]; then
    log "Stack detection skipped. Profile remains generic by default."
    return 0
  fi

  local stack_id detected_at
  stack_id="$(detect_stack_id)"
  detected_at="$(date +%F)"

  if [[ ${#STACK_MARKERS[@]} -gt 0 ]]; then
    log "Detected stack markers: ${STACK_MARKERS[*]}"
  else
    log "Detected stack markers: none"
  fi

  if [[ "$stack_id" == "laravel-inertia-react" || "$stack_id" == "mern" ]]; then
    local skill_path
    skill_path="$(resolve_stack_skill_path "$stack_id")"
    if [[ "$skill_path" != "none" ]]; then
      update_active_stack_profile "stack-specific" "$stack_id" "$skill_path" "$detected_at"
      log "Stack detected: $stack_id (activated $skill_path)"
      return 0
    fi
  fi

  update_active_stack_profile "generic" "$stack_id" "none" "$detected_at"

  if [[ "$stack_id" == "none" ]]; then
    log "Stack set to generic (no supported stack detected)."
  else
    log "Stack set to generic (detected $stack_id but no supported stack skill found)."
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET_DIR="${2:-}"
      shift 2
      ;;
    --force)
      FORCE="true"
      shift
      ;;
    --dry-run)
      DRY_RUN="true"
      shift
      ;;
    --detect-stack)
      RUN_DETECT_STACK="true"
      shift
      ;;
    --agents-mode)
      AGENTS_MODE="${2:-}"
      AGENTS_MODE_EXPLICIT="true"
      shift 2
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

trap cleanup EXIT

resolve_script_dir
resolve_source_dir

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

if [[ "$SOURCE_IS_LOCAL" == "true" && "$TARGET_DIR" == "$SOURCE_DIR" ]]; then
  log "Target is this template repo itself. Nothing to install."
  exit 0
fi

log "Installing Toji Agent into: $TARGET_DIR"

if [[ "$DRY_RUN" == "true" ]]; then
  log "Dry run mode enabled (no files will be changed)."
fi

if [[ "$FORCE" == "true" ]]; then
  # Back up and fully replace everything
  for item in ".github" "docs" ".gitignore"; do
    if [[ -e "$TARGET_DIR/$item" ]]; then
      backup_existing "$TARGET_DIR/$item"
    fi
  done

  if [[ "$DRY_RUN" == "true" ]]; then
    log "[dry-run] overwrite: $SOURCE_DIR/.github -> $TARGET_DIR/.github"
    log "[dry-run] overwrite: $SOURCE_DIR/docs -> $TARGET_DIR/docs"
    log "[dry-run] overwrite: $SOURCE_DIR/.gitignore -> $TARGET_DIR/.gitignore"
    handle_agents_file
    handle_stack_detection
    log "Install complete (dry run, force mode)."
    exit 0
  fi

  copy_item "$SOURCE_DIR/.github" "$TARGET_DIR"
  copy_item "$SOURCE_DIR/docs" "$TARGET_DIR"
  copy_item "$SOURCE_DIR/.gitignore" "$TARGET_DIR"

  handle_agents_file
  handle_stack_detection
  log "Install complete (force mode)."
  exit 0
fi

# Default: overwrite .github, safe-merge docs, keep .gitignore
if [[ "$DRY_RUN" == "true" ]]; then
  log "[dry-run] overwrite: $SOURCE_DIR/.github -> $TARGET_DIR/.github"
  log "[dry-run] safe-merge: $SOURCE_DIR/docs -> $TARGET_DIR/docs"
  if [[ ! -e "$TARGET_DIR/.gitignore" ]]; then
    log "[dry-run] copy file: $SOURCE_DIR/.gitignore -> $TARGET_DIR/.gitignore"
  else
    log "[dry-run] keep existing: $TARGET_DIR/.gitignore"
  fi
  handle_agents_file
  handle_stack_detection
  log "Install complete (dry run)."
  exit 0
fi

# Overwrite .github entirely
if [[ -e "$TARGET_DIR/.github" ]]; then
  rm -rf "$TARGET_DIR/.github"
fi
copy_item "$SOURCE_DIR/.github" "$TARGET_DIR"
log "installed: .github"

# Safe-merge docs (existing files kept, new files added)
mkdir -p "$TARGET_DIR/docs"
cp -Rn "$SOURCE_DIR/docs/." "$TARGET_DIR/docs/"
log "merged: docs"

# Keep .gitignore if it exists
if [[ ! -e "$TARGET_DIR/.gitignore" ]]; then
  cp "$SOURCE_DIR/.gitignore" "$TARGET_DIR/.gitignore"
  log "copied: .gitignore"
else
  log "kept existing: .gitignore"
fi

handle_agents_file
handle_stack_detection

log "Install complete."