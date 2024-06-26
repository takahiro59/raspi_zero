FROM arm32v6/alpine:3.14

RUN apk add --no-cache git curl wget g++ clang boost-static ninja boost-dev cmake make sudo bash vim libressl-dev util-linux-dev zlib-dev zlib-static

RUN mkdir /buildenv

WORKDIR /buildenv

RUN curl -JO 'https://developer.apple.com/file/?file=security&agree=Yes' -H 'Referer: https://developer.apple.com/security/' && unzip corecrypto.zip
WORKDIR /buildenv/corecrypto-2023
COPY CMakeLists.txt CMakeLists.txt
RUN curl -Lo scripts/code-coverage.cmake https://raw.githubusercontent.com/StableCoder/cmake-scripts/main/code-coverage.cmake
RUN mkdir build; cd build; CC=clang CXX=clang++ cmake ..;
WORKDIR /buildenv/corecrypto-2023/build
RUN sed -i -E 's|^(all: CMakeFiles\/corecrypto_perf)|#\1|' CMakeFiles/Makefile2; sed -i -E 's|^(all: CMakeFiles\/corecrypto_test)|#\1|' CMakeFiles/Makefile2
RUN make -j6; make install

WORKDIR /buildenv

RUN git clone --recursive https://github.com/microsoft/cpprestsdk
WORKDIR /buildenv/cpprestsdk
RUN sed -i 's|-Wcast-align||' "./Release/CMakeLists.txt"
RUN CFLAGS='-Wno-psabi' mkdir build; cd build; cmake -DBUILD_SHARED_LIBS=0 ..; make -j6; make install

WORKDIR /buildenv

RUN git clone https://github.com/nih-at/libzip && cd libzip; mkdir build; cd build; cmake -DBUILD_SHARED_LIBS=0 ..; make -j6; make install

RUN git clone --recursive https://github.com/NyaMisty/AltServer-Linux && cd AltServer-Linux && mkdir build; cd build; make -f ../Makefile -j6

RUN mkdir /output && mv AltServer-Linux/build/AltServer-* /output/altserver
