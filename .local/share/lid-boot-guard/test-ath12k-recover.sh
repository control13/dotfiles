#!/bin/sh
# Test the ath12k-recover safety net against both reachable failure states.
#
# The real production failure (a suspend racing the QMI firmware handshake) cannot be provoked
# on demand. What is tested here is the invariant the service rests on: no wiphy going in, a
# wiphy coming out. Each case aborts if the failure state was not actually reached -- a test
# that only passes because it broke nothing is worthless.

set -u

src=$(dirname "$0")/ath12k-recover
dst=/usr/local/bin/ath12k-recover
pci_dev=0000:02:00.0
pci_drv=/sys/bus/pci/drivers/ath12k_wifi7_pci

if [ "$(id -u)" -ne 0 ]; then
    echo "must run as root" >&2
    exit 1
fi

wiphy() {
    w=$(ls -A /sys/class/ieee80211 2>/dev/null)
    [ -n "$w" ] && echo "$w" || echo "(none)"
}

wait_wiphy() {
    i=0
    while [ "$i" -lt 25 ]; do
        [ -n "$(ls -A /sys/class/ieee80211 2>/dev/null)" ] && return 0
        sleep 1
        i=$((i + 1))
    done
    return 1
}

# --- install the corrected script, keeping the old one recoverable -----------------------

if [ ! -f "$src" ]; then
    echo "missing $src" >&2
    exit 1
fi

if [ -f "$dst" ]; then
    backup="$dst.bak-$(date +%Y%m%d-%H%M%S)"
    cp -a "$dst" "$backup"
    echo "==> backed up old script to $backup"
fi

install -m 755 "$src" "$dst"
echo "==> installed $dst"
echo

# --- case 1: module fully unloaded -------------------------------------------------------
# This is the state the previous broken test left the machine in, and the one the old guard
# silently ignored. Running it first also doubles as cleanup.

echo "=== case 1: module unloaded"
echo "    before / wiphy: $(wiphy)"

modprobe -r ath12k_wifi7 ath12k 2>/dev/null
if [ -n "$(ls -A /sys/class/ieee80211 2>/dev/null)" ]; then
    echo "    ABORT: could not unload the module, failure state not reached" >&2
    exit 1
fi
echo "    provoked / wiphy: $(wiphy)"

"$dst"
rc=$?

if wait_wiphy; then
    echo "    after / wiphy: $(wiphy)  (rc=$rc)"
    echo "    case 1: PASS"
    case1=pass
else
    echo "    after / wiphy: $(wiphy)  (rc=$rc)"
    echo "    case 1: FAIL"
    case1=fail
fi
echo

# --- case 2: module loaded, PCI device unbound -------------------------------------------
# Closer to the real bug, where the module stays loaded and the device stays present but no
# wiphy ever registers.

echo "=== case 2: module loaded, PCI device unbound"

if [ "$case1" = fail ]; then
    echo "    SKIP: case 1 left no working driver to unbind"
    case2=skip
elif [ ! -d "$pci_drv" ]; then
    echo "    SKIP: $pci_drv not present"
    case2=skip
else
    echo "    before / wiphy: $(wiphy)"

    echo "$pci_dev" > "$pci_drv/unbind" 2>/dev/null
    sleep 2

    if [ -n "$(ls -A /sys/class/ieee80211 2>/dev/null)" ]; then
        echo "    ABORT: unbind did not remove the wiphy, failure state not reached" >&2
        exit 1
    fi
    echo "    provoked / wiphy: $(wiphy)   (module still loaded: $(lsmod | grep -c '^ath12k '))"

    "$dst"
    rc=$?

    if wait_wiphy; then
        echo "    after / wiphy: $(wiphy)  (rc=$rc)"
        echo "    case 2: PASS"
        case2=pass
    else
        echo "    after / wiphy: $(wiphy)  (rc=$rc)"
        echo "    case 2: FAIL"
        case2=fail
    fi
fi
echo

# --- result -------------------------------------------------------------------------------

echo "=== service log"
journalctl -t ath12k-recover --since "-3 min" --no-pager | tail -12
echo

echo "=== final state"
echo "    wiphy:   $(wiphy)"
echo "    nmcli:   $(nmcli -f WIFI-HW,WIFI general 2>/dev/null | tail -1)"
echo "    driver:  $(lspci -k -s "${pci_dev#0000:}" 2>/dev/null | grep -i "in use" || echo '(not bound)')"
echo

if [ "$case1" = pass ] && [ "$case2" != fail ]; then
    echo "PASS: the safety net restores the wireless device. Proceed to install-lid-guard.sh."
    exit 0
fi

echo "FAIL: the safety net did NOT restore the wireless device."
echo "Do not proceed to the lid guard install until this is understood."
exit 1
