\l p.q
\l ml.q
\l util/util.q
\l optimize/optim.q

// Function for the capturing of expected errors
failingTest:{[function;data;applyType;expectedError]
  applyType:$[applyType;@;.];
  failureFunction:{[err;ret](`TestFailing;ret;err~ret)}[expectedError;];
  functionReturn:applyType[function;data;failureFunction];
  $[`TestFailing~first functionReturn;last functionReturn;0b]
  }

// Load in data saved as golden copy for this analysis
// Load files
fileList:`quadx0`quadx1`sinex0`sinex1`multix0`multix1`multix1Gtol`multiargs0`multiargs1
{load hsym`$":data/",string x}each fileList;

-1"Testing examples of optimization functionality expected to fail";
c1c2Fail:"When evaluating Wolfe conditions the following must hold 0 < c1 < c2 < 1"
normFail:"ord must be +/- infinity or a long atom"
failingTest[.ml.optimize.BFGS;({x[0]-x 1};1 2f;();``c1!(::; 1.2));0b;c1c2Fail]
failingTest[.ml.optimize.BFGS;({x[0]-x 1};1 2f;();``c2!(::;-1.2));0b;c1c2Fail]
failingTest[.ml.optimize.BFGS;({x[0]-x 1};1 2f;();`c1`c2!0.7 0.2);0b;c1c2Fail]
failingTest[.ml.optimize.BFGS;({x[0]-x 1};1 2f;();``norm!(::;1 2));0b;normFail]
failingTest[.ml.optimize.BFGS;({x[0]-x 1};1 2f;();``norm!(::;1.3));0b;normFail]

-1"Testing of 1-D quadratic function";
quadFunc:{xexp[x[0];2]-4*x[0]}
x0quad:enlist 4f
x1quad:enlist[`x]!enlist -2f
.ml.optimize.BFGS[quadFunc;x0quad;();::]~quadx0
.ml.optimize.BFGS[quadFunc;x1quad;();::]~quadx1

-1"Testing of 1-D Sine function with multiple minima";
sineFunc:{sin x 0}
x0sine:enlist 7f
x1sine:enlist[`x]!enlist 8.5
.ml.optimize.BFGS[sineFunc;x0sine;();::]~sinex0
.ml.optimize.BFGS[sineFunc;x1sine;();::]~sinex1

-1"Testing of 2-D parabolas with single global minima";
multiFunc:{xexp[x[0]-1;2]+xexp[x[1]-2.5;2]}
x0multi:10 20f
x1multi:`x`x1!-10 -10f
gtolDict:enlist[`gtol]!enlist 1e-8
.ml.optimize.BFGS[multiFunc;x0multi;();::]~multix0
.ml.optimize.BFGS[multiFunc;x1multi;();::]~multix1
.ml.optimize.BFGS[multiFunc;x1multi;();gtolDict]~multix1Gtol
not .ml.optimize.BFGS[multiFunc;x1multi;();::]~.ml.optimize.BFGS[multiFunc;x1multi;();gtolDict]


-1"Testing of 2-D parabolas with single global minima and unchanging additional parameters";
multiFuncArgList:{y[0]+xexp[x[0]-1;2]+xexp[x[1]-2.5;2]}
multiFuncArgDict:{y[`args0]+xexp[x[0]-1;2]+xexp[x[1]-2.5;2]}
args0:enlist 5f
args1:enlist[`args0]!args0
.ml.optimize.BFGS[multiFuncArgList;x0multi;args0;::]~multiargs0
.ml.optimize.BFGS[multiFuncArgDict;x1multi;args1;::]~multiargs1

