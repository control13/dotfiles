#!/usr/bin/env fish

function xerox_print --description 'forces a pdf to a4 and print it first to pdf, optionally print it with lp'
  argparse 'h/help' 'p/print' -- $argv

  if set --query _flag_help
    printf "Usage: xerox_print [OPTIONS] [files...]\n\n"
    printf "Options:\n"
    printf "  -h/--help       Prints help and exits\n"
    printf "  -p/--print      print it with printer"
    return 0
  end

  argparse --min-args=1 -- $argv

  if set --query _flag_print
    set printer (lpstat -p | grep enabled | awk -F ' ' '{print $2}' | fzf)
  end

  set newfolder 'to_print_'(date "+%Y-%m-%d-%H-%M-%S")
  mkdir $newfolder
  remove_spaces $argv
  for f in $argv
    echo 'process '$f
    pdf2ps $f - | ps2pdf - - | pdfjam --outfile $newfolder/$f --paper a4paper -q /dev/stdin &
  end

  wait


  if set --query printer
    for f in (command ls $newfolder)
      lp -d $printer $newfolder/$f
    end
  end
end
