---
name: mos
description: >
  MOS (Multiskill Optimum Saver) — שכבת אופטימיזציה ל-Claude Code.
  בודק מורכבות session בתחילתו, מציג תפריט ממוספר עם פרמטרים מלאים,
  ומעריך כל פרומפט תוך כדי session — מציע שדרוג/הורדת רמה בזמן אמת.
  חבילת סקילים: caveman, codebase-memory, strategic-compact, css-expert, ad-creative.
  Triggers: session start, every user prompt, /mos.
version: 3.0.0
always: true
requires:
  - JuliusBrussee/caveman
  - affaan-m/everything-claude-code/strategic-compact
---

# MOS — Multiskill Optimum Saver

## טבלת פרסטים

| # | רמה     | Model  | Caveman | Thinking | Subagents  | Score |
|---|---------|--------|---------|----------|------------|-------|
| 1 | TRIVIAL | haiku  | ultra   | off      | 0          | ~2    |
| 2 | SIMPLE  | sonnet | full    | off      | 1×haiku    | ~48   |
| 3 | MEDIUM  | sonnet | lite    | low      | 3×haiku    | ~64   |
| 4 | HARD    | sonnet | lite    | high     | 4×sonnet   | ~98   |
| 5 | EXPERT  | opus   | off     | high     | 5×sonnet   | ~157  |

---

## שלב 1 — קריאת CONFIG (שקט)

```bash
cat ~/.claude/session-config.json 2>/dev/null || echo "CONFIG_NOT_FOUND"
find . -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" 2>/dev/null | wc -l
git log --oneline -3 2>/dev/null
head -20 CLAUDE.md 2>/dev/null || head -20 .claude/CLAUDE.md 2>/dev/null
```

ברירות מחדל: model=sonnet, caveman=lite, thinking=low, subagents=3×haiku, compact=60%

Score: model(haiku=18/sonnet=58/opus=100) + thinking(off=0/low=8/high=22/max=38) + caveman(off=0/lite=−2/full=−8/ultra=−16) + subagents(haiku×4/sonnet×7, מקס 28)

---

## שלב 2 — זיהוי מורכבות

| רמה     | Score מינ | סיגנלים |
|---------|-----------|---------|
| TRIVIAL | 18        | שאלה, תרגום, סיכום, הסבר |
| SIMPLE  | 32        | fix, תיקון, שינוי, קובץ בודד |
| MEDIUM  | 55        | refactor, פיצ'ר, debug, component |
| HARD    | 75        | ארכיטקטורה, integration, agent, PRD |
| EXPERT  | 90        | rewrite, cross-cutting, multi-agent |

---

## שלב 3 — SESSION START (חובה, לפני תגובה ראשונה)

הצג בדיוק זה וחכה לקלט:

```
╔═ MOS ══════════════════════════════════════════════╗
║  זוהה: [LEVEL]                    Score: [n]/140   ║
║  Model: [model] · Thinking: [lvl] · Compact: [n]%  ║
║  Caveman: [lvl] · Subagents: [n]×[model]           ║
║  סטטוס: [✓ מתאים | ~ גבולי | ⚠ אי-התאמה]         ║
╠════════════════════════════════════════════════════╣
║  שנה רמה? הקלד מספר — Enter להמשיך               ║
║                                                    ║
║  1. TRIVIAL │ haiku  · ultra · off  · 0 subs       ║
║  2. SIMPLE  │ sonnet · full  · off  · 1×haiku      ║
║  3. MEDIUM  │ sonnet · lite  · low  · 3×haiku      ║
║  4. HARD    │ sonnet · lite  · high · 4×sonnet     ║
║  5. EXPERT  │ opus   · off   · high · 5×sonnet     ║
╚════════════════════════════════════════════════════╝
```

→ הרמה הנוכחית/המזוהה: סמן ✓ בסוף השורה שלה.
→ בחירת 1–5: החל פרסט (שלב 5). אשר: `✓ עבר ל-[LEVEL].`
→ Enter / אחר: המשך בשקט.

---

## שלב 4 — מעקב פרומפטים (כל פרומפט)

אחרי כל פרומפט, בחן בשקט אם רמת המורכבות שונה ב-2+ רמות מהנוכחי.

**פשוט מדי:**
```
💡 פרומפט פשוט יחסית לרמה הנוכחית ([LEVEL]). להוריד רמה?
  [הצג רק רמות מתחת לנוכחית עם פרמטרים מלאים]
  [Enter = המשך ב-[LEVEL]]
```

**מורכב מדי:**
```
⚠ פרומפט מורכב יחסית לרמה הנוכחית ([LEVEL]). לשדרג רמה?
  [הצג רק רמות מעל לנוכחית עם פרמטרים מלאים]
  [Enter = המשך ב-[LEVEL]]
```

ספים: מקס פעם אחת לכל 5 פרומפטים · לא חוזר על דחייה · מינימום פער 2 רמות.

---

## שלב 5 — החלת פרסט

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

| רמה     | model  | sub    | n | caveman | thinking | tokens | compact |
|---------|--------|--------|---|---------|----------|--------|---------|
| TRIVIAL | haiku  | haiku  | 0 | ultra   | off      | 0      | 40%     |
| SIMPLE  | sonnet | haiku  | 1 | full    | off      | 0      | 50%     |
| MEDIUM  | sonnet | haiku  | 3 | lite    | low      | 8000   | 60%     |
| HARD    | sonnet | sonnet | 4 | lite    | high     | 15000  | 70%     |
| EXPERT  | opus   | sonnet | 5 | off     | high     | 32000  | 80%     |

אשר: `✓ [LEVEL] פעיל. Model: [m] · Caveman: [c] · Thinking: [t] · Subs: [n]×[s]`

---

## ניתוב סקילים (שקט)

| טריגר | סקיל |
|-------|-------|
| z-index, stacking, RTL, CSS תקוע, PNG | css-expert |
| מודעה, קריאייטיב, פרומפט תמונה, קופי | ad-creative |
| מובייל, iOS, Android, רספונסיבי | mobile-inspector |
| Word, DOCX, PDF, מסמך RTL | docx |
| context > 60%, זיכרון מלא | strategic-compact |

---

## הצהרת סטטוס (כל תגובה, חובה)

שורה ראשונה של **כל תגובה** — לפני כל תוכן:

```
🧠 MOS [LEVEL] · score [n]/140
```

דוגמה: `🧠 MOS MEDIUM · score 64/140`

כללים:
- חל על **כל סוכן וסאב-אייג'נט** (ראשי, Explore, Plan, general-purpose וכו')
- מתעדכן מיידית כשהרמה משתנה
- לא להשמיט — גם בתשובות קצרות
- אם caveman פעיל, לשלב: `🧠 MOS MEDIUM · score 64/140 · caveman (full)`

---

## אכיפה

1. **בלוק SESSION START (שלב 3) חוסם** — אין תגובה לפני הצגתו.
2. **הצהרת סטטוס** — כל תגובה, כל סוכן.
3. **SessionStart hook** מדפיס `MOS: active` כאישור.
4. אם בלוק MOS דולג בתחילת session, הפרומפט הראשון מפעיל אותו לפני מענה.

---

## פקודות SESSION

| פקודה | פעולה |
|-------|-------|
| `/mos` | הצג סטטוס + תפריט רמות מלא |
| `/mos [1-5]` | החל פרסט מיידי |
| `/mos reset` | שחזר ל-MEDIUM (ברירת מחדל) |
| `/mos save` | שמור config נוכחי כברירת מחדל |
