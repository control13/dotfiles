# Interactive abbreviations for common command defaults.
if status is-interactive
    function __ensure_abbr --argument-names name expansion
        if abbr --query $name
            abbr --erase $name
        end

        abbr --add -- $name "$expansion"
    end

    __ensure_abbr cp 'cp -i'
    __ensure_abbr mv 'mv -i'
    __ensure_abbr rm 'rm -I'
    __ensure_abbr ln 'ln -i'
    __ensure_abbr mkdir 'mkdir -p -v'
    __ensure_abbr chmod 'chmod --preserve-root'
    __ensure_abbr chown 'chown --preserve-root'
    __ensure_abbr chgrp 'chgrp --preserve-root'
    __ensure_abbr grep 'grep --color=auto'
    __ensure_abbr rg 'rg --hyperlink-format=kitty'
    __ensure_abbr df 'df -Th'
    __ensure_abbr ip 'ip --color'
    __ensure_abbr less 'less -S -M'
    __ensure_abbr ls 'eza --icons --group-directories-first --hyperlink'
    __ensure_abbr lah 'eza --icons --group-directories-first --hyperlink -algh --git'
    __ensure_abbr tree 'eza --icons --group-directories-first --hyperlink -algh --git -T'
    __ensure_abbr hx 'helix'
    __ensure_abbr s 'kitten ssh'
    __ensure_abbr su 'su --shell=/usr/bin/fish'
    __ensure_abbr grip 'grep --color=auto -i'
    __ensure_abbr updateall 'yay -Syu --devel --timeupdate'
    __ensure_abbr remove 'yay -Rsun'
    __ensure_abbr bap 'bat -p'

    functions --erase __ensure_abbr
end
