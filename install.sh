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

# Install MOS status injector hook
HOOKS_DIR=~/.claude/hooks
mkdir -p "$HOOKS_DIR"
cp "$REPO_DIR/bin/mos-install.js" "$HOOKS_DIR/mos-status-injector.js" 2>/dev/null || true
# Create dedicated injector if not bundled
if [ ! -f "$HOOKS_DIR/mos-status-injector.js" ]; then
  cat > "$HOOKS_DIR/mos-status-injector.js" << 'HOOKEOF'
#!/usr/bin/env node
const fs=require('fs'),path=require('path'),os=require('os');
const configPath=path.join(os.homedir(),'.claude','session-config.json');
const M={haiku:18,sonnet:58,opus:100},T={off:0,low:8,high:22,max:38},C={off:0,lite:-2,full:-8,ultra:-16},S={haiku:4,sonnet:7};
const L=[{n:'TRIVIAL',m:0},{n:'SIMPLE',m:32},{n:'MEDIUM',m:55},{n:'HARD',m:75},{n:'EXPERT',m:90}];
let input='';process.stdin.on('data',c=>{input+=c});
process.stdin.on('end',()=>{try{
if(!fs.existsSync(configPath))return;
const c=JSON.parse(fs.readFileSync(configPath,'utf8'));
const model=(c.model_default||'sonnet').toLowerCase();
const think=(c.extended_thinking||'low').toLowerCase();
const cave=c.caveman?(c.caveman.level||'lite').toLowerCase():'off';
const subM=c.subagent?(c.subagent.model||'haiku').toLowerCase():'haiku';
const subN=c.subagent?(c.subagent.max||0):0;
let score=(M[model]||58)+(T[think]||0)+(C[cave]||0)+Math.min((S[subM]||4)*subN,28);
score=Math.max(score,0);
let level='TRIVIAL';for(const l of L)if(score>=l.m)level=l.n;
let decl='\u{1F9E0} MOS '+level+' · score '+score+'/140';
if(cave!=='off')decl+=' · caveman ('+cave+')';
process.stdout.write(JSON.stringify({hookSpecificOutput:{hookEventName:"UserPromptSubmit",
additionalContext:'MOS ACTIVE: '+level+' · score '+score+'/140. First line of EVERY response MUST be: '+decl+'. Applies to ALL agents and subagents. Never omit.'}}));
}catch(e){}});
HOOKEOF
  echo "✓ MOS status injector hook installed"
fi

# Add hooks to settings.json
SETTINGS=~/.claude/settings.json
if [ ! -f "$SETTINGS" ]; then
  cat > "$SETTINGS" << 'SETEOF'
{
  "hooks": {
    "SessionStart": [{"hooks":[{"type":"command","command":"echo \"MOS active\"","timeout":5}]}],
    "UserPromptSubmit": [{"hooks":[{"type":"command","command":"node ~/.claude/hooks/mos-status-injector.js","timeout":5,"statusMessage":"MOS status check..."}]}]
  }
}
SETEOF
  echo "✓ settings.json created with MOS hooks"
else
  echo "⚠  settings.json exists — add UserPromptSubmit hook manually if not present:"
  echo '  {"type":"command","command":"node ~/.claude/hooks/mos-status-injector.js","timeout":5}'
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
