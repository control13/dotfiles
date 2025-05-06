function updateall --wraps='yay -Syu --devel --timeupdate --sudoloop --noredownload --norebuild --removemake --answerclean' --description 'alias updateall=yay -Syu --devel --timeupdate --sudoloop --noredownload --norebuild --removemake --answerclean'
  yay -Syu --devel --timeupdate --sudoloop --noredownload --norebuild --removemake --answerclean $argv
        
end
