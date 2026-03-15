# Global Claude Code Instructions

## About Me
- Researcher and lecturer in Robotics & ML (HTWK Leipzig)
- Expert in Python, ML/DL, C++, computer vision
- I know what I'm doing — skip beginner explanations unless I ask

## Communication
- Reply in German, use "du"
- Code, comments, docstrings, commit messages, and identifiers always in English
- Be concise and direct; prefer structured answers with headings and bullet points
- Use tables for comparisons
- State assumptions explicitly when uncertain

## Workflow: Unclear Requirements
1. Ask focused clarifying questions (try 3, but more if necessary) before doing anything
2. Propose a short plan and wait for confirmation
3. Implement only after explicit approval

## Plan Mode
Do not change any code. Only describe the solution and list files to be changed.

## Code Style
- Clean, readable, maintainable over clever or abstract
- Small, focused changes that fit the existing architecture
- Preserve public APIs unless change is explicitly requested
- Avoid unnecessary renames, file moves, and broad refactors
- Prefer minimal diffs; no drive-by refactors

## Python Defaults
- Python 3.14+
- Docstrings in NumPy style
- argparse for CLI tools (no click unless already in project)
- Standard stack: PyTorch / Lightning, NumPy / SciPy / OpenCV, matplotlib, soundfile
- Always use `.venv` for virtual environments (`python -m venv .venv`)
- Always maintain a `requirements.txt`; pin versions explicitly

## ROS / ROS2
- Do NOT suggest, use, or assume ROS/ROS2 unless I explicitly ask for it
- This applies to build systems (colcon, ament), message types, and node patterns

## Shell & Tooling
- fish for interactive commands
- bash/sh with shebang for portable scripts
- Prefer Arch Linux CLI tools where suitable:
  git, fd, rg, rsync, ffmpeg, magick, pdfjam, helix, yay/pacman, yadm, yazi, zoxide, bat, kitty
- Prefer open-source tools and standard formats

## Git
- Commit messages: imperative style ("Add feature X", "Fix memory leak in loader")
- No conventional commits prefix unless repo already uses them
- Keep commits small and review-friendly

## Dependency Management
- Do not add new dependencies unless explicitly required
- If a new dependency is needed, justify it before adding

## Safety & Change Management
- Before destructive actions (rm, overwrite, mass edit, schema changes):
  - warn first
  - offer a dry-run, preview, or diff
- Do not touch hardware-critical control paths unless explicitly requested

## Debugging Protocol
1. Identify likely root causes first
2. Propose the smallest useful diagnostic step
3. Suggest the smallest reasonable fix

## Implementation Protocol (non-trivial tasks)
1. State assumptions
2. Propose a short plan → wait for confirmation
3. Implement
4. Mention risks and edge cases
5. Suggest validation steps (tests, logs, metrics, benchmarks)

## Robotics / ML / Scientific Code
Pay special attention to:
- Numerical stability
- Units and coordinate frames
- Timestamps and synchronization
- Randomness / seeds (reproducibility first)
- Simulation vs. hardware boundaries

Always:
- Call out hidden assumptions and likely failure modes
- Suggest validation through tests, logs, or benchmark scripts
- Do not modify hardware-critical control paths unless explicitly requested

## C++ Defaults
- Standard: C++17
- Compiler: prefer clang; gcc is acceptable, never mix within a project
- Build system: CMake; use `cmake -B build -G Ninja` if Ninja is available, otherwise default generator
- Typical CMakeLists.txt structure:
  - `cmake_minimum_required(VERSION 3.16)`
  - `set(CMAKE_CXX_STANDARD 17)` + `set(CMAKE_CXX_STANDARD_REQUIRED ON)`
  - Separate `add_executable` / `add_library` + `target_include_directories` + `target_link_libraries`
- Linear algebra: Eigen3 (find via `find_package(Eigen3 REQUIRED)`)
- Code style: enforce via clang-format and clang-tidy; respect existing `.clang-format` / `.clang-tidy` if present
- No raw owning pointers; prefer `std::unique_ptr` / `std::shared_ptr`
- No `using namespace std;` in headers
- Error handling: prefer return values / `std::optional` / exceptions consistently within the project; do not mix styles
- use cxxopts for command line argument parsing (https://github.com/jarro2783/cxxopts)
- Do not add dependencies beyond Eigen unless explicitly requested

## README (only when explicitly asked)
When I ask for a README, structure it as follows:
1. **One-paragraph summary** — what the program does and why
2. **Requirements** — OS, compiler/runtime version, all libraries that must be installed (with install hints)
3. **Build** — exact commands to build from a clean checkout
4. **Usage** — minimal working example; all relevant flags/arguments explained
5. **Optional sections** (only if content exists): Configuration, Examples, Known Limitations

Keep it factual and concise; no marketing language.

## Quality
- Explicit error handling over silent failures
- Clear naming over abbreviations
- Reproducibility: pin versions, set seeds, document environment assumptions
- Mention version-sensitive assumptions for libraries, tools, and APIs
- Keep changes review-friendly
