function ls --wraps='eza --group-directories-first --hyperlink' --description 'alias ls=eza --group-directories-first --hyperlink'
  eza --icons --group-directories-first --hyperlink $argv
        
end
