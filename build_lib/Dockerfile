FROM balenalib/raspberry-pi:bookworm-build

SHELL ["/bin/bash", "-c"]

RUN apt update && apt install -y \
build-essential libavahi-compat-libdnssd-dev usbmuxd \
ninja-build ldc libimobiledevice-dev libgtk-3-0 dub \
openssl build-essential pkg-config checkinstall git \
autoconf automake libtool-bin

WORKDIR /output

RUN git clone https://github.com/libimobiledevice/libplist.git \
&& cd libplist \
&& ./autogen.sh \
&& make \
&& make install

RUN git clone https://github.com/libimobiledevice/libimobiledevice-glue.git \
&& cd libimobiledevice-glue \
&& ./autogen.sh \
&& make \
&& make install

RUN git clone https://github.com/libimobiledevice/usbmuxd.git \
&& cd usbmuxd \
&& ./autogen.sh \
&& make \
&& make install




