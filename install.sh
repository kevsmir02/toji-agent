#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR=""
FORCE="false"
YES="false"
DRY_RUN="false"

usage() {
  cat <<'EOF'
Install Toji Agent into an existing project.

Usage:
  ./install.sh --target /path/to/project [--yes] [--force] [--dry-run]
  ./install.sh /path/to/project [--yes] [--force] [--dry-run]

Options:
  --target <path>  Target project directory
  --yes            Skip confirmation prompts
  --force          Overwrite existing .github/docs/.gitignore (backs up old files)
  --dry-run        Show what would happen without copying files
  -h, --help       Show this help message
EOF
}

log() {
  printf '%s\n' "$1"
}

confirm() {
  local prompt="$1"
  if [[ "$YES" == "true" ]]; then
    return 0
  fi

  read -r -p "$prompt [y/N]: " reply
  [[ "$reply" =~ ^[Yy]$ ]]
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

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET_DIR="${2:-}"
      shift 2
      ;;
    --yes)
      YES="true"
      shift
      ;;
    --force)
      FORCE="true"
      shift
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

if [[ "$TARGET_DIR" == "$SCRIPT_DIR" ]]; then
  log "Target is this template repo itself. Nothing to install."
  exit 0
fi

log "Installing Toji Agent into: $TARGET_DIR"
log "Items: .github, docs, .gitignore"

if [[ "$DRY_RUN" == "true" ]]; then
  log "Dry run mode enabled (no files will be changed)."
fi

if [[ "$FORCE" != "true" ]]; then
  if [[ -e "$TARGET_DIR/.github" || -e "$TARGET_DIR/docs" || -e "$TARGET_DIR/.gitignore" ]]; then
    if ! confirm "Some target files already exist. Continue with safe merge (existing files are kept, new files copied)?"; then
      log "Cancelled."
      exit 0
    fi
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    log "[dry-run] merge copy: $SCRIPT_DIR/.github/* -> $TARGET_DIR/.github/"
    log "[dry-run] merge copy: $SCRIPT_DIR/docs/* -> $TARGET_DIR/docs/"
    if [[ ! -e "$TARGET_DIR/.gitignore" ]]; then
      log "[dry-run] copy file: $SCRIPT_DIR/.gitignore -> $TARGET_DIR/.gitignore"
    else
      log "[dry-run] keep existing: $TARGET_DIR/.gitignore"
    fi
    log "Install complete (dry run)."
    exit 0
  fi

  mkdir -p "$TARGET_DIR/.github" "$TARGET_DIR/docs"
  cp -Rn "$SCRIPT_DIR/.github/." "$TARGET_DIR/.github/"
  cp -Rn "$SCRIPT_DIR/docs/." "$TARGET_DIR/docs/"

  if [[ ! -e "$TARGET_DIR/.gitignore" ]]; then
    cp "$SCRIPT_DIR/.gitignore" "$TARGET_DIR/.gitignore"
    log "copied: .gitignore"
  else
    log "kept existing: .gitignore"
  fi

  log "Install complete (safe merge mode)."
  exit 0
fi

for item in ".github" "docs" ".gitignore"; do
  if [[ -e "$TARGET_DIR/$item" ]]; then
    backup_existing "$TARGET_DIR/$item"
  fi
done

copy_item "$SCRIPT_DIR/.github" "$TARGET_DIR"
copy_item "$SCRIPT_DIR/docs" "$TARGET_DIR"
copy_item "$SCRIPT_DIR/.gitignore" "$TARGET_DIR"

log "Install complete (force mode)."