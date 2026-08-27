---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output before making any success claims; evidence before assertions always
---

# Verification Before Completion

## Overview

**Core principle:** Evidence before claims, always.

**Violating the letter of this rule is violating the spirit of this rule.**

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in this message, you cannot claim it passes.

## The Gate Function

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim

Skip any step = lying, not verifying
```

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Type check clean | Typechecker (`tsc --noEmit`, `mypy`, `cargo check`): 0 errors | Linter passing, code compiles |
| Build succeeds | Build command: exit 0 | Linter passing, logs look good |
| Web UI / Frontend works | Supported real-browser verification for the required flow: expected response, elements rendered/interactable, 0 unexpected console errors | jsdom unit test passes, "component mounted" |
| Required integration works | Real implementation/service/storage boundary exercised when required by acceptance criteria | Mock or in-memory substitute for the required boundary |
| Environment ready | Each required capability has a passing setup/health check and expected evidence | Packages installed, `.env` created, or one unrelated healthcheck |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Agent completed | VCS diff shows changes | Agent reports "success" |
| Requirements met | Line-by-line checklist | Tests passing |

## Red Flags - STOP

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!", etc.)
- About to commit/push/PR without verification
- Trusting agent success reports
- Relying on partial verification
- Assuming Web UI works because jsdom/mock tests pass
- Assuming a required integration works because a substitute boundary passed
- Assuming environment readiness because packages were installed without capability checks
- Thinking "just this once"
- Tired and wanting work over
- **ANY wording implying success without having run verification**

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | RUN the verification |
| "I'm confident" | Confidence ≠ evidence |
| "Just this once" | No exceptions |
| "Linter passed" | Linter ≠ compiler / typechecker |
| "JSDOM tests passed so web UI works" | JSDOM does not verify layout, CSS, browser APIs, hydration, or console behavior. Use an available supported real-browser capability when browser behavior is part of acceptance. |
| "The substitute implementation works, will integrate later" | A substitute cannot prove a required integration boundary. Prepare the real dependency or report the task as blocked. |
| "Packages are installed, so the environment is ready" | Verify every required capability with its setup/health command. |
| "Agent said success" | Verify independently |
| "I'm tired" | Exhaustion ≠ excuse |
| "Partial check is enough" | Partial proves nothing |
| "Different words so rule doesn't apply" | Spirit over letter |

## Key Patterns

**Tests:**
```
✅ [Run test command] [See: 34/34 pass] "All tests pass"
❌ "Should pass now" / "Looks correct"
```

**Web UI & Browser Verification:**
```
✅ [Use the supported browser capability named in the plan] [Verify the required flow, expected response, rendered/interactable elements, and 0 unexpected console errors; document accepted warnings] "UI verified in browser"
❌ "Component rendered in React test / jsdom"
```

**Required Integration Verification:**
```
✅ [Exercise the required real service/storage/persistence boundary] [See the expected state change or response]
❌ "Substitute repository returned fixture"
```

**Type Check & Static Analysis:**
```
✅ [Run tsc --noEmit / mypy] [See: 0 errors] "Type check passed with 0 errors"
❌ "It compiled and ran once"
```

**Regression tests (TDD Red-Green):**
```
✅ Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)
❌ "I've written a regression test" (without red-green verification)
```

**Build:**
```
✅ [Run build] [See: exit 0] "Build passes"
❌ "Linter passed" (linter doesn't check compilation)
```

**Requirements:**
```
✅ Re-read plan → Create checklist → Verify each → Report gaps or completion
❌ "Tests pass, phase complete"
```

**Agent delegation:**
```
✅ Agent reports success → Check VCS diff → Verify changes → Report actual state
❌ Trust agent report
```

## When To Apply

**ALWAYS before:**
- ANY variation of success/completion claims
- ANY expression of satisfaction
- ANY positive statement about work state
- Committing, PR creation, task completion
- Moving to next task
- Delegating to agents

**Rule applies to:**
- Exact phrases
- Paraphrases and synonyms
- Implications of success
- ANY communication suggesting completion/correctness
