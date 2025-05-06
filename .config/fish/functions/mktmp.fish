function mktmp --wraps='cd (mktemp -d)' --description 'alias mktmp=cd (mktemp -d)'
  cd (mktemp -d) $argv
        
end
