# OpenCode Skills Documentation

This document provides installation and usage instructions for using these skills with [OpenCode](https://opencode.ai).

## What is this Repository?

This is a fork of [mattpocock/skills](https://github.com/mattpocock/skills), adapted specifically for OpenCode. While the original repository is designed for Claude Code, this fork provides the same skills in a format compatible with OpenCode's skill system.

## Prerequisites

- [OpenCode](https://opencode.ai) must be installed on your system
- Git (for cloning and updating)
- Bash shell (for the install script)

## Installation

### Quick Install (Recommended)

Run the following command to clone the repository and install all skills:

```bash
curl -fsSL https://raw.githubusercontent.com/fullheart/mattpocock-skills-opencode/main/install.sh | bash
```

Or clone first and then install:

```bash
git clone https://github.com/fullheart/mattpocock-skills-opencode.git
cd mattpocock-skills-opencode
./install.sh
```

### Manual Installation

If you prefer to install manually:

1. Clone this repository:
   ```bash
   git clone https://github.com/fullheart/mattpocock-skills-opencode.git
   cd mattpocock-skills-opencode
   ```

2. Create the OpenCode skills directory:
   ```bash
   mkdir -p ~/.config/opencode/skills
   ```

3. Create symlinks for each skill:
   ```bash
   for skill_dir in */; do
     skill_name=$(basename "$skill_dir")
     if [ -f "$skill_dir/SKILL.md" ]; then
       ln -sfn "$(pwd)/$skill_name" ~/.config/opencode/skills/"$skill_name"
     fi
   done
   ```

## Usage

### Global Installation

The default installation makes skills available globally for all OpenCode sessions:

```bash
./install.sh
```

Skills will be installed to `~/.config/opencode/skills/`.

### Local Installation (Project-specific)

To install skills only for the current project:

```bash
./install.sh --local
```

This installs skills to `./.opencode/skills/` in your current directory, useful for testing or project-specific skill sets.

### Verifying Installation

After installation, you can verify that OpenCode recognizes the skills by running:

```bash
opencode skills list
```

## Update Workflow

To pull updates from the upstream repository (mattpocock/skills):

1. Add the upstream remote (one-time setup):
   ```bash
   git remote add upstream https://github.com/mattpocock/skills.git
   ```

2. Fetch and merge updates:
   ```bash
   git fetch upstream
   git checkout main
   git merge upstream/main
   ```

3. Re-run the install script to update symlinks:
   ```bash
   ./install.sh
   ```

### Checking for Updates

To see which skills differ from upstream:

```bash
git fetch upstream
git diff upstream/main --name-only
```

## Available Skills

See the [README.md](./README.md) for a complete list of available skills and their descriptions.

## Important Notes

### Renamed Skill: git-guardrails

The skill `git-guardrails-claude-code` has been renamed to `git-guardrails` in this fork to reflect that it works with OpenCode, not just Claude Code. The functionality remains the same.

## Troubleshooting

### OpenCode not found

**Problem**: The install script runs but OpenCode doesn't recognize the skills.

**Solution**: Ensure OpenCode is properly installed and in your PATH:
```bash
which opencode
opencode --version
```

### Permission denied

**Problem**: "Permission denied" when running `install.sh`.

**Solution**: Make the script executable:
```bash
chmod +x install.sh
```

### Skills not appearing

**Problem**: Skills were installed but don't appear in OpenCode.

**Solution**: 
1. Check the installation directory:
   ```bash
   ls -la ~/.config/opencode/skills/
   ```
2. Ensure symlinks are valid (should not be broken links)
3. Restart OpenCode to reload skills

### Symlink issues

**Problem**: "File exists" errors when re-running install.sh.

**Solution**: The script uses `ln -sfn` which should overwrite existing symlinks. If you still have issues, manually remove the old symlinks:
```bash
rm -rf ~/.config/opencode/skills/*
./install.sh
```

### SKILL.md not found

**Problem**: Some directories are skipped with "no SKILL.md found" warning.

**Solution**: This is expected behavior. The script only creates symlinks for directories that contain a `SKILL.md` file, which is the required format for OpenCode skills.

## Contributing

If you'd like to contribute to this fork:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Test the install script: `./install.sh --local`
5. Submit a pull request

Please note that this is a fork - for changes to the actual skill content, consider contributing to the [upstream repository](https://github.com/mattpocock/skills) instead.

## License

Same as the upstream repository. See [LICENSE](./LICENSE) for details.
