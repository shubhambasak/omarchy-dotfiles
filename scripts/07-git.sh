#!/bin/bash
# Apply git config — identity and personal preferences.
# Copies the full curated git config from the repo.
# Skips if user.name is already set to avoid overwriting a different identity.
set -euo pipefail
REPO_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
skip() { echo -e "  ${YELLOW}→${NC} $1 (skipped)"; }

GIT_CONFIG="$HOME/.config/git/config"
SRC="$REPO_DIR/.config/git/config"

# If user.name is already set to something else, don't overwrite their identity
EXISTING_NAME="$(git config --file "$GIT_CONFIG" user.name 2>/dev/null || true)"

if [[ -n "$EXISTING_NAME" && "$EXISTING_NAME" != "Shubham Basak" ]]; then
  skip "git user.name already set to '$EXISTING_NAME' — keeping existing identity"
  # Still copy everything except the [user] block by using git config commands
  # for the non-identity settings that may be missing
  git config --file "$GIT_CONFIG" alias.co checkout 2>/dev/null || true
  git config --file "$GIT_CONFIG" alias.br branch   2>/dev/null || true
  git config --file "$GIT_CONFIG" alias.ci commit   2>/dev/null || true
  git config --file "$GIT_CONFIG" alias.st status   2>/dev/null || true
  git config --file "$GIT_CONFIG" init.defaultBranch master      2>/dev/null || true
  git config --file "$GIT_CONFIG" pull.rebase true               2>/dev/null || true
  git config --file "$GIT_CONFIG" push.autoSetupRemote true      2>/dev/null || true
  git config --file "$GIT_CONFIG" diff.algorithm histogram       2>/dev/null || true
  git config --file "$GIT_CONFIG" diff.colorMoved plain          2>/dev/null || true
  git config --file "$GIT_CONFIG" diff.mnemonicPrefix true       2>/dev/null || true
  git config --file "$GIT_CONFIG" commit.verbose true            2>/dev/null || true
  git config --file "$GIT_CONFIG" column.ui auto                 2>/dev/null || true
  git config --file "$GIT_CONFIG" branch.sort -committerdate     2>/dev/null || true
  git config --file "$GIT_CONFIG" tag.sort -version:refname      2>/dev/null || true
  git config --file "$GIT_CONFIG" rerere.enabled true            2>/dev/null || true
  git config --file "$GIT_CONFIG" rerere.autoupdate true         2>/dev/null || true
  ok "git aliases and preferences applied (identity kept as-is)"
else
  # No existing identity or it's already ours — copy the full curated config
  mkdir -p "$(dirname "$GIT_CONFIG")"
  cp "$SRC" "$GIT_CONFIG"
  ok "git config applied (identity: Shubham Basak <bloggershubham7011@gmail.com>)"
fi
