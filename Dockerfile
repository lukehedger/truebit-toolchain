FROM apiaryio/emcc

SHELL ["/bin/bash", "-c"]

RUN apt-get update \
 && apt-get install -y git cmake ninja-build g++ python wget ocaml opam libzarith-ocaml-dev m4 pkg-config zlib1g-dev apache2 psmisc sudo mongodb curl

RUN wget -O rustup.sh https://sh.rustup.rs \
 && sh rustup.sh -y \
 && source $HOME/.cargo/env \
 && rustup toolchain add stable \
 && rustup target add wasm32-unknown-emscripten --toolchain stable

COPY . /truebit-toolchain

RUN opam init -y \
    && opam switch 4.06.1 \
    && eval `opam config env` \
    && opam install cryptokit yojson -y \
    && cd /truebit-toolchain/modules/ocaml-offchain/interpreter \
    && make

RUN cd /truebit-toolchain/modules/emscripten-module-wrapper \
    && npm install

VOLUME ["/workspace"]

WORKDIR /workspace
