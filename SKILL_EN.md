---
name: mos
description: >
  MOS (Multiskill Optimum Saver) — AI optimization layer for Claude Code.
  Evaluates session complexity at start, displays a numbered level menu with
  full parameters, and monitors every prompt for complexity drift — offering
  to upgrade or downgrade in real time. Multi-skill bundle: caveman,
  codebase-memory, strategic-compact, css-expert, ad-creative.
  Triggers: session start, every user prompt, /mos.
version: 3.0.0
always: true
requires:
  - JuliusBrussee/caveman
  - affaan-m/everything-claude-code/strategic-compact
---

# MOS — Multiskill Optimum Saver

## PRESET TABLE

| # | Level   | Model  | Caveman | Thinking | Subagents  | Score |
|---|---------|--------|---------|----------|------------|-------|
| 1 | TRIVIAL | haiku  | ultra   | off      | 0          | ~2    |
| 2 | SIMPLE  | sonnet | full    | off      | 1×haiku    | ~48   |
| 3 | MEDIUM  | sonnet | lite    | low      | 3×haiku    | ~64   |
| 4 | HARD    | sonnet | lite    | high     | 4×sonnet   | ~98   |
| 5 | EXPERT  | opus   | off     | high     | 5×sonnet   | ~157  |

---

## STEP 1 — READ CONFIG (silent)

```bash
cat ~/.claude/session-config.json 2>/dev/null || echo "CONFIG_NOT_FOUND"
find . -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" 2>/dev/null | wc -l
git log --oneline -3 2>/dev/null
head -20 CLAUDE.md 2>/dev/null || head -20 .claude/CLAUDE.md 2>/dev/null
```

Defaults: model=sonnet, caveman=lite, thinking=low, subagents=3×haiku, compact=60%

Score: model(haiku=18/sonnet=58/opus=100) + thinking(off=0/low=8/high=22/max=38) + caveman(off=0/lite=-2/full=-8/ultra=-16) + subagents(haiku×4/sonnet×7, max 28)

---

## STEP 2 — CLASSIFY COMPLEXITY

| Level   | Min Score | Signals |
|---------|-----------|---------|
| TRIVIAL | 18        | Q&A, translate, summarize, explain |
| SIMPLE  | 32        | fix, rename, style, single-file edit |
| MEDIUM  | 55        | feature, refactor, debug, component |
| HARD    | 77        | architecture, integration, agent, PRD |
| EXPERT  | 90        | rewrite, cross-cutting, multi-agent |

---

## STEP 3 — SESSION START BLOCK (mandatory, before first response)

Display exactly this and wait for input:

```
╔═ MOS ══════════════════════════════════════════════╗
║  Detected: [LEVEL]                Score: [n]/140   ║
║  Model: [model] · Thinking: [lvl] · Compact: [n]%  ║
║  Caveman: [lvl] · Subagents: [n]×[model]           ║
║  Status: [✓ match | ~ borderline | ⚠ mismatch]     ║
╠════════════════════════════════════════════════════╣
║  Change level? Type number — Enter to continue     ║
║                                                    ║
║  1. TRIVIAL │ haiku  · ultra · off  · 0 subs       ║
║  2. SIMPLE  │ sonnet · full  · off  · 1×haiku      ║
║  3. MEDIUM  │ sonnet · lite  · low  · 3×haiku      ║
║  4. HARD    │ sonnet · lite  · high · 4×sonnet     ║
║  5. EXPERT  │ opus   · off   · high · 5×sonnet     ║
╚════════════════════════════════════════════════════╝
```

→ Mark current/detected level with ✓ at end of its row.
→ User types 1–5: apply preset (Step 5). Confirm: `✓ Switched to [LEVEL].`
→ Enter / anything else: continue silently.

---

## STEP 4 — PROMPT MONITORING (every prompt)

After every prompt, silently check if complexity is 2+ levels from current config.

**Too simple:**
```
💡 Prompt simpler than current config ([LEVEL]). Downgrade?
  [show only levels below current, with full params]
  [Enter = stay at [LEVEL]]
```

**Too complex:**
```
⚠ Prompt more complex than current config ([LEVEL]). Upgrade?
  [show only levels above current, with full params]
  [Enter = stay at [LEVEL]]
```

Throttle: max once/5 prompts · never repeat declined suggestion · min 2-level gap.

**BLOCKING RULE:** When displaying an upgrade/downgrade suggestion, **STOP completely**. Do NOT continue with any other work. Wait for user input before proceeding. This applies regardless of permission settings, bypass mode, or automation level. The suggestion is a blocking prompt — treat it like a confirmation dialog.

---

## STEP 5 — APPLY PRESET

```bash
cat > ~/.claude/session-config.json << 'EOF'
{
  "model_default": "[model]",
  "subagent": { "model": "[sub]", "max": [n], "parallel": true },
  "caveman": { "enabled": true, "level": "[caveman]", "compress_claude_md": true },
  "compact_threshold": [compact],
  "extended_thinking": "[thinking]",
  "max_thinking_tokens": [tokens]
}
EOF
export ANTHROPIC_MODEL="[model]"
export CLAUDE_CODE_SUBAGENT_MODEL="[sub]"
```

| Level   | model  | sub    | n | caveman | thinking | tokens | compact |
|---------|--------|--------|---|---------|----------|--------|---------|
| TRIVIAL | haiku  | haiku  | 0 | ultra   | off      | 0      | 40%     |
| SIMPLE  | sonnet | haiku  | 1 | full    | off      | 0      | 50%     |
| MEDIUM  | sonnet | haiku  | 3 | lite    | low      | 8000   | 60%     |
| HARD    | sonnet | sonnet | 4 | lite    | high     | 15000  | 70%     |
| EXPERT  | opus   | sonnet | 5 | off     | high     | 32000  | 80%     |

Confirm: `✓ [LEVEL] active. Model: [m] · Caveman: [c] · Thinking: [t] · Subs: [n]×[s]`

---

## MULTI-SKILL ROUTING (silent)

| Trigger | Skill |
|---------|-------|
| z-index, stacking, RTL, CSS broken, PNG | css-expert |
| ad creative, image prompt, copywriting | ad-creative |
| mobile, iOS, Android, responsive | mobile-inspector |
| Word, DOCX, PDF, RTL document | docx |
| context > 60%, memory warning | strategic-compact |

---

## STATUS DECLARATION (every response, mandatory)

First line of **every response** — before any content:

```
🧠 MOS [LEVEL] · score [n]/140
```

Example: `🧠 MOS MEDIUM · score 64/140`

Rules:
- Applies to **all agents and subagents** (main, Explore, Plan, general-purpose, etc.)
- Updated immediately when level changes
- Never omit — even on short answers
- If caveman is also active, combine: `🧠 MOS MEDIUM · score 64/140 · caveman (full)`

---

## ENFORCEMENT

1. **Session start block (STEP 3) is blocking** — no response before displaying it.
2. **Status declaration** — every response, every agent.
3. **SessionStart hook** prints `MOS: active` as confirmation.
4. If MOS block was skipped at session start, the first user prompt triggers it before answering.

---

## SESSION COMMANDS

| Command | Action |
|---------|--------|
| `/mos` | Show full status + level menu |
| `/mos [1-5]` | Apply preset immediately |
| `/mos reset` | Restore default (MEDIUM) |
| `/mos save` | Save current as default |
