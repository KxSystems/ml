// optimize/optimize.q - Otimization algorithms
// Copyright (c) 2021 Kx Systems Inc
// 
// Contains an implementation of the BFGS algorithm.

// Broyden-Fletcher-Goldfarb-Shanno (BFGS) algorithm. This implementation
// is based on 
// https://github.com/scipy/scipy/blob/v1.5.0/scipy/optimize/optimize.py#L1058
// and is a quasi-Newton hill-climbing optimization technique used to find a
// preferably twice continuously differentiable stationary point of a 
// function.

// An outline of the algorithm mathematically is provided here:
// https://en.wikipedia.org/wiki/Broyden-Fletcher-Goldfarb-Shanno_algorithm 

\d .ml

// @kind function
// @category optimization
// @desc Optimize a function using the Broyden-Fletcher-Goldfarb-Shanno
//    (BFGS) algorithm
// @param func {fn} Function to be optimized. This function should take
//   as its arguments a list/dictionary of parameters to be optimized and
//   a list/dictionary of additional unchanging arguments
// @param x0 {number[]|dictionary} The first guess at the parameters to be 
//   optimized as a list or dictionary of numeric values
// @param args {list|dictionary|(::)} Any unchanging parameters to required for 
//   evaluation of the function, these should be in the order that they are to 
//   be applied to the function
// @param params {dictionary} Any modifications to be applied to the 
//   optimization procedure e.g.
//   - display   {boolean} Results at each optimization iteration to be printed
//   - optimIter {int} Maximum number of iterations in optimization procedure
//   - zoomIter  {int} Maximum number of iterations when finding optimal zoom
//   - wolfeIter {int} Maximum number of iterations
//   - norm {int} Order of norm (0W = max; -0W = min) otherwise calculated via
//      sum[abs[vec]xexp norm]xexp 1%norm
//   - gtol {float} Gradient norm must be less than gtol before successful 
//      termination
//   - geps {float} The absolute step size used for numerical approximation of
//      the jacobian via forward differences.
//   - stepSize {float} Maximum allowable 'alpha' step size between 
//     calculations
//   - c1 {float} Armijo rule condition 
//   - c2 {int} Curvature conditions rule 
// @returns {dictionary} Contains the estimated optimal parameters, number of
//   iterations and the evaluated return of the function being optimized
optimize.BFGS:{[func;x0;args;params]
  // Update the default behaviour of the parameters
  params:i.updDefault[params];
  // Format x0 based on input type
  x0:i.dataFormat[x0];
  // Evaluate the function at the starting point
  f0:i.funcEval[func;x0;args];
  // Calculate the starting gradient
  gk:i.grad[func;x0;args;params`geps];
  // Initialize Hessian matrix as identity matrix
  hess:.ml.eye count x0;
  // Set initial step guess i.e. the step before f0
  fkPrev:f0+sqrt[sum gk*gk]%2;
  gradNorm:i.vecNorm[gk;params`norm];
  optimKeys:`xk`fk`fkPrev`gk`xkPrev`hess`gnorm`I`idx;
  optimVals:(x0;f0;fkPrev;gk;0n;hess;gradNorm;hess;0);
  optimDict:optimKeys!optimVals;
  // Run optimization until one of the stopping conditions is met
  optimDict:i.stopOptimize[;params]i.BFGSFunction[func;;args;params]/optimDict;
  returnKeys:`xVals`funcRet`numIter;
  // If function returned due to a null xVal or the new value being worse than
  // the previous value then return the k-1 value
  nullOptim:not any null optimDict`xk;
  fkCompare:optimDict[`fk]<optimDict`fkPrev;
  returnVals:$[fkCompare & nullOptim;
    optimDict`xk`fk`idx;
    optimDict`xkPrev`fkPrev`idx
    ];
  returnKeys!returnVals
  }
