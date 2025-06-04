#!/usr/bin/env bash
if pgrep swayidle; then killall -9 swayidle; fi
swayidle "$@" &
