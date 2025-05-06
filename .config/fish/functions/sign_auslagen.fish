function sign_auslagen
    libreoffice --headless --convert-to pdf $argv[-1]
    source /home/tobias/programming/python/dienstreise/.venv/bin/activate.fish
    python /home/tobias/programming/python/dienstreise/auslagenerstattung.py $argv[1..-2] (string replace docx pdf $argv[-1])
    deactivate
end
