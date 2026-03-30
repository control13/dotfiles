# Restore colored man page formatting in less without overriding fish's man function.
# GROFF_NO_SGR makes groff emit overstrike sequences that less maps via LESS_TERMCAP_*.
set -gx GROFF_NO_SGR 1

set -gx LESS_TERMCAP_mb (set_color -o red)
set -gx LESS_TERMCAP_md (set_color -o red)
set -gx LESS_TERMCAP_me (set_color normal)
set -gx LESS_TERMCAP_se (set_color normal)
set -gx LESS_TERMCAP_so (set_color -b blue yellow)
set -gx LESS_TERMCAP_ue (set_color normal)
set -gx LESS_TERMCAP_us (set_color -u green)
