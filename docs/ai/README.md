# AI Docs

Use `docs/ai/` as the written source of truth for product intent, architecture, delivery, and operational concerns.

## Structure

- `features/{name}.md` — primary feature brief combining requirements, design, and delivery plan
- `implementation/{name}.md` — optional deep implementation notes, setup details, and integration specifics
- `testing/{name}.md` — optional test strategy, coverage notes, and manual validation checklist
- `deployment/README.md` — deployment checklist and environment notes
- `monitoring/README.md` — metrics, alerting, and incident response guidance

## Default Workflow

1. Start with `features/{name}.md`
2. Add `implementation/{name}.md` only when the feature needs extra technical depth
3. Add `testing/{name}.md` when test scope, fixtures, or deferred coverage need to be tracked explicitly
4. Keep these docs aligned as the feature changes

## Legacy Layout

Older Toji templates split feature work across `requirements/`, `design/`, and `planning/`.
This template consolidates those concerns into `features/{name}.md` to reduce duplication and drift.