#!/usr/bin/env fish

set -l max 10

set -l ws_json (swaymsg -t get_workspaces 2>/dev/null); or exit 0

set -l current (echo $ws_json | jq -r '.[] | select(.focused==true) | .num' | head -n 1)
test -n "$current"; or exit 0

# If current isn't 1..10, treat it like "before 1"
if test $current -lt 1 -o $current -gt $max
    set current 0
end

# Numbers of existing workspaces in 1..10
set -l used (echo $ws_json | jq -r ".[] | select(.num>=1 and .num<=$max) | .num")

# Search forward (current+1..10)
if test $current -lt $max
    for n in (seq (math $current + 1) $max)
        if not contains -- $n $used
            swaymsg "workspace number $n" >/dev/null
            exit 0
        end
    end
end

# Wrap (1..current-1)
if test $current -gt 1
    for n in (seq 1 (math $current - 1))
        if not contains -- $n $used
            swaymsg "workspace number $n" >/dev/null
            exit 0
        end
    end
end

# All 1..10 exist -> do nothing
exit 0
