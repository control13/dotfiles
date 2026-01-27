#!/usr/bin/env bash
SERVICE=$(python ~/.config/sway/cheatsheet list | fuzzel --dmenu --prompt="Select cheatsheet:")
if [[ -n "$SERVICE" ]]; then
  ~/.config/sway/cheatsheet "$SERVICE"
fi
