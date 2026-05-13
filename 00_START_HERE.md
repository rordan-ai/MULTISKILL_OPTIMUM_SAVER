# Start Here — MULTISKILL OPTIMUM SAVER

Welcome! This is the entry point for everything you need.

---

## What is this?

**MULTISKILL OPTIMUM SAVER (MOS)** is a Claude Code skill that automatically evaluates your session complexity at startup and recommends the optimal configuration — model, thinking level, subagents, and compression — so you're never over-spending tokens on simple tasks or under-powered on complex ones.

---

## 3-Minute Setup

### Step 1 — Clone

```bash
git clone https://github.com/rordan-ai/MULTISKILL_OPTIMUM_SAVER.git
cd MULTISKILL_OPTIMUM_SAVER
```

### Step 2 — Install

**Linux / Mac:**
```bash
bash install.sh           # English
bash install.sh --hebrew  # Hebrew
```

**Windows:** Right-click `Install-MOS.ps1` → *Run with PowerShell*

### Step 3 — Restart Claude

Restart Claude Code or Claude Desktop. That's it.

---

## What happens next?

At the start of every Claude session, you'll see:

```
╔═ MOS — MULTISKILL OPTIMUM SAVER ══════════════╗
║  Model: sonnet        Sub: haiku×3            ║
║  Caveman: lite        Thinking: low           ║
║  Compact@: 60%        Score: 64/140           ║
╠═══════════════════════════════════════════════╣
║  Session: MEDIUM      Reason: feature impl.   ║
║  Status:  ✓ Config matches session needs      ║
╚═══════════════════════════════════════════════╝
```

If there's a mismatch, MOS will recommend specific changes and wait for `yes` or `no`.

---

## Files in this repo

| File | Read this when... |
|------|------------------|
| `README.md` | You want the full overview |
| `SKILL_EN.md` | You want to see exactly what MOS does |
| `SKILL_HE.md` | גרסה עברית מלאה |
| `session-config.json` | You want to customize your defaults |
| `DESCRIPTION.md` | You want deep technical documentation |
| `install.sh` | You're on Linux/Mac |

---

## Useful commands once installed

| Command | What it does |
|---------|-------------|
| `/governor` | Show current config + score |
| `/mos-preset HARD` | Apply HARD complexity preset immediately |
| `/mos-reset` | Restore defaults |

---

## Questions?

Open an [issue](https://github.com/rordan-ai/MULTISKILL_OPTIMUM_SAVER/issues) or start a [discussion](https://github.com/rordan-ai/MULTISKILL_OPTIMUM_SAVER/discussions).
