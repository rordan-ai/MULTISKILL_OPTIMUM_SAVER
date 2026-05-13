---
name: multiskill-optimum-saver
description: >
  בודק מורכבות session בתחילתו, ממליץ על שינויי config ומבצע אותם
  באישור. חבילת סקילים: caveman, codebase-memory, strategic-compact,
  css-expert, ad-creative, mobile-responsiveness.
  Triggers: session start, /governor, /mos-status, "מה הסטטוס",
  "אופטימיזציה", "what's my config".
version: 2.0.0
always: true
requires:
  - JuliusBrussee/caveman
  - affaan-m/everything-claude-code/strategic-compact
---

# MULTISKILL OPTIMUM SAVER — גרסה עברית

## שלב 1 — קריאת CONFIG נוכחי

בתחילת כל session, הרץ בשקט:

```bash
cat ~/.claude/session-config.json 2>/dev/null || echo "CONFIG_NOT_FOUND"
```

אם CONFIG_NOT_FOUND — השתמש בברירות מחדל:
model=sonnet, caveman=lite, thinking=low, subagents=3(haiku),
compact_threshold=60, max_thinking_tokens=10000

חשב score:
- model: haiku=18, sonnet=58, opus=100
- thinking: off=0, low=8, high=22, max=38
- caveman: off=0, lite=-2, full=-8, ultra=-16
- subagents: מספר x (haiku=4 | sonnet=7), מוגבל ל-28
- claude-mem: +4, codebase-memory: +6

---

## שלב 2 — זיהוי מורכבות SESSION

הרץ בשקט:

```bash
find . -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" 2>/dev/null | wc -l
git log --oneline -3 2>/dev/null
head -20 CLAUDE.md 2>/dev/null || head -20 .claude/CLAUDE.md 2>/dev/null
```

סיווג לפי סיגנלים + הודעת המשתמש הראשונה:

| מורכבות          | Score מינימלי | סיגנלים אופייניים |
|------------------|---------------|-------------------|
| פשוטה            | 18            | שאלה, תרגום, סיכום, הסבר |
| לא מורכבת        | 32            | fix, תיקון, שינוי, הוספה קטנה |
| מורכבת           | 55            | refactor, פיצ'ר, debug, component |
| בינ' מורכבת      | 75            | ארכיטקטורה, integration, agent, PRD |
| מורכבת מאוד      | 90            | rewrite, cross-cutting, כל הפרויקט, multi-agent |

---

## שלב 3 — הצגת סטטוס

הצג בדיוק זה בתחילת כל session:

```
╔═ MOS — MULTISKILL OPTIMUM SAVER ══════════════╗
║  מודל: [model]        Sub: [sub_model]×[n]    ║
║  Caveman: [level]     Thinking: [level]        ║
║  Compact@: [n]%       Score: [score]/140       ║
╠═══════════════════════════════════════════════╣
║  Session: [מורכבות]   זוהה מ: [סיבה קצרה]   ║
║  סטטוס: [✓ מתאים | ~ גבולי | ⚠ אי-התאמה]   ║
╚═══════════════════════════════════════════════╝
```

כללי הסטטוס:
- score >= minScore → ✓ Config מתאים לצרכי ה-session
- score >= minScore × 0.8 → ~ גבולי — שינוי קל מומלץ
- score < minScore × 0.8 → ⚠ אי-התאמה — ראה המלצה

---

## שלב 4 — המלצה (רק אם יש אי-התאמה)

אם יש אי-התאמה, הוסף:

```
המלצה: Config מכוון ל[רמה נוכחית], ה-session דורש [רמה מזוהה].

שינויים מוצעים:
  model:         [נוכחי] → [מומלץ]
  thinking:      [נוכחי] → [מומלץ]
  caveman_level: [נוכחי] → [מומלץ]
  max_subagents: [נוכחי] → [מומלץ]

כתוב "כן" או "אשר" להחלה אוטומטית.
כתוב "לא" להשאיר את הconfig הנוכחי.
```

ערכי פרסט לפי מורכבות:

| מורכבות       | model  | caveman | thinking | subagents | sub_model |
|---------------|--------|---------|----------|-----------|-----------|
| פשוטה         | haiku  | ultra   | off      | 0         | haiku     |
| לא מורכבת     | sonnet | full    | off      | 1         | haiku     |
| מורכבת        | sonnet | lite    | low      | 3         | haiku     |
| בינ' מורכבת   | sonnet | lite    | high     | 4         | sonnet    |
| מורכבת מאוד   | opus   | off     | high     | 5         | sonnet    |

---

## שלב 5 — ביצוע באישור

אם המשתמש כתב "כן", "אשר", "yes", "approve":

1. כתוב config מעודכן:
```bash
cat > ~/.claude/session-config.json << 'EOF'
{
  "model_default": "[מומלץ]",
  "subagent": { "model": "[sub]", "max": [n], "parallel": true },
  "caveman": { "enabled": true, "level": "[רמה]", "compress_claude_md": true },
  "compact_threshold": [n],
  "extended_thinking": "[רמה]",
  "max_thinking_tokens": [n]
}
EOF
```

2. הגדר env vars לsession הנוכחי:
```bash
export ANTHROPIC_MODEL="[מודל]"
export CLAUDE_CODE_SUBAGENT_MODEL="[sub_model]"
```

3. אשר: "✓ Config עודכן ופעיל ל-session זה."

אם סרב: "→ נשמר config נוכחי. מוכן לעבודה."

---

## ניתוב סקילים (אוטומטי, שקט)

| טריגר | סקיל |
|-------|-------|
| z-index, stacking, RTL, CSS תקוע, PNG | css-expert |
| מודעה, קריאייטיב, פרומפט תמונה, קופי | ad-creative |
| מובייל, iOS, Android, רספונסיבי | mobile-inspector |
| Word, DOCX, PDF, מסמך RTL | docx |
| context > 60%, זיכרון מלא | strategic-compact |

---

## פקודות SESSION

| פקודה | פעולה |
|-------|-------|
| /governor | הצג סטטוס config נוכחי |
| /mos-status | זהה ל-/governor |
| /mos-preset [רמה] | החל פרסט לרמת מורכבות |
| /mos-reset | שחזר config ברירת מחדל |
| /mos-save | שמור config נוכחי כברירת מחדל |
