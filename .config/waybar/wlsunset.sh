#!/usr/bin/env bash

if pgrep -x wlsunset >/dev/null 2>&1; then
    pkill -x wlsunset >/dev/null 2>&1
else
    retries=30
    counter=0
    content=""

    while true; do
        if content=$(curl -fsS http://ip-api.com/json/); then
            break
        fi

        counter=$((counter + 1))
        if [ "$counter" -eq "$retries" ]; then
            notify-send wlsunset.sh "Unable to connect to ip-api."
            break
        fi
        sleep 2
    done

    if [ -n "$content" ]; then
        longitude=$(printf '%s' "$content" | jq -r '.lon // empty')
        latitude=$(printf '%s' "$content" | jq -r '.lat // empty')

        if [ -n "$latitude" ] && [ -n "$longitude" ]; then
            wlsunset -t 4300 -l "$latitude" -L "$longitude" >/dev/null 2>&1 &
        else
            notify-send wlsunset.sh "Unable to read coordinates from ip-api."
        fi
    fi
fi

pkill -35 waybar
