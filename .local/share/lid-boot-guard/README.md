# lid-boot-guard

Source copies of two fixes for docked boots on this machine (washburne, ThinkPad + AMD, ath12k
wcn7850). The files here are the originals; everything under `/etc` and `/usr/local` is installed
from them. Verified working 2026-07-17.

## The problem

systemd-logind evaluates the lid switch when it *starts watching* the device
(`button_check_switches()`, `is_edge=false`), which at boot happens before any compositor has
modeset the dock's DisplayPort link. `manager_count_external_displays()` only counts a connector
whose `enabled` sysfs attribute is set, and that needs a modeset no initramfs can perform. So a
docked boot with the lid shut counted zero external displays, was misread as undocked, and
suspended about a second in -- which also killed the in-flight ath12k firmware probe, leaving no
wiphy and no WiFi. Booting undocked always worked, which made this look like a WiFi bug.

`HoldoffTimeoutSec` is documented for exactly this case but does not gate the startup check.
Early KMS (`MODULES=(amdgpu)` in mkinitcpio.conf) cannot fix it either -- it only lights up eDP-1
sooner -- and costs ~35s of initrd plus moves the LUKS prompt onto the closed laptop panel.

## The fix

`71-lid-boot-guard.rules` withholds the `power-switch` tag from the Lid Switch while
`/run/lid-boot-guard-done` is absent, so logind never sees the switch at startup.
`lid-boot-guard-release` (oneshot, via `lid-boot-guard.service`) waits for an external connector to
become `enabled`, then sets the flag and re-triggers the device; logind picks the switch up and
evaluates it with the dock visible. `/run` is empty on every boot, so this re-arms itself.

Every code path in the release script ends in `release()`, including the timeout and the signal
trap: there is no state where the lid stays withheld and the machine cannot suspend.

`ath12k-recover` is an independent safety net that reloads the driver if no wiphy registered. Since
the guard landed it has never had to fire.

## Install

    sudo sh install-lid-guard.sh

That covers the lid guard and reverts `MODULES=(amdgpu)` to `MODULES=()` (rebuilding the
initramfs), but *not* the ath12k safety net. For that:

    sudo install -m 755 ath12k-recover /usr/local/bin/ath12k-recover
    sudo install -m 644 ath12k-recover.service /etc/systemd/system/ath12k-recover.service
    sudo systemctl daemon-reload && sudo systemctl enable ath12k-recover.service

Test it with `sudo sh test-ath12k-recover.sh` (unloads the driver on purpose; run it wired).

Removal: `sudo sh uninstall-lid-guard.sh`. It deliberately leaves `mkinitcpio.conf` alone and
prints the backups it found.

## Testing this: read before touching

**A lid-close in a running session proves nothing.** logind will not surrender a button it has
already opened, so the guard can only be tested by rebooting. Compare the journal:

    journalctl -b -u systemd-logind | grep -E "New seat|Watching system buttons|Suspending"
    journalctl -b -t lid-boot-guard

`Watching system buttons ... event1` in the same second as `New seat seat0` means logind took the
switch despite the withheld tag and the guard is bypassed. Appearing only *after* the
`lid-boot-guard` line is the passing signature.

**`TAG-=` removes only from `CURRENT_TAGS`.** The sticky `TAGS` set never shrinks, so checking
`TAGS` reports failure no matter how well the rule works. Read `CURRENT_TAGS` from `udevadm info`
after a real `udevadm trigger` -- not from `udevadm test`, whose `Properties:` section prints stale
database values.

**Trigger the event device by syspath.** `eventN` has no `name` attribute of its own -- it lives on
the `inputN` parent -- so `udevadm trigger --attr-match=name="Lid Switch"` silently fires on the
parent and leaves `eventN`'s database untouched.
