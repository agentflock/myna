#!/usr/bin/env bash
# update.sh — Myna update entry point
#
# Updates script-installed Myna runtimes to the latest version.
# Detects which runtimes were installed by Myna's own scripts and re-runs
# their idempotent install scripts to overwrite Myna-owned files while
# preserving user config.
#
# Claude users: update via `/plugin update myna` inside Claude Code.
#
# Usage: ./update.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# shellcheck source=install/lib.sh
source "$SCRIPT_DIR/install/lib.sh"

# ---------------------------------------------------------------------------
# Update a single script-installed runtime.
# ---------------------------------------------------------------------------

update_runtime() {
  local runtime="$1"

  case "$runtime" in
    kiro)
      echo ""
      echo "── Updating Kiro ──"
      resolve_vault_path
      echo ""
      bash "$SCRIPT_DIR/install/kiro.sh" "$VAULT_PATH"
      ;;
    codex)
      echo ""
      echo "── Codex ──"
      echo "Codex update not yet supported."
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

_INSTALLED_STR=""
detect_script_installs _INSTALLED_STR

installed=()
if [[ -n "$_INSTALLED_STR" ]]; then
  read -ra installed <<< "$_INSTALLED_STR"
fi

num_installed="${#installed[@]}"

# No script installs detected.
if [[ "$num_installed" -eq 0 ]]; then
  echo ""
  echo "No script-installed Myna runtimes detected."
  echo "Claude users update via \`/plugin update myna\` inside Claude Code."
  echo ""
  exit 0
fi

# One or more script installs — update each in sequence.
echo ""
echo "Script-installed runtimes detected: ${installed[*]}"

statuses=()

for runtime in "${installed[@]}"; do
  if update_runtime "$runtime"; then
    statuses+=("  $runtime  OK")
  else
    statuses+=("  $runtime  FAILED")
  fi
done

# Per-runtime summary (only shown when more than one runtime was updated).
if [[ "$num_installed" -gt 1 ]]; then
  echo ""
  echo "Update summary:"
  for status in "${statuses[@]}"; do
    echo "$status"
  done
  echo ""
fi
