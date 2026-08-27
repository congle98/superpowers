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
| Web UI / Frontend works | Real browser / Playwright / Chrome DevTools MCP: 200 OK, elements rendered, 0 console errors | jsdom unit test passes, "component mounted" |
| Database persistence works | Real integration test / migration executed on live DB instance | Mock ORM / in-memory array |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Environment ready | Sanity/healthcheck command: exit 0, ports open, DB pinged | Packages installed, `.env` created |
| Agent completed | VCS diff shows changes | Agent reports "success" |
| Requirements met | Line-by-line checklist | Tests passing |

## Red Flags - STOP

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!", etc.)
- About to commit/push/PR without verification
- Trusting agent success reports
- Relying on partial verification
- Assuming Web UI works because jsdom/mock tests pass
- Assuming Database integration works because mock repository tests pass
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
| "JSDOM tests passed so web UI works" | JSDOM does not verify layout, CSS, browser APIs, hydration, or console errors. Verify in real browser / Playwright / DevTools MCP. |
| "Mock database works, will connect later" | Mock debt breaks in production. Test against real DB / container. |
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

**Web UI & Browser Verification (Playwright / Chrome DevTools MCP):**
```
✅ [Navigate page / Run Playwright] [Verify: 200 OK, element visible & interactive, 0 console errors] "UI verified in browser"
❌ "Component rendered in React test / jsdom"
```

**Real Database & Persistence:**
```
✅ [Run migration & execute query on live DB] [See: record persisted and retrieved] "Real database persistence verified"
❌ "Mock repository returned fixture"
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
