FROM balenalib/raspberry-pi-python

RUN apt-get update && apt-get install -y \
    build-essential cmake libffi-dev

RUN --mount=type=tmpfs,target=/root/.cargo \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && . "$HOME/.cargo/env" \
    && python3 -m venv .venv \
    && . .venv/bin/activate \
    && pip3 install -U pip setuptools wheel \
    && pip3 install SideJITServer \
    && pip3 freeze > requirements.txt \
    && mkdir -p /output/wheel \
    && pip3 wheel -d /output/wheel -r requirements.txt
