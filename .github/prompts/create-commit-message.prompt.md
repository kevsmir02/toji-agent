```prompt
---
description: Generate a Conventional Commits message from current staged or unstaged changes.
---

Generate a well-structured commit message for the current repository changes.

1. **Inspect Changes** — Run the following to collect context:
   - `git status` — see which files are staged, modified, or untracked
   - `git diff --staged` — inspect staged diff (preferred)
   - If nothing is staged, fall back to `git diff HEAD` for unstaged changes
   - `git log --oneline -5` — check recent commit style for scope conventions used in this project

2. **Classify the Change Type** — Pick exactly one type:
   | Type | When to use |
   |---|---|
   | `feat` | New feature or capability |
   | `fix` | Bug fix |
   | `refactor` | Code change that is not a fix or feature |
   | `perf` | Performance improvement |
   | `style` | Formatting, whitespace — no logic change |
   | `test` | Adding or updating tests |
   | `docs` | Documentation only |
   | `build` | Build system, dependencies |
   | `ci` | CI/CD configuration |
   | `chore` | Maintenance not fitting another type |

3. **Determine Scope (optional but recommended)** — The scope is a short noun describing the area of the codebase changed (e.g. `auth`, `api`, `ui`, `db`, `cli`, `docs`). Use project-specific domain names, not generic framework names. Omit scope if the change is truly cross-cutting.

4. **Write the Subject Line** — Format: `<type>(<scope>): <summary>`
   - Use imperative present tense: `add`, `fix`, `remove`, `update` — not `added`, `fixes`, `removes`
   - All lowercase
   - No period at the end
   - Keep under 72 characters total (including type and scope)

5. **Write the Body (when needed)** — Add a body when:
   - The *why* is not obvious from the subject line
   - The change has important side-effects or constraints
   - Wrap body lines at 72 characters
   - Separate from subject with a blank line

6. **Write the Footer (when applicable)** — Add footer lines for:
   - `BREAKING CHANGE: <description>` — if the change breaks backward compatibility
   - `Closes #<issue>` or `Refs #<issue>` — if linked to an issue
   - Separate from body (or subject if no body) with a blank line

7. **Output the Final Message** — Present the complete commit message in a code block, ready to copy:

   ```
   <type>(<scope>): <summary>

   <body if needed>

   <footer if needed>
   ```

8. **Offer to Commit** — Ask if the user wants to run `git commit -m "..."` with the generated message, or if they want to adjust the type, scope, subject, body, or footer before committing.

```
