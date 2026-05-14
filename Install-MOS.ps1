# MULTISKILL OPTIMUM SAVER — Windows Installer
# Usage: Right-click → Run with PowerShell
#   -Lang hebrew  (default: english)

param(
    [ValidateSet("english", "hebrew")]
    [string]$Lang = "english"
)

$ErrorActionPreference = "Stop"
$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"

Write-Host "══════════════════════════════════════════"
Write-Host "  MULTISKILL OPTIMUM SAVER — Installer"
Write-Host "══════════════════════════════════════════"

# Install Caveman skill (required dependency)
$cavemanDir = Join-Path $ClaudeDir "skills\caveman"
$cavemanSkill = Join-Path $cavemanDir "SKILL.md"
New-Item -ItemType Directory -Force -Path $cavemanDir | Out-Null
if (-not (Test-Path $cavemanSkill)) {
    Write-Host "  Installing Caveman skill (required)..."
    try {
        $cavemanUrl = "https://raw.githubusercontent.com/JuliusBrussee/caveman/main/SKILL.md"
        Invoke-WebRequest -Uri $cavemanUrl -OutFile $cavemanSkill -UseBasicParsing
        Write-Host "[OK] Caveman skill installed"
    } catch {
        Write-Host "[!] Could not download Caveman. Install manually: https://github.com/JuliusBrussee/caveman"
    }
} else {
    Write-Host "  Caveman skill already installed - skipped"
}

# Create directories
$skillDir = Join-Path $ClaudeDir "skills\multiskill-optimum-saver"
New-Item -ItemType Directory -Force -Path $skillDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir "hooks") | Out-Null

# Copy skill file
if ($Lang -eq "hebrew") {
    Copy-Item "$RepoDir\SKILL_HE.md" "$skillDir\SKILL.md" -Force
    Write-Host "[OK] SKILL.md (Hebrew) installed"
} else {
    Copy-Item "$RepoDir\SKILL_EN.md" "$skillDir\SKILL.md" -Force
    Write-Host "[OK] SKILL.md (English) installed"
}

# Install default config (only if not exists)
$configPath = Join-Path $ClaudeDir "session-config.json"
if (-not (Test-Path $configPath)) {
    @'
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
'@ | Set-Content $configPath -Encoding UTF8
    Write-Host "[OK] session-config.json created"
} else {
    Write-Host "  session-config.json already exists - skipped"
}

# .claudeignore
$ignorePath = Join-Path $ClaudeDir ".claudeignore"
if (-not (Test-Path $ignorePath)) {
    @'
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
'@ | Set-Content $ignorePath -Encoding UTF8
    Write-Host "[OK] .claudeignore created"
}

# Settings hook
$settingsPath = Join-Path $ClaudeDir "settings.json"
if (-not (Test-Path $settingsPath)) {
    '{"hooks":{"SessionStart":[{"type":"command","command":"echo MOS active"}]}}' | Set-Content $settingsPath -Encoding UTF8
    Write-Host "[OK] settings.json created with SessionStart hook"
} else {
    Write-Host "[!] settings.json exists - add SessionStart hook manually if needed"
}

Write-Host ""
Write-Host "══════════════════════════════════════════"
Write-Host "[OK] MULTISKILL OPTIMUM SAVER installed!"
Write-Host ""
Write-Host "Next: restart Claude Code or Desktop"
Write-Host "══════════════════════════════════════════"
