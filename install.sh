#!/bin/bash
# MULTISKILL_OPTIMUM_SAVER — Auto-Installer
# Usage: bash install.sh [--hebrew | --english (default)]

set -e
LANG_FLAG="${1:---english}"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "══════════════════════════════════════════"
echo "  MULTISKILL OPTIMUM SAVER — Installer"
echo "══════════════════════════════════════════"

# Install Caveman skill (required dependency)
CAVEMAN_DIR=~/.claude/skills/caveman
if [ ! -f "$CAVEMAN_DIR/SKILL.md" ]; then
  echo "Installing Caveman skill (required)..."
  mkdir -p "$CAVEMAN_DIR"
  CAVEMAN_URL="https://raw.githubusercontent.com/JuliusBrussee/caveman/main/SKILL.md"
  if command -v curl &>/dev/null; then
    curl -sL "$CAVEMAN_URL" -o "$CAVEMAN_DIR/SKILL.md"
  elif command -v wget &>/dev/null; then
    wget -qO "$CAVEMAN_DIR/SKILL.md" "$CAVEMAN_URL"
  else
    echo "WARNING: curl/wget not found. Install Caveman manually: https://github.com/JuliusBrussee/caveman"
  fi
  echo "✓ Caveman skill installed"
else
  echo "  Caveman skill already installed — skipped"
fi

# Create directories
mkdir -p ~/.claude/skills/multiskill-optimum-saver
mkdir -p ~/.claude/hooks

# Copy skill file
if [ "$LANG_FLAG" = "--hebrew" ]; then
  cp "$REPO_DIR/SKILL_HE.md" ~/.claude/skills/multiskill-optimum-saver/SKILL.md
  echo "✓ SKILL.md (Hebrew) installed"
else
  cp "$REPO_DIR/SKILL_EN.md" ~/.claude/skills/multiskill-optimum-saver/SKILL.md
  echo "✓ SKILL.md (English) installed"
fi

# Install default config (only if not exists)
if [ ! -f ~/.claude/session-config.json ]; then
  cat > ~/.claude/session-config.json << 'CFGEOF'
{
  "model_default": "sonnet",
  "subagent": { "model": "haiku", "max": 3, "parallel": true },
  "caveman": { "enabled": true, "level": "lite", "compress_claude_md": true },
  "compact_threshold": 60,
  "extended_thinking": "low",
  "max_thinking_tokens": 10000,
  "memory": { "decisions_file": true, "claude_mem": false },
  "codebase_index": false,
  "claudeignore": true,
  "active_skills": ["multiskill-optimum-saver", "caveman", "strategic-compact"]
}
CFGEOF
  echo "✓ session-config.json created"
else
  echo "  session-config.json already exists — skipped"
fi

# .claudeignore
if [ ! -f ~/.claude/.claudeignore ]; then
  cat > ~/.claude/.claudeignore << 'IGEOF'
node_modules/
.next/
dist/
build/
*.lock
*.log
coverage/
.git/
*.min.js
*.min.css
IGEOF
  echo "✓ .claudeignore created"
fi

# Add SessionStart hook to settings.json
SETTINGS=~/.claude/settings.json
if [ ! -f "$SETTINGS" ]; then
  echo '{"hooks":{"SessionStart":[{"type":"command","command":"echo \"✓ MOS active\""}]}}' > "$SETTINGS"
  echo "✓ settings.json created with SessionStart hook"
else
  echo "⚠  settings.json exists — add this manually if not present:"
  echo '  "hooks": {"SessionStart": [{"type":"command","command":"echo \"✓ MOS active\""}]}'
fi

echo ""
echo "══════════════════════════════════════════"
echo "✓ MULTISKILL OPTIMUM SAVER installed!"
echo ""
echo "Next: restart Claude Code or Desktop"
echo "MOS activates automatically on every session"
echo ""
echo "For claude.ai: paste SKILL_EN.md content"
echo "into your Project instructions"
echo "══════════════════════════════════════════"
