---
description: "/audit-toji — Governance health check with numeric 0-100 score. Checks lessons hygiene, TDD compliance, skill coverage, and framework alignment. Explicit command only."
---

Run a **comprehensive governance health audit** in **one response**. Do **not** rewrite skills or instructions; do **not** ask clarifying questions unless the repo is unreadable.

## Inputs (read silently, in order)

1. **`.github/copilot-instructions.md`** — Active Stack Profile (`Mode`, `Stack ID`, `Active Skill`, `Last Detected`).
2. **Primary dependency manifests** — e.g. `package.json`, `composer.json`, `go.mod`, `pyproject.toml` (top-level deps / framework names only).
3. **`.github/lessons-learned.md`** — Count total instincts. Check for contradictions, stale entries, and framework mismatches vs Active Stack Profile.
4. **`.github/skills/`** — directory names only; note if `Active Skill` path is missing or points to a non-existent file.
5. **`.github/instructions/`** — Tier 1 shippables present vs **Tier 2** `toji-stack-*.instructions.md` aligned with Active Skill / stack markers.
6. **Recent git log** — Run `git log --oneline -20` and scan for TDD compliance signals.

## Scoring Rubric (0-100)

Calculate a numeric governance health score using these weighted categories:

### 1. Lessons Hygiene (25 points)
| Condition | Points |
| :--- | :--- |
| 1-30 instincts, no contradictions | 25 |
| 31-50 instincts, no contradictions | 20 |
| 51-75 instincts (needs pruning) | 10 |
| 75+ instincts or contradictions found | 5 |
| No `lessons-learned.md` exists | 0 |

### 2. TDD Compliance (25 points)
Scan the last 20 commits. For each commit that modifies production code files:
| Condition | Points |
| :--- | :--- |
| ≥80% of code commits include test files | 25 |
| 60-79% include test files | 20 |
| 40-59% include test files | 10 |
| <40% include test files | 5 |
| No test files anywhere in repo | 0 |

### 3. Skill Coverage (25 points)
Cross-reference detected stack (from manifests) against available skills:
| Condition | Points |
| :--- | :--- |
| All core + stack-specific skills present and aligned | 25 |
| Core skills present, 1-2 stack-specific gaps | 20 |
| Missing 1+ core skills (TDD, security, research-first) | 10 |
| Major misalignment between stack and active skills | 5 |

### 4. Framework Alignment (25 points)
| Condition | Points |
| :--- | :--- |
| Stack Profile matches manifests, instructions aligned, no stale references | 25 |
| Minor drift (1-2 stale references) | 20 |
| Stack Profile outdated or missing | 10 |
| Major misalignment (wrong stack detected, contradictory instructions) | 5 |

## Output Format (mandatory)

```
## /audit-toji — Governance Health

**Score: [XX] / 100**
**Grade: [A (90-100) | B (75-89) | C (60-74) | D (40-59) | F (0-39)]**

| Category | Score | Notes |
|---|---|---|
| Lessons Hygiene | XX/25 | ... |
| TDD Compliance | XX/25 | ... |
| Skill Coverage | XX/25 | ... |
| Framework Alignment | XX/25 | ... |

### Misalignments
- (max 10 bullets; each concrete: file/skill + issue; **none** → write `None — no issues detected.`)

### Suggested Actions
- (max 5 bullets; e.g. "Prune lessons-learned.md below 30 instincts", "Run /detect-stack", "Add test file to recent commit")
```

**Stop** after this block. **Invisible Governance** unchanged; do not suggest committing excluded paths.
