#!/bin/bash

#https://github.com/iden3/snarkjs

BUILD_DIR=./build
CIRCUIT_NAME=multiplier2
PROOF_JSON_FILE=proof.json
PUBLIC_JSON_FILE=public.json
SMART_CONTRACT=verifier.sol

if [ -d "$BUILD_DIR" ]; then
    echo "Build directory found. Removing build directory..."
    rm -rf "$BUILD_DIR"
fi

if [ ! -d "$BUILD_DIR" ]; then
    echo "No build directory found. Creating build directory..."
    mkdir -p "$BUILD_DIR"
fi

if [ -f "$PROOF_JSON_FILE" ]; then
    echo "Proof.json found. Deleting file..."
    rm -f "$PROOF_JSON_FILE"
fi

if [ -f "$PUBLIC_JSON_FILE" ]; then
    echo "Public.json found. Deleting file..."
    rm -f "$PUBLIC_JSON_FILE"
fi

if [ -f "$SMART_CONTRACT" ]; then
    echo "Smart Contract. Deleting file..."
    rm -f "$SMART_CONTRACT"
fi

echo "****COMPILING CIRCUIT****"
start=`date +%s`
circom "$CIRCUIT_NAME".circom --r1cs --wasm --sym --c --wat --output "$BUILD_DIR"
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****VIEW INFORMATION ABOUT THE CIRCUIT****"
start=`date +%s`
npx snarkjs r1cs info "$BUILD_DIR"/"$CIRCUIT_NAME".r1cs
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****PRINT THE CONSTRAINTS****"
start=`date +%s`
npx snarkjs r1cs print "$BUILD_DIR"/"$CIRCUIT_NAME".r1cs "$BUILD_DIR"/"$CIRCUIT_NAME".sym
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****GENERATING WITNESS FOR SAMPLE INPUT - SUCCESSFUL CASE****"
start=`date +%s`
node "$BUILD_DIR"/"$CIRCUIT_NAME"_js/generate_witness.js "$BUILD_DIR"/"$CIRCUIT_NAME"_js/"$CIRCUIT_NAME".wasm input_success.json "$BUILD_DIR"/witness.wtns
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****GENERATING WITNESS FOR SAMPLE INPUT - WRONG CASE****"
start=`date +%s`
node "$BUILD_DIR"/"$CIRCUIT_NAME"_js/generate_witness.js "$BUILD_DIR"/"$CIRCUIT_NAME"_js/"$CIRCUIT_NAME".wasm input_wrong.json "$BUILD_DIR"/witness.wtns
end=`date +%s`
echo "DONE ($((end-start))s)"