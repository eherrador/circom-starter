# Multiplier2 circuit

The purpose of this circuit is to easily test the system with a different number of constraints.

In this case, we've chosen 10, but we can change this to anything we want (as long as the value we choose is below the number we defined in step 1).

## Install dependencies

- To install  `snarkjs`  run:
```
npm install -g snarkjs@latest
```
- To install `circom`, follow the instructions at [installing circom](https://docs.circom.io/getting-started/installation).

- You'll need to download a Powers of Tau file with `2^20` constraints and copy it into this subdirectory (`circuits/multiplier`), with the name `pot20_final.ptau`. We do not provide such a file in this repo due to its large size. You can download and copy Powers of Tau files from the Hermez trusted setup from [this repository](https://github.com/iden3/snarkjs#7-prepare-phase-2).

## Building keys and witness generation files

Run `sh build_multiplier_option_1.sh` or `sh build_multiplier_option_2.sh` to compile the circuit and keys the result will be successful. This will create a `build` directory inside (which will be created if it doesn't already exist). Inside this directory, the build process will create `r1cs` and `wasm` files for witness generation, as well as a `zkey` file (proving and verifying keys). Note that this process will take several minutes.

## Using Node in the `proofusingnode` directory
```
npm init
```
```
npm install snarkjs
```
