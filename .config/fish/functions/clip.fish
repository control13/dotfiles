function clip --description 'Copy stdin to the Kitty clipboard without trailing newlines.'
    tr -d '\n' | kitten clipboard $argv
end
