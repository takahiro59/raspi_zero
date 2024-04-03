FROM --platform=linux/arm32/v6 techlife/raspios_lite_armhf

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        build-essential \
        pkg-config \
        checkinstall \
        git \
        autoconf \
        automake \
        libtool-bin \
        libavahi-glib-dev libavahi-client-dev \
        libusb-1.0-0-dev \
        libssl-dev \
        udev \
        libplist++-dev libtool autoconf automake \
        python3 python3-dev \
        curl usbmuxd \
        wget lsb-release wget software-properties-common \
        clang

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

RUN git clone --depth 1 https://github.com/jkcoxson/netmuxd.git

RUN cd netmuxd && . "$HOME/.cargo/env" && cargo build --release --bin netmuxd
