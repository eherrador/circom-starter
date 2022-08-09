# Multiplier Circuit

The purpose of this circuit is to allow us to prove to someone that we’re able to factor an integer *c*. Specifically, using this circuit we’ll be able to prove that we know two numbers (*a* and *b*) that multiply together to give *c*, without revealing *a* and *b*.

As you can see, this circuit has **two private input** signals named *a*, and *b* and **one output** signal named *c*.

The inputs and the outputs are related to each other using the **<==** operator. In circom, the **<==** operator does two things. The first is to connect signals. The second is to apply a constraint.

In our case, we’re using **<==** to connect *c* to *a* and *b* and at the same time constraint *c* to be the value of **a*b**.
