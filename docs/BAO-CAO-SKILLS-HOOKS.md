# Báo cáo khảo sát Skills và Hooks của Superpowers

**Ngày khảo sát:** 27/08/2026
**Phiên bản repository:** `6.3.0`
**Phạm vi:** thư mục `skills/`, `hooks/`, các plugin adapter/manifest và test liên quan.
**Nguồn chính:** mã nguồn và tài liệu hiện có trong repository; báo cáo này không suy diễn hành vi không được thể hiện trong source.

## 1. Tóm tắt điều hành

Superpowers là một framework phương pháp phát triển phần mềm dành cho coding agent. Project không cung cấp một thư viện runtime lớn; giá trị chính nằm ở:

1. **Thư viện 14 skill dạng Markdown** trong `skills/`. Mỗi skill có một `SKILL.md` với YAML frontmatter gồm `name` và `description`, sau đó là quy trình, nguyên tắc, checklist, ví dụ và các liên kết đến tài liệu hỗ trợ.
2. **Bootstrap `using-superpowers`** được nạp ở đầu phiên. Bootstrap dạy agent cách tìm và gọi các skill khác trước khi trả lời hoặc thực hiện hành động.
3. **Lớp adapter theo harness** để cùng một bộ skill hoạt động trong Claude Code, Cursor, OpenCode, Pi, Hermes, Kimi Code, Gemini CLI, Codex, Devin, Antigravity và các môi trường được README mô tả.
4. **Các hook/context injector** làm nhiệm vụ đưa bootstrap vào phiên; skill cụ thể thường được discovery và nạp on-demand bằng native skill tool của harness.

Luồng ý tưởng cốt lõi là:

```text
User mở phiên
    ↓
Nạp using-superpowers bootstrap
    ↓
Agent kiểm tra skill phù hợp trước khi hành động
    ↓
brainstorming / debugging / TDD / planning / review ...
    ↓
Thực hiện, kiểm chứng bằng bằng chứng
    ↓
finishing-a-development-branch
```

Project phân biệt rõ **skill** và **hook**:

- **Skill** định hình cách agent suy nghĩ và làm việc; đây là tài liệu hành vi được nạp khi cần.
- **Hook** là cơ chế của harness để chạy code hoặc biến đổi context tại các thời điểm như bắt đầu phiên, compact context, trước lượt gọi model hoặc trước khi discovery skill.

## 2. Kiến trúc thư mục liên quan

```text
skills/
├── brainstorming/
├── dispatching-parallel-agents/
├── executing-plans/
├── finishing-a-development-branch/
├── receiving-code-review/
├── requesting-code-review/
├── subagent-driven-development/
├── systematic-debugging/
├── test-driven-development/
├── using-git-worktrees/
├── using-superpowers/
├── verification-before-completion/
├── writing-plans/
└── writing-skills/

hooks/
├── hooks.json             # Claude Code
├── hooks-cursor.json      # Cursor
├── run-hook.cmd           # dispatcher CMD/bash đa nền tảng
└── session-start          # logic bootstrap dạng bash, không có extension

.claude-plugin/            # Claude Code
.codex-plugin/             # Codex
.cursor-plugin/            # Cursor
.devin-plugin/             # Devin
.hermes-plugin/            # Hermes
.kimi-plugin/              # Kimi Code
.opencode/plugins/         # OpenCode runtime plugin
.pi/extensions/            # Pi runtime extension
gemini-extension.json      # Gemini CLI extension manifest
GEMINI.md                  # Gemini context file
```

`package.json` khai báo package cho Pi: thư mục `./skills` là skill root và `.pi/extensions/superpowers.ts` là extension. Với các harness khác, manifest riêng trỏ về cùng thư viện skill hoặc đăng ký adapter tương ứng.

### 2.1. Quy ước của một skill

`skills/writing-skills/SKILL.md` mô tả quy ước chung:

- Tên skill dùng chữ cái, chữ số và dấu gạch ngang.
- Frontmatter phải có `name` và `description`.
- `description` phải tập trung vào **khi nào skill áp dụng**, không tóm tắt toàn bộ quy trình; điều này giúp agent quyết định có nên đọc skill hay không.
- Namespace là phẳng: skill được tìm theo tên trong một thư mục chung.
- Nội dung dài hoặc công cụ tái sử dụng được tách thành file hỗ trợ thay vì nhồi toàn bộ vào `SKILL.md`.
- Skill định hình hành vi phải được kiểm thử bằng pressure scenario/subagent theo mô hình RED-GREEN-REFACTOR, tương tự TDD.

## 3. Cơ chế discovery và bootstrap

### 3.1. Bootstrap `using-superpowers`

`skills/using-superpowers/SKILL.md` là skill nền tảng. Nó yêu cầu agent:

- kiểm tra skill liên quan **trước mọi phản hồi hoặc hành động**, kể cả hỏi làm rõ hay đọc file;
- nếu có dù chỉ 1% khả năng một skill áp dụng, phải gọi skill đó;
- ưu tiên skill quy trình trước skill triển khai;
- đọc file mapping tương ứng nếu harness có khác biệt về tên tool;
- tuân thủ `CLAUDE.md`, `AGENTS.md`, `GEMINI.md` hoặc instruction file của harness trước skill.

Bootstrap không phải là toàn bộ 14 skill. Nó chỉ giới thiệu cách dùng hệ thống và yêu cầu agent dùng native `Skill`/`skill`/`skill_view` tương ứng để nạp skill cụ thể.

### 3.2. Tự động kích hoạt và nạp on-demand

README mô tả rằng skill trigger tự động nên người dùng không phải opt-in từng skill. Về mặt runtime, điều này được thực hiện bằng hai lớp:

- bootstrap đầu phiên làm agent biết quy tắc và trigger;
- native skill discovery/tool của từng harness làm skill cụ thể có thể được load theo tên.

Ví dụ, `brainstorming` có description bắt buộc dùng trước công việc sáng tạo; `systematic-debugging` áp dụng khi có bug/test failure; `test-driven-development` áp dụng trước khi viết implementation cho feature hoặc bugfix.

## 4. Danh mục đầy đủ 14 skills

| Skill | Nhóm | Khi áp dụng | Kết quả chính |
|---|---|---|---|
| `using-superpowers` | Bootstrap/meta | Mọi conversation/phiên làm việc | Agent biết discovery và thứ tự gọi skill |
| `brainstorming` | Thiết kế | Ý tưởng, feature, thay đổi behavior, component mới | Design/spec được làm rõ và được người dùng duyệt |
| `using-git-worktrees` | Cô lập môi trường | Bắt đầu feature hoặc chạy implementation plan | Workspace/branch cô lập, baseline test sạch |
| `writing-plans` | Lập kế hoạch | Có spec/requirements cho tác vụ nhiều bước | Plan chi tiết theo file, code, test và commit |
| `test-driven-development` | Kiểm thử | Feature, bugfix, refactor, behavior change | Chu trình RED-GREEN-REFACTOR |
| `systematic-debugging` | Debug | Bug, test/build failure, behavior bất ngờ, performance | Root cause và fix có bằng chứng |
| `verification-before-completion` | Xác minh | Trước mọi claim hoàn tất/passing/fixed | Lệnh kiểm chứng mới và kết quả thực tế |
| `dispatching-parallel-agents` | Agent orchestration | Có từ hai tác vụ độc lập trở lên | Agent được chia theo domain và chạy song song |
| `subagent-driven-development` | Triển khai | Có implementation plan, task tương đối độc lập, cùng session | Implementer mới + review từng task + final review |
| `executing-plans` | Triển khai | Có plan và muốn chạy ở session riêng | Đọc plan, chạy tuần tự, checkpoint và finish branch |
| `requesting-code-review` | Review | Sau task, feature lớn hoặc trước merge | Review độc lập theo diff/requirements |
| `receiving-code-review` | Review | Nhận feedback trước khi sửa | Verify, đánh giá kỹ thuật, sửa từng mục |
| `finishing-a-development-branch` | Bàn giao | Implementation hoàn tất và test xanh | Verify, chọn merge/PR/giữ branch, cleanup |
| `writing-skills` | Meta/authoring | Tạo, sửa hoặc verify một skill | Skill được thiết kế/test như process code |

Các phần dưới đây mô tả chi tiết từng skill.

### 4.1. `using-superpowers` — bootstrap và luật discovery

**File:** `skills/using-superpowers/SKILL.md`

Đây là entry point của cả hệ thống. Skill chứa hai mức bắt buộc:

- `<SUBAGENT-STOP>`: nếu agent là subagent được dispatch cho một task cụ thể thì bỏ qua bootstrap này.
- `<EXTREMELY-IMPORTANT>`: nếu có khả năng skill áp dụng thì không được rationalize để bỏ qua.

Skill quy định phải invoke skill trước cả câu hỏi làm rõ. Nó đưa ra thứ tự ưu tiên: skill quy trình trước skill triển khai; ví dụ làm feature phải đi qua `brainstorming`, còn sửa bug phải đi qua `systematic-debugging`.

Nó cũng là nơi liên kết đến mapping của Codex, Pi, Antigravity và Hermes. Các file mapping biến hành động trừu tượng như “dispatch subagent”, “create todo”, “read file” thành tool thật của từng harness.

Bootstrap còn đặt invariant readiness ở cấp workflow: capability bắt buộc phải được verify trước hành động phụ thuộc; capability không liên quan không bị ép cài đặt; human gate chưa hoàn tất là blocker và không được invent credential, dùng fallback không được duyệt hoặc giảm acceptance scope.

### 4.2. `brainstorming` — từ ý tưởng đến design được duyệt

**File:** `skills/brainstorming/SKILL.md`

Đây là skill có hard gate mạnh nhất trước implementation: không được gọi skill triển khai, viết code, scaffold hoặc thay đổi implementation cho tới khi đã trình bày ý định và người dùng phê duyệt.

Skill phân loại yêu cầu thành ba path:

1. **Spike:** câu hỏi khả thi; điều tra tối thiểu, báo cáo recommendation; code thử chỉ là throwaway.
2. **Bounded:** thay đổi nhỏ trong flow đã tồn tại; hỏi các điểm cần thiết, trình bày design ngắn trong chat và chờ phê duyệt; không tạo spec file.
3. **Architectural:** project/subsystem mới hoặc thay đổi interface; hỏi từng câu, đưa 2–3 phương án, trình bày design theo phần (gồm architecture, persistence/storage/service boundaries, Environment & Capabilities Readiness, data flow, error handling, testing), viết spec vào `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`, tự review tính khả thi của real integration và môi trường rồi mới chuyển sang `writing-plans`.

Skill có red flags để ngăn các lý do như “quá đơn giản nên không cần approval”. Nếu phát hiện complexity tăng giữa chừng, path phải được nâng cấp chứ không hạ cấp.

Tài liệu hỗ trợ gồm `visual-companion.md` và thư mục `scripts/` với server zero-dependency, frame template, helper, start/stop server. Visual companion chỉ dùng khi câu hỏi thực sự mang tính thị giác như mockup, layout, diagram; câu hỏi requirements/trade-off vẫn xử lý bằng terminal.

### 4.3. `using-git-worktrees` — cô lập workspace

**File:** `skills/using-git-worktrees/SKILL.md`

Skill kiểm tra trước xem đang ở linked worktree hay submodule bằng `GIT_DIR`, `GIT_COMMON` và `git rev-parse --show-superproject-working-tree`. Nếu chưa cô lập, skill ưu tiên native worktree tool của harness; chỉ dùng `git worktree add` khi không có native tool.

Khi tạo worktree thủ công, thứ tự chọn thư mục là preference của người dùng, `.worktrees/`, `worktrees/`, rồi mặc định `.worktrees/`. Thư mục phải được `git check-ignore` xác nhận trước khi tạo.

Sau khi cô lập, skill tự nhận diện setup (`npm install`, Cargo, Python, Go nếu có) và chạy baseline test. Nếu baseline fail thì phải báo và không tự ý xem đó là lỗi mới của feature.

### 4.4. `writing-plans` — implementation plan có thể giao cho agent khác

**File:** `skills/writing-plans/SKILL.md`

Mục tiêu là viết plan cho một engineer biết rất ít context nhưng vẫn có thể làm đúng. Plan bắt buộc lưu ở `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md` và phải có header gồm Goal, Architecture, Tech Stack, Spec, Global Constraints, **Environment & Capabilities Readiness (Task 0 / Preflight)** và **Real Integration vs Mock Policy**.

Skill yêu cầu:

- **Environment & Capabilities Readiness / Task 0:** mọi plan phải khai báo các prerequisite thực sự liên quan theo các nhóm runtime/toolchain, dependencies, services, browser/tooling, browser acceptance decision, MCP, credentials/permissions/network và data/state; nhóm không áp dụng phải ghi `N/A — [reason]`. Task 0 phải có nhánh `Not applicable` nếu không có prerequisite.
- **Install-or-block:** tách rõ AI Actions an toàn (cài đặt/cấu hình và verify) khỏi Human Actions Required. Nếu thiếu secret, account, permission, cost hoặc approval thì dừng với trạng thái `BLOCKED`, nêu exact action và verification command; không invent credential, fallback không được duyệt hoặc giảm acceptance scope.
- **Real-integration-first:** dùng persistence, storage, service và core runtime thật ở các boundary mà acceptance criteria yêu cầu; không dùng fake persistence, hardcoded store hoặc simulated internal API để che integration chưa làm.
- **Mock policy có chủ đích:** mock được phép ở deliberate unit seams cho thao tác chậm, không deterministic, unavailable, paid, destructive hoặc external khi side effect thật không thuộc behavior đang test; không mock boundary integration bắt buộc.
- **Browser verification có điều kiện:** ghi rõ `Browser acceptance decision` gắn với acceptance criteria. Chỉ khi criteria có browser behavior mới yêu cầu Playwright hoặc capability Chrome DevTools MCP khả dụng; khi required phải verify flow, response, rendered/interactable elements và `0 unexpected console errors`, đồng thời xem xét warning riêng.
- map file trước khi chia task;
- mỗi task là deliverable độc lập, có test cycle riêng;
- từng bước nhỏ 2–5 phút: viết test fail, chạy RED, code tối thiểu, chạy GREEN, browser/e2e check chỉ khi browser acceptance required, commit;
- ghi path chính xác, interface producer/consumer, code cần viết và lệnh verify;
- không dùng placeholder như `TBD`, `TODO`, “add appropriate validation” hay “write tests for above”.

Sau khi viết plan, skill tự review coverage với spec, quét placeholder, kiểm tra consistency của type/signature, kiểm tra từng capability và verification của Task 0, kiểm tra real-integration/mock policy và browser decision có căn cứ. Nếu self-review phát hiện vấn đề, phải sửa plan trước handoff; không coi việc tự review là lý do để bỏ qua repair. Cuối cùng đưa lựa chọn `subagent-driven-development` hoặc `executing-plans`.

### 4.5. `test-driven-development` — RED-GREEN-REFACTOR

**File:** `skills/test-driven-development/SKILL.md`

Iron Law: **không có production code nếu chưa có failing test trước**. Quy tắc áp dụng cho feature, bugfix, refactor và behavior change; exception như prototype/Generated code/config chỉ được dùng khi người dùng cho phép.

Chu trình:

1. **RED:** viết một test nhỏ mô tả behavior.
2. Chạy test và xác nhận nó fail đúng vì feature chưa có, không phải vì typo/setup.
3. **GREEN:** viết implementation tối thiểu để pass.
4. Chạy test và toàn bộ test liên quan.
5. **REFACTOR:** chỉ dọn duplication/tên/helper sau khi đang xanh.

Nếu code đã viết trước test, skill yêu cầu xóa và bắt đầu lại, không giữ làm reference. `writing-good-tests.md` bổ sung quy tắc:
- **Real required integrations first:** không thay persistence, storage, service hoặc domain boundary mà acceptance criteria yêu cầu bằng in-memory array (`const store = []`), fake repository, hardcoded response hoặc simulated internal API; dùng implementation thật, local file thật hoặc service ephemeral/containerized với migration/config thật. Nếu dependency bắt buộc chưa sẵn sàng, phải chuẩn bị hoặc báo `BLOCKED`.
- **Real browser khi acceptance yêu cầu:** JSDOM chỉ phù hợp để test logic cây ảo; khi browser behavior nằm trong acceptance criteria, phải kết hợp capability real-browser được hỗ trợ (Playwright hoặc Chrome DevTools MCP đã cấu hình), verify flow/DOM/interaction và `0 unexpected console errors`. Warning phải được xem xét riêng.
- **Mock tại deliberate seams:** mock được phép để cô lập unit khỏi thao tác chậm, không deterministic, unavailable, paid, destructive hoặc external; side effect cần cho behavior vẫn phải real. Không dùng mock thay cho core persistence, service hoặc domain boundary đang giao.

### 4.6. `systematic-debugging` — tìm root cause trước khi sửa

**File:** `skills/systematic-debugging/SKILL.md`

Iron Law: **NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST**. Skill áp dụng cho test failure, production bug, build failure, integration issue, performance và mọi behavior bất ngờ.

Bốn phase bắt buộc:

1. **Root cause investigation:** đọc hết error/stack trace, reproduce, xem thay đổi gần đây, thêm instrumentation ở boundary nếu là hệ nhiều component, trace data flow ngược về nguồn.
2. **Pattern analysis:** tìm implementation đang chạy tốt, đọc reference đầy đủ, liệt kê mọi khác biệt và dependencies.
3. **Hypothesis/testing:** mỗi lần chỉ một hypothesis, thử thay đổi nhỏ nhất, không chồng nhiều fix.
4. **Implementation:** tạo regression test, sửa root cause một thay đổi, verify và kiểm tra regression.

Sau ba lần fix thất bại, skill yêu cầu dừng việc vá triệu chứng và thảo luận lại architecture. Tài liệu hỗ trợ gồm `root-cause-tracing.md`, `defense-in-depth.md`, `condition-based-waiting.md`, ví dụ TypeScript, `find-polluter.sh` và các pressure test.

### 4.7. `verification-before-completion` — bằng chứng trước claim

**File:** `skills/verification-before-completion/SKILL.md`

Skill cấm mọi claim dạng “done”, “fixed”, “tests pass”, “build succeeds” nếu chưa có verification mới trong chính context hiện tại.

Gate gồm năm bước:

1. Xác định claim cần chứng minh.
2. Chọn lệnh đầy đủ để chứng minh.
3. Chạy lệnh.
4. Đọc output và exit code, đếm failure.
5. Chỉ nói claim nếu output thực sự xác nhận; nếu không thì báo trạng thái thật.

Skill phân biệt rõ:
- **Unit/Integration test:** test command exit 0, 0 failures;
- **Web UI / Frontend:** chỉ khi acceptance criteria có browser behavior thì dùng capability real-browser được hỗ trợ (Playwright / Chrome DevTools MCP) để verify expected response, rendered/interactable elements và `0 unexpected console errors`; warning được review riêng;
- **Required integration:** exercise real implementation/service/storage boundary khi acceptance criteria yêu cầu, không chấp nhận mock hoặc in-memory substitute cho boundary đó;
- **Environment & Capabilities readiness:** mỗi capability bắt buộc phải có setup/health check và expected evidence; cài package hoặc tạo `.env` tự nó không chứng minh readiness;
- **Database/storage persistence:** khi là boundary bắt buộc, test ghi/đọc state thực tế trên instance đang chạy;
- **Type check & Lint:** `tsc --noEmit`, `mypy`, `cargo check` exit 0, 0 errors/warnings;
- **Build / Regression test / Requirements met.**
Report của agent cũng không được xem là bằng chứng thay cho diff/test độc lập.

### 4.8. `dispatching-parallel-agents` — song song hóa domain độc lập

**File:** `skills/dispatching-parallel-agents/SKILL.md`

Dùng khi có từ hai vấn đề độc lập trở lên, chẳng hạn nhiều test file có root cause khác nhau. Không dùng khi failure liên quan, có shared state, cần full context hoặc đang exploratory debugging.

Quy trình là xác định domain độc lập, tạo prompt self-contained cho từng agent, dispatch trong cùng một lượt để chạy song song, sau đó đọc summary, kiểm tra conflict và chạy full suite.

Prompt tốt phải có scope rõ, mục tiêu, constraint không đụng domain khác và output contract. Skill nhấn mạnh không được dispatch song song cho các task có dependency hoặc cùng sửa một resource.

### 4.9. `subagent-driven-development` — triển khai theo task với review hai tầng

**File:** `skills/subagent-driven-development/SKILL.md`

Đây là workflow đầy đủ khi có plan và các task tương đối độc lập trong cùng session. Mỗi task dùng một implementer subagent mới, sau đó có task reviewer kiểm tra hai verdict: spec compliance và code quality. Sau tất cả task có broad whole-branch review.

Các đặc điểm quan trọng:

- dùng workspace và ledger riêng cho từng plan trong `.superpowers/sdd/<plan-basename>/`;
- đọc plan một lần, tạo task brief riêng và report file riêng;
- setup phải đọc và thực thi Task 0 environment/capability readiness trước khi dispatch task implementation; human-action gate chưa hoàn tất là blocker;
- implementer không được spawn reviewer/subagent khác;
- implementer tự review và task reviewer kiểm tra nghiêm ngặt: prerequisites/capabilities đã verify hoặc task báo `BLOCKED` với exact human action; không invent credential hay dùng unapproved fallback; real-stack/required integration không bị thay bằng fake in-memory store; Web/UI chỉ dùng real-browser verification khi acceptance criteria yêu cầu (Playwright hoặc Chrome DevTools MCP khả dụng) và phải có `0 unexpected console errors`;
- task review dùng diff package, không tin mù quáng report của implementer;
- findings Critical/Important đi vào fix loop tối đa năm round;
- round 1–3 resume implementer cũ, round 4–5 dùng implementer mới mạnh hơn;
- sau mỗi task phải ghi ledger và chỉ tiến tiếp khi review sạch hoặc finding đã được adjudicate đúng quy trình;
- final review dùng merge-base tới HEAD, sau đó chuyển sang `finishing-a-development-branch`.

Script hỗ trợ gồm `scripts/sdd-workspace`, `scripts/task-brief` và `scripts/review-package`. Đây là skill nhiều quy tắc nhất vì nó quản lý cả memory recovery sau compaction, context hygiene, model selection, review loop và ledger.

### 4.10. `executing-plans` — chạy plan ở session riêng

**File:** `skills/executing-plans/SKILL.md`

Dùng khi đã có implementation plan và muốn thực hiện ở một session riêng, đặc biệt khi subagent orchestration không phù hợp. Skill yêu cầu announce, kiểm tra isolated workspace, đọc và review plan trước, nêu concern nếu có, tạo todo rồi chạy Task 0 / readiness verification trước các task feature; sau đó chạy từng task theo đúng thứ tự và verification ghi trong plan.

Task 0 phải dừng với trạng thái `BLOCKED` nếu còn human-action gate hoặc capability bắt buộc chưa được chuẩn bị; không được tự invent credential, dùng fallback không được duyệt hoặc tiếp tục implementation. Nếu tất cả category là `N/A` với lý do cụ thể, phải ghi nhận preflight không cần setup.

Nếu có subagent capability, skill khuyến nghị dùng `subagent-driven-development` thay thế. Sau khi hoàn tất, bắt buộc gọi `finishing-a-development-branch`; nếu gặp blocker, test fail hoặc instruction không rõ thì dừng và hỏi thay vì đoán.

### 4.11. `requesting-code-review` — yêu cầu review chủ động

**File:** `skills/requesting-code-review/SKILL.md`

Review bắt buộc sau mỗi task của SDD, sau feature lớn và trước merge; có thể dùng thêm khi bị stuck hoặc trước refactor.

Agent phải lấy `BASE_SHA` và `HEAD_SHA`, sau đó dispatch reviewer với template `code-reviewer.md`. Template yêu cầu reviewer:

- read-only trên checkout;
- đánh giá requirements, architecture, quality, edge cases, testing (real behavior, required persistence/service boundaries, conditional browser verification);
- kiểm tra production readiness (schema migration reversibility, không commit hardcoded secrets, tài liệu `.env.example`);
- phân loại Critical/Important/Minor;
- trích file:line, lý do và hướng sửa;
- đưa verdict rõ `Ready to merge?`.

Nguyên tắc là review sớm để lỗi không lan sang task sau; không được bỏ qua review chỉ vì diff “đơn giản”.

### 4.12. `receiving-code-review` — tiếp nhận feedback có kiểm chứng

**File:** `skills/receiving-code-review/SKILL.md`

Skill chống lại việc đồng ý mang tính xã giao hoặc sửa mù. Trình tự bắt buộc là:

```text
READ → UNDERSTAND → VERIFY → EVALUATE → RESPOND → IMPLEMENT
```

Feedback chưa rõ thì phải dừng toàn bộ, hỏi làm rõ trước khi sửa các mục khác. Feedback từ external reviewer phải được kiểm tra với codebase, compatibility, test và lý do của implementation hiện tại. Nếu feedback vi phạm YAGNI, phải grep usage thực tế trước khi thêm “professional feature”.

Các mục được xử lý theo thứ tự blocking/security, fix đơn giản, rồi logic/refactor; test từng fix và push back bằng lý do kỹ thuật nếu reviewer sai.

### 4.13. `finishing-a-development-branch` — hoàn tất và bàn giao

**File:** `skills/finishing-a-development-branch/SKILL.md`

Đây là workflow cuối: **Verify tests → Detect environment → Determine base → Present options → Execute choice → Cleanup**.

Skill phải chạy full test suite trước khi đưa menu. Nếu test fail, chỉ báo failure và dừng. Nếu xanh, detect normal repo, named worktree hoặc detached HEAD; sau đó trình bày đúng lựa chọn:

1. Merge local vào base branch.
2. Push và tạo Pull Request.
3. Giữ branch như hiện tại.

Không tự ý discard. Nếu người dùng muốn discard, phải yêu cầu xác nhận chính xác `discard`; khi cleanup worktree bị từ chối vì file untracked/uncommitted, phải trình bày danh sách và hỏi chọn commit, chuyển hoặc xóa.

### 4.14. `writing-skills` — viết skill như viết process code

**File:** `skills/writing-skills/SKILL.md`

Đây là meta-skill để tạo/sửa/verify skill. Nó áp dụng TDD vào tài liệu:

- **RED:** chạy pressure scenario khi chưa có skill, quan sát agent vi phạm và ghi lại rationalization.
- **GREEN:** viết guidance tối thiểu để xử lý đúng các failure đã quan sát.
- **REFACTOR:** tìm loophole mới, bổ sung counter và test lại.

Skill phân biệt discipline skill, technique skill, pattern skill và reference skill; mỗi loại có kiểu test khác nhau. Nó yêu cầu description tối ưu discovery, keyword có triệu chứng/tool thật, cross-reference có đánh dấu `REQUIRED`, ví dụ tốt và flowchart chỉ dùng cho decision không hiển nhiên.

Phần quan trọng là không viết skill hàng loạt rồi bỏ qua deployment checklist. Mỗi skill phải có pressure scenarios, baseline không có skill, kiểm thử có skill, micro-test wording/no-guidance control, rationalization table, red flags và xác minh trước khi chuyển sang skill khác.

Tài liệu/công cụ hỗ trợ: `testing-skills-with-subagents.md`, `anthropic-best-practices.md`, `persuasion-principles.md`, `graphviz-conventions.dot`, `render-graphs.js` và thư mục `examples/`.

## 5. Hooks và bootstrap runtime

### 5.1. Claude Code: `hooks/hooks.json`

Cấu hình:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" session-start",
            "shell": "bash",
            "async": false
          }
        ]
      }
    ]
  }
}
```

Hook chạy ở các lý do `startup`, `clear`, `compact`, không chạy cho `resume`. Hook là synchronous (`async: false`) để context có mặt trước lượt làm việc tiếp theo. Command gọi dispatcher với script extensionless `session-start`.

### 5.2. `hooks/session-start`: nội dung được inject

Script này:

1. xác định `PLUGIN_ROOT` từ vị trí script;
2. đọc toàn bộ `skills/using-superpowers/SKILL.md`;
3. escape backslash, quote, newline, carriage return và tab để nhúng an toàn vào JSON;
4. bọc nội dung trong marker `<EXTREMELY_IMPORTANT>` và lời nhắc “You have superpowers”;
5. chọn format output theo biến môi trường:
   - Claude Code: `hookSpecificOutput.additionalContext` và `hookEventName: SessionStart`;
   - Cursor: top-level `additional_context`;
   - Copilot CLI/unknown: top-level `additionalContext`.

Script cố ý chỉ emit một format phù hợp. Comment trong source lưu ý Claude Code có thể đọc nhiều field mà không deduplicate, nên không được emit đồng thời `additional_context` và `hookSpecificOutput`.

### 5.3. `hooks/run-hook.cmd`: dispatcher đa nền tảng

Đây là file polyglot:

- trên Windows CMD, phần đầu là batch script;
- trên Unix, block CMD nằm trong heredoc của lệnh no-op `:` rồi bị bỏ qua, sau đó bash `exec` script.

Trên Windows, dispatcher thử Git Bash ở:

1. `C:\Program Files\Git\bin\bash.exe`;
2. `C:\Program Files (x86)\Git\bin\bash.exe`;
3. `bash` trên `PATH`.

Script extensionless tránh việc Claude Code trên Windows tự prepend `bash` khi thấy `.sh`, gây hỏng command dispatcher. Nếu không tìm thấy bash, dispatcher exit `0` và bỏ qua bootstrap thay vì làm hỏng toàn bộ plugin.

`docs/windows/polyglot-hooks.md` là tài liệu giải thích thiết kế; source chuẩn vẫn là `hooks/run-hook.cmd`.

### 5.4. Cursor: `hooks/hooks-cursor.json`

Cursor dùng format khác:

```json
{
  "version": 1,
  "hooks": {
    "sessionStart": [
      {
        "command": "./hooks/run-hook.cmd session-start"
      }
    ]
  }
}
```

`.cursor-plugin/plugin.json` trỏ `skills` tới `./skills/` và `hooks` tới `./hooks/hooks-cursor.json`. Cùng một logic `session-start` được tái sử dụng, nhưng output phải là `additional_context` snake_case.

### 5.5. Copilot CLI: dùng chung script, đổi output format

Không có manifest hook riêng trong root tương đương Claude/Cursor. Tuy nhiên `session-start` nhận biết `COPILOT_CLI=1` và trả SDK-standard `additionalContext` top-level. Test `tests/hooks/test-session-start.sh` kiểm tra đúng shape này, cùng với shape Claude và Cursor.

### 5.6. OpenCode: plugin hooks trong `.opencode/plugins/superpowers.js`

OpenCode không dùng `hooks/session-start` trực tiếp. Plugin đăng ký hai hook:

1. **`config` hook:** thêm absolute path `skills/` vào `config.skills.paths`, giúp OpenCode discovery skill mà không cần symlink hay sửa config thủ công.
2. **`experimental.chat.messages.transform` hook:** lấy bootstrap từ `using-superpowers`, chèn nó vào đầu message user đầu tiên.

Bootstrap được đưa vào **user message**, không phải system message, để tránh system prompt bị lặp mỗi turn và tránh lỗi model không hỗ trợ nhiều system message. Hook có guard không inject lại nếu message đã chứa marker `EXTREMELY_IMPORTANT`.

`getBootstrapContent()` có module-level cache: lần đầu kiểm tra/đọc/strip frontmatter; những lần transform sau dùng cache. Trường hợp file thiếu cũng cache `null`, tránh kiểm tra filesystem lặp lại.

OpenCode thêm tool mapping:

- todo → `todowrite`;
- subagent general-purpose → `task` với `subagent_type: "general"`;
- skill → native `skill`;
- đọc → `read`;
- mutation → `apply_patch`;
- shell → `bash`;
- search → `grep`, `glob`;
- URL → `webfetch`.

Các test OpenCode còn ghi nhận priority behavior của skill trùng tên có thể phụ thuộc behavior native hiện tại; bundled skill đôi khi shadow local skill. Đây là điểm cần lưu ý khi đặt skill custom trùng tên.

### 5.7. Pi: `.pi/extensions/superpowers.ts`

Pi có native skill system nên không cần compatibility `Skill` tool. Extension đăng ký:

- `resources_discover`: trả `skillsDir` để Pi discovery toàn bộ skill;
- `session_start`: bật cờ inject bootstrap;
- `session_compact`: bật lại cờ inject sau compact;
- `context`: chèn bootstrap như một user message trước message đầu tiên không phải compaction summary;
- `agent_end`: tắt inject sau khi agent kết thúc.

Extension không dùng pre-compaction injection. Nó có guard marker để tránh duplicate, cache nội dung bootstrap, và giữ bootstrap sau compaction summary thay vì chèn trước summary. Tool mapping Pi ghi rõ subagent và todo/task là capability optional; nếu không có package tương ứng thì làm inline hoặc giải thích capability thiếu, không tự bịa tool.

### 5.8. Hermes: `.hermes-plugin/__init__.py`

Manifest `.hermes-plugin/plugin.yaml` khai báo `pre_llm_call`. Khi `register(ctx)` chạy, plugin:

1. tìm `skills/` theo hai layout: clone repository (`.hermes-plugin/` cạnh `skills/`) hoặc flattened install (`skills/` cạnh module);
2. đăng ký mọi thư mục có `SKILL.md` với Hermes native loader bằng `pathlib.Path`;
3. build bootstrap từ `using-superpowers`, strip frontmatter và nhúng `hermes-tools.md`;
4. đăng ký `pre_llm_call` hook.

Hook chỉ trả `{"context": bootstrap}` khi `is_first_turn` là true; các turn sau trả `None`. Nếu không tìm thấy skills tree, plugin raise lỗi rõ ràng thay vì âm thầm chạy thiếu skill. Test Hermes kiểm tra bootstrap dưới giới hạn 10.000 ký tự để không bị spill ra file context.

### 5.9. Kimi Code: declarative session start, không có shell hook

`.kimi-plugin/plugin.json` khai báo:

- `skills: "./skills/"`;
- `sessionStart.skill: "using-superpowers"`;
- `skillInstructions` để mapping hành động sang tool Kimi.

Kimi mapping gồm `AskUserQuestion`, `TodoList`, `Agent`, `Skill`, `Read`, `Write`, `Edit`, `Bash`, `Grep`, `Glob`, `FetchURL`, `WebSearch`. Source và test nhấn mạnh manifest không được có các field runtime unsupported như `hooks`, `bootstrap`, `inject`, `commands`.

### 5.10. Gemini CLI: context file thay cho hook

`gemini-extension.json` đặt `contextFileName` là `GEMINI.md`. File này include:

```text
@./skills/using-superpowers/SKILL.md
@./skills/using-superpowers/references/gemini-tools.md
```

Vì vậy Gemini nhận bootstrap qua context file và dùng mapping native như `read_file`, `write_file`, `replace`, `run_shell_command`, `grep_search`, `glob`, `activate_skill`, `invoke_agent`, `write_todos`.

### 5.11. Codex: cố ý không dùng hook của Claude

`.codex-plugin/plugin.json` trỏ skill root tới `./skills/` và khai báo chính xác `"hooks": {}`. Empty object có mục đích: Codex có cơ chế fallback auto-discover `hooks/hooks.json`; nếu bỏ field hoặc dùng dạng rỗng khác, Codex có thể vô tình đăng ký Claude SessionStart hook. Vì vậy Codex dựa vào native skill discovery/session behavior, không re-register hook Claude.

`.agents/plugins/marketplace.json` cung cấp marketplace entry cho Codex App/CLI và `scripts/package-codex-plugin.sh` đóng gói manifest, skill, metadata OpenAI và assets nhưng loại source-only hook/test/docs khỏi archive.

### 5.12. Devin và Antigravity

Theo test/documentation trong repository:

- **Devin CLI:** plugin chỉ mang skill; Devin tự discovery skill đồng hành và có native system prompt/tool, nên không cần injector/hook scaffold riêng. `.devin-plugin/plugin.json` cố ý không có `skills`, `hooks`, `commands`, `sessionStart`, `contextFileName` hoặc `inject`.
- **Antigravity:** cài trực tiếp repository, dùng bundled skills và SessionStart hook chung; tài liệu mapping `antigravity-tools.md` định nghĩa rõ:
  - `invoke_subagent` với built-in type `self` (full capabilities) hoặc `research` (read-only);
  - task tracking qua task artifact (`write_to_file` với `IsArtifact: true`, `ArtifactType: "task"`);
  - web/browser verification qua lazy-loaded `chrome-devtools` MCP tools (`navigate_page`, `evaluate_script`, `take_screenshot`, `list_console_messages`, `click`, `fill`) hoặc Playwright CLI qua `run_command`.

README cũng liệt kê Factory Droid và Grok Build CLI là môi trường cài đặt hỗ trợ. Trong snapshot được khảo sát, không có adapter hook riêng tương đương `.opencode` hoặc `.pi`; cơ chế cụ thể phụ thuộc plugin runtime/native skill support của các harness đó.

## 6. Bảng ánh xạ hành động theo harness

| Hành động trừu tượng trong skill | Claude Code | OpenCode | Kimi | Gemini | Hermes | Pi | Antigravity |
|---|---|---|---|---|---|---|---|
| Nạp skill | `Skill` | `skill` | `Skill` | `activate_skill` | `skill_view` | native skill/read | native skill |
| Đọc file | native read | `read` | `Read` | `read_file` | `read_file` | `read` | `view_file` |
| Sửa/tạo file | native tools | `apply_patch` | `Write`/`Edit` | `write_file`/`replace` | `write_file`/`patch` | `write`/`edit` | `write_to_file`/`replace_file_content` |
| Shell | native | `bash` | `Bash` | `run_shell_command` | `terminal` | `bash` | `run_command` |
| Search | native | `grep`/`glob` | `Grep`/`Glob` | `grep_search`/`glob` | `search_files`/`find` | optional `grep`/`find` | `grep_search`/`find_by_name` |
| Subagent | `Task`/native | `task` | `Agent` | `invoke_agent` | `delegate_task` | optional `subagent` | `invoke_subagent` |
| Todo/task | native | `todowrite` | `TodoList` | `write_todos` | `todo` | optional task tool/Markdown | task artifact |
| Web/Browser verify | Playwright | Playwright | Playwright | Playwright/Chrome | Playwright | Playwright | `chrome-devtools` MCP / Playwright |
| Hỏi user | native | native | `AskUserQuestion` | `ask_user` | native | terminal/dialogue | `ask_question` / native |

Bảng trên thể hiện mapping được ghi trong source; tool thực tế luôn cần đối chiếu với phiên bản harness đang chạy vì native tool inventory có thể thay đổi. Browser/Playwright/Chrome DevTools MCP trong bảng là capability hỗ trợ; chỉ dùng khi acceptance criteria của task yêu cầu browser behavior, không ép task không liên quan web phải cài hoặc gọi browser.

## 7. Kiểm thử và bằng chứng trong repository

Project có nhiều lớp test để kiểm tra không chỉ file tồn tại mà cả behavior runtime:

### 7.1. Hook bootstrap

`tests/hooks/test-session-start.sh` kiểm tra:

- `hooks.json` đăng ký `shell: "bash"` và command đúng;
- Claude output có nested `hookSpecificOutput.additionalContext`;
- Cursor chỉ có `additional_context`;
- Copilot CLI chỉ có `additionalContext`;
- wrapper gọi đúng extensionless `session-start`;
- context không còn cảnh báo legacy path cũ.

### 7.2. Claude Code skill/workflow

`tests/claude-code/` chạy Claude CLI headless, có fast test và integration test. Nội dung kiểm tra gồm skill loading, thứ tự spec compliance trước code quality, self-review, đọc plan hiệu quả, review loop, worktree policy và workflow SDD end-to-end.

`tests/explicit-skill-requests/` kiểm tra khi user gọi đích danh một skill thì `Skill` tool được trigger trước tool hành động khác; đây là kiểm tra chống premature action.

### 7.3. OpenCode

`tests/opencode/` kiểm tra plugin loading, skill directory discovery, native `skill` tool, personal/project/bundled skill và bootstrap caching. Test cache yêu cầu:

- file có thì chỉ đọc một lần nhưng các message array mới vẫn nhận bootstrap;
- file thiếu thì kết quả `null` cũng được cache;
- bootstrap dùng mapping mới (`task`/`apply_patch`), không chứa mapping cũ.

### 7.4. Pi và Hermes

- `tests/pi/test-pi-extension.mjs` kiểm tra package metadata, lifecycle handler, resource discovery, startup injection, chống duplicate, xử lý compaction và mapping docs.
- `tests/hermes/test_plugin.py` và `test_bootstrap.py` kiểm tra registration toàn bộ skill, layout clone/flat, lỗi missing skills, first-turn-only injection, frontmatter stripping, mapping nguồn và giới hạn context.

### 7.5. Manifest và tool mapping

Các test `tests/codex`, `tests/kimi`, `tests/devin` và `tests/antigravity` kiểm tra manifest không dùng field sai, version đồng nhất, Codex suppress hook auto-discovery, archive chứa đúng skill/metadata và mapping harness-specific tồn tại.

`tests/brainstorm-server/` kiểm tra server visual companion: auth/session key, HTTP, WebSocket, lifecycle, file watching, browser launcher, branding và Windows lifecycle.

### 7.6. Workflow invariants cho readiness và nghiệm thu

`tests/writing-skills/test-workflow-invariants.sh` là regression test tĩnh cho các quy tắc behavior-shaping mới. Test kiểm tra:

- readiness tổng quát theo capability và Task 0 `N/A` branch;
- stop condition khi human gate/capability bắt buộc chưa sẵn sàng, không fallback hoặc invent credential;
- real-integration-first cùng mock policy tại deliberate seams;
- browser verification chỉ bắt buộc khi acceptance criteria có browser behavior, dùng `0 unexpected console errors` và review warning riêng;
- self-review phải sửa plan trước handoff và SDD phải giữ hard gate.

Test này bảo vệ các invariant xuyên nhiều skill; nó bổ sung cho pressure/eval testing hành vi agent, không thay thế eval live.

## 8. Nhận xét kiến trúc và điểm cần lưu ý

### Điểm mạnh

- **Tách behavior khỏi runtime:** skill Markdown có thể tái sử dụng trên nhiều agent/harness.
- **Bootstrap nhỏ theo vai trò:** chỉ `using-superpowers` được inject sớm; các skill khác nạp on-demand, giảm context bloat.
- **Adapter có chủ đích:** mỗi harness dùng cách native của nó thay vì ép mọi nơi chạy cùng một shell hook.
- **Evidence-driven:** verification, TDD, debugging và review đều có hard gate hoặc output contract.
- **Cross-platform:** polyglot dispatcher, extensionless hook và test riêng cho format JSON/Windows giảm lỗi môi trường.
- **Khả năng phục hồi context:** Pi có reinject sau compaction; SDD dùng ledger; OpenCode cache bootstrap nhưng vẫn inject cho message array mới.

### Rủi ro/vận hành cần nhớ

1. **Thiếu Bash trên Windows:** hook vẫn exit thành công nhưng bootstrap SessionStart bị bỏ qua. Khi đó skill có trên disk nhưng agent có thể không được giới thiệu bootstrap.
2. **Hook không đồng nghĩa skill auto-trigger ở mọi harness:** Kimi/Gemini/Codex/Devin chủ yếu dựa vào native manifest/context/skill discovery; không nên giả định `hooks/session-start` luôn chạy.
3. **Trùng tên skill trong OpenCode:** test hiện tại ghi nhận bundled skill có thể shadow local skill tùy behavior native. Nên tránh đặt skill custom trùng tên Superpowers nếu chưa kiểm tra priority.
4. **Capability optional:** Pi không có sẵn subagent/todo chuẩn; workflow SDD phải degrade rõ ràng thay vì bịa tool.
5. **Context size:** Hermes có giới hạn spill 10.000 ký tự; thay đổi bootstrap hoặc mapping phải giữ test giới hạn này.
6. **Skill là behavior code:** sửa nội dung skill có thể thay đổi quyết định của agent. Theo `CLAUDE.md` và `writing-skills`, không nên reword/restructure tùy tiện nếu chưa có pressure/eval evidence.
7. **Không tự coi test report là bằng chứng:** `verification-before-completion` yêu cầu chạy verification mới và đọc output thực tế trước khi claim hoàn tất.
8. **Readiness không chỉ là database:** Task 0 phải phản ánh mọi capability bắt buộc — runtime, dependencies, services, browser/tooling, MCP, credentials, permissions, network và data state — với exact verification hoặc lý do `N/A`; không được tiếp tục khi human gate còn thiếu.

## 9. Kết luận

Superpowers không chỉ là một thư mục prompt. Đây là một hệ thống gồm:

- **14 skill quy trình** tạo thành methodology từ brainstorm → isolate → plan → TDD/debug → implement/review → verify → finish;
- **bootstrap `using-superpowers`** làm luật điều phối chung;
- **hook/adapter runtime** để đưa bootstrap và skill discovery vào đúng lifecycle của từng harness;
- **tool mapping** để instruction trừu tượng không bị khóa vào tên tool của một sản phẩm;
- **test/eval infrastructure** để kiểm tra cả cấu hình lẫn hành vi của agent.

Nếu cần mở rộng project, điểm mở rộng an toàn nhất là giữ `skills/<name>/SKILL.md` độc lập, thêm reference/tool mapping chỉ khi harness mới thực sự cần, và xây test integration chứng minh bootstrap được nạp ở phiên sạch. Một integration được coi là hoàn chỉnh khi prompt acceptance kiểu “Let's make a react todo list” khiến `brainstorming` được load trước khi code được viết, thay vì chỉ đơn giản copy file skill vào filesystem.

## 10. Danh sách file tham chiếu chính

- `README.md`
- `CLAUDE.md`
- `package.json`
- `skills/*/SKILL.md`
- `skills/using-superpowers/references/*.md`
- `skills/brainstorming/visual-companion.md`
- `skills/subagent-driven-development/*-prompt.md`
- `skills/subagent-driven-development/scripts/*`
- `hooks/hooks.json`
- `hooks/hooks-cursor.json`
- `hooks/session-start`
- `hooks/run-hook.cmd`
- `.opencode/plugins/superpowers.js`
- `.pi/extensions/superpowers.ts`
- `.hermes-plugin/__init__.py`
- `.hermes-plugin/plugin.yaml`
- `.kimi-plugin/plugin.json`
- `.codex-plugin/plugin.json`
- `.devin-plugin/plugin.json`
- `gemini-extension.json`
- `GEMINI.md`
- `docs/windows/polyglot-hooks.md`
- `tests/hooks/`
- `tests/claude-code/`
- `tests/opencode/`
- `tests/pi/`
- `tests/hermes/`
- `tests/brainstorm-server/`
