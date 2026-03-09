# Global Codex Instructions

## Communication
- Reply in German and use "du".
- Be concise and structured.
- Use headings and bullet points.
- Use tables for comparisons when helpful.
- If critical information is missing, ask up to 3 focused questions.
- If uncertainty remains, state assumptions explicitly.

## Code Style
- Write code, comments, docstrings, commit messages, and identifiers in English unless I explicitly request otherwise.
- Prefer clean, readable, maintainable code over clever or overly abstract solutions.
- Prefer small, focused changes that fit the existing architecture.
- Preserve public APIs unless a change is explicitly requested.
- Avoid unnecessary renames, file moves, and broad refactors.

## Defaults
- Prefer Python for automation, scripting, data processing, and quick prototypes.
- Prefer fish for interactive shell commands.
- Prefer bash/sh with shebang for portable scripts.
- Prefer open-source tools and standard formats.

## Tooling Preferences
- Prefer Arch Linux friendly CLI tools when suitable:
  git, fd, rg, rsync, ffmpeg, magick, pdfjam, helix, yay/pacman, yadm, yazi, zoxide, bat, kitty.

## Safety and Change Management
- Before destructive actions (rm, overwrite, mass edit, schema changes), warn first and offer:
  - a dry-run,
  - a preview,
  - or a diff.
- Before adding new dependencies, justify why they are needed.
- Prefer minimal dependency growth.

## Problem Solving
- For debugging:
  1. identify likely root causes first,
  2. propose the smallest useful diagnostic step,
  3. then suggest the smallest reasonable fix.
- For non-trivial implementation tasks:
  1. state assumptions,
  2. propose a short plan,
  3. implement,
  4. mention risks / edge cases,
  5. suggest validation steps.

## Quality
- Prefer reproducibility, explicit error handling, clear naming, and testability.
- Keep changes review-friendly.
- Mention version-sensitive assumptions for libraries, tools, and APIs.

## Robotics / AI / Scientific Code
- Be careful with:
  - numerical stability,
  - units,
  - coordinate frames,
  - timestamps,
  - randomness / seeds,
  - simulation vs hardware boundaries.
- Call out hidden assumptions and likely failure modes.
- Suggest validation through tests, logs, metrics, or benchmark scripts.
- Do not modify hardware-critical control paths unless explicitly requested.

## in Plan-Mode
Do not change Code. Only describe your solution and list files to be changed.

## Change discipline
- Prefer minimal diffs; avoid drive-by refactors.
- Do not add new dependencies unless explicitly required; if needed, explain why.
- Keep public APIs stable unless the spec says otherwise.
