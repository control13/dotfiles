if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fish_greeting

set -gx EDITOR helix
set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR"/ssh-agent.socket"
set -gx FZF_DEFAULT_COMMAND "fd --type f --no-ignore --follow --exclude .git"
set -gx FZF_DEFAULT_OPTS "--no-mouse --height 60% --multi --layout=reverse --preview 'rgf_helper {}'"
set -gx PAGER less
set -gx JDTLS_HOME /usr/bin/jdtls
set -gx LABEL_STUDIO_LOCAL_FILES_SERVING_ENABLED true
set -gx LABEL_STUDIO_LOCAL_FILES_DOCUMENT_ROOT /home/tobias
set -gx WEBKIT_DISABLE_COMPOSITING_MODE 1 # https://github.com/reflex-frp/reflex-platform/issues/735
set -gx PIP_REQUIRE_VIRTUALENV true
set -gx QT_QPA_PLATFORM wayland
#set -gx WLR_DRM_DEVICES /dev/dri/card1
set fzf_fd_opts --exclude=go --exclude=Android

fish_add_path /home/tobias/.local/bin
fish_add_path /usr/bin/vendor_perl/

function preexec --on-event fish_preexec
    set -l command_rows (echo $argv | wc -l)
    set -l vertical_movement 1
    if test $command_rows -gt 1
        set vertical_movement $command_rows
    else
        set -l command (echo $argv | sed 's/^\s*[0-9]*\s*//')
        set -l command_length (string length $command)
        set -l total_length (math $command_length+11)
        set -l lines (math -s0 $total_length/(tput cols)+1)
    # echo $lines
        set vertical_movement $lines
    end
    tput sc
    tput cuu $vertical_movement
    set_color -o cyan ; printf "└" ;set_color -o yellow ; printf (date "+%H:%M:%S")
    tput rc
end

# disable fzf binding for history, we use atui instead
fzf_configure_bindings --history

set -gx ATUIN_NOBIND "true"
atuin init fish | source

bind \cr _atuin_search
bind -M insert \cr _atuin_search
bind \ce _atuin_bind_up
bind -M insert \ce _atuin_bind_up

auto_activate_venv
zoxide init fish | source
# status is-interactive; and pyenv init --path | source
# pyenv init - | source
# source /opt/esp-idf/export.sh
starship init fish | source
navi widget fish | source

