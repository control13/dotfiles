#!/usr/bin/env bash
player_count=$(playerctl --list-all | wc -l)
if (( player_count < 2)); then
  playerctl play-pause
  exit
fi

PLAYER=$(playerctl --list-all | fuzzel --dmenu)
if [[ -n "$PLAYER" ]]; then
  playerctl --player=$PLAYER play-pause
fi
