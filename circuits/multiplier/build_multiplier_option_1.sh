#!/bin/bash

#https://github.com/iden3/snarkjs

BUILD_DIR=./build
CIRCUIT_NAME=multiplier
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

echo "****GENERATING WITNESS FOR SAMPLE INPUT****"
start=`date +%s`
node "$BUILD_DIR"/"$CIRCUIT_NAME"_js/generate_witness.js "$BUILD_DIR"/"$CIRCUIT_NAME"_js/"$CIRCUIT_NAME".wasm input.json "$BUILD_DIR"/witness.wtns
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "***STARTING A NEW 'POWERS OF TAU' CEREMONY***"
start=`date +%s`
npx snarkjs powersoftau new bn128 12 "$BUILD_DIR"/pot12_0000.ptau -v
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "***CONTRIBUTE TO 'POWERS OF TAU' CEREMONY***"
start=`date +%s`
npx snarkjs powersoftau contribute "$BUILD_DIR"/pot12_0000.ptau "$BUILD_DIR"/pot12_0001.ptau --name="First contribution" -v
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "***STARTING THE GENERATION OF PHASE 2***"
start=`date +%s`
npx snarkjs powersoftau prepare phase2 "$BUILD_DIR"/pot12_0001.ptau "$BUILD_DIR"/pot12_final.ptau -v
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****GENERATING ZKEY 0****"
start=`date +%s`
npx snarkjs groth16 setup "$BUILD_DIR"/"$CIRCUIT_NAME".r1cs "$BUILD_DIR"/pot12_final.ptau "$BUILD_DIR"/"$CIRCUIT_NAME"_0000.zkey
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****CONTRIBUTE TO THE PHASE 2 CEREMONY****"
start=`date +%s`
echo "test" | npx snarkjs zkey contribute "$BUILD_DIR"/"$CIRCUIT_NAME"_0000.zkey "$BUILD_DIR"/"$CIRCUIT_NAME"_0001.zkey --name="1st Contributor Name" -v
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****EXPORTING VERIFICATION KEY****"
start=`date +%s`
npx snarkjs zkey export verificationkey "$BUILD_DIR"/"$CIRCUIT_NAME"_0001.zkey "$BUILD_DIR"/verification_key.json
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****GENERATING THE PROOF****"
start=`date +%s`
npx snarkjs groth16 prove "$BUILD_DIR"/"$CIRCUIT_NAME"_0001.zkey "$BUILD_DIR"/witness.wtns "$PROOF_JSON_FILE" "$PUBLIC_JSON_FILE" 
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****VERIFYING THE PROOF****"
start=`date +%s`
npx snarkjs groth16 verify "$BUILD_DIR"/verification_key.json "$PUBLIC_JSON_FILE" "$PROOF_JSON_FILE"
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****GENERATING A SOLIDITY VERIFIER THAT ALLOWS VERIFYING PROOFS ON ETHEREUM BLOCKCHAIN****"
start=`date +%s`
npx snarkjs zkey export solidityverifier "$BUILD_DIR"/"$CIRCUIT_NAME"_0001.zkey "$SMART_CONTRACT"
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****GENERATING THE PARAMETERS OF THE CALL TO 'verifyProof' FUNCTION IN THE 'VERIFIER' SMART CONTRACT****"
start=`date +%s`
npx snarkjs generatecall
end=`date +%s`
echo "DONE ($((end-start))s)"