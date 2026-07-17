#!/bin/sh
# Step 1 + 2 of the docked-boot fix:
#   1. take amdgpu back out of the initramfs, so the LUKS prompt returns to the external monitor
#   2. install the lid-boot-guard, so logind stops misreading a docked boot as undocked
#
# Fails closed: if the udev rule does not behave exactly as intended, the rule is removed again
# before the machine can reboot with a lid switch that never reaches logind.

set -u

src=$(cd "$(dirname "$0")" && pwd)
conf=/etc/mkinitcpio.conf
flag=/run/lid-boot-guard-done

if [ "$(id -u)" -ne 0 ]; then
    echo "must run as root" >&2
    exit 1
fi

for f in 71-lid-boot-guard.rules lid-boot-guard-release lid-boot-guard.service; do
    if [ ! -f "$src/$f" ]; then
        echo "missing $src/$f" >&2
        exit 1
    fi
done

# logind watches the event device, so its tags are the ones that matter. Locate it via the
# parent's name attribute -- eventN has no "name" of its own.
lid_dev=""
for d in /sys/class/input/event*; do
    [ "$(cat "$d/device/name" 2>/dev/null)" = "Lid Switch" ] || continue
    lid_dev=$d
    break
done

if [ -z "$lid_dev" ]; then
    echo "no lid event device found" >&2
    exit 1
fi

# Fire a real change event on that exact device. --attr-match=name="Lid Switch" would match the
# inputN parent instead and leave eventN's database untouched -- a silent no-op.
trigger_lid() {
    udevadm trigger --action=change "$lid_dev" || true
    sleep 1
}

# Check the applied database, not a udevadm test simulation, and check CURRENT_TAGS rather than
# TAGS: "-=" only removes from the current set. TAGS is sticky and never shrinks, so testing it
# would report failure no matter how well the rule works.
tags_now() {
    udevadm info "$lid_dev" 2>/dev/null | grep -E "^E: (CURRENT_)?TAGS=" | tr '\n' ' '
}

has_current_tag() {
    udevadm info "$lid_dev" 2>/dev/null | grep -q "^E: CURRENT_TAGS=.*power-switch"
}

# --- 0. protect the running session ------------------------------------------------------
# The rule strips the tag whenever the flag is absent. Set it before the rule exists, so the
# session you are sitting in keeps normal lid handling no matter what happens below.

touch "$flag"
echo "==> $flag set: the running session keeps its lid switch"
echo

# --- 1. amdgpu out of MODULES ------------------------------------------------------------

echo "=== step 1: mkinitcpio"
current=$(grep -n "^MODULES=" "$conf")
echo "    current: $current"

if echo "$current" | grep -q "^7:MODULES=()$"; then
    # The config can already be right while the built image is stale -- an earlier run rewrote
    # the file and then aborted before mkinitcpio. Trust the image, not the config.
    echo "    already reverted; checking whether the built image matches"
    if lsinitcpio /boot/initramfs-linux.img 2>/dev/null | grep -q amdgpu; then
        echo "    image still contains amdgpu -> rebuild needed"
        rebuild=yes
    else
        echo "    image is clean, nothing to do"
        rebuild=no
    fi
elif echo "$current" | grep -q "MODULES=(amdgpu)"; then
    backup="$conf.bak-$(date +%Y%m%d-%H%M%S)"
    cp -a "$conf" "$backup"
    echo "    backed up to $backup"

    sed -i 's/^MODULES=(amdgpu)$/MODULES=()/' "$conf"

    if ! grep -q "^MODULES=()$" "$conf"; then
        echo "    FAILED to rewrite MODULES, restoring backup" >&2
        cp -a "$backup" "$conf"
        exit 1
    fi

    echo "    diff:"
    diff -u "$backup" "$conf" | sed 's/^/      /' || true
    rebuild=yes
else
    echo "    unexpected MODULES line, refusing to touch it" >&2
    exit 1
fi
echo

# --- 2. lid-boot-guard -------------------------------------------------------------------

echo "=== step 2: lid-boot-guard"

if ! udevadm verify "$src/71-lid-boot-guard.rules" >/dev/null 2>&1; then
    echo "    udev rule fails verification, aborting" >&2
    udevadm verify "$src/71-lid-boot-guard.rules"
    exit 1
fi
echo "    udev rule verified"

install -m 644 "$src/71-lid-boot-guard.rules" /etc/udev/rules.d/71-lid-boot-guard.rules
install -m 755 "$src/lid-boot-guard-release" /usr/local/bin/lid-boot-guard-release
install -m 644 "$src/lid-boot-guard.service" /etc/systemd/system/lid-boot-guard.service
echo "    files installed"

systemctl daemon-reload
systemctl enable lid-boot-guard.service >/dev/null 2>&1
udevadm control --reload-rules
echo "    service enabled, rules reloaded"
echo

# --- 3. prove the rule does what it claims -----------------------------------------------
# Both directions matter, and the second one more: a rule that never strips the tag is merely
# useless, but a release path that cannot hand it back leaves the lid dead for the session.
# Everything below fires real udev events and reads the resulting database.

abort_guard() {
    echo "      $1" >&2
    echo "      Removing the rule so the next boot behaves as it does today." >&2
    rm -f /etc/udev/rules.d/71-lid-boot-guard.rules
    udevadm control --reload-rules
    touch "$flag"
    trigger_lid
    if has_current_tag; then
        echo "      lid switch restored for this session." >&2
    else
        echo "      lid switch NOT restored -- reboot to rebuild the udev database in /run." >&2
    fi
    exit 1
}

echo "=== verification (device: $lid_dev)"

echo "    flag present -- logind must SEE the switch:"
trigger_lid
echo "      $(tags_now)"
has_current_tag || abort_guard "BROKEN: current tag missing while the flag is set."
echo "      ok: power-switch present"

rm -f "$flag"
echo "    flag absent (boot state) -- logind must NOT see the switch:"
trigger_lid
echo "      $(tags_now)"
if has_current_tag; then
    abort_guard "BROKEN: current tag survived without the flag, the guard would do nothing."
fi
echo "      ok: power-switch withheld (sticky TAGS still lists it, which is expected)"

# Now exercise the exact code that runs at boot, rather than trusting it. With the lid open it
# releases at once; with the lid shut and nothing external attached it takes its 40s timeout.
echo "    running the real release script to hand the switch back:"
if ! /usr/local/bin/lid-boot-guard-release; then
    abort_guard "BROKEN: lid-boot-guard-release exited non-zero."
fi
echo "      $(tags_now)"
has_current_tag || abort_guard "BROKEN: release ran but the current tag did not come back."
echo "      ok: release works end to end"
echo

# --- 4. rebuild the initramfs ------------------------------------------------------------

if [ "$rebuild" = yes ]; then
    echo "=== step 3: mkinitcpio -P"
    if ! mkinitcpio -P; then
        echo "    mkinitcpio FAILED -- do not reboot until this is fixed" >&2
        exit 1
    fi
    echo
fi

echo "=== final check"

# Read the listing once and make sure it actually produced something. An lsinitcpio that fails
# pipes nothing into grep, which then reports 0 matches -- the same value that means success.
listing=$(lsinitcpio /boot/initramfs-linux.img 2>/dev/null)
if [ -z "$listing" ]; then
    echo "    could not read /boot/initramfs-linux.img -- cannot confirm amdgpu is gone" >&2
    exit 1
fi

n=$(echo "$listing" | grep -c amdgpu)
echo "    initramfs entries: $(echo "$listing" | wc -l), of them amdgpu: $n (want 0)"
if [ "$n" -ne 0 ]; then
    echo "    amdgpu is still in the initramfs -- the LUKS prompt will stay on the laptop panel" >&2
    exit 1
fi

echo "    lid-boot-guard.service: $(systemctl is-enabled lid-boot-guard.service 2>&1)"
echo "    ath12k-recover.service: $(systemctl is-enabled ath12k-recover.service 2>&1)"
echo
echo "Ready. Test in two stages -- the first one settles whether this approach works at all."
echo
echo "  1. Reboot UNDOCKED with the lid OPEN, then:"
echo "       journalctl -b -u systemd-logind | grep -E 'Watching system buttons|New seat'"
echo "       journalctl -b -t lid-boot-guard"
echo
echo "     'Watching system buttons ... event1' at logind startup  -> logind takes the switch"
echo "        despite the withheld tag. The guard cannot work; uninstall it."
echo "     'Watching ...' only after the lid-boot-guard line        -> logind never got the"
echo "        switch at startup. The guard works."
echo
echo "     Runtime evidence says logind will not give a button up once opened, so nothing can"
echo "     be concluded from a lid-close test in a running session -- only from boot."
echo
echo "  2. Only if stage 1 passes: reboot DOCKED with the lid closed. LUKS prompt must appear"
echo "     on the external monitor, and 'Suspending...' must not appear at all."
