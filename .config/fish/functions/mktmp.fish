function mktmp --description 'Create a temporary directory and change into it.'
    set -l tmpdir (mktemp -d $argv); or return
    cd -- "$tmpdir"
end
