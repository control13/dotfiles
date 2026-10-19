---
name: scout
description: Delegate a bounded, non-sensitive task to the external agy agent (Google Antigravity) - research (find relevant files/functions, trace call paths or dependencies, pre-sort error sites, sift many logs, search the web and read public pages or PDFs with sources), an independent critical review of a diff, plan or report as a quality step, or, with --write, a clearly specified edit in a git repo - and get a compact answer back. Use when reading or mechanical editing would cost more than the handoff, or for a blind second opinion before finishing non-trivial work; never for privacy-sensitive data, work mail, trivial lookups or decisions.
---

# Scout / worker (agy)

```
llm-scout --reason <reason> --caller <claude-code|codex|opencode> -C <workspace> "<concrete question>"
llm-scout --reason review --caller <...> -C <workspace> "<what to review: diff, plan, report, file>"
llm-scout --write --reason mechanical_edit --caller <...> -C <git repo> "<exact change, files, constraints>"
```

Presets, one line each (reason and workspace are set; options still apply):

```
llm-scout map [DIR]                     # coarse map of a repo or folder
llm-scout review-diff [RANGE]           # blind review of `git diff RANGE` (default HEAD)
llm-scout summarize FILE|URL [FOCUS]    # summary of a document or web page
llm-scout extract "WHAT" FILE...        # table of WHAT with file and line/page
llm-scout --bg <anything above>         # detached; desktop notice when done
llm-scout --result [JOB]                # answer of a job (exit 75 = still running)
```

Documents: anything outside the vault and outside mail is fine to summarize or extract. Vault
files, mail and transcripts never go to the scout; the command refuses marked paths per file.

`--reason` (logged for statistics; pick the closest, default `other`):
`repo_search` find files, functions, dependencies, code paths · `bulk_extract` extract/structure many
similar items from large context · `log_analysis` search or pre-sort logs, errors, diagnostics output ·
`mechanical_edit` clearly specified edits via `--write` · `web_research` websites and online
documents (PDFs), e.g. listings, official pages, brochures · `review` independent critical review
of a diff, plan, report or design (read-only, findings by severity) · `other` anything else.

Web research: `llm-scout --reason web_research "<question>"` without `-C` runs agy in an empty temp
directory, so it sees no local files; it searches the web, reads pages/PDFs by URL and cites sources.
The task text itself goes to Google: no personal data (income, documents, contacts), no note contents.

Research mode answers compactly: files with line ranges, findings, open points. Write mode edits
files with agy's file tools, prints agy's change report and then `git status --short`. Both log
metadata only to `~/.local/share/llm-routing/events.jsonl`. In every mode agy may run read-only
terminal commands (`rg`, `fd`, `cat`, `head`, `sed -n`, `awk`, `git log/show/diff/blame`, …;
list in `ALLOWED_COMMANDS` of llm_routing.py, mirrored in `~/.gemini/antigravity-cli/settings.json`).
sed and awk could write; the prompt limits them to reading. Any other command ends its turn
without an answer; it cannot run tests, builds or pipes.

Use it when:
- many files, logs or call paths must be read before a change, and the answer is checkable; or
- several public web pages or PDFs must be searched and read, and the answer can be sourced; or
- an edit is large, mechanical and fully specified (roughly 50+ lines or several files: series of
  similar changes, boilerplate, tests after an existing pattern). Subtle logic, security and small
  edits stay with you: in the 2026-10-19 pilot agy got the logic right but skipped the test and
  used abbreviated names, so the review cost about as much as writing it. `--write` works only
  under `~/programming` (agy's write allowlist); or
- a non-trivial analysis starts: run a scout in the background as a coarse map while you read
  yourself, then compare; it finds places you would not have looked at; or
- a non-trivial analysis, report, plan or code change is about to be finished: get a blind second
  opinion or a `review`, even when the context is already loaded. This is a quality step, not a
  time saver.

Models and quota: the default is Gemini 3.8 Flash; its quota is ample (a dozen large calls used
~3 % of the weekly limit), so use the scout freely. `--model claude-sonnet-5-5-high` was faster
and more complete on a repo question, but one call costs ~6 % of the weekly Claude/GPT limit:
use it for important reviews and precision questions, about five to ten calls a week (a Flash
review costs ~0.1–0.2 % of the Gemini week; measured 2026-10-19). `agy -p /quota` shows what is left; every call also logs it as
`quota_remaining`. Gemini Pro is not available headless.

Do not use it for:
- privacy-sensitive projects, work mail, personal data, credentials. External provider (Google).
  The command refuses in `opencode-work`, below `~/.local/share/thunderbird-miyo`, below any
  directory containing a `.no-external-llm` file, and `--write` outside a git work tree.
  A refusal is final; do not work around it.
- trivial one-file lookups or edits, and decisions: a review may criticise a design, but you
  decide.
- tasks where the handoff costs more than doing it (a narrow question takes ~20–90 s, a broad
  analysis several minutes).

Ask blind: give the scout the question or the object to review, not your findings, paths or
guesses. It finds relevant places you did not look at; it does not save the time of checking them.

Writing a research question:
- One question per topic. Require `file:line` for every fact and an explicit "not found".
- Add: "Cite the line where the symbol or value is defined, not a header or comment line."
- For configuration: "State the default value and whether it is enabled."
- "Name a library or algorithm only if the code imports or calls it."
- End with: "List closely related functionality you saw but were not asked about, one line each."

While it runs:
- Output arrives only at the end; an empty output file does not mean it hangs. After `--timeout`
  (default 300 s) or a denied command, llm-scout asks agy once more, in the same conversation, to
  answer with what it has (up to 120 s more). agy reports a timeout as SUCCESS with partial
  text; llm-scout detects that and asks too. So a run ends after at most about 7 minutes; do not
  stop it earlier, and do not raise the timeout without reason.
- A narrow question takes about 1 minute, a broad analysis or review 3–5 minutes. Prefer several
  narrow questions over one broad multi-topic task; name the scope of a review exactly.
- Start longer runs in the background and keep working; foreground calls started together may
  run one after another. Without a background feature of your own (Codex, OpenCode) use `--bg`.
- For important reviews run Flash and `--model claude-sonnet-5-5-high` in parallel: Flash found
  agy-specific bugs, Sonnet the security issues in the same commit.
- Claude Code reminds you via a PostToolUse hook after ten reading tool calls without a scout.

Afterwards:
- Research answers are leads, not facts: open the named locations yourself before relying on them.
  Line numbers are a starting point; symbol and class names can be slightly wrong. Never adopt
  judgements such as "deployed", "works", "active" or "default" unchecked; config lists often
  omit that a feature is off.
- Treat review findings as arguments: accept or reject each one with a reason.
- After `--write`: review `git diff` yourself and run the tests yourself; agy cannot run tests.
  Revert what is wrong instead of patching around it.
- If it fails (non-zero exit), report that and continue without it; do not retry in a loop.
