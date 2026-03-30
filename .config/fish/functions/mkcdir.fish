function mkcdir --description 'Create a directory and change into it.'
    if test (count $argv) -ne 1
        echo "Usage: mkcdir <directory>" >&2
        return 2
    end

    command mkdir -p -- "$argv[1]"; or return
    cd -- "$argv[1]"
end
