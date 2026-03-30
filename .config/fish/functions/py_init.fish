function py_init --description 'Initialize a Python virtual environment and install requirements.'
    python -m venv .venv; or return

    if not test -f .venv/bin/activate.fish
        echo "Error: .venv/bin/activate.fish was not created." >&2
        return 1
    end

    source .venv/bin/activate.fish; or return
    python -m pip install -U pip; or return

    if test -f requirements.txt
        python -m pip install -r requirements.txt; or return
    end
end
