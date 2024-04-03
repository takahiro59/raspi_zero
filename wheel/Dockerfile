FROM balenalib/raspberry-pi-python

RUN apt-get update && apt-get install -y \
    build-essential cmake libffi-dev libssl-dev libjpeg-dev pkg-config \
    libtiff-dev libopenjp2-7-dev zlib1g-dev \
    libfreetype-dev liblcms2-dev libwebp-dev tcl-dev tk-dev python3-tk \
    libharfbuzz-dev libfribidi-dev libxcb1-dev

RUN --mount=type=tmpfs,target=/root/.cargo \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && . "$HOME/.cargo/env" \
    && python3 -m venv .venv \
    && . .venv/bin/activate \
    && pip3 install -U pip setuptools wheel \
    && pip3 install SideJITServer \
    && pip3 freeze > requirements.txt \
    && mkdir -p /output/wheel \
    && pip3 wheel --wheel-dir=/output/wheel -r requirements.txt
