function myfeh --wraps='feh --scale-down --start-at' --description 'alias ls=exa --group-directories-first'
    set mystring (string sub -s 2 -e -1 $argv[1])
    set fname (string split '/' $mystring)
    # echo $argv
    # echo $fname
    feh --quiet --scale-down --image-bg "#000000" --start-at "$fname[-1]" (string join / $fname[1..-2]); 
end
