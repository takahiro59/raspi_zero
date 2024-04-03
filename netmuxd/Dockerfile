FROM balenalib/raspberry-pi-debian:latest

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

RUN git clone --recursive https://github.com/jkcoxson/netmuxd.git
RUN git clone --recursive https://github.com/zeyugao/zeroconf-rs.git

RUN cp $HOME/.cargo/env cargo_env
RUN --mount=type=tmpfs,target=/root/.cargo . cargo_env && cd netmuxd && cargo build --release --bin netmuxd

RUN mkdir /output && mv netmuxd/target/release/netmuxd /output
