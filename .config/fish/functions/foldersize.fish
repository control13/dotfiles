function foldersize --wraps='du -ch | grep total' --description 'alias foldersize=du -ch | grep total'
  du -ch | grep total $argv; 
end
