#!/usr/bin/env bash
# Toji Agent — Health Check
#
# Run from inside the target Git repository root to verify that the Toji
# installation is complete and all expected governance files are in place.
#
# Usage:
#   bash scripts/linux/check.sh [--antigravity | --copilot-cli | --both | --all]
#   curl -fsSL https://raw.githubusercontent.com/kevsmir02/toji-agent/main/scripts/linux/check.sh | bash
#
# Exit codes:
#   0  — All checks passed
#   1  — One or more checks failed
#
set -euo pipefail

# ── Colour helpers ────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  GREEN="\033[0;32m"; RED="\033[0;31m"; YELLOW="\033[0;33m"
  BOLD="\033[1m"; RESET="\033[0m"
else
  GREEN=""; RED=""; YELLOW=""; BOLD=""; RESET=""
fi

PASS="${GREEN}✔${RESET}"
FAIL="${RED}✘${RESET}"
WARN="${YELLOW}!${RESET}"

# ── State ─────────────────────────────────────────────────────────────────────
ROOT="$(pwd)"
ANTIGRAVITY_FLAG=0
BOTH_FLAG=0
STATUS_MODE=0
TOTAL=0
PASSED=0
FAILED=0
WARNINGS=0

# ── CLI flags ─────────────────────────────────────────────────────────────────
usage() {
  cat <<'EOF'
Toji check.sh — verify that the Toji installation is complete.

Usage:
  bash scripts/linux/check.sh [--antigravity | --both | --status]

Flags:
  (none)         Check Copilot install (default)
  --antigravity  Check Antigravity install
  --both         Check Copilot and Antigravity install
  --status       Print local governance diagnostic status and exit
  --from-install Internal no-op flag accepted for installer compatibility
  --from-update  Internal no-op flag accepted for updater compatibility

Run from the root of the target repository.
EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --copilot)      shift ;;
    --antigravity)  ANTIGRAVITY_FLAG=1; shift ;;
    --both)         BOTH_FLAG=1; shift ;;
    --status)       STATUS_MODE=1; shift ;;
    --from-install) shift ;;
    --from-update)  shift ;;
    -h|--help)      usage ;;
    *) echo "Unknown argument: $1"; usage ;;
  esac
done

SELECTED_MODES=$((ANTIGRAVITY_FLAG + BOTH_FLAG))
if [[ "$SELECTED_MODES" -gt 1 ]]; then
  echo "check.sh: --antigravity and --both are mutually exclusive. Use one mode flag, or no flag for Copilot only."
  exit 1
fi

if [[ "$STATUS_MODE" -eq 1 ]]; then
  echo ""
  echo -e "${BOLD}Toji Agent — Local Governance Status${RESET}"
  echo "  Repository: $ROOT"

  echo ""
  echo -e "${BOLD}[ Exclusions ] .git/info/exclude${RESET}"
  if [[ -f "$ROOT/.git/info/exclude" ]]; then
    if grep -qF "Toji Agent — Invisible Governance" "$ROOT/.git/info/exclude" 2>/dev/null; then
      echo "  $PASS  Toji exclusion block present"
      grep -n "Toji Agent — Invisible Governance\|^docs/ai/\|^\.github/\|^\.agent/\|^AGENTS.md" "$ROOT/.git/info/exclude" | sed 's/^/  /'
    else
      echo "  $WARN  Toji exclusion block missing"
    fi
  else
    echo "  $FAIL  Missing .git/info/exclude"
  fi

  echo ""
  echo -e "${BOLD}[ Hook ] .git/hooks/pre-commit${RESET}"
  if [[ -f "$ROOT/.git/hooks/pre-commit" ]]; then
    if grep -qF "Toji Invisible Governance" "$ROOT/.git/hooks/pre-commit" 2>/dev/null; then
      echo "  $PASS  Toji pre-commit hook installed"
    else
      echo "  $WARN  pre-commit exists but Toji marker missing"
    fi
  else
    echo "  $FAIL  Missing .git/hooks/pre-commit"
  fi

  echo ""
  exit 0
fi

# ── Check helpers ─────────────────────────────────────────────────────────────
check_file() {
  local label="$1" path="$2"
  TOTAL=$((TOTAL + 1))
  if [[ -f "$ROOT/$path" ]]; then
    echo -e "  $PASS  $label"
    PASSED=$((PASSED + 1))
  else
    echo -e "  $FAIL  $label ${RED}(missing: $path)${RESET}"
    FAILED=$((FAILED + 1))
  fi
}

check_dir() {
  local label="$1" path="$2"
  TOTAL=$((TOTAL + 1))
  if [[ -d "$ROOT/$path" ]]; then
    echo -e "  $PASS  $label"
    PASSED=$((PASSED + 1))
  else
    echo -e "  $FAIL  $label ${RED}(missing: $path/)${RESET}"
    FAILED=$((FAILED + 1))
  fi
}

check_dir_nonempty() {
  local label="$1" path="$2"
  TOTAL=$((TOTAL + 1))
  if [[ ! -d "$ROOT/$path" ]]; then
    echo -e "  $FAIL  $label ${RED}(missing: $path/)${RESET}"
    FAILED=$((FAILED + 1))
    return
  fi
  local count
  count=$(find "$ROOT/$path" -maxdepth 1 -mindepth 1 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$count" -gt 0 ]]; then
    echo -e "  $PASS  $label ${GREEN}($count item(s))${RESET}"
    PASSED=$((PASSED + 1))
  else
    echo -e "  $WARN  $label ${YELLOW}(directory exists but is empty)${RESET}"
    WARNINGS=$((WARNINGS + 1))
  fi
}

check_glob() {
  local label="$1" pattern="$2"
  TOTAL=$((TOTAL + 1))
  local matches
  matches=$(find "$ROOT" -maxdepth 3 -path "$ROOT/$pattern" -type f 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$matches" -gt 0 ]]; then
    echo -e "  $PASS  $label ${GREEN}($matches file(s))${RESET}"
    PASSED=$((PASSED + 1))
  else
    echo -e "  $FAIL  $label ${RED}(no files matching $pattern)${RESET}"
    FAILED=$((FAILED + 1))
  fi
}

check_file_contains() {
  local label="$1" path="$2" needle="$3"
  TOTAL=$((TOTAL + 1))
  if [[ -f "$ROOT/$path" ]] && grep -qF "$needle" "$ROOT/$path" 2>/dev/null; then
    echo -e "  $PASS  $label"
    PASSED=$((PASSED + 1))
  elif [[ ! -f "$ROOT/$path" ]]; then
    echo -e "  $FAIL  $label ${RED}(file missing: $path)${RESET}"
    FAILED=$((FAILED + 1))
  else
    echo -e "  $WARN  $label ${YELLOW}(file exists but Toji marker not found)${RESET}"
    WARNINGS=$((WARNINGS + 1))
  fi
}

section() {
  echo ""
  echo -e "${BOLD}$1${RESET}"
}

# ── Banner ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Toji Agent — Installation Health Check${RESET}"
echo -e "  Repository: ${BOLD}$ROOT${RESET}"



# ── Copilot checks (always run unless antigravity only) ───────────────────────
if [[ "$ANTIGRAVITY_FLAG" -eq 0 ]] || [[ "$BOTH_FLAG" -eq 1 ]]; then
  section "[ Copilot ] shared instruction surfaces"
  check_file   "copilot-instructions.md"         ".github/copilot-instructions.md"
  check_dir_nonempty "prompts/ (slash commands)" ".github/prompts"
  check_dir_nonempty "instructions/ (Tier 1)"   ".github/instructions"
  check_dir_nonempty "skills/ (SKILL.md library)" ".github/skills"

  check_dir    "agents/ (@toji agent)"           ".github/agents"
  check_file "AGENTS.md (agent instructions)" "AGENTS.md"
fi

# ── Antigravity checks ────────────────────────────────────────────────────────
if [[ "$ANTIGRAVITY_FLAG" -eq 1 ]] || [[ "$BOTH_FLAG" -eq 1 ]]; then
  section "[ Antigravity ] .agent/"
  check_file "toji.agent.md (Antigravity persona)" ".agent/agents/toji.agent.md"
  check_file_contains "toji.agent.md has governance markers" ".agent/agents/toji.agent.md" "toji-governance:start"
  check_glob "toji-*.md (workflows)"             ".agent/workflows/toji-*.md"
  check_file "mcp_config.template.json"          ".agent/mcp_config.template.json"
fi

# ── Shared governance checks (always) ────────────────────────────────────────
section "[ Governance ] Invisible Mode"
check_file_contains "AGENTS.md contains Toji mandate" \
  "AGENTS.md" "Toji Agent"

HOOK_PATH=".git/hooks/pre-commit"
check_file_contains "pre-commit hook installed" \
  "$HOOK_PATH" "Toji Invisible Governance"

EXCLUDE_PATH=".git/info/exclude"
check_file_contains ".git/info/exclude has Toji block" \
  "$EXCLUDE_PATH" "Toji Agent — Invisible Governance"

section "[ Docs ] docs/ai/"
check_dir "docs/ai/ directory exists" "docs/ai"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "────────────────────────────────────────"
echo -e "  Total:    ${BOLD}$TOTAL${RESET}"
echo -e "  ${GREEN}Passed:${RESET}   $PASSED"
if [[ "$WARNINGS" -gt 0 ]]; then
  echo -e "  ${YELLOW}Warnings: $WARNINGS${RESET}"
fi
if [[ "$FAILED" -gt 0 ]]; then
  echo -e "  ${RED}Failed:   $FAILED${RESET}"
fi
echo "────────────────────────────────────────"

if [[ "$FAILED" -eq 0 && "$WARNINGS" -eq 0 ]]; then
  echo -e ""
  echo -e "  ${GREEN}${BOLD}All checks passed. Toji is installed correctly.${RESET}"
  echo ""
  exit 0
elif [[ "$FAILED" -eq 0 ]]; then
  echo -e ""
  echo -e "  ${YELLOW}${BOLD}Installation complete with warnings.${RESET}"
  echo -e "  ${YELLOW}Run '/onboard' in your IDE to complete governance setup.${RESET}"
  echo ""
  exit 0
else
  echo ""
  echo -e "  ${RED}${BOLD}Installation is incomplete or corrupted.${RESET}"
  echo -e "  ${RED}Re-run the installer from the repository root:${RESET}"
  echo ""
  echo "    curl -fsSL https://raw.githubusercontent.com/kevsmir02/toji-agent/main/scripts/linux/install.sh | bash"
  echo ""
  exit 1
fi
