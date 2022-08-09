pragma circom 2.0.0;

/*This circuit template checks that c is the multiplication of a and b.*/

template Multiplier3 (n) {
    // Declaration of signals.
    signal input a;
    signal input b;
    signal output c;
    signal int[n];

    // Constraints.
    int[0] <== a*a + b;
    for (var i=1; i<n; i++) {
        int[i] <== int[i-1]*int[i-1] + b;
    }

    c <== int[n-1];
}

component main = Multiplier3(10);