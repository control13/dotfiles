#!/usr/bin/env fish
# Diese Funktion ersetzt Leerzeichen im Dateinamen:
#  - Alle aufeinanderfolgenden Leerzeichen werden durch einen Unterstrich ersetzt.
#  - Falls exakt die Zeichenfolge " - " vorkommt, werden die Leerzeichen entfernt (also zu "-").
# Das Verzeichnis bleibt unverändert, es wird nur der Basisname bearbeitet.
# 
# Optionen:
#   -n, --dry-run   Nur anzeigen, was geändert wird, ohne die Dateien tatsächlich umzubenennen.
#   -h, --help      Zeige diese Hilfemeldung an.
#
function remove_spaces -d "Ersetzt Leerzeichen in Dateinamen und entfernt Leerzeichen um Bindestriche (z. B. ' - ' wird zu '-')."
    # Parse die Kommandozeilenoptionen mit argparse.
    argparse n/dry-run h/help -- $argv
    # Falls Hilfe angefordert wurde, gib eine kurze Beschreibung aus und beende die Funktion.
    if set -q _flag_help
        echo "Usage: rename_spaces [-n|--dry-run] file1 [file2 ...]"
        echo ""
        echo "Dieses Skript ersetzt Leerzeichen im Dateinamen:"
        echo "  - Ersetzt alle (mehrfach vorkommende) Leerzeichen durch einen Unterstrich."
        echo "  - Entfernt Leerzeichen in der Zeichenfolge ' - ' (ersetzt sie durch einen einfachen Bindestrich)."
        echo ""
        echo "Optionen:"
        echo "  -n, --dry-run   Zeigt an, was geändert würde, ohne die Dateien umzubenennen."
        echo "  -h, --help      Diese Hilfsnachricht anzeigen."
        return 0
    end

    # Setze den Dry-Run-Modus, falls das Flag -n bzw. --dry-run angegeben wurde.
    set -l dryrun 0
    if set -q _flag_dry_run
        set dryrun 1
    end

    # Überprüfe, ob mindestens eine Datei als Argument angegeben wurde.
    if test (count $argv) -eq 0
        echo "Fehler: Keine Datei(en) angegeben."
        echo "Usage: rename_spaces [-n|--dry-run] file1 [file2 ...]"
        return 1
    end

    # Verarbeite jeden angegebenen Dateinamen.
    for file in $argv
        if not test -e "$file"
            echo "Datei '$file' existiert nicht – überspringe."
            continue
        end

        # Bestimme Verzeichnis und Basisnamen.
        set dir (dirname "$file")
        set base (basename "$file")

        # Schritt 1: Falls exakt " - " vorkommt, entferne die Leerzeichen (ersetze durch "-").
        set newbase (string replace -ar "\s*-\s*" "-" "$base")
        set newbase (string replace -ar "\s*_\s*" "_" "$base")
        # Schritt 2: Ersetze alle (eine oder mehrere) Leerzeichen durch einen Unterstrich.
        set newbase (string replace -ar '\s+' '_' "$newbase")

        # Ausgabe des alten und neuen Dateinamens.
        if test "$base" != "$newbase"
            echo "$file -> $newbase"
        else
            echo "$file -> (keine Änderung)"
        end

        # Falls nicht im Dry-Run-Modus, führe die Umbenennung durch.
        if test $dryrun -eq 0
            set newfile "$dir/$newbase"
            mv -- "$file" "$newfile"
        end
    end
end

# Falls das Skript direkt ausgeführt wird, rufe die Funktion mit allen übergebenen Parametern auf.
# if status --is-interactive
#     # Bei interaktiver Nutzung wird die Funktion erst geladen.
#     echo "Funktion 'rename_spaces' geladen. Bitte rufe sie mit rename_spaces [-n|--dry-run] file1 [file2 ...] auf."
# else
#     rename_spaces $argv
# end
