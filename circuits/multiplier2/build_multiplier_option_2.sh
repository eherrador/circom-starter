#!/bin/bash

#https://github.com/iden3/snarkjs

PHASE1=pot20_final.ptau
BUILD_DIR=./build
CIRCUIT_NAME=multiplier
PROOF_JSON_FILE=proof.json
PUBLIC_JSON_FILE=public.json
SMART_CONTRACT=verifier.sol

if [ -f "$PHASE1" ]; then
    echo "Found Phase 1 ptau file"
else
    echo "No Phase 1 ptau file found."
       
    echo "You will need to download a Powers of Tau file with 2^20 constraints (powersOfTau28_hez_final_20.ptau) and copy it into this directory, with the name pot20_final.ptau"
    echo "We do not provide such a file due to its large size. You can download and copy Powers of Tau files from the Hermez trusted setup from:"
    echo "https://github.com/iden3/snarkjs"
    echo "Exiting..."
    exit 1
fi

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
node "$BUILD_DIR"/"$CIRCUIT_NAME"_js/generate_witness.js "$BUILD_DIR"/"$CIRCUIT_NAME"_js/"$CIRCUIT_NAME".wasm input_success.json "$BUILD_DIR"/witness.wtns
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****GENERATING ZKEY 0****"
start=`date +%s`
npx snarkjs groth16 setup "$BUILD_DIR"/"$CIRCUIT_NAME".r1cs "$PHASE1" "$BUILD_DIR"/"$CIRCUIT_NAME"_0000.zkey
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****CONTRIBUTE TO THE PHASE 2 CEREMONY****"
start=`date +%s`
echo "test" | npx snarkjs zkey contribute "$BUILD_DIR"/"$CIRCUIT_NAME"_0000.zkey "$BUILD_DIR"/"$CIRCUIT_NAME"_0001.zkey --name="1st Contributor Name" -v
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****PROVIDE A SECOND CONTRIBUTION****"
start=`date +%s`
echo "test" | npx snarkjs zkey contribute "$BUILD_DIR"/"$CIRCUIT_NAME"_0001.zkey "$BUILD_DIR"/"$CIRCUIT_NAME"_0002.zkey --name="Second Contributor Name" -v -e="Another random entropy"
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****PROVIDE A THIRD CONTRIBUTION USING THIRD PARTY SOFTWARE****"
start=`date +%s`
npx snarkjs zkey export bellman "$BUILD_DIR"/"$CIRCUIT_NAME"_0002.zkey "$BUILD_DIR"/challenge_phase2_0003
npx snarkjs zkey bellman contribute bn128 "$BUILD_DIR"/challenge_phase2_0003 "$BUILD_DIR"/response_phase2_0003 -e="some random text"
npx snarkjs zkey import bellman "$BUILD_DIR"/"$CIRCUIT_NAME"_0002.zkey "$BUILD_DIR"/response_phase2_0003 "$BUILD_DIR"/"$CIRCUIT_NAME"_0003.zkey -n="Third contribution name"
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****VERIFYING THE LATEST ZKEY****"
start=`date +%s`
npx snarkjs zkey verify "$BUILD_DIR"/"$CIRCUIT_NAME".r1cs "$PHASE1" "$BUILD_DIR"/"$CIRCUIT_NAME"_0003.zkey
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****APPLY A RANDOM BEACON****"
start=`date +%s`
npx snarkjs zkey beacon "$BUILD_DIR"/"$CIRCUIT_NAME"_0003.zkey "$BUILD_DIR"/"$CIRCUIT_NAME"_final.zkey 0102030405060708090a0b0c0d0e0f101112231415161718221a1b1c1d1e1f 10 -n="Final Beacon phase2"
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****VERIFYING THE FINAL ZKEY****"
start=`date +%s`
npx snarkjs zkey verify "$BUILD_DIR"/"$CIRCUIT_NAME".r1cs "$PHASE1" "$BUILD_DIR"/"$CIRCUIT_NAME"_final.zkey
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****EXPORTING VKEY****"
start=`date +%s`
npx snarkjs zkey export verificationkey "$BUILD_DIR"/"$CIRCUIT_NAME"_final.zkey "$BUILD_DIR"/vkey.json
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****CREATING THE PROOF****"
start=`date +%s`
npx snarkjs groth16 prove "$BUILD_DIR"/"$CIRCUIT_NAME"_final.zkey "$BUILD_DIR"/witness.wtns "$PROOF_JSON_FILE" "$PUBLIC_JSON_FILE"
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****VERIFYING PROOF****"
start=`date +%s`
npx snarkjs groth16 verify "$BUILD_DIR"/vkey.json "$PUBLIC_JSON_FILE" "$PROOF_JSON_FILE"
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****GENERATING A SOLIDITY VERIFIER THAT ALLOWS VERIFYING PROOFS ON ETHEREUM BLOCKCHAIN****"
start=`date +%s`
npx snarkjs zkey export solidityverifier "$BUILD_DIR"/"$CIRCUIT_NAME"_final.zkey "$SMART_CONTRACT"
end=`date +%s`
echo "DONE ($((end-start))s)"

echo "****GENERATING THE PARAMETERS OF THE CALL TO 'verifyProof' FUNCTION IN THE 'VERIFIER' SMART CONTRACT****"
start=`date +%s`
npx snarkjs generatecall
end=`date +%s`
echo "DONE ($((end-start))s)"