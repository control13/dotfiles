function foldersize --description 'Print the total size reported by du for the given paths.'
    du -ch $argv | grep total
end
