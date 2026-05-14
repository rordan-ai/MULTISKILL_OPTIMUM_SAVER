#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const os = require("os");

const args = process.argv.slice(2);
const lang = args.includes("--hebrew") ? "hebrew" : "english";
const homeDir = os.homedir();
const claudeDir = path.join(homeDir, ".claude");
const skillDir = path.join(claudeDir, "skills", "multiskill-optimum-saver");
const pkgDir = path.resolve(__dirname, "..");

console.log("══════════════════════════════════════════");
console.log("  MULTISKILL OPTIMUM SAVER — Installer");
console.log("══════════════════════════════════════════");
console.log();

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

// Install Caveman skill (required dependency)
const cavemanDir = path.join(claudeDir, "skills", "caveman");
ensureDir(cavemanDir);
const cavemanSkill = path.join(cavemanDir, "SKILL.md");
if (!fs.existsSync(cavemanSkill)) {
  console.log("    Installing Caveman skill (required)...");
  try {
    const { execSync } = require("child_process");
    const cavemanUrl =
      "https://raw.githubusercontent.com/JuliusBrussee/caveman/main/SKILL.md";
    execSync(`curl -sL "${cavemanUrl}" -o "${cavemanSkill}"`, {
      stdio: "pipe",
    });
    console.log("OK  Caveman skill installed");
  } catch {
    console.log(
      "!!  Could not download Caveman. Install manually: https://github.com/JuliusBrussee/caveman"
    );
  }
} else {
  console.log("--  Caveman skill already installed — skipped");
}

// Create directories
ensureDir(skillDir);
ensureDir(path.join(claudeDir, "hooks"));

// Copy skill file
const skillFile = lang === "hebrew" ? "SKILL_HE.md" : "SKILL_EN.md";
const src = path.join(pkgDir, skillFile);

if (!fs.existsSync(src)) {
  console.error(`ERROR: ${skillFile} not found in package. Reinstall.`);
  process.exit(1);
}

fs.copyFileSync(src, path.join(skillDir, "SKILL.md"));
console.log(`OK  SKILL.md (${lang}) installed`);

// session-config.json
const configPath = path.join(claudeDir, "session-config.json");
if (!fs.existsSync(configPath)) {
  const config = {
    model_default: "sonnet",
    subagent: { model: "haiku", max: 3, parallel: true },
    caveman: { enabled: true, level: "lite", compress_claude_md: true },
    compact_threshold: 60,
    extended_thinking: "low",
    max_thinking_tokens: 10000,
    memory: { decisions_file: true, claude_mem: false },
    codebase_index: false,
    claudeignore: true,
    active_skills: [
      "multiskill-optimum-saver",
      "caveman",
      "strategic-compact",
    ],
  };
  fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
  console.log("OK  session-config.json created");
} else {
  console.log("--  session-config.json exists — skipped");
}

// .claudeignore
const ignorePath = path.join(claudeDir, ".claudeignore");
if (!fs.existsSync(ignorePath)) {
  const ignore = [
    "node_modules/",
    ".next/",
    "dist/",
    "build/",
    "*.lock",
    "*.log",
    "coverage/",
    ".git/",
    "*.min.js",
    "*.min.css",
  ].join("\n");
  fs.writeFileSync(ignorePath, ignore);
  console.log("OK  .claudeignore created");
}

// settings.json — SessionStart hook
const settingsPath = path.join(claudeDir, "settings.json");
if (!fs.existsSync(settingsPath)) {
  const settings = {
    hooks: {
      SessionStart: [{ type: "command", command: 'echo "MOS active"' }],
    },
  };
  fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2));
  console.log("OK  settings.json created with SessionStart hook");
} else {
  console.log("!!  settings.json exists — add SessionStart hook manually if needed");
}

console.log();
console.log("══════════════════════════════════════════");
console.log("OK  MULTISKILL OPTIMUM SAVER installed!");
console.log();
console.log("Next: restart Claude Code or Desktop");
console.log("══════════════════════════════════════════");
