---
description: Global personal coding preferences — always apply to all requests.
applyTo: '**'
---

## Communication
- Reply in German, use "du".
- Keep answers concise: headline + bullets; comparisons as tables.
- If key info is missing, ask clarifying questions (try 3, but more if needed) before doing anything.
- Code, comments, docstrings, commit messages, and identifiers always in English.

## Workflow
- For unclear requirements: ask first, then propose a short plan and wait for confirmation, then implement.
- For non-trivial tasks, structure the response as: (1) assumptions, (2) plan, (3) code change, (4) risks/edge cases, (5) validation steps.
- For debugging: identify likely root causes first, then suggest the smallest useful diagnostic step.
- Before destructive actions (rm, overwrite, mass edits, schema changes): warn and offer a dry-run or diff.

## Code Style
- Clean, readable, maintainable over clever or abstract.
- Minimal changes that fit the existing architecture; no drive-by refactors.
- Preserve public APIs and file structure unless a refactor is explicitly requested.
- Prefer: reproducibility, testability, explicit error handling, clear naming, small focused functions.
- Mention version-sensitive assumptions for libraries, tools, and APIs.
- Do not add dependencies unless clearly needed; justify before adding.

## Python
- Python 3.14+.
- Docstrings in NumPy style.
- argparse for CLI tools (no click unless already in project).
- Standard stack: PyTorch / Lightning, NumPy / SciPy / OpenCV, matplotlib, soundfile.
- Always use `.venv` (`python -m venv .venv`) and maintain a `requirements.txt` with pinned versions.

## ROS / ROS2
- Do NOT suggest, use, or assume ROS/ROS2 unless I explicitly ask for it.
- This applies to build systems (colcon, ament), message types, and node patterns.

## C++
- Standard: C++17.
- Compiler: prefer clang; gcc acceptable; never mix within a project.
- Build: CMake; use `cmake -B build -G Ninja` if Ninja is available.
- CMakeLists.txt: `cmake_minimum_required(VERSION 3.16)`, `CMAKE_CXX_STANDARD 17`, separate targets with `target_include_directories` / `target_link_libraries`.
- Linear algebra: Eigen3 (`find_package(Eigen3 REQUIRED)`).
- CLI argument parsing: cxxopts.
- Code style: clang-format and clang-tidy; respect existing `.clang-format` / `.clang-tidy`.
- No raw owning pointers; prefer `std::unique_ptr` / `std::shared_ptr`.
- No `using namespace std;` in headers.
- No new dependencies beyond Eigen and cxxopts unless explicitly requested.

## Shell & Tooling
- fish for interactive commands; bash/sh with shebang for portable scripts.
- Prefer Arch Linux CLI tools: git, fd, rg, rsync, ffmpeg, magick, pdfjam, helix, yay/pacman, yadm, yazi, zoxide, bat, kitty.
- Prefer open-source tools and standard formats (Markdown, CSV, JSON, WAV/FLAC, PNG, PDF).

## Git
- Commit messages: imperative style ("Add feature X", "Fix memory leak in loader").
- No conventional commits prefix unless the repo already uses them.
- Keep commits small and review-friendly.

## Scientific / Robotics / ML Code
- Be careful with: numerical stability, units, coordinate frames, timestamps, randomness/seeds, simulation vs. hardware boundaries.
- Call out hidden assumptions and likely failure modes.
- Suggest validation via tests, logs, metrics, or benchmark scripts.
- Do not modify hardware-critical control paths unless explicitly requested.

## README (only when explicitly asked)
Structure: (1) one-paragraph summary, (2) requirements with install hints, (3) exact build commands, (4) usage with all flags explained, (5) optional: Configuration, Examples, Known Limitations. Factual and concise; no marketing language.
