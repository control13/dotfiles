#!/bin/bash
# Claude Code status line, styled after the starship prompt in ~/.config/starship.toml:
# directory (bold cyan, "~" for home, truncated to the last 3 components),
# git branch (bold purple, "*" when dirty), then usage figures.
#
# LC_NUMERIC must be C: under de_DE.UTF-8 bash's printf rejects "87.6" as an
# invalid number, prints a warning to stderr and truncates instead of rounding.
export LC_NUMERIC=C

input=$(cat)

# One field per line, not space-separated: directory names here contain spaces
# ("work/htwk/Lehre/Intelligente Systeme"), which word splitting would tear apart.
mapfile -t fields < <(
    printf '%s' "$input" | jq -r '
        [ (.model.display_name // ""),
          (.effort.level // ""),
          (.workspace.current_dir // .cwd // ""),
          (.context_window.used_percentage // ""),
          (.rate_limits.five_hour.used_percentage // ""),
          (.rate_limits.seven_day.used_percentage // "")
        ] | map(if . == "" then "-" else (. | tostring) end) | .[]'
)
model=${fields[0]}
effort=${fields[1]}
dir=${fields[2]}
ctx_used=${fields[3]}
five_hour=${fields[4]}
seven_day=${fields[5]}
[ "$dir" = "-" ] && dir=$PWD

# Home as "~", like starship's directory module.
case "$dir" in
    "$HOME") display=$HOME ;;
    "$HOME"/*) display="~${dir#"$HOME"}" ;;
    *) display=$dir ;;
esac
[ "$display" = "$HOME" ] && display="~"

# Keep only the last few components so the line stays short in deep trees.
readonly max_components=3
IFS='/' read -r -a parts <<<"$display"
components=()
for part in "${parts[@]}"; do
    [ -n "$part" ] && components+=("$part")
done
if ((${#components[@]} > max_components)); then
    display="…"
    for ((i = ${#components[@]} - max_components; i < ${#components[@]}; i++)); do
        display+="/${components[i]}"
    done
fi

# --no-optional-locks keeps this from fighting with a git command the user is running.
branch=""
if git -C "$dir" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null)
    [ -z "$branch" ] && branch=$(git -C "$dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ] && [ -n "$(git -C "$dir" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
        branch+="*"
    fi
fi

cyan_bold=$'\033[1;36m'
purple_bold=$'\033[1;35m'
green_bold=$'\033[1;32m'
dim=$'\033[2m'
reset=$'\033[0m'

segments=()
# Model and reasoning effort first, the way codex shows them. effort.level is
# absent for models without the reasoning parameter, so print the model alone then.
if [ "$model" != "-" ]; then
    if [ "$effort" != "-" ]; then
        segments+=("${green_bold}${model}${reset} ${dim}${effort}${reset}")
    else
        segments+=("${green_bold}${model}${reset}")
    fi
fi
segments+=("${cyan_bold}${display}${reset}")
[ -n "$branch" ] && segments+=("${purple_bold}${branch}${reset}")

# rate_limits only arrive on a Claude.ai subscription, context_window only once a
# response has been generated -- skip whichever is absent rather than print a gap.
add_percentage() {
    local label=$1 value=$2
    [ "$value" = "-" ] && return
    segments+=("${dim}${label}${reset} $(printf '%.0f' "$value")%")
}
add_percentage 5h "$five_hour"
add_percentage 7d "$seven_day"
add_percentage ctx "$ctx_used"

separator="${dim} · ${reset}"
output=""
for segment in "${segments[@]}"; do
    [ -n "$output" ] && output+=$separator
    output+=$segment
done

printf '%s' "$output"
