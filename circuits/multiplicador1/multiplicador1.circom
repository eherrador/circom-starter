pragma circom 2.2.0;

/*This circuit template checks that c is the multiplication of a and b.*/

template Multiplier2 () {
    // Declaration of signals.
    signal input a;
    signal input b;
    signal output c;
    signal inva;
    signal invb;

    // Constraints.
    
    // Se asegura que los valores de "a" y "b", no sean 1, ya que esto generaria un valor indefinido
    inva <-- 1/(a-1);
    (a-1)*inva === 1;

    invb <-- 1/(b-1);
    (b-1)*invb === 1;

    c <== a * b;
}

component main = Multiplier2();