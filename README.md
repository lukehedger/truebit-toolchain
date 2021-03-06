# TrueBit Toolchain

[![Build Status](https://travis-ci.org/TrueBitFoundation/truebit-toolchain.svg?branch=master)](https://travis-ci.org/TrueBitFoundation/truebit-toolchain)

## Docker Guide

The truebit-toolchain docker image is built from the submodules in the `./modules` directory.

The `./workspace` directory is meant to be mounted into the image, and used to compile, interpret and test wasm code.

#### Building the Image

Make sure to pull in all of this repos submodule dependencies
```
git submodule update --init --recursive
```

Now you can build the Image
```
docker build . -t truebit-toolchain:latest
```

#### Open Bash

```
chmod 755 scripts/open_bash.sh
./scripts/open_bash.sh
```

Or

```
docker run -it \
-v $(pwd)/workspace:/workspace \
truebit-toolchain:latest \
/bin/bash
```

The rest of this README will assume you are in the bash inside Docker.

### Compile Rust to WASM

```
source $HOME/.cargo/env
cd reverse_alphabet
cargo build --target wasm32-unknown-emscripten --release
mv target/wasm32-unknown-emscripten/release/{reverse_alphabet.js,reverse_alphabet.wasm} .
```

#### Compile C to WASM

```
cd src
emcc -s WASM=1 /workspace/src/reverse_alphabet.c -o /workspace/src/reverse_alphabet.js
```

#### Prepare WASM for TrueBit Interpreter

Once we've compiled our program to wasm this is the last step.

You'll want to replace *DIR* with your project directory (ex: reverse_alphabet). Absolute paths work best.

```
DIR=*DIR*
node /truebit-toolchain/modules/emscripten-module-wrapper/prepare.js \
/workspace/$DIR/reverse_alphabet.js \
--file /workspace/$DIR/alphabet.txt \
--file /workspace/$DIR/reverse_alphabet.txt \
--asmjs \
--out /workspace/dist
```

Successful compilation should print out something like this:

```
{
  "vm": {
    "code": "0x3f6b3f1a468a34102140afb7dee16e7f2128e0cac5717f3eb7184eeba4a706d6",
    "stack": "0xb4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d30",
    "memory": "0xb4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d30",
    "input_size": "0x6f55d147a0b66458280fda3caf4b46564bc7998544f3d78a503f328d970a31cd",
    "input_name": "0x4da89d96f282aac9cc2d4042cf98d702afcedb9870f4f7afd221b138a34b72c4",
    "input_data": "0xf2f7d1878bfcf422892f78a56702f2f142c3a55153fba767d241b7083ccf8260",
    "call_stack": "0xb4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d30",
    "globals": "0xb4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d30",
    "calltable": "0x7bf9aa8e0ce11d87877e8b7a304e8e7105531771dbff77d1b00366ecb1549624",
    "calltypes": "0xb4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d30",
    "pc": 0,
    "stack_ptr": 0,
    "call_ptr": 0,
    "memsize": 0
  },
  "hash": "0x9ab5c445aebf76fceada9a1eaedc834cfe3697bfab725795e19e4def6793c1fb"
}
```

When submitting a truebit task you will only need a few things.

The first being the hash field from the json output above. The second is the Truebit flavored wasm file you just created.
If you look in `/workspace/dist` you should see a `globals.wasm` file. This will need to be uploaded to either IPFS or the Blockchain. The IPFS hash or the contract address will act as the storage address.

## MacOS Guide

#### Setup EMSDK

```
cd ./modules/emsdk

# Fetch the latest registry of available tools.
./emsdk update

# Download and install the latest SDK tools.
./emsdk install latest

# Make the "latest" SDK "active" for the current user. (writes ~/.emscripten file)
./emsdk activate latest

# Activate PATH and other environment variables in the current terminal
source ./emsdk_env.sh

cd  ../..

```

#### Compile C to WASM

Use emcc to compile C code to wasm.

```
emcc -s WASM=1 ./workspace/src/reverse_alphabet.c -o ./workspace/src/reverse_alphabet.js
```

If all goes well, you will have `./workspace/src/reverse_alphabet.js` and `./workspace/src/reverse_alphabet.wasm`.

#### Setup Interpreter

Make sure you have ocaml installed and set to the correct version.

```
brew install opam  
opam init -y
opam switch 4.06.1
```

Build the truebit wasm interpreter

```
cd ./modules/ocaml-offchain
eval $(opam config env)
opam install cryptokit yojson
cd interpreter
make
```

We can't test the interpreter without the module wrapper, which we'll setup next.

#### Setup Module Wrapper

```
cd ./modules/emscripten-module-wrapper
npm i
```

#### Instrument WASM for TrueBit Interpreter  

This will test both the compiled wasm code, the emscripten module wrapper and the interpreter.

```
node ./modules/emscripten-module-wrapper/prepare.js \
./workspace/src/reverse_alphabet.js \
--file ./workspace/src/alphabet.txt \
--file ./workspace/src/reverse_alphabet.txt \
--asmjs \
--out ./workspace/dist
```

Success looks like this:

```
child process exited with code 0
{
  "vm": {
    "code": "0xcc0d89e2f7ad0f720cdc6521ab698c1053dac534cd770fb6531d935975ee5d7e",
    "stack": "0xb4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d30",
    "memory": "0xb4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d30",
    "input_size": "0x593e5b969fbeac1646d534f40aeeb6d440f1b60353267ff7a67bb53a3a8f1125",
    "input_name": "0x9f9a605ee9da9ebd0f0a58d289c2345d279c3e11baafdefe72bb5aa2ead36e38",
    "input_data": "0x066ccee69369f2589250d208feef82cd3e06356124c01b9e9e8d56c9393e0e85",
    "call_stack": "0xb4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d30",
    "globals": "0xb4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d30",
    "calltable": "0x7bf9aa8e0ce11d87877e8b7a304e8e7105531771dbff77d1b00366ecb1549624",
    "calltypes": "0xb4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d30",
    "pc": 0,
    "stack_ptr": 0,
    "call_ptr": 0,
    "memsize": 0
  },
  "hash": "0x9e10c72398fc17ba4fa0163ea8da8d1401abfe4ef93335b122df18498cac5da7"
}

```

Now test the interpreter:

```
./modules/ocaml-offchain/interpreter/wasm \
-m -output -memory-size 16 -stack-size 14 -table-size 8 -globals-size 8 -call-stack-size 10 \
-file ./workspace/src/alphabet.txt \
-file ./workspace/src/reverse_alphabet.txt \
-wasm ./workspace/src/reverse_alphabet.wasm \
-asmjs
```

Success looks like this:

```
Warning: asm.js initialization is very dependant on the filesystem.wasm
Warning, cannot find global variable TOTAL_MEMORY. Use emscripten-module-wrapper to run files that were generated by emscripten
STUB env . ___syscall5
STUB env . ___syscall54
STUB env . ___lock
STUB env . ___unlock
STUB env . ___lock
STUB env . ___unlock
STUB env . nullFunc_iiii
STUB env . ___syscall6
STUB env . ___syscall5
STUB env . ___syscall54
STUB env . ___lock
STUB env . ___unlock
STUB env . nullFunc_iiii
STUB env . ___lock
STUB env . ___unlock
STUB env . nullFunc_iiii
STUB env . ___syscall6
{
  "vm": {
    "code": "0x8e891415c9620009e061e8f4a1bd6308c5b7c41cb65fbf4a697bbd675c145e3b",
    "stack": "0x2d52148999d6995f2d73f8676d9a0ca3ca07d5311c2b13400e762b2f232e7f50",
    "memory": "0xc93409e80b43d215e501e25b2b424acfd177f07dbb8e64296fe5a713c5c09c5a",
    "input_size": "0x593e5b969fbeac1646d534f40aeeb6d440f1b60353267ff7a67bb53a3a8f1125",
    "input_name": "0x9f4c2f7983a269a754906b124d17afdbdde81523d88233071058882c1fe72c0b",
    "input_data": "0x066ccee69369f2589250d208feef82cd3e06356124c01b9e9e8d56c9393e0e85",
    "call_stack": "0x817d9ede28dcb78bae11b94eb0965876da3e57f2f079fbd2f42a199b855d824e",
    "globals": "0x7d13b6d2d20d9a562a4d6286c9846b566ede5305ebd6da78c1bfc857696569ba",
    "calltable": "0xe712a0b2433b450758076aa5a00603d8080363fa1a34126455c15072305d993d",
    "calltypes": "0x87c337054355411efa7f7195bb1afd7078b79c10ce5abfb9e85ab5e36649a9ff",
    "pc": 1099511627775,
    "stack_ptr": 20,
    "call_ptr": 0,
    "memsize": 100000000
  },
  "hash": "0x84713b9950ce35a131222d0d54d0476406524cc28be1db0329e62e2d414c5d71",
  "steps": 27541,
  "files": [
    "./workspace/src/alphabet.txt.out",
    "./workspace/src/reverse_alphabet.txt.out"
  ]
}
```


### Git Submodule Commands

```
git submodule update --init --recursive
git submodule update --remote --merge
```
