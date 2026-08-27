#!/usr/bin/env bash
# Regression checks for the environment-readiness workflow additions.
# These are static invariants; agent pressure scenarios should be run through
# the Claude Code integration suite when that harness is available.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

PLANS="$REPO_ROOT/skills/writing-plans/SKILL.md"
SUPERPOWERS="$REPO_ROOT/skills/using-superpowers/SKILL.md"
SDD="$REPO_ROOT/skills/subagent-driven-development/SKILL.md"
EXECUTING="$REPO_ROOT/skills/executing-plans/SKILL.md"
BRAINSTORMING="$REPO_ROOT/skills/brainstorming/SKILL.md"
TDD="$REPO_ROOT/skills/test-driven-development/writing-good-tests.md"
VERIFY="$REPO_ROOT/skills/verification-before-completion/SKILL.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
contains() {
  local file="$1"; local text="$2"; local description="$3"
  grep -Fq "$text" "$file" || fail "$description"
}
absent() {
  local file="$1"; local text="$2"; local description="$3"
  ! grep -Fq "$text" "$file" || fail "$description"
}

contains "$PLANS" "Environment & Capabilities Readiness" "writing-plans lacks generalized environment readiness"
contains "$PLANS" "Task 0: Not applicable" "writing-plans lacks the no-prerequisite branch"
contains "$PLANS" "Every plan must include the Task 0 section below" "writing-plans does not require a Task 0 section"
contains "$PLANS" "Browser acceptance decision" "writing-plans lacks an acceptance-bound browser decision"
contains "$PLANS" "only when \`Browser acceptance decision\` is \`Required\`" "writing-plans browser step is not tied to the readiness decision"
contains "$PLANS" "stop and report the exact action" "writing-plans lacks the human-action blocker rule"
contains "$PLANS" "If any check fails, fix the plan inline" "writing-plans self-review no longer repairs failures"
contains "$SUPERPOWERS" "Required Environment and Capabilities" "using-superpowers lacks the global environment rule"
contains "$SDD" "human-action gate from Task 0" "SDD lacks the environment/human gate stop condition"
contains "$EXECUTING" "Every plan must include Task 0" "executing-plans lacks the mandatory Task 0 check"
contains "$EXECUTING" "declarations and Task 0 disagree" "executing-plans lacks the readiness consistency check"
contains "$BRAINSTORMING" "real-vs-isolated boundary decisions" "brainstorming lacks the real-vs-isolated design decision"
contains "$TDD" "Mocks remain valid at deliberate seams" "TDD guidance lacks the deliberate mock seam policy"
contains "$VERIFY" "0 unexpected console errors" "verification guidance lacks the unexpected-console-error criterion"
contains "$VERIFY" "Each required capability has a passing setup/health check" "verification guidance lacks per-capability environment evidence"

absent "$PLANS" "Allowed Mocks: Mocks are strictly limited" "writing-plans still has the over-broad mock prohibition"
absent "$TDD" "Reserve mocks strictly for external boundaries" "TDD still has the contradictory external-only mock rule"
absent "$SDD" "Four things stop you, and only these" "SDD still has the old four-stop-condition rule"

printf '%s\n' "PASS: workflow environment, mock, browser, human-gate, and self-review invariants are present"
