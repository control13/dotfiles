function py_init --description 'initialise a py venv and install requirements'
    python -m venv .venv
    source .venv/bin/activate.fish
    pip install -U pip
    if test -f requirements.txt
        pip install -r requirements.txt
    end
end
