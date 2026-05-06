#!/bin/sh
set -u

log_dir="$HOME/.local/state/waybar"
log_file="$log_dir/supervise.log"
output_event_file="$log_dir/last-output-event-ms"
quiet_period_ms="${WAYBAR_OUTPUT_QUIET_PERIOD_MS:-1500}"
boot_window_ms="${WAYBAR_BOOT_RECOVERY_WINDOW_MS:-30000}"
poll_interval_s="${WAYBAR_BOOT_RECOVERY_POLL_INTERVAL_S:-0.2}"
mkdir -p "$log_dir"

now_ms() {
  date +%s%3N
}

write_output_event_ms() {
  tmp_file="${output_event_file}.tmp"
  printf '%s\n' "$1" > "$tmp_file"
  mv "$tmp_file" "$output_event_file"
}

read_output_event_ms() {
  if ! read -r last_event_ms < "$output_event_file"; then
    printf '0\n'
    return
  fi

  case "$last_event_ms" in
    ''|*[!0-9]*)
      printf '0\n'
      ;;
    *)
      printf '%s\n' "$last_event_ms"
      ;;
  esac
}

wait_for_quiet_outputs() {
  last_event_ms=$(read_output_event_ms)
  idle_ms=$(( $(now_ms) - last_event_ms ))

  if [ "$idle_ms" -ge "$quiet_period_ms" ]; then
    return 0
  fi

  return 1
}

cleanup() {
  :
}

trap cleanup EXIT HUP INT TERM

start_ms="$(now_ms)"
end_ms=$(( start_ms + boot_window_ms ))
last_handled_event_ms=0
last_recovery_attempt_ms=0

write_output_event_ms "$start_ms"
echo "=== $(date --iso-8601=seconds) boot recovery start ===" >> "$log_file"

while [ "$(now_ms)" -lt "$end_ms" ]; do
  last_event_ms="$(read_output_event_ms)"

  if ! wait_for_quiet_outputs; then
    sleep "$poll_interval_s"
    continue
  fi

  if pgrep -x waybar >/dev/null 2>&1; then
    if [ "$last_event_ms" -ne "$last_handled_event_ms" ]; then
      echo "--- $(date --iso-8601=seconds) waybar still running after quiet period; no restart ---" >> "$log_file"
      last_handled_event_ms="$last_event_ms"
    fi
  else
    current_ms="$(now_ms)"
    if [ $(( current_ms - last_recovery_attempt_ms )) -lt "$quiet_period_ms" ]; then
      sleep "$poll_interval_s"
      continue
    fi

    echo "--- $(date --iso-8601=seconds) waybar missing after quiet period; launching recovery instance ---" >> "$log_file"
    waybar >> "$log_file" 2>&1 &
    waybar_pid=$!
    last_recovery_attempt_ms="$current_ms"
  fi

  sleep "$poll_interval_s"
done

echo "--- $(date --iso-8601=seconds) boot recovery window ended ---" >> "$log_file"
