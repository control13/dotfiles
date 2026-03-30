#!/usr/bin/env fish

function xerox_print --description 'Flatten PDFs (render annotations), force A4, optionally print via lp'
    argparse h/help p/print 'j/jobs=!_validate_int --min 1' -- $argv
    or return 1

    if set --query _flag_help
        printf "Usage: xerox_print [OPTIONS] <files...>\n\n"
        printf "Flatten PDFs through Ghostscript (renders annotations/comments),\n"
        printf "force A4 paper size via pdfjam, and optionally send to a printer.\n\n"
        printf "Options:\n"
        printf "  -h, --help         Show this help and exit\n"
        printf "  -p, --print        Select a printer via fzf and print\n"
        printf "  -j, --jobs=N       Max parallel jobs (default: 4)\n"
        return 0
    end

    if test (count $argv) -eq 0
        echo "Error: No input files given. Use -h for help." >&2
        return 1
    end

    set -l max_jobs 4
    if set --query _flag_jobs
        set max_jobs $_flag_jobs
    end

    set -l printer ""

    # Select printer upfront so we fail early if none is available
    if set --query _flag_print
        set -l printer_list (lpstat -p 2>/dev/null | grep enabled | awk '{print $2}')
        if test (count $printer_list) -eq 0
            echo "Error: No enabled printers found." >&2
            return 1
        end
        set printer (printf '%s\n' $printer_list | fzf --prompt="Select printer: ")
        if test -z "$printer"
            echo "No printer selected, aborting." >&2
            return 1
        end
    end

    set -l newfolder "to_print_"(date "+%Y-%m-%d-%H-%M-%S")
    mkdir -p "$newfolder"

    set -l failed 0

    for f in $argv
        if not test -f "$f"
            echo "Warning: '$f' not found, skipping." >&2
            set failed (math $failed + 1)
            continue
        end

        # Sanitize output filename: replace spaces, keep only basename
        set -l outname (string replace --all ' ' '_' -- (basename "$f"))
        set -l outpath "$newfolder/$outname"

        echo "Processing: $f -> $outpath"

        # Throttle: wait if too many background jobs are running
        while test (jobs -p | count) -ge $max_jobs
            sleep 0.2
        end

        begin
            # Step 1: Flatten PDF via Ghostscript (renders annotations, strips broken features)
            set -l tmp (mktemp --suffix=.pdf)
            gs -dNOPAUSE -dBATCH -dQUIET \
                -sDEVICE=pdfwrite \
                -dPrinted \
                -dPreserveAnnots=false \
                -sOutputFile="$tmp" \
                -- "$f" 2>/dev/null

            if test $status -ne 0
                echo "Error: Ghostscript failed on '$f'" >&2
                rm -f "$tmp"
                return 1
            end

            # Step 2: Force A4 via pdfjam
            pdfjam --outfile "$outpath" --paper a4paper --quiet "$tmp"

            if test $status -ne 0
                echo "Error: pdfjam failed on '$f'" >&2
                rm -f "$tmp"
                return 1
            end

            rm -f "$tmp"
        end &
    end

    wait

    # Verify outputs exist
    set -l output_files (command ls "$newfolder" 2>/dev/null)
    if test (count $output_files) -eq 0
        echo "Error: No output files were created." >&2
        return 1
    end

    echo "Done: "(count $output_files)" file(s) in $newfolder/"

    if test -n "$printer"
        for f in $output_files
            echo "Printing: $f -> $printer"
            lp -d "$printer" "$newfolder/$f"
        end
    end
end
