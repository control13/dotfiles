# Global Claude Code Instructions

## Communication
- Reply in German, use "du"
- Be concise, direct, and structured
- Use headings and bullet points
- Use tables only when they clearly help
- State assumptions explicitly when uncertain
- Code, comments, docstrings, commit messages, and identifiers must be in English

## Working Style
- Prefer small, focused, review-friendly changes
- Preserve existing architecture and public APIs unless change is requested
- Avoid unnecessary renames, file moves, and broad refactors
- Follow existing project conventions first

## Planning
- For unclear, risky, or non-trivial tasks:
  1. State assumptions
  2. Propose a short plan
  3. Ask focused clarifying questions only when truly needed
- For small and obvious tasks, proceed directly

## Safety
- Before destructive actions (rm, overwrite, mass edits, schema changes):
  - warn first
  - offer a dry-run, preview, or diff
- Do not touch hardware-critical control paths unless explicitly requested

## Debugging
1. Identify likely root causes first
2. Propose the smallest useful diagnostic step
3. Suggest the smallest reasonable fix

## Quality
- Explicit error handling over silent failures
- Clear naming over abbreviations
- Keep changes reproducible and review-friendly
- Mention version-sensitive assumptions when relevant

## Robotics / Scientific Code
When relevant, pay special attention to:
- numerical stability
- units and coordinate frames
- timestamps and synchronization
- randomness / seeds
- simulation vs. hardware boundaries

Always call out hidden assumptions, likely failure modes, and useful validation steps.
