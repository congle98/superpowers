# Antigravity CLI (`agy`) Tool Mapping

Skills speak in actions ("dispatch a subagent", "create a todo", "read a file"). On the Antigravity CLI (`agy`) these resolve to the tools below.

| Action skills request | Antigravity CLI equivalent |
|----------------------|----------------------|
| Dispatch a subagent (`Subagent (general-purpose):` template) | `invoke_subagent` with a built-in `TypeName` — `self` for full-capability work, `research` for read-only |
| Task tracking ("create a todo", "mark complete") | a **task artifact** — `write_to_file` with `IsArtifact: true` and `ArtifactType: "task"` (see [Task tracking](#task-tracking)). **Not** `manage_task`, which manages background processes. |
| Read file | `view_file` |
| Create file / Write | `write_to_file` |
| Edit file | `replace_file_content` |
| Search code | `grep_search` / `find_by_name` |
| Shell / Run command | `run_command` |
| Web / Browser verification (E2E) | Lazy MCP tools from `chrome-devtools` (`navigate_page`, `evaluate_script`, `take_screenshot`, `list_console_messages`, `click`, `fill`) or Playwright via `run_command` |

## Task tracking

Antigravity has **no todo tool** (`manage_task` manages background
processes — `list`/`kill`/`status`/`send_input` — it is *not* a checklist). When a
skill says to create a todo list or track tasks, maintain a **task artifact**: a
markdown checklist saved with `write_to_file` (`IsArtifact: true`,
`ArtifactMetadata.ArtifactType: "task"`), edited with `replace_file_content` /
`multi_replace_file_content` as you go.

At the start of any multi-step task, create the task artifact listing every step of
your plan. As you complete each step, edit the artifact to mark it done (`- [x]`).
If the plan changes, update the checklist. Keep it current — it is your source of
truth for what remains; once the conversation gets long, re-read it before starting
each step.

## Web & Browser Verification (Chrome DevTools MCP / Playwright)

When verifying Web/UI deliverables, Antigravity provides access to the `chrome-devtools` MCP server tools:
- `call_mcp_tool` with `ServerName: "chrome-devtools"`:
  - `navigate_page`: Load target local/remote URL.
  - `evaluate_script`: Evaluate JavaScript expressions and inspect DOM state directly.
  - `list_console_messages` / `get_console_message`: Verify zero unexpected console errors or unhandled exceptions; review warnings separately and document accepted ones.
  - `take_screenshot`: Capture visual state of components.
  - `click`, `fill`, `fill_form`: Simulate real user interactions.
- Alternatively, run headless Playwright test suites (`npx playwright test`) via `run_command`.
