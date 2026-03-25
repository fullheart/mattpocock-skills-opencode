#!/bin/bash

# Install script for OpenCode skills
# Creates symlinks from repository skills to OpenCode skills directory

set -e

# Parse arguments
LOCAL_MODE=false

if [[ "$1" == "--local" ]]; then
  LOCAL_MODE=true
fi

# Determine target directory
if [[ "$LOCAL_MODE" == true ]]; then
  TARGET_DIR=".opencode/skills"
else
  TARGET_DIR="$HOME/.config/opencode/skills"
fi

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Get script directory (repository root)
# Allow override via SKILLS_REPO_DIR for testing
if [[ -n "$SKILLS_REPO_DIR" ]]; then
  REPO_DIR="$SKILLS_REPO_DIR"
else
  REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# Find all skill directories and create symlinks
for skill_dir in "$REPO_DIR"/*/; do
  # Remove trailing slash
  skill_dir="${skill_dir%/}"

  # Get skill name from directory name
  skill_name=$(basename "$skill_dir")

  # Skip tests directory
  if [[ "$skill_name" == "tests" ]]; then
    continue
  fi

  # Skip hidden directories
  if [[ "$skill_name" == .* ]]; then
    continue
  fi

  # Validate that SKILL.md exists
  if [[ ! -f "$skill_dir/SKILL.md" ]]; then
    echo "Warning: Skipping '$skill_name' - no SKILL.md found" >&2
    continue
  fi

  # Create symlink
  ln -sf "$skill_dir" "$TARGET_DIR/$skill_name"
done

echo "Skills installed to $TARGET_DIR"
