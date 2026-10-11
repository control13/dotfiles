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
- an edit is mechanical and fully specified (series of similar changes, boilerplate, tests after an
  existing pattern), so writing the instruction is cheaper than doing it; or
- a non-trivial analysis, report, plan or code change is about to be finished: get a blind second
  opinion or a `review`, even when the context is already loaded. This is a quality step, not a
  time saver.

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
  answer with what it has (up to 120 s more). So a run ends after at most about 7 minutes; do not
  stop it earlier, and do not raise the timeout without reason.
- A narrow question takes about 1 minute, a broad analysis or review 3–5 minutes. Prefer several
  narrow questions over one broad multi-topic task; name the scope of a review exactly.
- Start longer runs in the background and keep working; foreground calls started together may
  run one after another.

Afterwards:
- Research answers are leads, not facts: open the named locations yourself before relying on them.
  Line numbers are a starting point; symbol and class names can be slightly wrong. Never adopt
  judgements such as "deployed", "works", "active" or "default" unchecked; config lists often
  omit that a feature is off.
- Treat review findings as arguments: accept or reject each one with a reason.
- After `--write`: review `git diff` yourself and run the tests yourself; agy cannot run tests.
  Revert what is wrong instead of patching around it.
- If it fails (non-zero exit), report that and continue without it; do not retry in a loop.
