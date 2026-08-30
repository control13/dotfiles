#!/bin/sh
# sway on this machine is started by the autologin helper as `autologin tobias sway`,
# without a login shell. sway therefore has no PATH and no locale in its own
# environment, and every child it spawns inherits that gap: fuzzel launches,
# `swaymsg exec`, and .desktop entries all run without them, while `systemd --user`
# services are unaffected because systemd supplies its own defaults.
#
# Concrete breakage this fixes: AppImages (e.g. BambuStudio) resolve `fusermount`
# through $PATH and abort when launched from fuzzel, and apps that pick a UI
# language from the locale fall back to one that is not generated here.
#
# /etc/environment is read by pam_env and already carries this session's other
# variables, so the block goes there. User-writable directories such as
# ~/.local/bin are deliberately kept out: /etc/environment applies to root logins
# too.
#
# Idempotent: re-running leaves an already-patched file untouched.

set -eu

envfile=${ENVFILE:-/etc/environment}
marker='# PATH/locale for the sway session'

if [ ! -w "$(dirname "$envfile")" ] && [ "$(id -u)" -ne 0 ]; then
    echo "must run as root" >&2
    exit 1
fi

if grep -qF "$marker" "$envfile"; then
    echo "already installed in $envfile"
    exit 0
fi

cp -a "$envfile" "$envfile.bak"

cat >> "$envfile" <<'BLOCK'

# PATH/locale for the sway session: sway is started by the autologin helper
# without a login shell, so its children inherit neither. Absolute-path Exec=
# lines still work, but programs resolving helpers via $PATH (e.g. AppImage
# runtimes looking for fusermount) fail when launched from fuzzel.
PATH=/usr/local/sbin:/usr/local/bin:/usr/bin
LANG=de_DE.UTF-8
LC_MESSAGES=en_US.UTF-8
LANGUAGE=en_US:en:C:de_DE:de
BLOCK

echo "patched $envfile (backup: $envfile.bak)"
echo "log out and back in -- pam_env only reads it at login"
