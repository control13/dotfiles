#!/usr/bin/env fish
# git-backup-check.fish
# - nimmt Pfade als Argumente ODER von stdin (pipe)
# - optional -0/--null für NUL-getrennte Eingabe von stdin

function print_status
    set path "$argv[1]"

    if not test -e "$path"
        echo "$path, not-found"
        return
    end

    # Git-Root (auch wenn Unterordner übergeben wird)
    set root (git -C "$path" rev-parse --show-toplevel 2>/dev/null)
    if test -z "$root"
        # evtl. bare repo?
        if git -C "$path" rev-parse --git-dir 2>/dev/null >/dev/null
            set root (realpath "$path")
        else
            echo "$path, not-a-git-repo"
            return
        end
    end

    set reasons

    # Bare?
    if test (git -C "$root" rev-parse --is-bare-repository 2>/dev/null) = true
        set -a reasons bare-repo
    end

    # Detached HEAD?
    git -C "$root" symbolic-ref -q --short HEAD >/dev/null 2>&1
    if test $status -ne 0
        set -a reasons detached-head
    end

    # Noch keine Commits?
    git -C "$root" rev-parse -q HEAD >/dev/null 2>&1
    if test $status -ne 0
        set -a reasons no-commits
    end

    # Remotes / Upstream prüfen
    set remotes (git -C "$root" remote 2>/dev/null)
    if test (count $remotes) -eq 0
        set -a reasons no-remote
    end

    set has_upstream 1
    git -C "$root" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1
    if test $status -ne 0
        set has_upstream 0
        set -a reasons no-upstream
    end

    # Ahead/Behind vs. Upstream
    if test $has_upstream -eq 1
        set lr (git -C "$root" rev-list --left-right --count '@{u}...HEAD' 2>/dev/null | string trim)
        if test -n "$lr"
            # Tab/Whitespace-sicher splitten
            set parts (string match -ra '\S+' -- $lr)
            if test (count $parts) -ge 2
                set behind $parts[1]
                set ahead $parts[2]
                if test (math "$ahead") -gt 0
                    set -a reasons unpushed-commits
                end
                if test (math "$behind") -gt 0
                    set -a reasons behind-remote
                end
            end
        end
    end

    # Arbeitsbaum-Status
    git -C "$root" diff --cached --quiet --ignore-submodules=all
    if test $status -ne 0
        set -a reasons staged-changes
    end

    git -C "$root" diff --quiet --ignore-submodules=all
    if test $status -ne 0
        set -a reasons unstaged-changes
    end

    set untracked (git -C "$root" ls-files --others --exclude-standard)
    if test -n "$untracked"
        set -a reasons untracked-files
    end

    git -C "$root" rev-parse -q --verify refs/stash >/dev/null 2>&1
    if test $status -eq 0
        set -a reasons stash-present
    end

    if git -C "$root" submodule status >/dev/null 2>&1
        set sm (git -C "$root" submodule status)
        if string match -qr '^\+' -- $sm
            set -a reasons submodule-modified
        end
        if string match -qr '^\-' -- $sm
            set -a reasons submodule-uninitialized
        end
    end

    if test (count $reasons) -eq 0
        echo (realpath "$root")", clean-and-pushed"
    else
        echo (realpath "$root")", "(string join '+' $reasons)
    end
end

function git-backup-check --description 'Check Git-Repos für Backup-Bedarf'
    set use_null 0
    set paths

    # Flags & Pfade
    for a in $argv
        switch $a
            case -0 --null
                set use_null 1
            case --
                set idx (contains -i -- -- $argv)
                if test -n "$idx"
                    set paths $paths $argv[(math $idx + 1)..-1]
                end
                break
            case '-*'
                echo (status function)": unknown option $a" >&2
                return 2
            case '*'
                set -a paths "$a"
        end
    end

    # (1) Pfade als Argumente?
    if test (count $paths) -gt 0
        for p in $paths
            print_status "$p"
        end
        return
    end

    # (2) Kommt was über stdin? (Pipe/Datei) → dann lesen
    if not isatty stdin
        if test $use_null -eq 1
            while read -z p
                if test -n "$p"
                    print_status "$p"
                end
            end
        else
            while read -l p
                if test -n "$p"
                    print_status "$p"
                end
            end
        end
        return
    end

    # (3) Weder Args noch Pipe → Usage
    echo "usage: "(status function)" [-0|--null] /pfad/zu/repo1 [/pfad/zu/repo2 ...]" >&2
    echo "       ...oder Pfade via stdin pipen (newline-Standard; mit -0 für NUL-getrennt)" >&2
    return 2
end
