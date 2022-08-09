# Multiplier2 circuit

The purpose of this circuit is to allow us to prove to someone that we’re able to factor an integer *c*. Specifically, using this circuit we’ll be able to prove that we know two numbers (*a* and *b*) that multiply together to give *c*, without revealing *a* and *b*.

As you can see, this circuit has **two private input** signals named *a*, and *b* and **one output** signal named *c*.

The inputs and the outputs are related to each other using the **<==** operator. In circom, the **<==** operator does two things. The first is to connect signals. The second is to apply a constraint.

In our case, we’re using **<==** to connect *c* to *a* and *b* and at the same time constraint *c* to be the value of *a*b*.

## Install dependencies

- To install  `snarkjs`  run:
```
npm install -g snarkjs@latest
```
- To install `circom`, follow the instructions at [installing circom](https://docs.circom.io/getting-started/installation).

- You'll need to download a Powers of Tau file with `2^20` constraints and copy it into this subdirectory (`circuits/multiplier`), with the name `pot20_final.ptau`. We do not provide such a file in this repo due to its large size. You can download and copy Powers of Tau files from the Hermez trusted setup from [this repository](https://github.com/iden3/snarkjs#7-prepare-phase-2).

## Building keys and witness generation files

Run `sh build_multiplier_option_1.sh`, only to compile the circuit and for build the witness. We will get two witness result, the first one will be a successful witness (we are using correct values in the input_success.json file), but the second witness build will be wrong (because we are using a wrong values in the input_wrong.json file).

When you run`sh build_multiplier_option_2.sh` to compile the circuit and keys the result will be successful. This will create a `build` directory inside (which will be created if it doesn't already exist). Inside this directory, the build process will create `r1cs` and `wasm` files for witness generation, as well as a `zkey` file (proving and verifying keys). Note that this process will take several minutes.

## Using Node in the `proofusingnode` directory
```
npm init
```
```
npm install snarkjs
```
