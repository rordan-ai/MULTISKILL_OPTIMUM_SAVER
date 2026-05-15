# MOS — Technical Documentation
### Multiskill Optimum Saver

Version 3.0.0 | MIT License | Bilingual (EN + HE)

---

## Table of Contents

1. [Problem Statement](#1-problem-statement)
2. [Solution Overview](#2-solution-overview)
3. [Architecture](#3-architecture)
4. [Scoring Algorithm](#4-scoring-algorithm)
5. [Complexity Classification](#5-complexity-classification)
6. [Configuration Presets](#6-configuration-presets)
7. [Multi-Skill Routing](#7-multi-skill-routing)
8. [Session Commands](#8-session-commands)
9. [Real-World Scenarios](#9-real-world-scenarios)
10. [Performance Impact](#10-performance-impact)
11. [Interface Coverage](#11-interface-coverage)
12. [Companion Tools](#12-companion-tools)
13. [Limitations & Design Decisions](#13-limitations--design-decisions)
14. [Configuration Reference](#14-configuration-reference)

---

## 1. Problem Statement

Claude Code users face a persistent optimization problem: **config is set once and left unchanged.**

A developer opens Claude Code Monday morning with Opus + extended thinking + 5 subagents. They use it for a quick question about a regex, renaming a variable across 3 files, and designing a full microservices architecture. All three tasks run on the same config. Two of them are massively over-resourced. One might be under-resourced.

Over a week of typical development work: 30–40% of tokens go to tasks that haiku + no thinking would have handled equally well. 10–15% of tasks hit complexity ceilings because the config was set for "light" work. Zero visibility into whether the current config is appropriate.

---

## 2. Solution Overview

MOS runs automatically at session start, evaluates context, and makes a recommendation. You approve or decline in one word.

**The flow:**
Session starts → MOS reads session-config.json → scans project context → classifies complexity (TRIVIAL/SIMPLE/MEDIUM/HARD/EXPERT) → computes config score (0–140) → compares score against complexity minimum → shows status or recommendation → user approves/declines

**Key principles:** Non-disruptive (never changes without approval), Transparent (shows current→recommended values), Contextual (based on actual project signals), Ephemeral env (sets env vars for immediate effect).

---

## 3. Architecture

```
~/.claude/
├── skills/
│   └── mos/
│       └── SKILL.md          ← Core skill logic
├── session-config.json        ← User configuration
└── settings.json              ← Hooks (SessionStart)
```

The skill uses `always: true` in its frontmatter, loading at every session start. Context scanning (silent): file count, git log, CLAUDE.md.

---

## 4. Scoring Algorithm

MOS assigns a numeric score (0–140) to any config combination.

| Parameter | Option | Points |
|-----------|--------|--------|
| **Model** | haiku | +18 |
| | sonnet | +58 |
| | opus | +100 |
| **Extended thinking** | off | +0 |
| | low | +8 |
| | high | +22 |
| | max | +38 |
| **Caveman compression** | lite | −2 |
| | full | −8 |
| | ultra | −16 |
| **Subagents** | each haiku | +4 (max +28) |
| | each sonnet | +7 (max +28) |

**Example:** Default config (sonnet + caveman-lite + thinking-low + 3×haiku): 58+8−2+12 = **76**

---

## 5. Complexity Classification

| Level | Min Score | Primary Signals |
|-------|-----------|-----------------|
| TRIVIAL | 18 | Q&A, translation, summarize, explain |
| SIMPLE | 32 | Fix a bug, rename, single-file edit |
| MEDIUM | 55 | Feature, refactor, debug, write tests |
| HARD | 77 | Architecture, integration, agent, PRD |
| EXPERT | 90 | Rewrite, cross-cutting, multi-agent |

Borderline: score ≥ 80% of minimum → soft warning instead of full mismatch.

---

## 6. Configuration Presets

| Complexity | Model  | Caveman | Thinking | Subagents | Sub Model |
|------------|--------|---------|----------|-----------|-----------|
| TRIVIAL    | haiku  | ultra   | off      | 0         | haiku     |
| SIMPLE     | sonnet | full    | off      | 1         | haiku     |
| MEDIUM     | sonnet | lite    | low      | 3         | haiku     |
| HARD       | sonnet | lite    | high     | 4         | sonnet    |
| EXPERT     | opus   | off     | high     | 5         | sonnet    |

---

## 7. Multi-Skill Routing

| Trigger Keywords | Activated Skill |
|-----------------|-----------------|
| z-index, stacking, RTL, CSS not working, PNG | css-expert |
| ad creative, image prompt, copywriting, campaign | ad-creative |
| mobile layout, iOS, Android, responsive | mobile-inspector |
| Word, DOCX, PDF, RTL document | docx |
| Context > 60%, memory warning | strategic-compact |

---

## 8. Session Commands

| Command | Description |
|---------|-------------|
| `/mos` | Display current config status + level menu |
| `/mos [1-5]` | Apply preset for complexity level |
| `/mos reset` | Restore default config |
| `/mos save` | Save current config as default |

---

## 9. Real-World Scenarios

**Scenario A:** User asks "What's the difference between useEffect and useLayoutEffect?" — TRIVIAL detected, sonnet→haiku recommended, ~77% token savings if approved.

**Scenario B:** "Fix the TypeError in UserCard.tsx line 47" — SIMPLE detected, current score 76 > min 32, ✓ no recommendation.

**Scenario C:** "Design a real-time notification system for 100k events/second" — EXPERT detected, score 76 < min 90, recommends opus+thinking-high+5×sonnet.

---

## 10. Performance Impact

| Scenario | Typical Config | MOS Config | Savings |
|----------|---------------|------------|---------|
| Q&A / explanation | sonnet | haiku | ~77% |
| Translation / summarize | sonnet+thinking | haiku | ~80% |
| Single-file fix | opus | sonnet | ~40% |
| Architecture design | sonnet | opus+thinking+subagents | (justified increase) |

---

## 11. Interface Coverage

| Interface | Config R/W | Env Vars | Advisory |
|-----------|-----------|----------|----------|
| Claude Code | ✅ | ✅ | ✅ |
| Claude Desktop | ✅ | ✅ | ✅ |
| Cowork (Desktop) | ✅ | ✅ | ✅ |
| claude.ai Chat | ❌ | ❌ | ✅ |

---

## 12. Companion Tools

- **[Caveman](https://github.com/JuliusBrussee/caveman)** — Output token compression (50–75% reduction), MOS adjusts level as part of presets
- **[Codebase Memory MCP](https://github.com/DeusData/codebase-memory-mcp)** — Pre-indexes codebase, MOS adds +6 to score when active
- **[Claude-Mem](https://github.com/thedotmack/claude-mem)** — Persistent memory across sessions, MOS adds +4 to score
- **[Token Savior](https://github.com/Mibayy/token-savior)** — Symbol navigation with ~77% token reduction
- **[Model Router Hook](https://github.com/tzachbon/claude-model-router-hook)** — Warns when model doesn't match complexity

---

## 13. Limitations & Design Decisions

**Cannot do in claude.ai Chat:** Write files or set env vars. Advisory mode only.

**Complexity detection:** Can misclassify when first message is ambiguous. Use `/mos [1-5]` to override.

**Why not auto-apply?** Forced changes mid-workflow break focus. One-word approval keeps user in control.

**Why numeric score?** Makes it possible to see *how far* a config is from requirement, not just whether it matches.

**Why bilingual?** Built for Hebrew-speaking developers who work with English tools. Both versions maintained at feature parity.

**Why not MCP?** Skills load directly into Claude context without a running server process — simpler and more reliable.

---

## 14. Configuration Reference

```json
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
  "active_skills": ["mos", "caveman", "strategic-compact"]
}
```

| Field | Values | Description |
|-------|--------|-------------|
| `model_default` | haiku/sonnet/opus | Primary model |
| `subagent.max` | 0–10 | Max concurrent subagents |
| `caveman.level` | lite/full/ultra | Compression aggressiveness |
| `compact_threshold` | 0–100 | Context % for compaction |
| `extended_thinking` | off/low/high/max | Thinking budget |

---

*MOS v3.0.0 — MIT License — Built by [rordan-ai](https://github.com/rordan-ai)*
