FROM balenalib/raspberry-pi-python

RUN apt-get update && apt-get install -y \
    build-essential cmake 

RUN python3 -m venv .venv \
    && source .venv/bin/activate \
    && pip3 install -U pip setuptools wheel \
    && pip3 install SideJITServer \
    && pip3 freeze > requirements.txt \
    && mkdir -p /output/wheel \
    && pip3 wheel -d /output/wheel -r requirements.txt
