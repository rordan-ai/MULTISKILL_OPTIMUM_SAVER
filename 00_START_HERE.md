# Start Here — MOS

Welcome! This is the entry point for everything you need.

---

## What is MOS?

**MOS (Multiskill Optimum Saver)** is a Claude Code skill that automatically evaluates your session complexity at startup and recommends the optimal configuration — model, thinking level, subagents, and compression — so you're never over-spending tokens on simple tasks or under-powered on complex ones.

---

## 3-Minute Setup

### Option A — npm (recommended)

```bash
npx mos-claude
```

### Option B — Clone & run

```bash
git clone https://github.com/Yula-Digital/MOS.git
cd MULTISKILL_OPTIMUM_SAVER
bash install.sh           # English
bash install.sh --hebrew  # Hebrew
```

**Windows:** Right-click `Install-MOS.ps1` → *Run with PowerShell*

### Then — Restart Claude

Restart Claude Code or Claude Desktop. That's it.

---

## What happens next?

At the start of every Claude session, you'll see:

```
╔═ MOS ═════════════════════════════════════════╗
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
| `/mos` | Show current config + score |
| `/mos [1-5]` | Apply preset immediately |
| `/mos reset` | Restore defaults |
| `/mos save` | Save current as default |

---

## Questions?

Open an [issue](https://github.com/Yula-Digital/MOS/issues) or start a [discussion](https://github.com/Yula-Digital/MOS/discussions).
