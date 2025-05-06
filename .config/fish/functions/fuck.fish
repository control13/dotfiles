function fuck --description 'run previous command with sudo'
    commandline -i "sudo $history[1]"
    history delete --exact --case-sensitive "$history[1]"
end
