#!/usr/bin/env node
// MOS — SessionStart version checker
// Compares installed SKILL.md version against latest on npm.
// Silent if up-to-date. Prints update notice if newer version exists.
// Caches result for 24h to avoid hitting npm on every session.

const fs = require("fs");
const path = require("path");
const os = require("os");
const https = require("https");

const PACKAGE = "mos-claude";
const claudeDir = path.join(os.homedir(), ".claude");
const skillPath = path.join(claudeDir, "skills", "mos", "SKILL.md");
const altSkillPath = path.join(
  claudeDir,
  "skills",
  "multiskill-optimum-saver",
  "SKILL.md"
);
const cachePath = path.join(claudeDir, ".mos-version-cache.json");
const CACHE_TTL = 24 * 60 * 60 * 1000; // 24 hours

function getInstalledVersion() {
  const paths = [skillPath, altSkillPath];
  for (const p of paths) {
    try {
      const content = fs.readFileSync(p, "utf8");
      const match = content.match(/^version:\s*(.+)$/m);
      if (match) return match[1].trim();
    } catch {}
  }
  return null;
}

function readCache() {
  try {
    const data = JSON.parse(fs.readFileSync(cachePath, "utf8"));
    if (Date.now() - data.timestamp < CACHE_TTL) return data;
  } catch {}
  return null;
}

function writeCache(latest) {
  try {
    fs.writeFileSync(
      cachePath,
      JSON.stringify({ latest, timestamp: Date.now() })
    );
  } catch {}
}

function fetchLatestVersion() {
  return new Promise((resolve) => {
    const req = https.get(
      `https://registry.npmjs.org/${PACKAGE}/latest`,
      { timeout: 3000 },
      (res) => {
        let data = "";
        res.on("data", (c) => (data += c));
        res.on("end", () => {
          try {
            resolve(JSON.parse(data).version || null);
          } catch {
            resolve(null);
          }
        });
      }
    );
    req.on("error", () => resolve(null));
    req.on("timeout", () => {
      req.destroy();
      resolve(null);
    });
  });
}

function compareVersions(installed, latest) {
  const a = installed.split(".").map(Number);
  const b = latest.split(".").map(Number);
  for (let i = 0; i < 3; i++) {
    if ((b[i] || 0) > (a[i] || 0)) return true;
    if ((b[i] || 0) < (a[i] || 0)) return false;
  }
  return false;
}

async function main() {
  const installed = getInstalledVersion();
  if (!installed) return;

  let latest;
  const cache = readCache();
  if (cache) {
    latest = cache.latest;
  } else {
    latest = await fetchLatestVersion();
    if (latest) writeCache(latest);
  }

  if (!latest) return;

  if (compareVersions(installed, latest)) {
    process.stdout.write(
      JSON.stringify({
        hookSpecificOutput: {
          hookEventName: "SessionStart",
          additionalContext:
            `MOS UPDATE AVAILABLE: ${installed} → ${latest}. ` +
            `Update with: npx mos-claude (or npm update -g mos-claude). ` +
            `Inform the user about this update at the start of the session.`,
        },
      })
    );
  }
}

main();
