# 🧠 MULTISKILL OPTIMUM SAVER (MOS)

**AI optimization layer for Claude Code — match processing power to task complexity, automatically.**

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.0.0-orange)](SKILL_EN.md)
[![Bilingual](https://img.shields.io/badge/lang-EN%20%7C%20HE-purple)](SKILL_HE.md)

---

MOS is an AI optimization layer designed to streamline work with Claude-based development tools through intelligent resource management. It solves the problem of token waste and unnecessary costs that occur when overpowered models are used for simple tasks — or conversely, when insufficient power degrades output quality on complex ones.

Using a scoring algorithm (0–140), the system weighs parameters such as model type, thinking depth, text compression, and sub-agent count. Users can choose from five predefined levels — from an economical **Trivial** tier to a powerful **Expert** tier — or make manual adjustments. Throughout the session, MOS monitors incoming requests and suggests real-time configuration updates to ensure optimal alignment between task complexity and allocated processing power.

**The goal: maximize productivity and cut operational costs by 30–75% — without compromising output quality.**

---

## What It Does

At the start of every Claude session, MOS:

1. **Reads** your current `session-config.json`
2. **Scans** project context (file count, git history, CLAUDE.md)
3. **Classifies** complexity: `TRIVIAL → SIMPLE → MEDIUM → HARD → EXPERT`
4. **Scores** your config (0-140) against complexity requirements
5. **Displays** a status block — match, borderline, or mismatch
6. **Recommends** specific changes only when needed
7. **Applies** changes on your approval (`yes` / `no`)

---

## Status Block (every session)

```
╔═ MOS — MULTISKILL OPTIMUM SAVER ══════════════╗
║  Model: sonnet        Sub: haiku×3            ║
║  Caveman: lite        Thinking: low           ║
║  Compact@: 60%        Score: 64/140           ║
╠═══════════════════════════════════════════════╣
║  Session: MEDIUM      Reason: refactor task   ║
║  Status:  ✓ Config matches session needs      ║
╚═══════════════════════════════════════════════╝
```

---

## Presets by Complexity

| Complexity | Model  | Caveman | Thinking | Subagents |
|------------|--------|---------|----------|-----------|
| TRIVIAL    | haiku  | ultra   | off      | 0         |
| SIMPLE     | sonnet | full    | off      | 1×haiku   |
| MEDIUM     | sonnet | lite    | low      | 3×haiku   |
| HARD       | sonnet | lite    | high     | 4×sonnet  |
| EXPERT     | opus   | off     | high     | 5×sonnet  |

---

## Scoring (0-140)

| Parameter | Points |
|-----------|--------|
| haiku | +18 |
| sonnet | +58 |
| opus | +100 |
| thinking low/high/max | +8/+22/+38 |
| caveman lite/full/ultra | -2/-8/-16 |
| each haiku subagent | +4 (max 28) |
| each sonnet subagent | +7 (max 28) |

---

## Multi-Skill Routing (automatic)

| Trigger | Skill |
|---------|-------|
| z-index, CSS stuck, RTL, PNG | css-expert |
| ad creative, image prompt, copy | ad-creative |
| mobile, iOS, Android, responsive | mobile-inspector |
| Word, DOCX, PDF | docx |
| context > 60% | strategic-compact |

---

## Installation

### Easy install (recommended)

```bash
npx multiskill-optimum-saver
```

Hebrew version:
```bash
npx multiskill-optimum-saver --hebrew
```

That's it. One command — MOS is ready. **Caveman skill is installed automatically** as a required dependency.

### Alternative: global install

```bash
npm i -g multiskill-optimum-saver
mos-install            # English
mos-install --hebrew   # Hebrew
```

### Alternative: clone & run

```bash
git clone https://github.com/rordan-ai/MULTISKILL_OPTIMUM_SAVER.git
cd MULTISKILL_OPTIMUM_SAVER
bash install.sh           # English
bash install.sh --hebrew  # Hebrew
```

**Windows:** Right-click `Install-MOS.ps1` → Run with PowerShell

**claude.ai:** Paste `SKILL_EN.md` into Project Instructions.

Restart Claude Code / Claude Desktop. Done.

---

## Commands

| Command | Action |
|---------|--------|
| `/governor` | Show config status |
| `/mos-preset [level]` | Apply preset |
| `/mos-reset` | Restore defaults |

---

## Companion Tools

- [Caveman](https://github.com/JuliusBrussee/caveman) — 50-75% token reduction
- [Codebase Memory MCP](https://github.com/DeusData/codebase-memory-mcp) — 99% reduction
- [Claude-Mem](https://github.com/thedotmack/claude-mem) — cross-session memory
- [Token Savior](https://github.com/Mibayy/token-savior) — -77% tokens

---

## License

MIT — free to use, modify, and distribute.

---

⭐ Star if useful | 🐛 [Issues](https://github.com/rordan-ai/MULTISKILL_OPTIMUM_SAVER/issues) | 💬 [Discuss](https://github.com/rordan-ai/MULTISKILL_OPTIMUM_SAVER/discussions)
