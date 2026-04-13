#!/usr/bin/env bash
# Myna Update Script
#
# Updates Myna skills and agent file to the latest version.
# Does NOT touch your vault — configs and data are preserved.
#
# Usage:
#   ./update.sh
#   ./update.sh --vault-path ~/path/to/vault   # required only if agent file is missing
#
# Upgrade workflow:
#   git pull && ./update.sh

set -eo pipefail

# ── Defaults ──────────────────────────────────────────────────

VAULT_PATH=""
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION="1.0.0"

AGENT_FILE="$HOME/.claude/agents/myna.md"

# ── Colors ────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

info()  { printf "${GREEN}✓${NC} %s\n" "$1"; }
warn()  { printf "${YELLOW}!${NC} %s\n" "$1"; }
err()   { printf "${RED}✗${NC} %s\n" "$1" >&2; }
step()  { printf "\n${BOLD}── %s ──${NC}\n" "$1"; }

# ── Usage ─────────────────────────────────────────────────────

usage() {
  cat <<EOF
${BOLD}Myna Update${NC} — Update skills and agent file to the latest version

${BOLD}Usage:${NC}
  ./update.sh [options]

${BOLD}Options:${NC}
  --vault-path <path>     Path to your Obsidian vault root (auto-detected if omitted)
  --help                  Show this help message

${BOLD}Examples:${NC}
  ./update.sh
  ./update.sh --vault-path ~/Documents/MyVault

${BOLD}Note:${NC}
  Your vault data and configs are never touched.
  Only skills (~/.claude/skills/) and agent file (~/.claude/agents/myna.md) are updated.
EOF
  exit 0
}

# ── Parse Arguments ───────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case "$1" in
    --vault-path)  VAULT_PATH="$2"; shift 2 ;;
    --help|-h)     usage ;;
    *)             err "Unknown option: $1"; usage ;;
  esac
done

# ── Prerequisites ─────────────────────────────────────────────

step "Prerequisites"

# Check source files exist
if [ ! -f "$SCRIPT_DIR/agents/main.md" ]; then
  err "agents/main.md not found — run update from the Myna repo root"
  exit 1
fi
info "Source files found"

# ── Detect Vault Path ─────────────────────────────────────────

if [ -z "$VAULT_PATH" ]; then
  # Try to read vault path from existing agent file
  if [ -f "$AGENT_FILE" ]; then
    # Extract the vault path from the line: All Myna data lives under `<path>/{{SUBFOLDER}}/`.
    # After substitution the line looks like: All Myna data lives under `/absolute/path/subfolder/`.
    # We match the path before the last path component (the subfolder).
    detected=$(grep -oE 'under `[^`]+`' "$AGENT_FILE" 2>/dev/null | head -1 | sed "s/under \`//;s/\`//")
    if [ -n "$detected" ]; then
      # detected is VAULT_PATH/SUBFOLDER/ — strip trailing /SUBFOLDER/
      VAULT_PATH="$(dirname "$detected")"
      SUBFOLDER="$(basename "$detected")"
      info "Detected vault path from existing agent file: $VAULT_PATH (subfolder: $SUBFOLDER)"
    fi
  fi
fi

# If still empty, fail with a helpful message
if [ -z "$VAULT_PATH" ]; then
  err "Could not detect vault path — no existing agent file found at $AGENT_FILE"
  echo ""
  echo "  Run with --vault-path to provide it explicitly:"
  echo "    ./update.sh --vault-path ~/path/to/vault"
  exit 1
fi

# If vault path was provided on CLI, we also need the subfolder from the existing agent file
if [ -z "$SUBFOLDER" ]; then
  if [ -f "$AGENT_FILE" ]; then
    detected=$(grep -oE 'under `[^`]+`' "$AGENT_FILE" 2>/dev/null | head -1 | sed "s/under \`//;s/\`//")
    if [ -n "$detected" ]; then
      SUBFOLDER="$(basename "$detected")"
      info "Detected subfolder from existing agent file: $SUBFOLDER"
    fi
  fi
  # Fall back to default if still unset
  SUBFOLDER="${SUBFOLDER:-myna}"
fi

# Resolve vault path to absolute
VAULT_PATH="$(cd "$VAULT_PATH" 2>/dev/null && pwd)" || {
  err "Vault path does not exist: $VAULT_PATH"
  exit 1
}

if [ ! -d "$VAULT_PATH" ]; then
  err "Vault path is not a directory: $VAULT_PATH"
  exit 1
fi
info "Vault path: $VAULT_PATH"

# ── Copy Skills ───────────────────────────────────────────────

step "Updating skills in ~/.claude/skills/"

SKILLS_DEST="$HOME/.claude/skills"

feature_count=0
steering_count=0

for skill_dir in "$SCRIPT_DIR"/agents/skills/myna-*/; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"

  if [[ "$skill_name" == myna-steering-* ]]; then
    steering_count=$((steering_count + 1))
  else
    feature_count=$((feature_count + 1))
  fi

  dest_dir="$SKILLS_DEST/$skill_name"
  mkdir -p "$dest_dir"
  cp "$skill_dir/SKILL.md" "$dest_dir/SKILL.md"
done

info "Updated $feature_count feature skills + $steering_count steering skills"

# ── Regenerate Agent File ─────────────────────────────────────

step "Regenerating agent file"

AGENT_DIR="$HOME/.claude/agents"
mkdir -p "$AGENT_DIR"

sed \
  -e "s|{{VAULT_PATH}}|$VAULT_PATH|g" \
  -e "s|{{SUBFOLDER}}|$SUBFOLDER|g" \
  "$SCRIPT_DIR/agents/main.md" > "$AGENT_FILE"

info "Agent file: $AGENT_FILE"

# ── Summary ───────────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════════════════"
printf "${GREEN}${BOLD}UPDATE COMPLETE${NC}\n"
echo "════════════════════════════════════════════════════"
echo ""
echo "  Agent file:  $AGENT_FILE"
echo "  Skills:      $SKILLS_DEST/myna-*/ ($feature_count feature + $steering_count steering)"
echo ""
printf "  Your vault at ${BOLD}$VAULT_PATH/$SUBFOLDER/${NC} was not touched.\n"
echo ""
