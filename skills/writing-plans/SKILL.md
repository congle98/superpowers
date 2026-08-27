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

## Environment & Capabilities Readiness (Task 0 / Preflight)

Document only the prerequisites required by this task. Cover the categories that apply and write `N/A — [reason]` for the rest:

- **Runtime and toolchain:** [exact versions and commands]
- **Project dependencies:** [package manager, install command, lockfile]
- **Local/external services:** [services, containers, endpoints, ports]
- **Browser/tooling:** [browser, Playwright, emulator, or other tools]
- **Browser acceptance decision:** [`Required — cite the acceptance criterion and supported capability/command`, or `N/A — the acceptance criteria contain no browser behavior`]
- **MCP capabilities:** [server/tool names and how they are verified]
- **Credentials/permissions/network:** [human-provided secrets, accounts, roles, VPN, proxy]
- **Data/state:** [migrations, fixtures, seed data, clean-state requirements]
- **AI Actions:** [exact safe setup commands the agent can run]
- **Human Actions Required (Gates):** [exact user action; do not invent secrets or permissions]
- **Verification commands:** [one exact command per required capability and its expected evidence]

Every plan must include the Task 0 section below. If no prerequisite is required, state `Task 0: Not applicable — [specific reason]` and mark every readiness category `N/A — [reason]`; do not copy generic setup steps.

**Readiness rule:** Verify every required prerequisite before core implementation. If the agent can safely install or configure a missing prerequisite, it must do so and verify it afterward. If human action, secret, permission, account, cost, or external approval is required, stop and report the exact action. Do not silently skip, substitute an unapproved fallback, reduce acceptance scope, or claim readiness.

## Real Integration vs Mock Policy

- **Real-stack-first:** Use the real persistence, storage, service, browser, and core runtime boundaries required by the spec from the earliest meaningful integration task.
- **Prohibited:** Fake persistence, hardcoded stores, or simulated internal APIs when real behavior is part of the acceptance criteria.
- **Allowed mocks:** Mocks are allowed for deliberately isolated unit seams, slow or nondeterministic operations, unavailable/paid/destructive external services, and other boundaries whose real side effects are not part of the test. Keep all side effects required by the behavior under test real.
- **Integration/E2E:** Do not use mocks to replace the core integration being delivered. If a required real dependency is unavailable, prepare it or mark the task blocked.

---
```

## Task Structure

### Task 0: Environment Setup & Capability Verification

````markdown
### Task 0: Environment Setup & Capability Verification

**Files:**
- Create/Modify: [only files genuinely needed for setup, or `None`]
- Test/Verify: [exact verification script or command]

**Prerequisites:**
- [Required capability and exact version/configuration]
- [Human gate, or `None`]

- [ ] **Step 1: Verify the declared environment**
Run the exact checks listed in `Environment & Capabilities Readiness`.
Expected: each required capability is present and reachable.

- [ ] **Step 2: Perform safe AI setup actions**
Run the exact install/configuration commands listed in the plan. Do not
invent credentials, permissions, or external account values.

- [ ] **Step 3: Complete human action gates (if any)**
If a required human action remains incomplete, stop with status `BLOCKED`
and report the exact action and the verification command. Do not dispatch
implementation tasks or use an unapproved fallback.

- [ ] **Step 4: Run readiness verification**
Run: [exact project-specific command(s)]
Expected: [exact output/condition for every required capability]
````

If the plan has no required prerequisites, explicitly write `Task 0: Not applicable — [reason]` and begin with the first feature task.

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

- [ ] **Step 5: Browser / E2E Verification (only when `Browser acceptance decision` is `Required`)**

Use the supported capability and exact command named in `Environment & Capabilities Readiness`.
If the required browser tool is unavailable, install/configure it when safe;
otherwise stop and report the human setup required. Do not silently substitute
an unapproved browser or manual check.

Run: [exact Playwright or supported browser verification command/tool call]
Expected: [required user flow passes, expected elements are rendered and
interactive, and there are 0 unexpected console errors; explain accepted
warnings rather than treating every warning as a failure]

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
- Fake persistence when real architecture is specified
- Vague environment setup ("set up the environment") without exact commands, expected evidence, and an explicit `N/A` rationale where appropriate
- Browser verification that names a tool without checking its availability or specifying a concrete command/tool call

## Self-Review

After writing the complete plan, look at the spec with fresh eyes and check the plan against it. This is a checklist you run yourself — not a subagent dispatch.

**1. Spec coverage:** Skim each section/requirement in the spec. Can you point to a task that implements it? List any gaps.

**2. Placeholder scan:** Search your plan for red flags — any of the patterns from the "No Placeholders" section above. Fix them.

**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

**4. Environment & Capability Check:** Are all required runtime, dependencies, services, tools, browser/MCP capabilities, credentials, permissions, network access, and data state identified? Are AI actions separated from human gates? Does each required capability have an exact verification command, or an explicit `N/A` rationale?

**5. Real Integration Check:** Does the plan use the real core boundaries required by the spec from the earliest meaningful integration task? Are mocks limited to deliberate seams without replacing required persistence or service behavior?

**6. Web / Browser Verification Check:** Does every plan make an explicit `Browser acceptance decision` tied to the spec's acceptance criteria? If `Required`, does it identify an available supported browser capability and exact command with 0 unexpected console errors? If `N/A`, is the reason clear?

If any check fails, fix the plan inline before handoff. If a requirement has no implementation task, add the missing task. Re-run the self-review after making changes.

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/superpowers/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints for review

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Fresh subagent per task + two-stage review

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:executing-plans
- Batch execution with checkpoints for review
