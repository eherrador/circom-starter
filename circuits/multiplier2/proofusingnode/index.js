//Before you run this node script, you need to run build_multiplier_option_2.sh

const snarkjs = require("snarkjs");
const fs = require("fs");

async function run() {
    //run any of the next lines after you run: sh build_multiplier_option_2.sh

    //success proof
    //const { proof, publicSignals } = await snarkjs.groth16.fullProve({a: 10, b: 21}, "../build/multiplier2_js/multiplier2.wasm", "../build/multiplier2_final.zkey");
    
    //wrong proof
    //const { proof, publicSignals } = await snarkjs.groth16.fullProve({a: 1, b: 33}, "../build/multiplier2_js/multiplier2.wasm", "../build/multiplier2_final.zkey");
    
    //success proof
    const { proof, publicSignals } = await snarkjs.groth16.fullProve({a: 3, b: 11}, "../build/multiplier2_js/multiplier2.wasm", "../build/multiplier2_final.zkey");

    console.log("Proof: ");
    console.log(JSON.stringify(proof, null, 1));

    const vKey = JSON.parse(fs.readFileSync("../build/vkey.json"));

    const res = await snarkjs.groth16.verify(vKey, publicSignals, proof);

    if (res === true) {
        console.log("Verification OK");
    } else {
        console.log("Invalid proof");
    }

}

run().then(() => {
    process.exit(0);
});