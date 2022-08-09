//Before you run this node script, you need to run build_multiplier_option_2.sh

const snarkjs = require("snarkjs");
const fs = require("fs");

async function run() {
    //success proof
    //const { proof, publicSignals } = await snarkjs.groth16.fullProve({a: 10, b: 21}, "../build/multiplier3_js/multiplier3.wasm", "../build/multiplier3_final.zkey");
        
    //success proof
    const { proof, publicSignals } = await snarkjs.groth16.fullProve({a: 3, b: 11}, "../build/multiplier3_js/multiplier3.wasm", "../build/multiplier3_final.zkey");

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