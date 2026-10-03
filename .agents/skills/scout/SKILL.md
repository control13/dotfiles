---
name: scout
description: Delegate a bounded, non-sensitive task to the external agy agent (Google Antigravity) - research (find relevant files/functions, trace call paths or dependencies, pre-sort error sites, sift many logs) or, with --write, a clearly specified edit in a git repo - and get a compact answer back. Use when reading or mechanical editing would cost more than the handoff; never for privacy-sensitive data, work mail, trivial lookups or decisions.
---

# Scout / worker (agy)

```
llm-scout --reason <reason> --caller <claude-code|codex|opencode> -C <workspace> "<concrete question>"
llm-scout --write --reason mechanical_edit --caller <...> -C <git repo> "<exact change, files, constraints>"
```

`--reason` (logged for statistics; pick the closest, default `other`):
`repo_search` find files, functions, dependencies, code paths · `bulk_extract` extract/structure many
similar items from large context · `log_analysis` search or pre-sort logs, errors, diagnostics output ·
`mechanical_edit` clearly specified edits via `--write` · `other` anything else worth delegating.

Research mode answers compactly: files with line ranges, findings, open points. Write mode edits
files with agy's file tools, prints agy's change report and then `git status --short`. Both log
metadata only to `~/.local/share/llm-routing/events.jsonl`.

Use it when:
- many files, logs or call paths must be read before a change, and the answer is checkable; or
- an edit is mechanical and fully specified (series of similar changes, boilerplate, tests after an
  existing pattern), so writing the instruction is cheaper than doing it.

Do not use it for:
- privacy-sensitive projects, work mail, personal data, credentials. External provider (Google).
  The command refuses in `opencode-work`, below `~/.local/share/thunderbird-miyo`, below any
  directory containing a `.no-external-llm` file, and `--write` outside a git work tree.
  A refusal is final; do not work around it.
- trivial one-file lookups or edits, architecture decisions, anything needing judgement.
- tasks where the handoff costs more than doing it (a call takes ~20–90 s).

Afterwards:
- Research answers are leads, not facts: open the named locations yourself before relying on them.
- After `--write`: review `git diff` yourself and run the tests yourself; agy cannot run commands.
  Revert what is wrong instead of patching around it.
- If it fails (non-zero exit), report that and continue without it; do not retry in a loop.
