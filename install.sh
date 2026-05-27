#!/usr/bin/env bash
# install.sh — Myna install entry point
#
# Detects available AI runtimes (claude, kiro, codex) and dispatches to the
# appropriate per-runtime installer.  Idempotent: safe to re-run.
#
# Usage: ./install.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# shellcheck source=install/lib.sh
source "$SCRIPT_DIR/install/lib.sh"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Print usage instructions for installing each AI runtime.
print_no_runtime_help() {
  cat <<'EOF'

No supported AI runtime found on PATH (claude, kiro, codex).

Install one of the following, then re-run ./install.sh:

  Claude Code   https://claude.ai/code
                macOS: brew install --cask claude   (or download from the link above)

  Kiro          https://kiro.dev
                macOS: brew install --cask kiro     (or download from the link above)

  Codex         https://github.com/openai/codex
                npm install -g @openai/codex

EOF
}

# Resolve the vault path: read from ~/.myna/config.yaml if present,
# otherwise prompt the user and validate the directory exists.
# Sets VAULT_PATH in the caller's scope.
resolve_vault_path() {
  local config="$HOME/.myna/config.yaml"

  if [[ -f "$config" ]]; then
    # Parse the vault_path: line (strip quotes if present)
    local raw
    raw=$(grep '^vault_path:' "$config" 2>/dev/null | sed 's/vault_path: *"*//;s/"*$//' || true)
    if [[ -n "$raw" ]]; then
      VAULT_PATH="$raw"
      return 0
    fi
  fi

  # No config — prompt until the user supplies a valid directory.
  while true; do
    printf 'Enter the absolute path to your Obsidian vault: '
    read -r VAULT_PATH
    if [[ -d "$VAULT_PATH" ]]; then
      break
    else
      echo "  Error: directory does not exist: $VAULT_PATH" >&2
      echo "  Please enter a valid absolute path." >&2
    fi
  done
}

# Install for a single runtime.
install_runtime() {
  local runtime="$1"

  case "$runtime" in
    claude)
      echo ""
      echo "Myna for Claude Code"
      echo ""
      echo "Run these commands inside Claude Code:"
      echo ""
      echo "  /plugin marketplace add agentflock/plugins"
      echo "  /plugin install myna@agentflock"
      echo ""
      echo "Then run /myna:setup to configure your vault, identity, and integrations."
      echo ""
      ;;
    kiro)
      resolve_vault_path
      echo ""
      bash "$SCRIPT_DIR/install/kiro.sh" "$VAULT_PATH"
      ;;
    codex)
      echo ""
      echo "Codex support is on the way — landing June 5, 2026. Stay tuned."
      echo ""
      ;;
    *)
      echo "Unknown runtime: $runtime" >&2
      return 1
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

# Detect runtimes into a space-separated string, then split into an array.
_DETECTED_STR=""
detect_runtimes _DETECTED_STR

detected=()
if [[ -n "$_DETECTED_STR" ]]; then
  read -ra detected <<< "$_DETECTED_STR"
fi

num_detected="${#detected[@]}"

# No runtimes found — print install help and exit.
if [[ "$num_detected" -eq 0 ]]; then
  print_no_runtime_help
  exit 0
fi

# One runtime found — install without prompting.
if [[ "$num_detected" -eq 1 ]]; then
  install_runtime "${detected[0]}"
  exit 0
fi

# Multiple runtimes found — prompt for pick, then offer remaining.
echo ""
echo "Multiple AI runtimes detected: ${detected[*]}"
echo ""

remaining=("${detected[@]}")

while [[ "${#remaining[@]}" -gt 0 ]]; do
  # Offer a numbered pick menu.
  _CHOSEN=""
  pick_runtime _CHOSEN "${remaining[@]}"
  chosen="$_CHOSEN"

  install_runtime "$chosen"

  # Remove the chosen runtime from remaining.
  new_remaining=()
  for r in "${remaining[@]}"; do
    [[ "$r" != "$chosen" ]] && new_remaining+=("$r")
  done
  remaining=("${new_remaining[@]}")

  # If there are more runtimes, ask whether to install for them.
  if [[ "${#remaining[@]}" -gt 0 ]]; then
    for r in "${remaining[@]}"; do
      printf 'Also install for %s? [y/N] ' "$r"
      read -r answer
      if [[ "$answer" =~ ^[Yy]$ ]]; then
        install_runtime "$r"
      fi
    done
    # All remaining were handled in the loop above — clear the list.
    remaining=()
  fi
done
