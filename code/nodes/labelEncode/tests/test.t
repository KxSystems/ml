\l automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

-1"\nTesting appropriate labelencoding";

// Appropriate target data that can be passed to be labelencoded;
apprSymTgt   :`a`b`c`b`b`a`c`b
apprNonSymTgt:{x#/:prd[x]?/:("befhij"$\:0)}[enlist 50]
dictKeys:`symMap`target

// Appropriate return for each target value
apprSymReturn:dictKeys!(`a`b`c!0 1 2;0 1 2 1 1 0 2 1)
apprNonSymReturn:{x!(()!();y)}[dictKeys]each apprNonSymTgt

passingTest[.automl.labelEncode.node.function;apprSymTgt;1b;apprSymReturn]
all passingTest[.automl.labelEncode.node.function;;1b;]'[apprNonSymTgt;apprNonSymReturn]
