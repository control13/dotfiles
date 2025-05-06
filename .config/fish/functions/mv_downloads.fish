#!/usr/bin/env fish

function mv_downloads --description 'move downloaded things to its folders'
  argparse 'h/help' 'n/dry-run' -- $argv

  if set --query _flag_help
    printf "Usage: mv_downloads [OPTIONS] [sourcefolder]\n\n"
    printf "Options:\n"
    printf "  -h/--help       Prints help and exits\n"
    printf "  -n/--dryrun    do not actually move the files\n"
    return 0
  end

  if set --query $argv[1]
    set source_folder $argv[1]
  else
    set source_folder "/home/tobias/Downloads/"
  end

  # echo $source_folder

  # Congstar
  # congstar_2201386981_2024_12_Monatsrechnung_7570482939.pdf
  set congstar (fd -i --base-directory $source_folder congstar)
  set congstar_dir "/home/tobias/Documents/Congstar/"

  # Deka
  # Deka_Ertragsausschuettung.PDF
  set deka (fd -i --base-directory $source_folder deka)
  set deka_dir "/home/tobias/Documents/Sparkasse/DeKa/"

  # Sparkasse
  #Konto_1630502711-Auszug_2024_0010.PDF
  set kontoauszug (fd -i --base-directory $source_folder Konto_1630502711-Auszug_)
  set kontoauszug_dir "/home/tobias/Documents/Sparkasse/Kontoauszüge/"

  # Hanseatic
  # Kontoauszug-24-10_2014373678.pdf - GenialCard
  # Kontoauszug-25-01_0230956065.pdf - Tagesgeld
  set hanseatic (fd -i --base-directory $source_folder Kontoauszug-)
  set hanseatic_dir "/home/tobias/Documents/Hanseatic/"

  # # SimON
  # Rechnung vom 01.02.2025.pdf
  set simon (fd -i --base-directory $source_folder "Rechnung vom ")
  set simon_dir "/home/tobias/Documents/SimON/"

  # # trade Republic

  # # finanzen dot net zero

  if set -q _flag_dry_run
    set _flag_dryrun "yes"
  else
    set _flag_dryrun "no"
  end

  function my_print
    if test -n "$argv[3]"
      printf "to ""$argv[2]""\n"
      printf \t%s\n $argv[3..]
      if string match -q $argv[1] "no"
        remove_spaces $argv[3..]
        mv $argv[3..] "$argv[2]"
      end
    end
  end

  pushd $source_folder
  my_print $_flag_dryrun "$congstar_dir" $congstar
  my_print $_flag_dryrun "$deka_dir" $deka
  my_print $_flag_dryrun "$kontoauszug_dir" $kontoauszug
  my_print $_flag_dryrun "$hanseatic_dir" $hanseatic
  my_print $_flag_dryrun "$simon_dir" $simon
  popd
  
end
