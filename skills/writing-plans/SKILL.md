---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** If working in an isolated worktree, it should have been created via the `superpowers:using-git-worktrees` skill at execution time.

**Save plans to:** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan location override this default)

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## Two Plan Shapes

Before mapping files, classify the plan's shape and say the
classification out loud — "this composes three subsystems, so I'll plan
it skeleton-first" — so your human partner can override it:

- **Task-by-task (default)** — tasks build the feature a component at a
  time, each step carrying the actual content the engineer needs. Use it
  for changes to code that already exists, for a spec that touches one
  subsystem, and whenever the alternative's conditions do not clearly
  hold. The rest of this skill describes this shape.
- **Skeleton-first (alternative)** — Task 1 is the thinnest end-to-end
  slice through every subsystem the spec composes; later tasks widen it
  one component at a time, each from a contract rather than written-out
  code. Use it when the spec composes more than one subsystem AND a
  running end-to-end slice early is worth a longer total build. Read
  [skeleton-first-plans.md](skeleton-first-plans.md) before writing one
  — it adds one line to the plan header and replaces this skill's task
  granularity, task template, and plan-failure list.

When in doubt, plan task-by-task. Skeleton-first buys an earlier running
system and pays for it in total wall clock; it is a trade, not an
upgrade.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

## Task Right-Sizing

A task is the smallest unit that carries its own test cycle and is worth a
fresh reviewer's gate. When drawing task boundaries: fold setup,
configuration, scaffolding, and documentation steps into the task whose
deliverable needs them; split only where a reviewer could meaningfully
reject one task while approving its neighbor. Each task ends with an
independently testable deliverable.

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

**Spec:** [path to the spec/design doc this plan implements — the plan
argues from the spec, so the spec travels with it; executors read both]

## Global Constraints

[The spec's project-wide requirements — version floors, dependency limits,
naming and copy rules, platform requirements — one line each, with exact
values copied verbatim from the spec. Every task's requirements implicitly
include this section.]

## Environment & Prerequisites (Task 0 / Preflight)

[Document all setup required before starting core feature work. Clearly separate automated AI actions from required human partner inputs.]
- **AI Actions (Automated):** [e.g., install dependencies, start docker services `docker compose up -d postgres`, run database migrations `alembic upgrade head` / `prisma migrate dev`, generate `.env` from `.env.example`]
- **Human Actions Required (Gates):** [e.g., provide secret API keys, configure OAuth sandbox app, grant cloud permissions]
- **Sanity Verification Command:** [e.g., `npm run db:ping` or curl healthcheck to prove services and database are live and reachable before Task 1]

## Real Stack vs Mock Policy

- **Real-Stack-First:** Use real databases, storage engines, schema migrations, and core runtime technologies from Task 1.
- **Prohibited:** In-memory fake arrays (`const users = []`), hardcoded mock JSON stores, or simulated API layers where real persistence is required by the spec.
- **Allowed Mocks:** Mocks are strictly limited to non-hostable, paid, or destructive 3rd-party external boundaries (e.g., Stripe live charges, external SMS/Email gateways).

---
```

## Task Structure

### Task 0: Environment Setup & Sanity Verification (when applicable)

````markdown
### Task 0: Environment Setup & Health Verification

**Files:**
- Create: `.env.example`, `docker-compose.yml`, `src/db/schema.sql` (if needed)
- Test/Verify: Sanity check command

- [ ] **Step 1: AI Setup Actions**
Run automated package installs, start local containers, copy env files.

- [ ] **Step 2: Human Action Gate (if secrets/keys required)**
Prompt human partner for required credentials or external permissions.

- [ ] **Step 3: Run Sanity Verification**
Run: `npm run healthcheck` (or DB connection probe).
Expected: 0 errors, DB connected, services ready.
````

### Feature Tasks

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Interfaces:**
- Consumes: [what this task uses from earlier tasks — exact signatures]
- Produces: [what later tasks rely on — exact function names, parameter
  and return types. A task's implementer sees only their own task; this
  block is how they learn the names and types neighboring tasks use.]

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Browser / E2E Verification (for Web/UI tasks)**

Run: Playwright test, or Chrome DevTools MCP navigation check (`navigate_page`, `evaluate_script`, `take_screenshot`, `list_console_messages`).
Expected: Page loads with HTTP 200, element rendered & clickable, 0 console errors/warnings.

- [ ] **Step 6: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## No Placeholders

Every step must contain the actual content an engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may be reading tasks out of order)
- Steps that describe what to do without showing how (code blocks required for code steps)
- References to types, functions, or methods not defined in any task
- Mocking databases or persistent state when real architecture is specified
- Vague environment setup ("set up database") without exact commands and sanity checks

## Self-Review

After writing the complete plan, look at the spec with fresh eyes and check the plan against it. This is a checklist you run yourself — not a subagent dispatch.

**1. Spec coverage:** Skim each section/requirement in the spec. Can you point to a task that implements it? List any gaps.

**2. Placeholder scan:** Search your plan for red flags — any of the patterns from the "No Placeholders" section above. Fix them.

**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

**4. Environment & Preflight Check:** Are AI setup actions separated from Human action gates? Is there a Task 0 sanity verification command to confirm real databases and services are live before Task 1?

**5. Real Stack First Check:** Does the plan use real databases, migrations, and core technologies from Task 1 instead of accumulating mock debt or fake in-memory stores?

**6. Web / Browser Verification Check:** For any Web/UI deliverables, do the verification steps specify real browser testing (Playwright / Chrome DevTools MCP checks: status 200, DOM visibility, 0 console errors) instead of jsdom-only unit tests?

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/superpowers/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Fresh subagent per task + two-stage review

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:executing-plans
- Batch execution with checkpoints for review
