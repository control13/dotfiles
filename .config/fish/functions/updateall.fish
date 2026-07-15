function updateall --description 'Update rust toolchains and Arch repos; preview AUR/devel unless --aur is given'
    argparse a/aur -- $argv
    or return

    echo '==> sudo (cache credentials)'
    sudo -v
    or return $status

    echo '==> rustup update'
    rustup update
    or return $status

    echo '==> yay -Syu --repo (official repos, no prompts)'
    yay -Syu --repo --noconfirm
    or return $status

    if set -q _flag_aur
        echo '==> yay -Syu --aur --devel (AUR + devel, interactive)'
        yay -Syu --aur --devel $argv
    else
        echo '==> AUR updates available (preview; pass --aur to apply):'
        yay -Qua

        echo '==> AUR/devel targets (yay -Su --aur --devel --print):'
        yay -Su --aur --devel --print
    end
end
