---
name: multiskill-optimum-saver
description: >
  Evaluates session complexity at start, recommends config changes, and
  executes approved changes automatically. Multi-skill bundle: caveman,
  codebase-memory, strategic-compact, css-expert, ad-creative,
  mobile-responsiveness. Triggers: session start, /governor,
  /mos-status, "what's my config", "optimize session".
version: 2.0.0
always: true
requires:
  - JuliusBrussee/caveman
  - affaan-m/everything-claude-code/strategic-compact
---

# MULTISKILL OPTIMUM SAVER (MOS)

## STEP 1 — READ CURRENT CONFIG

At the very start of every session, silently run:

```bash
cat ~/.claude/session-config.json 2>/dev/null || echo "CONFIG_NOT_FOUND"
```

If CONFIG_NOT_FOUND: use defaults: model=sonnet, caveman=lite, thinking=low,
subagents=3(haiku), compact_threshold=60, max_thinking_tokens=10000

Compute score:
- model: haiku=18, sonnet=58, opus=100
- thinking: off=0, low=8, high=22, max=38
- caveman: off=0, lite=-2, full=-8, ultra=-16
- subagents: count x (haiku=4|sonnet=7), capped at 28
- claude-mem bonus: +4, codebase-memory bonus: +6

---

## STEP 2 — DETECT SESSION COMPLEXITY

Run these silently at session start:

```bash
find . -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" 2>/dev/null | wc -l
git log --oneline -3 2>/dev/null
head -20 CLAUDE.md 2>/dev/null || head -20 .claude/CLAUDE.md 2>/dev/null
```

Classify based on signals + first user message:

| Complexity | Min Score | Signals |
|------------|-----------|---------|
| TRIVIAL    | 18        | Q&A, translation, summarize, explain |
| SIMPLE     | 32        | fix, change, add, style, rename, single file |
| MEDIUM     | 55        | refactor, implement, feature, debug, component |
| HARD       | 75        | architecture, integration, agent, PRD |
| EXPERT     | 90        | rewrite, cross-cutting, all files, multi-agent |

---

## STEP 3 — OUTPUT STATUS BLOCK

Output at every session start:

```
╔═ MOS — MULTISKILL OPTIMUM SAVER ══════════════╗
║  Model: [model]       Sub: [sub_model]x[n]    ║
║  Caveman: [level]     Thinking: [level]        ║
║  Compact@: [n]%       Score: [score]/140       ║
╠═══════════════════════════════════════════════╣
║  Session: [COMPLEXITY]  Reason: [brief]        ║
║  Status:  [match / borderline / mismatch]      ║
╚═══════════════════════════════════════════════╝
```

Status rules:
- score >= minScore: Config matches session needs
- score >= minScore x 0.8: borderline — minor change recommended
- score < minScore x 0.8: mismatch — see recommendation

---

## STEP 4 — RECOMMEND CHANGES (mismatch only)

If score < complexity minScore x 0.8, output:

```
RECOMMENDATION: Config tuned for [current], session needs [detected].

Suggested:
  model:         [current] -> [recommended]
  thinking:      [current] -> [recommended]
  caveman_level: [current] -> [recommended]
  max_subagents: [current] -> [recommended]

Type "yes"/"approve" to apply. Type "no" to keep current.
```

Preset values:

| Complexity | model  | caveman | thinking | subagents | sub_model |
|------------|--------|---------|----------|-----------|-----------|
| TRIVIAL    | haiku  | ultra   | off      | 0         | haiku     |
| SIMPLE     | sonnet | full    | off      | 1         | haiku     |
| MEDIUM     | sonnet | lite    | low      | 3         | haiku     |
| HARD       | sonnet | lite    | high     | 4         | sonnet    |
| EXPERT     | opus   | off     | high     | 5         | sonnet    |

---

## STEP 5 — EXECUTE ON APPROVAL

If user says "yes"/"approve"/"כן"/"אשר":

1. Write updated config:
```bash
cat > ~/.claude/session-config.json << 'EOF'
{
  "model_default": "[recommended]",
  "subagent": { "model": "[sub]", "max": [n], "parallel": true },
  "caveman": { "enabled": true, "level": "[level]", "compress_claude_md": true },
  "compact_threshold": [n],
  "extended_thinking": "[level]",
  "max_thinking_tokens": [n]
}
EOF
```

2. Set env vars:
```bash
export ANTHROPIC_MODEL="[model]"
export CLAUDE_CODE_SUBAGENT_MODEL="[sub_model]"
```

3. Confirm: "Config updated and active for this session."

If declined: "Keeping current config. Ready to work."

---

## MULTI-SKILL ROUTING (automatic, silent)

| Trigger | Skill |
|---------|-------|
| z-index, stacking, RTL, CSS stuck, PNG | css-expert |
| ad creative, image prompt, copy | ad-creative |
| mobile layout, iOS, Android, responsive | mobile-inspector |
| Word doc, DOCX, PDF, RTL document | docx |
| context > 60%, memory warning | strategic-compact |

---

## SESSION COMMANDS

| Command | Action |
|---------|--------|
| /governor | Show current config status |
| /mos-status | Same as /governor |
| /mos-preset [level] | Apply complexity preset |
| /mos-reset | Restore default config |
| /mos-save | Save current as default |
