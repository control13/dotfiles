#!/bin/sh
# Roll back install-lid-guard.sh. Restores the mkinitcpio.conf backup it names, removes the
# lid-boot-guard files and rebuilds the initramfs. Run this if the docked boot test goes wrong.

set -u

if [ "$(id -u)" -ne 0 ]; then
    echo "must run as root" >&2
    exit 1
fi

echo "==> disabling lid-boot-guard.service"
systemctl disable --now lid-boot-guard.service 2>/dev/null || true

echo "==> removing files"
rm -f /etc/systemd/system/lid-boot-guard.service
rm -f /usr/local/bin/lid-boot-guard-release
rm -f /etc/udev/rules.d/71-lid-boot-guard.rules
rm -f /run/lid-boot-guard-done

systemctl daemon-reload
udevadm control --reload-rules

echo "==> restoring the lid switch tag for the running session"
udevadm trigger --action=change --subsystem-match=input --attr-match=name="Lid Switch" || true
sleep 1
udevadm info /sys/class/input/event1 2>/dev/null | grep -E "^E: (CURRENT_)?TAGS"

echo
echo "==> mkinitcpio.conf backups available:"
ls -1t /etc/mkinitcpio.conf.bak-* 2>/dev/null || echo "    (none)"
echo
echo "The lid guard is gone. mkinitcpio.conf was NOT touched -- if you also want amdgpu back"
echo "in MODULES, restore one of the backups above and run: mkinitcpio -P"
