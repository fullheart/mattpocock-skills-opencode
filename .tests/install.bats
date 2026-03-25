#!/usr/bin/env bats

setup() {
  # Create a temporary HOME directory for testing
  export TEST_HOME=$(mktemp -d)
  export HOME="$TEST_HOME"
  export REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  cd "$REPO_ROOT"
}

teardown() {
  # Clean up temporary HOME
  rm -rf "$TEST_HOME"
}

@test "install.sh creates global skills directory and symlinks" {
  # Ensure opencode config directory exists
  mkdir -p "$HOME/.config/opencode/"

  # Execute install script
  run ./install.sh

  # Assert: Script succeeds
  [ "$status" -eq 0 ]

  # Assert: Skills directory created
  [ -d "$HOME/.config/opencode/skills/" ]

  # Assert: At least one skill symlinked (tdd is one we know exists)
  [ -L "$HOME/.config/opencode/skills/tdd" ]

  # Assert: Symlink points to actual directory
  [ -d "$HOME/.config/opencode/skills/tdd" ]
}

@test "install.sh --local creates symlinks in .opencode/skills/" {
  # Create a temporary directory to simulate project root
  export PROJECT_DIR=$(mktemp -d)
  cd "$PROJECT_DIR"

  # Execute install script with --local flag
  run "$REPO_ROOT/install.sh" --local

  # Assert: Script succeeds
  [ "$status" -eq 0 ]

  # Assert: Local skills directory created
  [ -d "$PROJECT_DIR/.opencode/skills/" ]

  # Assert: At least one skill symlinked locally
  [ -L "$PROJECT_DIR/.opencode/skills/tdd" ]

  # Assert: Symlink points to actual directory
  [ -d "$PROJECT_DIR/.opencode/skills/tdd" ]

  # Cleanup
  rm -rf "$PROJECT_DIR"
}

@test "install.sh is idempotent (running twice doesn't fail)" {
  # Ensure opencode config directory exists
  mkdir -p "$HOME/.config/opencode/"

  # First run
  run ./install.sh
  [ "$status" -eq 0 ]

  # Count symlinks after first run
  local first_count
  first_count=$(find "$HOME/.config/opencode/skills" -maxdepth 1 -type l | wc -l)

  # Second run (should not fail)
  run ./install.sh
  [ "$status" -eq 0 ]

  # Count symlinks after second run - should be the same
  local second_count
  second_count=$(find "$HOME/.config/opencode/skills" -maxdepth 1 -type l | wc -l)

  [ "$first_count" -eq "$second_count" ]

  # Assert: No nested symlinks created
  [ ! -L "$HOME/.config/opencode/skills/tdd/tdd" ]

  # Assert: Skills still work
  [ -d "$HOME/.config/opencode/skills/" ]
  [ -L "$HOME/.config/opencode/skills/tdd" ]
  [ -d "$HOME/.config/opencode/skills/tdd" ]
}

@test "install.sh validates SKILL.md exists in skill directories" {
  # Create a temporary repo with mixed content
  export TEMP_REPO=$(mktemp -d)
  cd "$TEMP_REPO"

  # Initialize as git repo with correct remote
  git init
  git remote add origin https://github.com/fullheart/mattpocock-skills-opencode.git

  # Create a valid skill directory with SKILL.md
  mkdir -p "$TEMP_REPO/valid-skill"
  touch "$TEMP_REPO/valid-skill/SKILL.md"

  # Create an invalid directory without SKILL.md
  mkdir -p "$TEMP_REPO/not-a-skill"
  touch "$TEMP_REPO/not-a-skill/README.md"

  # Run install script with local mode, pointing to temp repo
  export SKILLS_REPO_DIR="$TEMP_REPO"
  run "$REPO_ROOT/install.sh" --local

  # Assert: Script succeeds
  [ "$status" -eq 0 ]

  # Assert: Valid skill is linked
  [ -L "$TEMP_REPO/.opencode/skills/valid-skill" ]

  # Assert: Invalid directory is NOT linked
  [ ! -L "$TEMP_REPO/.opencode/skills/not-a-skill" ]

  # Cleanup
  unset SKILLS_REPO_DIR
  rm -rf "$TEMP_REPO"
}

@test "install.sh links all skills from the repository" {
  # Ensure opencode config directory exists
  mkdir -p "$HOME/.config/opencode/"

  # Execute install script
  run ./install.sh

  # Assert: Script succeeds
  [ "$status" -eq 0 ]

  # Count actual skill directories in repo (those with SKILL.md)
  local skill_count
  skill_count=$(find "$REPO_ROOT" -maxdepth 2 -name "SKILL.md" -type f | wc -l)

  # Assert: All skills are linked
  local linked_count
  linked_count=$(find "$HOME/.config/opencode/skills" -maxdepth 1 -type l | wc -l)

  [ "$linked_count" -eq "$skill_count" ]
}

@test "install.sh provides clear output about what it's doing" {
  # Ensure opencode config directory exists
  mkdir -p "$HOME/.config/opencode/"

  # Execute install script
  run ./install.sh

  # Assert: Script outputs installation message
  [[ "$output" == *"Skills installed to"* ]]
}

@test "install.sh --local provides clear output about local installation" {
  # Create a temporary directory
  export PROJECT_DIR=$(mktemp -d)
  cd "$PROJECT_DIR"

  # Execute install script with --local flag
  run "$REPO_ROOT/install.sh" --local

  # Assert: Script outputs local installation message
  [[ "$output" == *".opencode/skills"* ]]

  # Cleanup
  rm -rf "$PROJECT_DIR"
}

@test "install.sh rejects unknown arguments with usage message" {
  # Execute install script with an invalid flag
  run ./install.sh --unknown-flag

  # Assert: Script fails with non-zero exit code
  [ "$status" -ne 0 ]

  # Assert: Usage message is printed to stderr
  [[ "$output" == *"Usage:"* ]]
}

@test "install.sh clones repository when run standalone (not in skills repo)" {
  # Create a temporary directory outside the repo (no git repo)
  export TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"

  # Run install script from outside the repo
  run "$REPO_ROOT/install.sh"

  # Assert: Script succeeds
  [ "$status" -eq 0 ]

  # Assert: Skills directory created
  [ -d "$HOME/.config/opencode/skills/" ]

  # Assert: At least one skill symlinked (tdd should exist)
  [ -L "$HOME/.config/opencode/skills/tdd" ]

  # Assert: Symlink points to actual directory (cloned)
  [ -d "$HOME/.config/opencode/skills/tdd" ]

  # Cleanup
  rm -rf "$TEMP_DIR"
}

@test "install.sh clones repository when run standalone with --local flag" {
  # Create a temporary directory outside the repo (no git repo)
  export TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"

  # Run install script with --local flag from outside the repo
  run "$REPO_ROOT/install.sh" --local

  # Assert: Script succeeds
  [ "$status" -eq 0 ]

  # Assert: Local skills directory created
  [ -d "$TEMP_DIR/.opencode/skills/" ]

  # Assert: At least one skill symlinked locally
  [ -L "$TEMP_DIR/.opencode/skills/tdd" ]

  # Assert: Symlink points to actual directory
  [ -d "$TEMP_DIR/.opencode/skills/tdd" ]

  # Cleanup
  rm -rf "$TEMP_DIR"
}

@test "install.sh does not clone when in correct repository" {
  # Ensure opencode config directory exists
  mkdir -p "$HOME/.config/opencode/"

  # Run install script from within the actual repo (REPO_ROOT)
  cd "$REPO_ROOT"
  run ./install.sh

  # Assert: Script succeeds
  [ "$status" -eq 0 ]

  # Assert: Skills directory created
  [ -d "$HOME/.config/opencode/skills/" ]

  # Assert: At least one skill symlinked
  [ -L "$HOME/.config/opencode/skills/tdd" ]

  # Assert: "Cloning repository" message should NOT appear
  [[ "$output" != *"Cloning repository"* ]]
}

@test "install.sh clones when in different git repository" {
  # Create a temporary directory with a git repo that has a different remote
  export TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"
  git init
  git remote add origin https://github.com/someone/another-repo.git

  # Run install script - should clone because remote doesn't match
  run "$REPO_ROOT/install.sh"

  # Assert: Script succeeds
  [ "$status" -eq 0 ]

  # Assert: Skills directory created
  [ -d "$HOME/.config/opencode/skills/" ]

  # Assert: At least one skill symlinked (tdd should exist)
  [ -L "$HOME/.config/opencode/skills/tdd" ]

  # Assert: Symlink points to actual directory (cloned)
  [ -d "$HOME/.config/opencode/skills/tdd" ]

  # Cleanup
  rm -rf "$TEMP_DIR"
}
